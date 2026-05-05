import Foundation

@main
struct V1ArchiveWorkflowHarness {
    static func main() async {
        do {
            try await run()
            print("V1ArchiveWorkflowHarness passed")
        } catch {
            fputs("V1ArchiveWorkflowHarness failed: \(error)\n", stderr)
            exit(1)
        }
    }

    private static func run() async throws {
        let fileManager = FileManager.default
        let rootURL = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let service = ArchiveService()
        let status = service.sevenZipStatus()
        guard let executableURL = status.executableURL else {
            throw HarnessError.missingSevenZip(status.message)
        }

        print("7zz: \(executableURL.path)")

        let workURL = rootURL.appendingPathComponent(".build/v1-runtime-harness", isDirectory: true)
        try? fileManager.removeItem(at: workURL)
        try fileManager.createDirectory(at: workURL, withIntermediateDirectories: true)

        let inputFolderURL = try prepareInputFolder(rootURL: rootURL, workURL: workURL, fileManager: fileManager)
        let archiveURL = workURL.appendingPathComponent("test2zip-v1.7z")
        let extractRootURL = workURL.appendingPathComponent("extract", isDirectory: true)
        try fileManager.createDirectory(at: extractRootURL, withIntermediateDirectories: true)

        let compressResult = try await service.compress(
            options: CompressionOptions(
                inputURLs: [inputFolderURL],
                outputURL: archiveURL,
                format: .sevenZip
            )
        )
        guard compressResult.succeeded, fileManager.fileExists(atPath: archiveURL.path) else {
            throw HarnessError.operationFailed("compress")
        }

        let listResult = try await service.listArchive(url: archiveURL)
        let entryPaths = Set(listResult.entries.map(\.path))
        let expectedPaths: Set<String> = [
            "test2zip",
            "test2zip/test1.txt",
            "test2zip/test2.txt",
            "test2zip/测试3.txt"
        ]
        guard expectedPaths.isSubset(of: entryPaths) else {
            throw HarnessError.unexpectedEntries(Array(entryPaths).sorted())
        }

        let testResult = try await service.testArchive(url: archiveURL)
        guard testResult.succeeded else {
            throw HarnessError.operationFailed("test")
        }

        let plan = SmartExtractionPlanner().plan(
            archiveURL: archiveURL,
            entries: listResult.entries,
            selectedDestinationURL: extractRootURL
        )
        guard plan.destinationURL == extractRootURL, !plan.createdArchiveFolder else {
            throw HarnessError.operationFailed("smart extract plan")
        }

        let extractResult = try await service.extractArchive(url: archiveURL, to: plan.destinationURL)
        guard extractResult.succeeded else {
            throw HarnessError.operationFailed("extract")
        }

        let extractedFiles = [
            extractRootURL.appendingPathComponent("test2zip/test1.txt").path,
            extractRootURL.appendingPathComponent("test2zip/test2.txt").path,
            extractRootURL.appendingPathComponent("test2zip/测试3.txt").path
        ]

        for path in extractedFiles where !fileManager.fileExists(atPath: path) {
            throw HarnessError.missingExtractedFile(path)
        }
    }

    private static func prepareInputFolder(rootURL: URL, workURL: URL, fileManager: FileManager) throws -> URL {
        let userProvidedURL = rootURL.appendingPathComponent("test2zip", isDirectory: true)
        if fileManager.fileExists(atPath: userProvidedURL.path) {
            return userProvidedURL
        }

        let generatedURL = workURL.appendingPathComponent("test2zip", isDirectory: true)
        try fileManager.createDirectory(at: generatedURL, withIntermediateDirectories: true)
        try "test one\n".write(
            to: generatedURL.appendingPathComponent("test1.txt"),
            atomically: true,
            encoding: .utf8
        )
        try "test two\n".write(
            to: generatedURL.appendingPathComponent("test2.txt"),
            atomically: true,
            encoding: .utf8
        )
        try "中文测试\n".write(
            to: generatedURL.appendingPathComponent("测试3.txt"),
            atomically: true,
            encoding: .utf8
        )
        return generatedURL
    }
}

enum HarnessError: Error, CustomStringConvertible {
    case missingSevenZip(String)
    case operationFailed(String)
    case unexpectedEntries([String])
    case missingExtractedFile(String)

    var description: String {
        switch self {
        case .missingSevenZip(let message):
            return "missing 7zz: \(message)"
        case .operationFailed(let operation):
            return "operation failed: \(operation)"
        case .unexpectedEntries(let entries):
            return "unexpected archive entries: \(entries.joined(separator: ", "))"
        case .missingExtractedFile(let path):
            return "missing extracted file: \(path)"
        }
    }
}
