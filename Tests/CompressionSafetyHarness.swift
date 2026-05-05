import Foundation

@main
struct CompressionSafetyHarness {
    static func main() async {
        do {
            try await run()
            print("CompressionSafetyHarness passed")
        } catch {
            fputs("CompressionSafetyHarness failed: \(error)\n", stderr)
            exit(1)
        }
    }

    private static func run() async throws {
        let fileManager = FileManager.default
        let rootURL = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let workURL = rootURL.appendingPathComponent(".build/compression-safety-harness", isDirectory: true)
        try? fileManager.removeItem(at: workURL)
        try fileManager.createDirectory(at: workURL, withIntermediateDirectories: true)

        let service = ArchiveService()
        guard let executableURL = service.sevenZipStatus().executableURL else {
            throw HarnessError.missingSevenZip
        }
        print("7zz: \(executableURL.path)")

        let sourceURL = workURL.appendingPathComponent("奇怪 源", isDirectory: true)
        try fileManager.createDirectory(at: sourceURL, withIntermediateDirectories: true)
        let firstFileURL = sourceURL.appendingPathComponent("test 1.txt")
        let secondFileURL = sourceURL.appendingPathComponent("测试3.txt")
        try "first\n".write(to: firstFileURL, atomically: true, encoding: .utf8)
        try "second\n".write(to: secondFileURL, atomically: true, encoding: .utf8)

        guard CompressionDefaults.format == .zip else {
            throw HarnessError.invalidDefault("default format is not zip")
        }
        guard CompressionDefaults.archiveBaseName(for: [firstFileURL, secondFileURL]) == "test 1" else {
            throw HarnessError.invalidDefault("default name should come from first input file")
        }
        guard CompressionDefaults.archiveBaseName(for: [sourceURL]) == "奇怪 源" else {
            throw HarnessError.invalidDefault("default name should preserve directory name")
        }

        try await assertNestedOutputIsRejected(service: service, sourceURL: sourceURL, outputName: "test 1.zip")

        let userTest2ZipURL = rootURL.appendingPathComponent("test2zip", isDirectory: true)
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: userTest2ZipURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
            try await assertNestedOutputIsRejected(service: service, sourceURL: userTest2ZipURL, outputName: "压缩包.zip")
            try await assertNestedOutputCanProceedViaTemporaryArchive(
                service: service,
                sourceURL: userTest2ZipURL,
                outputName: "压缩包.zip",
                fileManager: fileManager
            )
        }

        let staleSourceURL = workURL.appendingPathComponent("stale", isDirectory: true)
        try fileManager.createDirectory(at: staleSourceURL, withIntermediateDirectories: true)
        try "stale\n".write(
            to: staleSourceURL.appendingPathComponent("old.txt"),
            atomically: true,
            encoding: .utf8
        )

        let archiveURL = workURL.appendingPathComponent("test 1.zip")
        _ = try await service.compress(
            options: CompressionOptions(inputURLs: [staleSourceURL], outputURL: archiveURL, format: .zip)
        )
        try await assertExistingOutputRequiresReplacementChoice(
            service: service,
            sourceURL: sourceURL,
            archiveURL: archiveURL
        )
        _ = try await service.compress(
            options: CompressionOptions(inputURLs: [sourceURL], outputURL: archiveURL, format: .zip),
            replacingExistingOutput: true
        )

        let listResult = try await service.listArchive(url: archiveURL)
        let paths = Set(listResult.entries.map(\.path))
        guard paths.contains("奇怪 源/test 1.txt"), paths.contains("奇怪 源/测试3.txt") else {
            throw HarnessError.unexpectedArchiveEntries(Array(paths).sorted())
        }
        guard !paths.contains("stale/old.txt") else {
            throw HarnessError.staleEntryWasNotRemoved
        }

