import SwiftUI

struct LogView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("日志")
                .font(.headline)

            ScrollView {
                Text(text.isEmpty ? "暂无日志" : text)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(.background)
    }
}
