import Foundation

enum CompressionFormat: String, CaseIterable, Identifiable {
    case sevenZip = "7z"
    case zip = "zip"

    var id: String { rawValue }

    var sevenZipTypeArgument: String {
        switch self {
        case .sevenZip:
            return "-t7z"
        case .zip:
            return "-tzip"
        }
    }

    static func fromOutputURL(_ url: URL) -> CompressionFormat? {
        switch url.pathExtension.lowercased() {
        case "7z":
            return .sevenZip
        case "zip":
            return .zip
        default:
            return nil
        }
    }
}

struct CompressionOptions: Equatable {
    var inputURLs: [URL]
    var outputURL: URL
    var format: CompressionFormat
    var level: Int = 5
}
