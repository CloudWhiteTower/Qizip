import Foundation

enum ArchiveJobKind: String, Equatable {
    case list = "读取"
    case extract = "解压"
    case smartExtract = "智能解压"
    case test = "测试"
    case compress = "压缩"
}

struct ArchiveJob: Identifiable, Equatable {
    let id = UUID()
    var kind: ArchiveJobKind
    var title: String
    var startedAt: Date = Date()
    var finishedAt: Date?
    var succeeded: Bool?
    var message: String?
}
