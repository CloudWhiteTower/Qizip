# Patterns — Phase 1: Walking Skeleton Archive List

## Existing Analogs

The existing codebase is too small to provide product patterns. The only current analogs are:

- `Qizip/QizipApp.swift` — SwiftUI lifecycle and `WindowGroup`.
- `Qizip/ContentView.swift` — placeholder SwiftUI view and `#Preview`.

## Patterns To Establish

### Folder Organization

Create folders under `Qizip/`:

- `Models/`
- `Services/`
- `Views/`
- `Utilities/`

### Service Boundary

Keep subprocess code in `Services/SevenZipRunner.swift`; views should call higher-level `ArchiveService`.

### UI Boundary

Keep reusable screens under `Views/`:

- `EmptyHomeView`
- `ArchiveBrowserView`
- `LogView`

`ContentView` should orchestrate state and route between home and browser, not implement parsing or subprocess logic.

### AppKit Boundary

Keep `NSOpenPanel` code in `Utilities/FileDialogs.swift` so SwiftUI views do not accumulate AppKit setup details.

