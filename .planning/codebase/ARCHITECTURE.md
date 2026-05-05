---
last_mapped: 2026-05-04
last_mapped_commit: bcccebb58644444ab4c8bc008f1d2eeac90b9379
focus: arch
---

# Architecture

## Summary

Qizip is currently a single-target SwiftUI app skeleton.
There are no domain layers, service boundaries, persistence components, or archive-processing abstractions yet.
The existing architecture should be treated as a blank starting point rather than an established product architecture.

## Entry Points

- App entry point: `Qizip/QizipApp.swift`
- Root scene: `WindowGroup` in `Qizip/QizipApp.swift`
- Root view: `ContentView()` from `Qizip/ContentView.swift`
- SwiftUI preview: `#Preview` in `Qizip/ContentView.swift`

## Current View Flow

`QizipApp` creates the application scene and loads `ContentView`.
`ContentView` renders a `VStack` with:

- `Image(systemName: "globe")`
- `Text("Hello, world!")`
- `.padding()`

There is no state model, navigation stack, file picker, command menu, document model, or archive operation flow.

## Current Layers

- App lifecycle layer: `Qizip/QizipApp.swift`
- Placeholder UI layer: `Qizip/ContentView.swift`
- Assets/configuration layer: `Qizip/Assets.xcassets/**`
- Build metadata: `Qizip.xcodeproj/project.pbxproj`

No separate layers currently exist for:

- Archive engine invocation
- Job queue or operation state
- Progress parsing
- File system access
- Security-scoped bookmarks
- Preferences
- Error presentation
- Archive format detection

## Architectural Implications For Qizip

The product goal is a macOS compression/decompression app built around 7-Zip behavior with a more native user experience inspired by NanaZip.
That implies the future architecture should likely separate:

- UI and command surface
- Archive job orchestration
- 7-Zip process or library adapter
- Filesystem permission handling
- Archive model and operation history
- Error normalization and recovery suggestions

## Suggested Future Boundaries

- `ArchiveCore`: format detection, operation request models, result models, progress events.
- `SevenZipAdapter`: invocation of `7zz` or other 7-Zip-compatible engine.
- `FileAccess`: macOS sandbox, security-scoped URLs, output destination handling.
- `AppUI`: SwiftUI screens, toolbar commands, drag/drop, operation detail views.
- `Settings`: defaults for overwrite behavior, password handling, destination rules, and compression level.

These boundaries do not exist yet and should be introduced only as implementation reaches those areas.

## Data Flow Today

There is no meaningful data flow.
The app starts and renders static SwiftUI content.

## Data Flow Needed For v1

Expected future flow:

1. User selects or drops archive/files into the app.
2. UI creates an archive operation request.
3. Archive coordinator validates file access and destination.
4. 7-Zip adapter performs list/extract/compress/test operation.
5. Progress output is parsed into app state.
6. UI presents progress, success, warnings, or normalized errors.

