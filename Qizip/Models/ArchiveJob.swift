import Foundation

enum ArchiveJobKind: String, Equatable {
    case list = "List"
    case extract = "Extract"
    case smartExtract = "Smart Extract"
    case test = "Test"
    case compress = "Compress"
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
