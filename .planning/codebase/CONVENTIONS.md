---
last_mapped: 2026-05-04
last_mapped_commit: bcccebb58644444ab4c8bc008f1d2eeac90b9379
focus: quality
---

# Conventions

## Summary

There are very few application conventions in the current codebase because it is still the default SwiftUI app skeleton.
Existing conventions come mostly from Xcode-generated Swift formatting and build settings.

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

No error handling conventions exist yet.
This is an important gap because archive operations will need consistent handling for:

- Invalid archives
- Unsupported formats
- Password-protected archives
- Wrong passwords
- File permission failures
- Destination conflicts
- 7-Zip process failures
- Partial extraction/compression failures

## State Management

No app state model exists yet.
There are no `@State`, `@Observable`, `ObservableObject`, environment values, reducers, or dependency injection patterns.
Future state conventions should be chosen once the first archive workflow is designed.

## Concurrency

- Build settings enable Swift approachable concurrency.
- Default actor isolation is configured as `MainActor`.
- No async code exists yet.

Archive operations should not run on the main actor.
Future implementation should isolate UI updates from long-running compression/decompression work.

## File Access

- Sandbox is enabled.
- User-selected files are currently read-only.
- No security-scoped URL handling exists yet.

Future conventions should make file access explicit and centralized, because archive tools require both input reads and output writes.

## Comments

- Existing Swift files include Xcode-generated header comments.
- No explanatory comments are needed in current code.
- Future comments should be reserved for non-obvious archive engine behavior, especially process output parsing and sandbox permission handling.

## Recommended Near-Term Convention

Keep the SwiftUI view layer thin.
Put archive operation logic in separate service/core types rather than directly in views.
This will make progress reporting, cancellation, testing, and UI iteration easier.

