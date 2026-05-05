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
                TableColumn("名称", value: \.name)

                TableColumn("路径", value: \.path)

                TableColumn("大小") { entry in
                    Text(formatBytes(entry.size))
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .width(min: 80, ideal: 110)

                TableColumn("修改时间") { entry in
                    Text(entry.modified ?? "")
                }
                .width(min: 150, ideal: 190)

                TableColumn("文件夹") { entry in
                    Image(systemName: entry.isDirectory ? "checkmark" : "minus")
                        .foregroundStyle(entry.isDirectory ? .secondary : .tertiary)
                }
                .width(88)
            }
            .overlay {
                if entries.isEmpty {
                    ContentUnavailableView(
                        isLoading ? "正在读取压缩包" : "没有条目",
                        systemImage: isLoading ? "hourglass" : "archivebox",
                        description: Text(isLoading ? "正在运行 7zz l -slt。" : "打开或拖入压缩包以查看内容。")
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
                Label("添加", systemImage: "plus")
            }
            .help("添加")

            Button {
                onExtract()
            } label: {
                Label("解压", systemImage: "arrow.down.doc")
            }
            .disabled(isLoading)
            .help("解压")

            Button {
                onSmartExtract()
            } label: {
                Label("智能解压", systemImage: "wand.and.stars")
            }
            .disabled(isLoading)
            .help("智能解压")

            Button {
                onTest()
            } label: {
                Label("测试", systemImage: "checkmark.seal")
            }
            .disabled(isLoading)
            .help("测试")

            Button {
                onInfo()
            } label: {
                Label("信息", systemImage: "info.circle")
            }
            .help("信息")
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
            || lowercased.contains("失败")
            || lowercased.contains("未找到")
            || lowercased.contains("退出码")
    }
}
