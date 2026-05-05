import Foundation

struct SevenZipLocator {
    static let missingMessage = "7zz was not found. Please install it with: brew install sevenzip"

    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    var candidateURLs: [URL] {
        var urls = [
            URL(fileURLWithPath: "/opt/homebrew/bin/7zz"),
            URL(fileURLWithPath: "/usr/local/bin/7zz")
        ]

        if let overridePath = ProcessInfo.processInfo.environment["QIZIP_SEVENZIP_PATH"], !overridePath.isEmpty {
            urls.insert(URL(fileURLWithPath: overridePath), at: 0)
        }

        #if DEBUG
        urls.append(URL(fileURLWithPath: fileManager.currentDirectoryPath)
            .appendingPathComponent(".build/tools/7zip/7zz"))
        #endif

        return urls
    }

    func locate() -> URL? {
        candidateURLs.first { fileManager.isExecutableFile(atPath: $0.path) }
    }

    func status() -> SevenZipStatus {
        if let url = locate() {
            return SevenZipStatus(executableURL: url, message: "Found at \(url.path)")
        }

        return SevenZipStatus(executableURL: nil, message: Self.missingMessage)
    }
}

struct SevenZipStatus: Equatable {
    var executableURL: URL?
    var message: String

    var isAvailable: Bool {
        executableURL != nil
    }
}
