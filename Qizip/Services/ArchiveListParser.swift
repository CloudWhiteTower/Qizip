import Foundation

struct ArchiveListParser {
    func parse(_ text: String) -> [ArchiveEntry] {
        var entries: [ArchiveEntry] = []
        var currentRecord: [String: String] = [:]
        var isInsideFileListing = false

        func flushCurrentRecord() {
            defer { currentRecord.removeAll() }

            guard let path = currentRecord["Path"], !path.isEmpty else {
                return
            }

            entries.append(
                ArchiveEntry(
                    path: path,
                    size: Int64(currentRecord["Size"] ?? ""),
                    modified: currentRecord["Modified"],
                    isDirectory: currentRecord["Folder"] == "+"
                )
            )
        }

        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

            if line == "----------" {
                isInsideFileListing = true
                currentRecord.removeAll()
                continue
            }

            guard isInsideFileListing else {
                continue
            }

            if line.isEmpty {
                flushCurrentRecord()
                continue
            }

            guard let separatorRange = line.range(of: " = ") else {
                continue
            }

            let key = String(line[..<separatorRange.lowerBound])
            let value = String(line[separatorRange.upperBound...])
            currentRecord[key] = value
        }

        flushCurrentRecord()
        return entries
    }
}
