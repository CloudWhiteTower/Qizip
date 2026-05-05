//
//  ContentView.swift
//  Qizip
//
//  Created by CloudWhiteTower on 2026/5/5.
//

import SwiftUI
import UniformTypeIdentifiers

private struct OperationPresentation: Identifiable {
    let id = UUID()
    var title: String
    var message: String
    var url: URL?
}

struct ContentView: View {
    @State private var selectedArchiveURL: URL?
    @State private var entries: [ArchiveEntry] = []
    @State private var logText = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var isDropTargeted = false
    @State private var parseSucceeded = false
    @State private var currentJob: ArchiveJob?
    @State private var archiveInfo: ArchiveInfo?
    @State private var extractionPresentation: OperationPresentation?
    @State private var compressionPresentation: OperationPresentation?

    private let archiveService = ArchiveService()
    private let smartExtractionPlanner = SmartExtractionPlanner()
    private let sevenZipStatus = ArchiveService().sevenZipStatus()

    var body: some View {
        Group {
            if let selectedArchiveURL {
                ArchiveBrowserView(
                    archiveURL: selectedArchiveURL,
                    entries: entries,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    logText: logText,
                    onAdd: showAddDeferred,
                    onExtract: extractArchive,
                    onSmartExtract: smartExtractArchive,
                    onTest: testArchive,
                    onInfo: showArchiveInfo
                )
            } else {
                EmptyHomeView(
                    sevenZipStatusText: sevenZipStatus.message,
                    isSevenZipAvailable: sevenZipStatus.isAvailable,
                    isWorking: isLoading,
                    statusText: errorMessage,
                    logText: logText,
                    onOpenArchive: openArchive,
                    onCompressFiles: compressFiles
                )
            }
        }
        .navigationTitle("Qizip")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    openArchive()
                } label: {
                    Label("打开压缩包", systemImage: "folder")
                }
            }
        }
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDropTargeted) { providers in
            loadDroppedFiles(from: providers)
        }
        .overlay {
            if isDropTargeted {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, dash: [8]))
                    .padding(12)
                    .allowsHitTesting(false)
            }
        }
        .sheet(item: $archiveInfo) { info in
            archiveInfoSheet(info)
        }
        .sheet(item: $extractionPresentation) { presentation in
            ExtractSheet(
                title: presentation.title,
                message: presentation.message,
                destinationURL: presentation.url,
                onReveal: presentation.url.map { url in
                    { FileDialogs.revealInFinder(url) }
                },
                onDismiss: {
                    extractionPresentation = nil
                }
            )
        }
        .sheet(item: $compressionPresentation) { presentation in
            CompressSheet(
                title: presentation.title,
                message: presentation.message,
                outputURL: presentation.url,
                onReveal: presentation.url.map { url in
                    { FileDialogs.revealInFinder(url) }
                },
                onDismiss: {
                    compressionPresentation = nil
                }
            )
        }
    }

    private func openArchive() {
        guard let url = FileDialogs.openArchive() else {
            return
        }

        loadArchive(url: url)
    }

    private func loadDroppedFiles(from providers: [NSItemProvider]) -> Bool {
        let fileProviders = providers.filter { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }
        guard !fileProviders.isEmpty else {
            return false
        }

        let group = DispatchGroup()
        var droppedURLs: [URL] = []
        let lock = NSLock()

        for provider in fileProviders {
            group.enter()
            provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                defer { group.leave() }

                guard let data, let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }

                lock.lock()
                droppedURLs.append(url)
                lock.unlock()
            }
        }

        group.notify(queue: .main) {
            Task { @MainActor in
                if droppedURLs.count == 1, let url = droppedURLs.first, FileDialogs.isSupportedArchive(url) {
                    loadArchive(url: url)
                } else if !droppedURLs.isEmpty {
                    startCompression(inputURLs: droppedURLs)
                }
            }
        }

        return true
    }

    private func loadArchive(url: URL) {
        selectedArchiveURL = url
        entries = []
        logText = ""
        errorMessage = nil
        isLoading = true
        parseSucceeded = false
        currentJob = ArchiveJob(kind: .list, title: "正在读取 \(url.lastPathComponent)")

        Task {
            do {
                let result = try await archiveService.listArchive(url: url)
                entries = result.entries
                logText = combinedLog(stdout: result.stdout, stderr: result.stderr)
                parseSucceeded = true
                currentJob?.finishedAt = Date()
                currentJob?.succeeded = true
            } catch {
                errorMessage = error.localizedDescription
                logText = error.localizedDescription
                currentJob?.finishedAt = Date()
                currentJob?.succeeded = false
                currentJob?.message = error.localizedDescription
            }

            isLoading = false
        }
    }

    private func showAddDeferred() {
        errorMessage = "添加功能将在下一个版本实现"
        appendLog("添加\n\(errorMessage ?? "")")
    }

    private func extractArchive() {
        guard let selectedArchiveURL, let destinationURL = FileDialogs.chooseOutputFolder(title: "选择解压目标文件夹") else {
            return
        }

        runExtraction(
            kind: .extract,
            archiveURL: selectedArchiveURL,
            destinationURL: destinationURL,
            successMessage: "压缩包已成功解压。"
        )
    }

    private func smartExtractArchive() {
        guard let selectedArchiveURL, let selectedDestinationURL = FileDialogs.chooseOutputFolder(title: "选择智能解压目标文件夹") else {
            return
        }

        let plan = smartExtractionPlanner.plan(
            archiveURL: selectedArchiveURL,
            entries: entries,
            selectedDestinationURL: selectedDestinationURL
        )

        runExtraction(
            kind: .smartExtract,
            archiveURL: selectedArchiveURL,
            destinationURL: plan.destinationURL,
            successMessage: plan.createdArchiveFolder
                ? "智能解压已为 \(plan.topLevelItems.count) 个顶层项目创建同名文件夹。"
                : "压缩包只有一个顶层项目，已直接解压到所选文件夹。"
        )
    }

    private func runExtraction(
        kind: ArchiveJobKind,
        archiveURL: URL,
        destinationURL: URL,
        successMessage: String
    ) {
        errorMessage = nil
        isLoading = true
        currentJob = ArchiveJob(kind: kind, title: "\(kind.rawValue) \(archiveURL.lastPathComponent)")

        Task {
            do {
                let result = try await archiveService.extractArchive(url: archiveURL, to: destinationURL)
                appendLog("\(kind.rawValue)\n\(combinedLog(stdout: result.stdout, stderr: result.stderr))")
                extractionPresentation = OperationPresentation(
                    title: "\(kind.rawValue)完成",
                    message: successMessage,
                    url: destinationURL
                )
                currentJob?.succeeded = true
            } catch {
                errorMessage = error.localizedDescription
                appendLog("\(kind.rawValue)失败\n\(error.localizedDescription)")
                extractionPresentation = OperationPresentation(
                    title: "\(kind.rawValue)失败",
                    message: error.localizedDescription,
                    url: nil
                )
                currentJob?.succeeded = false
                currentJob?.message = error.localizedDescription
            }

            currentJob?.finishedAt = Date()
            isLoading = false
        }
    }

    private func testArchive() {
        guard let selectedArchiveURL else {
            return
        }

        errorMessage = nil
        isLoading = true
        currentJob = ArchiveJob(kind: .test, title: "正在测试 \(selectedArchiveURL.lastPathComponent)")

        Task {
            do {
                let result = try await archiveService.testArchive(url: selectedArchiveURL)
                appendLog("测试通过\n\(combinedLog(stdout: result.stdout, stderr: result.stderr))")
                errorMessage = "测试通过。"
                currentJob?.succeeded = true
            } catch {
                errorMessage = "测试失败：\(error.localizedDescription)"
                appendLog(errorMessage ?? error.localizedDescription)
                currentJob?.succeeded = false
                currentJob?.message = error.localizedDescription
            }

            currentJob?.finishedAt = Date()
            isLoading = false
        }
    }

    private func showArchiveInfo() {
        guard let selectedArchiveURL else {
            return
        }

        archiveInfo = archiveService.info(
            for: selectedArchiveURL,
            entries: entries,
            parseSucceeded: parseSucceeded
        )
    }

    private func compressFiles() {
        let inputURLs = FileDialogs.chooseCompressionInputs()
        guard !inputURLs.isEmpty else {
            return
        }

        startCompression(inputURLs: inputURLs)
    }

    private func startCompression(inputURLs: [URL]) {
        let defaultName = inputURLs.count == 1 ? inputURLs[0].deletingPathExtension().lastPathComponent : "压缩包"
        guard var outputURL = FileDialogs.chooseArchiveOutput(defaultName: defaultName) else {
            return
        }

        let format = CompressionFormat.fromOutputURL(outputURL) ?? .sevenZip
        if outputURL.pathExtension.isEmpty {
            outputURL.appendPathExtension(format.rawValue)
        }

        let options = CompressionOptions(inputURLs: inputURLs, outputURL: outputURL, format: format)
        errorMessage = nil
        logText = ""
        isLoading = true
        selectedArchiveURL = nil
        currentJob = ArchiveJob(kind: .compress, title: "正在压缩 \(inputURLs.count) 个项目")

        Task {
            do {
                let result = try await archiveService.compress(options: options)
                appendLog("压缩完成\n\(combinedLog(stdout: result.stdout, stderr: result.stderr))")
                compressionPresentation = OperationPresentation(
                    title: "压缩完成",
                    message: "压缩包已成功创建。",
                    url: outputURL
                )
                currentJob?.succeeded = true
            } catch {
                errorMessage = error.localizedDescription
                appendLog("压缩失败\n\(error.localizedDescription)")
                compressionPresentation = OperationPresentation(
                    title: "压缩失败",
                    message: error.localizedDescription,
                    url: nil
                )
                currentJob?.succeeded = false
                currentJob?.message = error.localizedDescription
            }

            currentJob?.finishedAt = Date()
            isLoading = false
        }
    }

    private func archiveInfoSheet(_ info: ArchiveInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                Text("压缩包信息")
                    .font(.headline)
            }

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                GridRow {
                    Text("路径")
                        .foregroundStyle(.secondary)
                    Text(info.archiveURL.path)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                }

                GridRow {
                    Text("文件数")
                        .foregroundStyle(.secondary)
                    Text("\(info.fileCount)")
                        .monospacedDigit()
                }

                GridRow {
                    Text("总大小")
                        .foregroundStyle(.secondary)
                    Text(ByteCountFormatter.string(fromByteCount: info.totalSize, countStyle: .file))
                        .monospacedDigit()
                }

                GridRow {
                    Text("解析状态")
                        .foregroundStyle(.secondary)
                    Text(info.parseSucceeded ? "成功" : "失败或不完整")
                }
            }

            HStack {
                Spacer()
                Button("完成") {
                    archiveInfo = nil
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 520)
    }

    private func combinedLog(stdout: String, stderr: String) -> String {
        var sections: [String] = []
        if !stdout.isEmpty {
            sections.append("标准输出\n\(stdout)")
        }
        if !stderr.isEmpty {
            sections.append("错误输出\n\(stderr)")
        }
        return sections.joined(separator: "\n\n")
    }

    private func appendLog(_ text: String) {
        guard !text.isEmpty else {
            return
        }

        if logText.isEmpty {
            logText = text
        } else {
            logText += "\n\n\(text)"
        }
    }
}
