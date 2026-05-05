import Foundation

enum ArchiveServiceError: LocalizedError, Equatable {
    case missingSevenZip
    case processFailed(exitCode: Int32, detail: String)

    var errorDescription: String? {
        switch self {
        case .missingSevenZip:
            return SevenZipLocator.missingMessage
        case .processFailed(let exitCode, let detail):
            let suffix = detail.isEmpty ? "" : "\n\(detail)"
            return "7zz exited with code \(exitCode).\(suffix)"
        }
    }
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

    init(
        locator: SevenZipLocator = SevenZipLocator(),
        runner: SevenZipRunner = SevenZipRunner(),
        parser: ArchiveListParser = ArchiveListParser()
    ) {
        self.locator = locator
        self.runner = runner
        self.parser = parser
    }

    func sevenZipStatus() -> SevenZipStatus {
        locator.status()
    }

    func listArchive(url archiveURL: URL) async throws -> ArchiveListResult {
        guard let executableURL = locator.locate() else {
            throw ArchiveServiceError.missingSevenZip
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
            arguments: ["x", archiveURL.path, "-o\(destinationURL.path)"]
        )
    }

    func testArchive(url archiveURL: URL) async throws -> ArchiveOperationResult {
        try await runArchiveOperation(
            archiveURL: archiveURL,
            additionalScopedURLs: [],
            arguments: ["t", archiveURL.path]
        )
    }

    func compress(options: CompressionOptions) async throws -> ArchiveOperationResult {
        guard let executableURL = locator.locate() else {
            throw ArchiveServiceError.missingSevenZip
        }

        let scopedURLs = options.inputURLs + [options.outputURL.deletingLastPathComponent()]
        var activeScopedURLs: [URL] = []
        for url in scopedURLs where url.startAccessingSecurityScopedResource() {
            activeScopedURLs.append(url)
        }
        defer {
            activeScopedURLs.forEach { $0.stopAccessingSecurityScopedResource() }
        }

        let processResult = try await runner.run(
            executableURL: executableURL,
            arguments: ["a", options.format.sevenZipTypeArgument, "-mx=\(options.level)", options.outputURL.path] + options.inputURLs.map(\.path)
        )

        try validate(processResult)
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
        guard let executableURL = locator.locate() else {
            throw ArchiveServiceError.missingSevenZip
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
}
