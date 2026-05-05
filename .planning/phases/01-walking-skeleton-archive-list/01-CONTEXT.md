# Phase 1: Walking Skeleton Archive List - Context

**Gathered:** 2026-05-04
**Status:** Ready for planning
**Source:** User product brief + codebase map

<domain>
## Phase Boundary

This phase turns the current SwiftUI skeleton into the smallest runnable Qizip experience:

- Launch a macOS SwiftUI app named Qizip.
- Detect local `7zz`.
- Show a home view with open/compress buttons and drag/drop guidance.
- Open or drop supported archives.
- Run `7zz l -slt`.
- Parse archive entries.
- Display entries in a SwiftUI `Table`.
- Show stdout/stderr in an in-app log.

This phase does not implement Extract, Smart Extract, Test, Info, or Compression execution. `Compress Files...` may exist as a visible entry point but can remain disabled or deferred until Phase 4.

</domain>

<decisions>
## Implementation Decisions

### Naming
- App name remains Qizip.
- Do not rename the Xcode target or module.

### Structure
- Create source folders under `Qizip/`: `Models`, `Services`, `Views`, and `Utilities`.
- Do not keep product logic in `ContentView.swift`.
- Keep the first implementation small but real; no pseudocode.

### 7zz Invocation
- Locate `7zz` at `/opt/homebrew/bin/7zz` first, then `/usr/local/bin/7zz`.
- Missing executable message must be: `7zz was not found. Please install it with: brew install sevenzip`.
- Use `Process.executableURL` and `Process.arguments`.
- Never concatenate shell command strings.

### Listing
- Use `7zz l -slt archivePath`.
- Parse output into `ArchiveEntry`.
- Preserve enough raw log output for debugging.

### UI
- Home view copy must include: `Drop an archive to open, or drop files to compress.`
- Home view exposes `Open Archive` and `Compress Files...`.
- Archive browser uses a SwiftUI `Table` with Name, Path, Size, Modified, and Is Directory.
- UI should be macOS-native, restrained, and dark-mode friendly.

### Permissions
- Use only user-provided files through `NSOpenPanel` or drag/drop.
- Do not scan Downloads, Desktop, or Documents.
- Do not add Full Disk Access or security-scoped bookmarks in Phase 1.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Definition
- `.planning/PROJECT.md` — product goals, constraints, and decisions
- `.planning/REQUIREMENTS.md` — Phase 1 requirement IDs and acceptance surface
- `.planning/ROADMAP.md` — Phase 1 scope and success criteria

### Current Codebase
- `.planning/codebase/STACK.md` — current SwiftUI/Xcode project settings
- `.planning/codebase/ARCHITECTURE.md` — skeleton architecture and suggested boundaries
- `.planning/codebase/STRUCTURE.md` — current directory layout
- `.planning/codebase/CONCERNS.md` — sandbox, platform, 7zz, and UX risks

### Source Files
- `Qizip/QizipApp.swift` — app entry point
- `Qizip/ContentView.swift` — placeholder root view to replace with orchestration
- `Qizip.xcodeproj/project.pbxproj` — Xcode synchronized folder behavior and platform settings

</canonical_refs>

<specifics>
## Specific Ideas

- `ArchiveEntry` should be `Identifiable` and carry `name`, `path`, `size`, `modified`, and `isDirectory`.
- `SevenZipLocator` should return an optional executable URL and a user-facing status.
- `SevenZipRunner` should own `Process`, pipes, async execution, output capture, exit code, and error handling.
- `ArchiveListParser` should parse `-slt` records separated by blank lines and key/value lines such as `Path =`, `Size =`, `Modified =`, and `Folder =`.
- `ArchiveService` should combine locator, runner, and parser for `listArchive`.
- `FileDialogs` should own `NSOpenPanel` configuration for archive opening.
- `LogView` should display accumulated stdout/stderr text.

</specifics>

<deferred>
## Deferred Ideas

- Extract, Test, Info, and Add toolbar behavior — Phase 2.
- Smart Extract planner and Finder reveal — Phase 3.
- Real compression flow — Phase 4.
- Finder integration, App Store, bundled 7-Zip core, Full Disk Access, and bookmarks — v2+.

</deferred>

---

*Phase: 01-walking-skeleton-archive-list*
*Context gathered: 2026-05-04 via PRD-style product brief*
