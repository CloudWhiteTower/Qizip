import Foundation

enum ArchiveServiceError: LocalizedError, Equatable {
    case missingSevenZip(String = SevenZipLocator.missingMessage)
    case processFailed(exitCode: Int32, detail: String)
    case unsafeCompressionOutput(String)

    var errorDescription: String? {
        switch self {
        case .missingSevenZip(let message):
            return message
        case .processFailed(let exitCode, let detail):
            let suffix = detail.isEmpty ? "" : "\n\(detail)"
            return "7zz 退出码为 \(exitCode)。\(suffix)"
        case .unsafeCompressionOutput(let message):
            return message
        }
    }
}

enum CompressionOutputIssue: Equatable {
    case outputIsDirectory(URL)
    case outputMatchesInput(URL)
    case outputInsideInput(outputURL: URL, inputURL: URL)
    case outputExists(URL)
}

struct ArchiveListResult: Equatable {
    var entries: [ArchiveEntry]
    var stdout: String
    var stderr: String
}

struct ArchiveOperationResult: Equatable {
    var stdout: String
    var stderr: String
    var exitCode: Int32

    var succeeded: Bool {
        exitCode == 0
    }
}

struct ArchiveInfo: Identifiable, Equatable {
    var id: String { archiveURL.path }
    var archiveURL: URL
    var fileCount: Int
    var totalSize: Int64
    var parseSucceeded: Bool
}

struct ArchiveService {
    private let locator: SevenZipLocator
    private let runner: SevenZipRunner
    private let parser: ArchiveListParser
    private let fileManager: FileManager

    init(
        locator: SevenZipLocator = SevenZipLocator(),
        runner: SevenZipRunner = SevenZipRunner(),
        parser: ArchiveListParser = ArchiveListParser(),
        fileManager: FileManager = .default
    ) {
        self.locator = locator
        self.runner = runner
        self.parser = parser
        self.fileManager = fileManager
    }

    func sevenZipStatus() -> SevenZipStatus {
        locator.status()
    }

    func listArchive(url archiveURL: URL) async throws -> ArchiveListResult {
        let sevenZipStatus = locator.status()
        guard let executableURL = sevenZipStatus.executableURL else {
            throw ArchiveServiceError.missingSevenZip(sevenZipStatus.message)
        }

        let didStartSecurityScope = archiveURL.startAccessingSecurityScopedResource()
        defer {
            if didStartSecurityScope {
                archiveURL.stopAccessingSecurityScopedResource()
            }
        }

        let processResult = try await runner.run(
            executableURL: executableURL,
            arguments: ["l", "-slt", archiveURL.path]
        )
        let entries = parser.parse(processResult.stdout)

        guard processResult.exitCode == 0 else {
            let detail = processResult.stderr.isEmpty ? processResult.stdout : processResult.stderr
            throw ArchiveServiceError.processFailed(exitCode: processResult.exitCode, detail: detail)
        }

        return ArchiveListResult(
            entries: entries,
            stdout: processResult.stdout,
            stderr: processResult.stderr
        )
    }

    func extractArchive(url archiveURL: URL, to destinationURL: URL) async throws -> ArchiveOperationResult {
        try await runArchiveOperation(
            archiveURL: archiveURL,
            additionalScopedURLs: [destinationURL],
            arguments: ["x", "-y", "-aoa", archiveURL.path, "-o\(destinationURL.path)"]
        )
    }

    func testArchive(url archiveURL: URL) async throws -> ArchiveOperationResult {
        try await runArchiveOperation(
            archiveURL: archiveURL,
            additionalScopedURLs: [],
            arguments: ["t", archiveURL.path]
        )
    }

    func compressionOutputIssues(for options: CompressionOptions) -> [CompressionOutputIssue] {
        let outputURL = normalizedFileURL(options.outputURL)
        var issues: [CompressionOutputIssue] = []

        var outputIsDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: outputURL.path, isDirectory: &outputIsDirectory) {
            if outputIsDirectory.boolValue {
                issues.append(.outputIsDirectory(outputURL))
            } else {
                issues.append(.outputExists(outputURL))
            }
        }

        for inputURL in options.inputURLs {
            let normalizedInputURL = normalizedFileURL(inputURL)

            if outputURL.path == normalizedInputURL.path {
                issues.append(.outputMatchesInput(outputURL))
                continue
            }

            var inputIsDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: normalizedInputURL.path, isDirectory: &inputIsDirectory) else {
                continue
            }

