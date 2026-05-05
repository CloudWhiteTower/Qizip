import SwiftUI

struct LogView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Log")
                .font(.headline)

            ScrollView {
                Text(text.isEmpty ? "(empty)" : text)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(.background)
    }
}
