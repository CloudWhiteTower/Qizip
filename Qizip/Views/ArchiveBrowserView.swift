import SwiftUI

struct ArchiveBrowserView: View {
    let archiveURL: URL
    let entries: [ArchiveEntry]
    let isLoading: Bool
    let errorMessage: String?
    let logText: String
    let onAdd: () -> Void
    let onExtract: () -> Void
    let onSmartExtract: () -> Void
    let onTest: () -> Void
    let onInfo: () -> Void

    @State private var sortOrder = [KeyPathComparator(\ArchiveEntry.path)]

    var sortedEntries: [ArchiveEntry] {
        entries.sorted(using: sortOrder)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding()

            Divider()

            Table(sortedEntries, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.name)

                TableColumn("Path", value: \.path)

                TableColumn("Size") { entry in
                    Text(formatBytes(entry.size))
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .width(min: 80, ideal: 110)

                TableColumn("Modified") { entry in
                    Text(entry.modified ?? "")
                }
                .width(min: 150, ideal: 190)

                TableColumn("Is Directory") { entry in
                    Image(systemName: entry.isDirectory ? "checkmark" : "minus")
                        .foregroundStyle(entry.isDirectory ? .secondary : .tertiary)
                }
                .width(88)
            }
            .overlay {
                if entries.isEmpty {
                    ContentUnavailableView(
                        isLoading ? "Reading Archive" : "No Entries",
                        systemImage: isLoading ? "hourglass" : "archivebox",
                        description: Text(isLoading ? "Running 7zz l -slt." : "Open or drop an archive to inspect its entries.")
                    )
                }
            }

            Divider()

            LogView(text: logText)
                .frame(minHeight: 150, idealHeight: 210)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(archiveURL.lastPathComponent)
                    .font(.headline)
                    .lineLimit(1)

                Text(archiveURL.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            actionButtons

            if isLoading {
                ProgressView()
                    .controlSize(.small)
            }

            if let errorMessage {
                Label(errorMessage, systemImage: statusIsError(errorMessage) ? "exclamationmark.triangle" : "info.circle")
                    .font(.caption)
                    .foregroundStyle(statusIsError(errorMessage) ? .orange : .secondary)
                    .lineLimit(2)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button {
                onAdd()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .help("Add")

            Button {
                onExtract()
            } label: {
                Label("Extract", systemImage: "arrow.down.doc")
            }
            .disabled(isLoading)
            .help("Extract")

            Button {
                onSmartExtract()
            } label: {
                Label("Smart Extract", systemImage: "wand.and.stars")
            }
            .disabled(isLoading)
            .help("Smart Extract")

            Button {
                onTest()
            } label: {
                Label("Test", systemImage: "checkmark.seal")
            }
            .disabled(isLoading)
            .help("Test")

            Button {
                onInfo()
            } label: {
                Label("Info", systemImage: "info.circle")
            }
            .help("Info")
        }
        .labelStyle(.titleAndIcon)
    }

    private func formatBytes(_ value: Int64?) -> String {
        guard let value else {
            return ""
        }

        return ByteCountFormatter.string(fromByteCount: value, countStyle: .file)
    }

    private func statusIsError(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return lowercased.contains("failed")
            || lowercased.contains("not found")
            || lowercased.contains("exited with code")
    }
}
