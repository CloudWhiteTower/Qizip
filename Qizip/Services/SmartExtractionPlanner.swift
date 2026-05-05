import Foundation

struct SmartExtractionPlan: Equatable {
    var destinationURL: URL
    var createdArchiveFolder: Bool
    var topLevelItems: [String]
}

struct SmartExtractionPlanner {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func plan(archiveURL: URL, entries: [ArchiveEntry], selectedDestinationURL: URL) -> SmartExtractionPlan {
        let topLevels = topLevelItems(from: entries)

        guard topLevels.count > 1 else {
            return SmartExtractionPlan(
                destinationURL: selectedDestinationURL,
                createdArchiveFolder: false,
                topLevelItems: topLevels
            )
        }

        let baseName = archiveBaseName(from: archiveURL)
        let destinationURL = availableFolderURL(named: baseName, in: selectedDestinationURL)
        return SmartExtractionPlan(
            destinationURL: destinationURL,
            createdArchiveFolder: true,
            topLevelItems: topLevels
        )
    }

    private func topLevelItems(from entries: [ArchiveEntry]) -> [String] {
        let items = entries.compactMap { entry -> String? in
            let normalizedPath = entry.path
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                .replacingOccurrences(of: "\\", with: "/")

            guard !normalizedPath.isEmpty else {
                return nil
            }

            return normalizedPath.split(separator: "/", omittingEmptySubsequences: true).first.map(String.init)
        }

        return Array(Set(items)).sorted()
    }

    private func archiveBaseName(from archiveURL: URL) -> String {
        let commonExtensions = ["tar.gz", "tar.bz2", "tar.xz", "tar.zst", "7z", "zip", "rar", "tar", "gz", "bz2", "xz", "zst", "iso", "dmg", "cab", "wim"]
        let fileName = archiveURL.lastPathComponent
        let lowercased = fileName.lowercased()

        for archiveExtension in commonExtensions {
            let suffix = ".\(archiveExtension)"
            if lowercased.hasSuffix(suffix) {
                let endIndex = fileName.index(fileName.endIndex, offsetBy: -suffix.count)
                let baseName = String(fileName[..<endIndex])
                return baseName.isEmpty ? archiveURL.deletingPathExtension().lastPathComponent : baseName
            }
        }

        return archiveURL.deletingPathExtension().lastPathComponent
    }

    private func availableFolderURL(named baseName: String, in parentURL: URL) -> URL {
        let cleanedName = baseName.isEmpty ? "压缩包" : baseName
        var candidateURL = parentURL.appendingPathComponent(cleanedName, isDirectory: true)

        if !fileManager.fileExists(atPath: candidateURL.path) {
            return candidateURL
        }

        var index = 2
        repeat {
            candidateURL = parentURL.appendingPathComponent("\(cleanedName) \(index)", isDirectory: true)
            index += 1
        } while fileManager.fileExists(atPath: candidateURL.path)

        return candidateURL
    }
}
