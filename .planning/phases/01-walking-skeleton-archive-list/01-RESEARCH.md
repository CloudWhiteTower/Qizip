# Phase 1: Walking Skeleton Archive List - Research

**Researched:** 2026-05-04
**Question:** What is needed to plan the Qizip walking skeleton well?

## Phase Capabilities And Owners

| Capability | Tier Owner | Secondary Tier | Why |
|------------|------------|----------------|-----|
| `7zz` detection | Services | UI | It is a filesystem/process capability surfaced as UI status |
| Archive open/drop | UI | Utilities | User-selected file access begins in AppKit/SwiftUI UI boundaries |
| `7zz l -slt` invocation | Services | Models | Process execution must be isolated from views |
| `-slt` parsing | Services | Models | Converts external text into app domain data |
| Table rendering | UI | Models | Pure presentation of parsed entries |
| Log rendering | UI | Services | Shows service output without owning process logic |

## Relevant Current State

- `Qizip/QizipApp.swift` contains only a `WindowGroup` with `ContentView`.
- `Qizip/ContentView.swift` contains placeholder SwiftUI content.
- No services, models, utility helpers, tests, or archive logic exist.
- Sandbox is enabled and user-selected files are read-only in the Xcode project, which is compatible with Phase 1 listing.

## Implementation Patterns To Use

### Process Boundary

Use a single service boundary for subprocess execution:

- `Process.executableURL = sevenZipURL`
- `Process.arguments = ["l", "-slt", archiveURL.path]`
- Capture `standardOutput` and `standardError` through `Pipe`.
- Return a structured result containing stdout, stderr, and termination status.
- Throw or surface a typed error on missing executable and non-zero exit.

Do not use `/bin/sh -c` or command strings.

### Parser Boundary

`7zz l -slt` emits technical records with `Key = Value` lines. A practical v1 parser should:

- Split records on blank lines.
- Collect known fields.
- Treat `Path` as the stable full archive path.
- Use last path component as display name.
- Parse `Size` as `Int64?`.
- Treat `Folder = +` as directory.
- Keep date parsing tolerant; raw string or optional `Date` is acceptable if the Table can display it.

### UI State

Use a simple `@State`/`@MainActor` flow in Phase 1 rather than adding a larger architecture prematurely. Keep state ownership in `ContentView` or a small view model only if needed.

Minimum state:

- selected archive URL
- entries
- log text
- loading flag
- error message
- sevenZipStatus

### Drag And Drop

Use SwiftUI drop handling for file URLs. Accept archives by extension and route the first supported archive into the same open flow used by `NSOpenPanel`.

## Risks And Mitigations

| Risk | Mitigation |
|------|------------|
| UI freeze during `7zz` call | Run process work from an async `Task`; update UI on main actor |
| Chinese paths/spaces break | Pass paths only as `Process.arguments` elements |
| Parser fails on partial metadata | Make fields optional and tolerate missing values |
| Missing `7zz` crashes flow | Detect before execution and show exact install guidance |
| Scope creep into extraction/compression | Keep Phase 1 action surface limited to open/list/log |

## Validation Architecture

Phase 1 should be validated with:

- Build check through Xcode or `xcodebuild` if available.
- Manual check with a `.zip` or `.7z` archive containing at least one nested folder.
- Missing `7zz` simulation can be code-reviewed if local machine has `7zz`; do not require uninstalling tools.
- Path check with an archive path containing spaces and ideally Chinese characters.

## Planner Guidance

Split into three plans:

1. Core models/services/utilities.
2. SwiftUI views.
3. Wiring, drag/drop, integration, and manual verification.

Do not implement Extract, Smart Extract, Test, Info, or real compression in Phase 1.

