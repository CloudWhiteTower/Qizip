import Foundation

enum CompressionDefaults {
    static let format: CompressionFormat = .zip
    static let fallbackArchiveName = "压缩包"

    static func archiveBaseName(for inputURLs: [URL]) -> String {
        guard let firstURL = inputURLs.first else {
            return fallbackArchiveName
        }

        let name: String
        if firstURL.hasDirectoryPath || firstURL.pathExtension.isEmpty {
            name = firstURL.lastPathComponent
        } else {
            name = firstURL.deletingPathExtension().lastPathComponent
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? fallbackArchiveName : trimmedName
    }
}
