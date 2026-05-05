import SwiftUI

struct CompressSheet: View {
    let title: String
    let message: String
    let outputURL: URL?
    let onReveal: (() -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: outputURL == nil ? "exclamationmark.triangle" : "checkmark.circle")
                    .foregroundStyle(outputURL == nil ? .orange : .green)

                Text(title)
                    .font(.headline)
            }

            Text(message)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            if let outputURL {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Archive")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(outputURL.path)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                }
            }

            HStack {
                Spacer()

                if onReveal != nil {
                    Button {
                        onReveal?()
                    } label: {
                        Label("Reveal in Finder", systemImage: "finder")
                    }
                }

                Button("Done") {
                    onDismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 460)
    }
}
