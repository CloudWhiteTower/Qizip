import Foundation

struct ArchiveEntry: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var path: String
    var size: Int64?
    var modified: String?
    var isDirectory: Bool

    init(
        name: String? = nil,
        path: String,
        size: Int64? = nil,
        modified: String? = nil,
        isDirectory: Bool = false
    ) {
        self.name = name ?? URL(fileURLWithPath: path).lastPathComponent
        self.path = path
        self.size = size
        self.modified = modified
        self.isDirectory = isDirectory
    }
}
