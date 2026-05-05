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
        panel.title = "打开压缩包"
        panel.prompt = "打开"
        panel.allowedContentTypes = supportedArchiveExtensions.compactMap { UTType(filenameExtension: $0) }

        guard panel.runModal() == .OK else {
            return nil
        }

        return panel.url
    }

    @MainActor
    static func chooseOutputFolder(title: String = "选择输出文件夹") -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.title = title
        panel.prompt = "选择"

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
        panel.title = "选择要压缩的文件"
        panel.prompt = "选择"

        guard panel.runModal() == .OK else {
            return []
        }

        return panel.urls
    }

    @MainActor
    static func chooseArchiveOutput(defaultName: String = "压缩包", defaultFormat: CompressionFormat = .zip) -> URL? {
        let panel = NSSavePanel()
        panel.title = "保存压缩包"
        panel.prompt = "保存"
        panel.nameFieldStringValue = "\(defaultName).\(defaultFormat.rawValue)"
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