        let extractURL = workURL.appendingPathComponent("extract", isDirectory: true)
        try fileManager.createDirectory(at: extractURL, withIntermediateDirectories: true)
        _ = try await service.extractArchive(url: archiveURL, to: extractURL)

        let extractedFirstFileURL = extractURL.appendingPathComponent("奇怪 源/test 1.txt")
        try "dirty\n".write(to: extractedFirstFileURL, atomically: true, encoding: .utf8)
        _ = try await service.extractArchive(url: archiveURL, to: extractURL)

        let overwrittenContents = try String(contentsOf: extractedFirstFileURL, encoding: .utf8)
        guard overwrittenContents == "first\n" else {
            throw HarnessError.extractDidNotOverwrite(overwrittenContents)
        }
    }

    private static func assertNestedOutputIsRejected(service: ArchiveService, sourceURL: URL, outputName: String) async throws {
        let nestedOutputURL = sourceURL.appendingPathComponent(outputName)

        do {
            _ = try await service.compress(
                options: CompressionOptions(inputURLs: [sourceURL], outputURL: nestedOutputURL, format: .zip)
            )
            throw HarnessError.nestedOutputWasAccepted
        } catch ArchiveServiceError.unsafeCompressionOutput(let message) {
            guard message.contains("不能保存在正在压缩的文件夹内部") else {
                throw HarnessError.unexpectedErrorMessage(message)
            }
        }
    }

    private static func assertNestedOutputCanProceedViaTemporaryArchive(
        service: ArchiveService,
        sourceURL: URL,
        outputName: String,
        fileManager: FileManager
    ) async throws {
        let nestedOutputURL = sourceURL.appendingPathComponent(outputName)
        _ = try await service.compress(
            options: CompressionOptions(inputURLs: [sourceURL], outputURL: nestedOutputURL, format: .zip),
            replacingExistingOutput: true,
            allowingOutputInsideInput: true
        )

        guard fileManager.fileExists(atPath: nestedOutputURL.path) else {
            throw HarnessError.nestedOutputWasNotCreated
        }
    }

    private static func assertExistingOutputRequiresReplacementChoice(
        service: ArchiveService,
        sourceURL: URL,
        archiveURL: URL
    ) async throws {
        do {
            _ = try await service.compress(
                options: CompressionOptions(inputURLs: [sourceURL], outputURL: archiveURL, format: .zip),
                replacingExistingOutput: false
            )
            throw HarnessError.existingOutputWasAcceptedWithoutReplacement
        } catch ArchiveServiceError.unsafeCompressionOutput(let message) {
            guard message.contains("已存在") else {
                throw HarnessError.unexpectedErrorMessage(message)
            }
        }
    }
}

enum HarnessError: Error, CustomStringConvertible {
    case missingSevenZip
    case invalidDefault(String)
    case nestedOutputWasAccepted
    case unexpectedErrorMessage(String)
    case unexpectedArchiveEntries([String])
    case staleEntryWasNotRemoved
    case extractDidNotOverwrite(String)
    case nestedOutputWasNotCreated
    case existingOutputWasAcceptedWithoutReplacement

    var description: String {
        switch self {
        case .missingSevenZip:
            return "missing 7zz"
        case .invalidDefault(let message):
            return message
        case .nestedOutputWasAccepted:
            return "nested output archive was accepted"
        case .unexpectedErrorMessage(let message):
            return "unexpected error message: \(message)"
        case .unexpectedArchiveEntries(let entries):
            return "unexpected archive entries: \(entries.joined(separator: ", "))"
        case .staleEntryWasNotRemoved:
            return "stale entry was not removed when replacing existing output archive"
        case .extractDidNotOverwrite(let contents):
            return "extract did not overwrite existing file, contents: \(contents)"
        case .nestedOutputWasNotCreated:
            return "nested output was not created after user-approved temporary archive flow"
        case .existingOutputWasAcceptedWithoutReplacement:
            return "existing output was accepted without replacement choice"
        }
    }
}
