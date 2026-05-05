---
last_mapped: 2026-05-04
last_mapped_commit: bcccebb58644444ab4c8bc008f1d2eeac90b9379
focus: tech
---

# Stack

## Summary

Qizip is currently a minimal SwiftUI application generated from an Xcode app template.
The repository contains the app target, Swift entry point, placeholder content view, asset catalog, and Xcode project metadata.
There is no archive engine integration yet.

## Languages

- Swift in `Qizip/QizipApp.swift` and `Qizip/ContentView.swift`
- Xcode project configuration in `Qizip.xcodeproj/project.pbxproj`
- JSON asset catalog metadata in `Qizip/Assets.xcassets/**/Contents.json`

## Runtime And Platforms

- App target: `Qizip`
- Product type: `com.apple.product-type.application`
- SwiftUI app lifecycle via `@main` in `Qizip/QizipApp.swift`
- Configured platforms in `Qizip.xcodeproj/project.pbxproj`:
  - `macosx`
  - `iphoneos`
  - `iphonesimulator`
  - `xros`
  - `xrsimulator`
- Deployment targets:
  - `MACOSX_DEPLOYMENT_TARGET = 15.7`
  - `IPHONEOS_DEPLOYMENT_TARGET = 26.2`
  - `XROS_DEPLOYMENT_TARGET = 26.2`

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

