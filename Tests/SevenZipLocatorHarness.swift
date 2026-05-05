import Foundation

@main
struct SevenZipLocatorHarness {
    static func main() {
        do {
            try run()
            print("SevenZipLocatorHarness passed")
        } catch {
            fputs("SevenZipLocatorHarness failed: \(error)\n", stderr)
            exit(1)
        }
    }

    private static func run() throws {
        let fileManager = FileManager.default
        let rootURL = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let bundledURL = rootURL.appendingPathComponent("Qizip/Vendor/7zz")

        let bundledStatus = SevenZipLocator(fileManager: fileManager, bundledResourceURL: bundledURL).status()
        guard bundledStatus.executableURL == bundledURL, bundledStatus.source == .bundled else {
            throw HarnessError.unexpectedStatus(bundledStatus)
        }

        let workURL = rootURL.appendingPathComponent(".build/sevenzip-locator-harness-work", isDirectory: true)
        try? fileManager.removeItem(at: workURL)
        try fileManager.createDirectory(at: workURL, withIntermediateDirectories: true)

        let nonExecutableURL = workURL.appendingPathComponent("7zz")
        try Data("not executable".utf8).write(to: nonExecutableURL)

        let nonExecutableStatus = SevenZipLocator(
            fileManager: fileManager,
            bundledResourceURL: nonExecutableURL
        ).status()
        guard !nonExecutableStatus.isAvailable,
              nonExecutableStatus.message.contains("not executable") else {
            throw HarnessError.unexpectedStatus(nonExecutableStatus)
        }
    }
}

enum HarnessError: Error, CustomStringConvertible {
    case unexpectedStatus(SevenZipStatus)

    var description: String {
        switch self {
        case .unexpectedStatus(let status):
            return "unexpected status: source=\(status.sourceDisplayName), url=\(status.executablePath ?? "nil"), message=\(status.message)"
        }
    }
}
