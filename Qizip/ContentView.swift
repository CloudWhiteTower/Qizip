//
//  ContentView.swift
//  Qizip
//
//  Created by CloudWhiteTower on 2026/5/5.
//

import SwiftUI
import UniformTypeIdentifiers
import AppKit

private struct OperationPresentation: Identifiable {
    let id = UUID()
    var title: String
    var message: String
    var url: URL?
}

private enum CompressionChoice {
    case proceed(replacingExistingOutput: Bool, allowingOutputInsideInput: Bool)
    case chooseAnotherLocation
    case cancel
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
    @State private var sevenZipStatus = SevenZipLocator().status()

    private let archiveService = ArchiveService()
    private let smartExtractionPlanner = SmartExtractionPlanner()

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
                    sevenZipSourceText: sevenZipStatus.sourceDisplayName,
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
        .onAppear {
            refreshSevenZipStatus()
        }
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

    private func refreshSevenZipStatus() {
        sevenZipStatus = archiveService.sevenZipStatus()
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
        guard confirmExtractionOverwriteIfNeeded(destinationURL: destinationURL) else {
            appendLog("\(kind.rawValue)已取消\n用户取消覆盖目标位置的同名项目。")
            return
        }

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
        let defaultName = CompressionDefaults.archiveBaseName(for: inputURLs)
        var pendingOptions: CompressionOptions?
        var compressionChoice = CompressionChoice.cancel

        while pendingOptions == nil {
            guard var outputURL = FileDialogs.chooseArchiveOutput(defaultName: defaultName, defaultFormat: CompressionDefaults.format) else {
                return
            }

            var format = CompressionFormat.fromOutputURL(outputURL) ?? CompressionDefaults.format
            if outputURL.pathExtension.isEmpty {
                outputURL.appendPathExtension(format.rawValue)
            } else {
                format = CompressionFormat.fromOutputURL(outputURL) ?? format
            }

            let options = CompressionOptions(inputURLs: inputURLs, outputURL: outputURL, format: format)
            compressionChoice = confirmCompressionIfNeeded(options: options)

            switch compressionChoice {
            case .proceed:
                pendingOptions = options
            case .chooseAnotherLocation:
                continue
            case .cancel:
                appendLog("压缩已取消\n用户取消了压缩操作。")
                return
            }
        }

        guard let options = pendingOptions else {
            return
        }

        errorMessage = nil
        logText = ""
        isLoading = true
        selectedArchiveURL = nil
        currentJob = ArchiveJob(kind: .compress, title: "正在压缩 \(inputURLs.count) 个项目")

        Task {
            do {
                let result: ArchiveOperationResult
                switch compressionChoice {
                case .proceed(let replacingExistingOutput, let allowingOutputInsideInput):
                    result = try await archiveService.compress(
                        options: options,
                        replacingExistingOutput: replacingExistingOutput,
                        allowingOutputInsideInput: allowingOutputInsideInput
                    )
                case .chooseAnotherLocation, .cancel:
                    return
                }
                appendLog("压缩完成\n\(combinedLog(stdout: result.stdout, stderr: result.stderr))")
                compressionPresentation = OperationPresentation(
                    title: "压缩完成",
                    message: "压缩包已成功创建。",
                    url: options.outputURL
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

    private func confirmCompressionIfNeeded(options: CompressionOptions) -> CompressionChoice {
        let issues = archiveService.compressionOutputIssues(for: options)
        guard !issues.isEmpty else {
            return .proceed(replacingExistingOutput: false, allowingOutputInsideInput: false)
        }

        if let blockingMessage = blockingCompressionMessage(from: issues) {
            showInformationalAlert(title: "无法保存压缩包", message: blockingMessage)
            return .chooseAnotherLocation
        }

        let outputExists = issues.contains { issue in
            if case .outputExists = issue {
                return true
            }
            return false
        }
        let outputInsideInput = issues.contains { issue in
            if case .outputInsideInput = issue {
                return true
            }
            return false
        }

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "确认压缩包保存方式"
        alert.informativeText = compressionConfirmationMessage(
            outputURL: options.outputURL,
            outputExists: outputExists,
            outputInsideInput: outputInsideInput
        )
        alert.addButton(withTitle: outputExists ? "替换并继续" : "继续")
        alert.addButton(withTitle: "选择其他位置")
        alert.addButton(withTitle: "取消")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            return .proceed(
                replacingExistingOutput: outputExists,
                allowingOutputInsideInput: outputInsideInput
            )
        case .alertSecondButtonReturn:
            return .chooseAnotherLocation
        default:
            return .cancel
        }
    }

    private func blockingCompressionMessage(from issues: [CompressionOutputIssue]) -> String? {
        for issue in issues {
            switch issue {
            case .outputIsDirectory(let url):
                return "输出位置是文件夹，无法保存为压缩包：\n\(url.path)"
            case .outputMatchesInput(let url):
                return "输出压缩包不能覆盖正在压缩的源文件：\n\(url.path)"
            case .outputInsideInput, .outputExists:
                continue
            }
        }

        return nil
    }

    private func compressionConfirmationMessage(outputURL: URL, outputExists: Bool, outputInsideInput: Bool) -> String {
        var lines: [String] = []

        if outputExists {
            lines.append("目标位置已经存在同名压缩包。继续会替换旧压缩包。")
        }

        if outputInsideInput {
            lines.append("目标位置在正在压缩的源文件夹内部。继续时 QiZip 会先在临时目录创建压缩包，再移动到目标位置，避免把压缩包压进自身。")
        }

        lines.append("")
        lines.append(outputURL.path)
        return lines.joined(separator: "\n")
    }

    private func confirmExtractionOverwriteIfNeeded(destinationURL: URL) -> Bool {
        let existingURLs = existingExtractionTargets(in: destinationURL)
        guard !existingURLs.isEmpty else {
            return true
        }

        let shownTargets = existingURLs.prefix(6).map(\.path).joined(separator: "\n")
        let remainingCount = existingURLs.count - min(existingURLs.count, 6)
        let suffix = remainingCount > 0 ? "\n另有 \(remainingCount) 个同名项目。" : ""

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "目标位置已有同名项目"
        alert.informativeText = "继续解压会覆盖这些项目：\n\(shownTargets)\(suffix)"
        alert.addButton(withTitle: "覆盖")
        alert.addButton(withTitle: "取消")
        return alert.runModal() == .alertFirstButtonReturn
    }

    private func existingExtractionTargets(in destinationURL: URL) -> [URL] {
        let fileManager = FileManager.default
        var seenPaths = Set<String>()
        var existingURLs: [URL] = []

        for entry in entries {
            let normalizedPath = entry.path
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                .replacingOccurrences(of: "\\", with: "/")

            guard !normalizedPath.isEmpty else {
                continue
            }

            let targetURL = destinationURL.appendingPathComponent(normalizedPath)
            let path = targetURL.standardizedFileURL.path
            guard !seenPaths.contains(path), fileManager.fileExists(atPath: path) else {
                continue
            }

            seenPaths.insert(path)
            existingURLs.append(targetURL)
        }

        return existingURLs
    }

    private func showInformationalAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "选择其他位置")
        alert.runModal()
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
