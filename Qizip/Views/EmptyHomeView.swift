import SwiftUI

struct EmptyHomeView: View {
    let sevenZipStatusText: String
    let isSevenZipAvailable: Bool
    let isWorking: Bool
    let statusText: String?
    let logText: String
    let onOpenArchive: () -> Void
    let onCompressFiles: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Image(systemName: "archivebox")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)

                Text("拖入压缩包即可打开，拖入文件即可压缩。")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Label(sevenZipStatusText, systemImage: isSevenZipAvailable ? "checkmark.circle" : "exclamationmark.triangle")
                    .font(.callout)
                    .foregroundColor(isSevenZipAvailable ? .secondary : .orange)
                    .multilineTextAlignment(.center)

                if isWorking {
                    ProgressView()
                        .controlSize(.small)
                }

                if let statusText {
                    Text(statusText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .textSelection(.enabled)
                }
            }

            HStack(spacing: 12) {
                Button {
                    onOpenArchive()
                } label: {
                    Label("打开压缩包", systemImage: "folder")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isWorking)

                Button {
                    onCompressFiles()
                } label: {
                    Label("压缩文件...", systemImage: "plus.rectangle.on.folder")
                }
                .disabled(isWorking)
            }

            if !logText.isEmpty {
                LogView(text: logText)
                    .frame(maxWidth: 760, minHeight: 180, idealHeight: 240)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
