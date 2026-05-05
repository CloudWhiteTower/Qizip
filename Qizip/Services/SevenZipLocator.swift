import Foundation

enum SevenZipSource: String, Equatable {
    case bundled
    case homebrew
    case system
    case developerOverride
    case debugLocal
    case notFound

    var displayName: String {
        switch self {
        case .bundled:
            return "Bundled 7zz"
        case .homebrew:
            return "Homebrew 7zz"
        case .system:
            return "System 7zz"
        case .developerOverride:
            return "Developer override 7zz"
        case .debugLocal:
            return "Debug local 7zz"
        case .notFound:
            return "Not Found"
        }
    }
}

struct SevenZipCandidate: Equatable {
    var url: URL
    var source: SevenZipSource
}

struct SevenZipLocator {
    static let missingMessage = "7zz was not found. Please install it with: brew install sevenzip, or bundle 7zz inside QiZip."

    let fileManager: FileManager
    private let bundledResourceURL: URL?

    init(fileManager: FileManager = .default, bundledResourceURL: URL? = Bundle.main.url(forResource: "7zz", withExtension: nil)) {
        self.fileManager = fileManager
        self.bundledResourceURL = bundledResourceURL
    }

    var candidates: [SevenZipCandidate] {
        var values: [SevenZipCandidate] = []

        if let bundledResourceURL {
            values.append(SevenZipCandidate(url: bundledResourceURL, source: .bundled))
        }

        values += [
            SevenZipCandidate(url: URL(fileURLWithPath: "/opt/homebrew/bin/7zz"), source: .homebrew),
            SevenZipCandidate(url: URL(fileURLWithPath: "/usr/local/bin/7zz"), source: .homebrew),
            SevenZipCandidate(url: URL(fileURLWithPath: "/usr/bin/7zz"), source: .system)
        ]

        if let overridePath = ProcessInfo.processInfo.environment["QIZIP_SEVENZIP_PATH"], !overridePath.isEmpty {
            values.append(SevenZipCandidate(url: URL(fileURLWithPath: overridePath), source: .developerOverride))
        }

        #if DEBUG
        values.append(
            SevenZipCandidate(
                url: URL(fileURLWithPath: fileManager.currentDirectoryPath)
                    .appendingPathComponent(".build/tools/7zip/7zz"),
                source: .debugLocal
            )
        )
        #endif

        return values
    }

    var candidateURLs: [URL] {
        candidates.map(\.url)
    }

    func locate() -> URL? {
        status().executableURL
    }

    func status() -> SevenZipStatus {
        var existingButNotExecutable: SevenZipCandidate?

        for candidate in candidates {
            var isDirectory: ObjCBool = false
            let exists = fileManager.fileExists(atPath: candidate.url.path, isDirectory: &isDirectory)

            guard exists, !isDirectory.boolValue else {
                continue
            }

            guard fileManager.isExecutableFile(atPath: candidate.url.path) else {
                if candidate.source == .bundled {
                    return SevenZipStatus(
                        executableURL: nil,
                        source: .notFound,
                        message: "\(candidate.source.displayName) exists but is not executable: \(candidate.url.path). Please run chmod +x on the bundled 7zz."
                    )
                }

                if existingButNotExecutable == nil {
                    existingButNotExecutable = candidate
                }
                continue
            }

            return SevenZipStatus(
                executableURL: candidate.url,
                source: candidate.source,
                message: "\(candidate.source.displayName): \(candidate.url.path)"
            )
        }

        if let candidate = existingButNotExecutable {
            return SevenZipStatus(
                executableURL: nil,
                source: .notFound,
                message: "\(candidate.source.displayName) exists but is not executable: \(candidate.url.path). Please run chmod +x on the bundled 7zz."
            )
        }

        return SevenZipStatus(executableURL: nil, source: .notFound, message: Self.missingMessage)
    }
}

struct SevenZipStatus: Equatable {
    var executableURL: URL?
    var source: SevenZipSource
    var message: String

    var isAvailable: Bool {
        executableURL != nil
    }

    var sourceDisplayName: String {
        source.displayName
    }

    var executablePath: String? {
        executableURL?.path
    }
}
