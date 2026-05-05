import Foundation

@main
struct ParserPlannerHarness {
    static func main() {
        testArchiveListParser()
        testSmartExtractionPlannerSingleTopLevel()
        testSmartExtractionPlannerMultipleTopLevels()
        print("ParserPlannerHarness passed")
    }

    private static func testArchiveListParser() {
        let listing = """
        7-Zip listing
        ----------
        Path = folder
        Folder = +
        Modified = 2026-05-05 10:00:00

        Path = folder/中文 file.txt
        Size = 42
        Modified = 2026-05-05 10:01:00
        Folder = -

        """

        let entries = ArchiveListParser().parse(listing)
        assert(entries.count == 2, "Expected two parsed entries")
        assert(entries[0].isDirectory, "Expected first entry to be directory")
        assert(entries[1].path == "folder/中文 file.txt", "Expected non-ASCII path to survive parsing")
        assert(entries[1].size == 42, "Expected size to parse")
    }

    private static func testSmartExtractionPlannerSingleTopLevel() {
        let planner = SmartExtractionPlanner(fileManager: .default)
        let selectedURL = URL(fileURLWithPath: "/tmp/Qizip Harness Output", isDirectory: true)
        let archiveURL = URL(fileURLWithPath: "/tmp/Single Root.zip")
        let entries = [
            ArchiveEntry(path: "root"),
            ArchiveEntry(path: "root/file.txt")
        ]

        let plan = planner.plan(archiveURL: archiveURL, entries: entries, selectedDestinationURL: selectedURL)
        assert(plan.destinationURL == selectedURL, "Single top-level archives should extract to selected folder")
        assert(!plan.createdArchiveFolder, "Single top-level archives should not create archive folder")
    }

    private static func testSmartExtractionPlannerMultipleTopLevels() {
        let tempParent = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("Qizip Planner Harness", isDirectory: true)
        try? FileManager.default.removeItem(at: tempParent)
        try? FileManager.default.createDirectory(at: tempParent, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempParent)
        }

        let existingURL = tempParent.appendingPathComponent("Archive", isDirectory: true)
        try? FileManager.default.createDirectory(at: existingURL, withIntermediateDirectories: true)

        let planner = SmartExtractionPlanner(fileManager: .default)
        let archiveURL = URL(fileURLWithPath: "/tmp/Archive.tar.gz")
        let entries = [
            ArchiveEntry(path: "a.txt"),
            ArchiveEntry(path: "nested/b.txt")
        ]

        let plan = planner.plan(archiveURL: archiveURL, entries: entries, selectedDestinationURL: tempParent)
        assert(plan.destinationURL.lastPathComponent == "Archive 2", "Existing destination should use numbered alternative")
        assert(plan.createdArchiveFolder, "Multiple top-level archives should create archive folder")
    }
}