            if inputIsDirectory.boolValue, outputURL.isDescendant(of: normalizedInputURL) {
                issues.append(.outputInsideInput(outputURL: outputURL, inputURL: normalizedInputURL))
            }
        }

        return issues
    }

    func compress(
        options: CompressionOptions,
        replacingExistingOutput: Bool = true,
        allowingOutputInsideInput: Bool = false
    ) async throws -> ArchiveOperationResult {
        let sevenZipStatus = locator.status()
        guard let executableURL = sevenZipStatus.executableURL else {
            throw ArchiveServiceError.missingSevenZip(sevenZipStatus.message)
        }

        let scopedURLs = options.inputURLs + [options.outputURL.deletingLastPathComponent()]
        var activeScopedURLs: [URL] = []
        for url in scopedURLs where url.startAccessingSecurityScopedResource() {
            activeScopedURLs.append(url)
        }
        defer {
            activeScopedURLs.forEach { $0.stopAccessingSecurityScopedResource() }
        }

        let issues = compressionOutputIssues(for: options)
        try validateCompressionOutputIssues(
            issues,
            replacingExistingOutput: replacingExistingOutput,
            allowingOutputInsideInput: allowingOutputInsideInput
        )

        let outputInsideInput = issues.contains { issue in
            if case .outputInsideInput = issue {
                return true
            }
            return false
        }
        let actualOutputURL = try temporaryOutputURLIfNeeded(for: options, outputInsideInput: outputInsideInput)
        if replacingExistingOutput {
            try removeExistingArchiveIfNeeded(at: actualOutputURL)
            if actualOutputURL != options.outputURL {
                try removeExistingArchiveIfNeeded(at: options.outputURL)
            }
        }

        let processResult = try await runner.run(
            executableURL: executableURL,
            arguments: ["a", "-y", options.format.sevenZipTypeArgument, "-mx=\(options.level)", actualOutputURL.path] + options.inputURLs.map(\.path)
        )

        do {
            try validate(processResult)
            if actualOutputURL != options.outputURL {
                try moveTemporaryOutput(actualOutputURL, to: options.outputURL, replacingExistingOutput: replacingExistingOutput)
            }
        } catch {
            if actualOutputURL != options.outputURL {
                try? fileManager.removeItem(at: actualOutputURL)
            }
            throw error
        }

        return ArchiveOperationResult(stdout: processResult.stdout, stderr: processResult.stderr, exitCode: processResult.exitCode)
    }

    func info(for archiveURL: URL, entries: [ArchiveEntry], parseSucceeded: Bool) -> ArchiveInfo {
        ArchiveInfo(
            archiveURL: archiveURL,
            fileCount: entries.filter { !$0.isDirectory }.count,
            totalSize: entries.compactMap(\.size).reduce(0, +),
            parseSucceeded: parseSucceeded
        )
    }

    private func runArchiveOperation(
        archiveURL: URL,
        additionalScopedURLs: [URL],
        arguments: [String]
    ) async throws -> ArchiveOperationResult {
        let sevenZipStatus = locator.status()
        guard let executableURL = sevenZipStatus.executableURL else {
            throw ArchiveServiceError.missingSevenZip(sevenZipStatus.message)
        }

        let scopedURLs = [archiveURL] + additionalScopedURLs
        var activeScopedURLs: [URL] = []
        for url in scopedURLs where url.startAccessingSecurityScopedResource() {
            activeScopedURLs.append(url)
        }
        defer {
            activeScopedURLs.forEach { $0.stopAccessingSecurityScopedResource() }
        }

        let processResult = try await runner.run(executableURL: executableURL, arguments: arguments)
        try validate(processResult)
        return ArchiveOperationResult(stdout: processResult.stdout, stderr: processResult.stderr, exitCode: processResult.exitCode)
    }

    private func validate(_ processResult: SevenZipProcessResult) throws {
        guard processResult.exitCode == 0 else {
            let detail = processResult.stderr.isEmpty ? processResult.stdout : processResult.stderr
            throw ArchiveServiceError.processFailed(exitCode: processResult.exitCode, detail: detail)
        }
    }

    private func validateCompressionOutputIssues(
        _ issues: [CompressionOutputIssue],
        replacingExistingOutput: Bool,
        allowingOutputInsideInput: Bool
    ) throws {
        for issue in issues {
            switch issue {
            case .outputIsDirectory(let url):
                throw ArchiveServiceError.unsafeCompressionOutput("输出位置是文件夹，无法保存为压缩包：\(url.path)")
            case .outputMatchesInput(let url):
                throw ArchiveServiceError.unsafeCompressionOutput("输出压缩包不能覆盖正在压缩的源文件：\(url.path)")
            case .outputInsideInput(let outputURL, _):
                if !allowingOutputInsideInput {
                    throw ArchiveServiceError.unsafeCompressionOutput("输出压缩包不能保存在正在压缩的文件夹内部。请选择源文件夹外的位置：\(outputURL.path)")
                }
            case .outputExists(let url):
                if !replacingExistingOutput {
                    throw ArchiveServiceError.unsafeCompressionOutput("输出压缩包已存在：\(url.path)")
                }
            }
        }
    }

    private func removeExistingArchiveIfNeeded(at outputURL: URL) throws {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: outputURL.path, isDirectory: &isDirectory) else {
            return
        }

        guard !isDirectory.boolValue else {
            throw ArchiveServiceError.unsafeCompressionOutput("输出位置是文件夹，无法保存为压缩包：\(outputURL.path)")
        }

        try fileManager.removeItem(at: outputURL)
    }

    private func normalizedFileURL(_ url: URL) -> URL {
        url.standardizedFileURL.resolvingSymlinksInPath()
    }

    private func temporaryOutputURLIfNeeded(for options: CompressionOptions, outputInsideInput: Bool) throws -> URL {
        guard outputInsideInput else {
            return options.outputURL
        }

        let temporaryFolderURL = fileManager.temporaryDirectory
            .appendingPathComponent("QiZip-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true)
        return temporaryFolderURL.appendingPathComponent(options.outputURL.lastPathComponent)
    }

    private func moveTemporaryOutput(_ temporaryURL: URL, to destinationURL: URL, replacingExistingOutput: Bool) throws {
        if replacingExistingOutput {
            try removeExistingArchiveIfNeeded(at: destinationURL)
        }

        try fileManager.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try fileManager.moveItem(at: temporaryURL, to: destinationURL)
        try? fileManager.removeItem(at: temporaryURL.deletingLastPathComponent())
    }
}

private extension URL {
    func isDescendant(of parentURL: URL) -> Bool {
        let childComponents = standardizedFileURL.pathComponents
        let parentComponents = parentURL.standardizedFileURL.pathComponents

        guard childComponents.count > parentComponents.count else {
            return false
        }

        return zip(parentComponents, childComponents).allSatisfy { parent, child in
            parent == child
        }
    }
}
