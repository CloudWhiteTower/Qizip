# Phase 2: Archive Actions - Context

**Gathered:** 2026-05-05
**Status:** Ready for planning
**Mode:** Auto from user-provided MVP requirements

<domain>
## Phase Boundary

Add the first usable archive actions to the existing SwiftUI archive browser: Extract, Test, Info, and an Add placeholder. Preserve the macOS-native MVP direction and keep all 7zz calls path-safe via `Process.executableURL` and `Process.arguments`.

</domain>

<decisions>
## Implementation Decisions

- Add remains a v1 placeholder with the exact message `Add will be implemented in the next milestone`.
- Extract chooses an output folder using `NSOpenPanel` and calls `7zz x archive -o<outputDirectory>`.
- Test calls `7zz t archive` and surfaces success or failure without crashing.
- Info shows archive path, file count, total size, and parse status.
- All operation output is appended to `LogView`.

</decisions>

<specifics>
## Specific Ideas

Use the current `ArchiveService` as the service boundary and keep UI orchestration in `ContentView`, while `ArchiveBrowserView` only renders controls and delegates actions through closures.

</specifics>
