<!-- GSD:project-start source:PROJECT.md -->
## Project

**Qizip**

Qizip is a macOS-native SwiftUI archive manager inspired by NanaZip's user experience and powered in v1 by the official 7-Zip command-line tool `7zz`. It is not a Windows NanaZip port; it aims to bring a modern, simple archive browser to macOS with open, list, extract, smart extract, test, info, and basic compression workflows.

The first release is a runnable MVP for Mac: users open or drop archives, browse archive contents in a file-manager-style interface, extract safely, test archives, and compress selected files or folders into `.7z` or `.zip`.

**Core Value:** Qizip must make archive open, inspect, extract, and compress workflows feel reliable and native on macOS while preserving 7-Zip's format capability.

### Constraints

- **Platform**: macOS SwiftUI app — the product is for Mac first, even though the current Xcode target lists multiple Apple platforms.
- **Archive engine**: v1 depends on local `7zz` — keeps MVP simple but requires a clear missing-tool error.
- **Subprocess safety**: Use URL and argument arrays — required for Chinese paths, spaces, quotes, and shell-injection avoidance.
- **Permissions**: Only user-selected files — aligns with macOS privacy expectations and avoids Full Disk Access.
- **Distribution**: No App Store in v1 — avoids sandbox/distribution complexity while validating core UX.
- **Code quality**: Clear file responsibilities — avoid turning `ContentView.swift` into a large mixed-responsibility file.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Summary
## Languages
- Swift in `Qizip/QizipApp.swift` and `Qizip/ContentView.swift`
- Xcode project configuration in `Qizip.xcodeproj/project.pbxproj`
- JSON asset catalog metadata in `Qizip/Assets.xcassets/**/Contents.json`
## Runtime And Platforms
- App target: `Qizip`
- Product type: `com.apple.product-type.application`
- SwiftUI app lifecycle via `@main` in `Qizip/QizipApp.swift`
- Configured platforms in `Qizip.xcodeproj/project.pbxproj`:
- Deployment targets:
## Frameworks
- `SwiftUI` is imported by both current Swift files.
- No explicit third-party frameworks are linked in `PBXFrameworksBuildPhase`.
- No Swift Package Manager dependencies are configured in `packageProductDependencies`.
## Build Configuration
- `SWIFT_VERSION = 5.0`
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `ENABLE_APP_SANDBOX = YES`
- `ENABLE_HARDENED_RUNTIME = YES`
- `ENABLE_USER_SELECTED_FILES = readonly`
- `CODE_SIGN_STYLE = Automatic`
- `DEVELOPMENT_TEAM = D5ST8RM87C`
- Bundle identifier: `com.cloudewhitetower.Qizip`
## Current Application Surface
- `Qizip/QizipApp.swift` creates a `WindowGroup` and displays `ContentView`.
- `Qizip/ContentView.swift` renders a placeholder globe icon and `Hello, world!` text.
- `Qizip/Assets.xcassets/AppIcon.appiconset/Contents.json` exists but contains only catalog metadata.
- `Qizip/Assets.xcassets/AccentColor.colorset/Contents.json` exists for generated accent color support.
## Missing Stack Pieces For Product Goal
- No 7-Zip binary, library, package, subprocess wrapper, or build phase exists yet.
- No archive format model, compression/decompression service, file picker, destination picker, progress reporting, cancellation, or error taxonomy exists yet.
- No macOS-specific document/open-with integration exists yet.
- No tests, CI, packaging, notarization, or release automation exist yet.
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Summary
## Swift Style Present
- Imports are placed at the top of Swift files.
- Types use UpperCamelCase: `QizipApp`, `ContentView`.
- SwiftUI view body uses a computed `var body: some View`.
- Modifiers are chained below the view tree, as seen in `Qizip/ContentView.swift`.
- Previews use the modern `#Preview` macro.
## App Lifecycle Pattern
- The app uses SwiftUI lifecycle with `@main`.
- The root scene is a `WindowGroup`.
- `Qizip/QizipApp.swift` directly instantiates `ContentView`.
## Error Handling
- Invalid archives
- Unsupported formats
- Password-protected archives
- Wrong passwords
- File permission failures
- Destination conflicts
- 7-Zip process failures
- Partial extraction/compression failures
## State Management
## Concurrency
- Build settings enable Swift approachable concurrency.
- Default actor isolation is configured as `MainActor`.
- No async code exists yet.
## File Access
- Sandbox is enabled.
- User-selected files are currently read-only.
- No security-scoped URL handling exists yet.
## Comments
- Existing Swift files include Xcode-generated header comments.
- No explanatory comments are needed in current code.
- Future comments should be reserved for non-obvious archive engine behavior, especially process output parsing and sandbox permission handling.
## Recommended Near-Term Convention
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Summary
## Entry Points
- App entry point: `Qizip/QizipApp.swift`
- Root scene: `WindowGroup` in `Qizip/QizipApp.swift`
- Root view: `ContentView()` from `Qizip/ContentView.swift`
- SwiftUI preview: `#Preview` in `Qizip/ContentView.swift`
## Current View Flow
- `Image(systemName: "globe")`
- `Text("Hello, world!")`
- `.padding()`
## Current Layers
- App lifecycle layer: `Qizip/QizipApp.swift`
- Placeholder UI layer: `Qizip/ContentView.swift`
- Assets/configuration layer: `Qizip/Assets.xcassets/**`
- Build metadata: `Qizip.xcodeproj/project.pbxproj`
- Archive engine invocation
- Job queue or operation state
- Progress parsing
- File system access
- Security-scoped bookmarks
- Preferences
- Error presentation
- Archive format detection
## Architectural Implications For Qizip
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
## Data Flow Today
## Data Flow Needed For v1
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
