import AppKit
import Foundation
import UniformTypeIdentifiers

enum FileDialogs {
    static let supportedArchiveExtensions = [
        "7z", "zip", "rar", "tar", "gz", "bz2", "xz", "zst", "iso", "dmg", "cab", "wim"
    ]

    static func isSupportedArchive(_ url: URL) -> Bool {
        supportedArchiveExtensions.contains(url.pathExtension.lowercased())
    }

    @MainActor
    static func openArchive() -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = "Open Archive"
        panel.prompt = "Open"
        panel.allowedContentTypes = supportedArchiveExtensions.compactMap { UTType(filenameExtension: $0) }

        guard panel.runModal() == .OK else {
            return nil
        }

        return panel.url
    }

    @MainActor
    static func chooseOutputFolder(title: String = "Choose Output Folder") -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.title = title
        panel.prompt = "Choose"

        guard panel.runModal() == .OK else {
            return nil
        }

        return panel.url
    }

    @MainActor
    static func chooseCompressionInputs() -> [URL] {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.title = "Choose Files To Compress"
        panel.prompt = "Choose"

        guard panel.runModal() == .OK else {
            return []
        }

        return panel.urls
    }

    @MainActor
    static func chooseArchiveOutput(defaultName: String = "Archive") -> URL? {
        let panel = NSSavePanel()
        panel.title = "Save Archive"
        panel.prompt = "Save"
        panel.nameFieldStringValue = "\(defaultName).7z"
        panel.allowedContentTypes = [
            UTType(filenameExtension: "7z"),
            UTType(filenameExtension: "zip")
        ].compactMap { $0 }

        guard panel.runModal() == .OK else {
            return nil
        }

        return panel.url
    }

    @MainActor
    static func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
