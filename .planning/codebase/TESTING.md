---
last_mapped: 2026-05-04
last_mapped_commit: bcccebb58644444ab4c8bc008f1d2eeac90b9379
focus: quality
---

# Testing

## Summary

No test target or test files currently exist.
The current app is a generated SwiftUI skeleton with no product behavior to verify yet.

## Current Test Structure

- No `QizipTests/` directory.
- No `QizipUITests/` directory.
- No XCTest files.
- No Swift Testing files.
- No fixtures for archive formats.
- No CI workflow for running tests.

## Current Build Verification

The only practical verification available today is opening/building the Xcode project.
No automated command has been run as part of this mapping.

Relevant project file:

- `Qizip.xcodeproj/project.pbxproj`

Relevant app files:

- `Qizip/QizipApp.swift`
- `Qizip/ContentView.swift`

## Testing Needs For Product Goal

An archive app should quickly add focused automated coverage around the core engine behavior:

- List archive contents.
- Extract a simple archive.
- Extract nested folders.
- Handle password-protected archives.
- Detect wrong password failure.
- Compress files into an archive.
- Preserve file names, directory structure, and basic metadata where required.
- Report progress without blocking the UI.
- Cancel a running operation.
- Handle destination conflict behavior.

## Fixture Needs

Future tests should include small fixture archives under a test resources directory.
Useful fixtures:

- `.zip`
- `.7z`
- `.tar`
- `.tar.gz`
- password-protected archive
- archive with nested directories
- archive with Unicode file names
- intentionally corrupt archive

## UI Testing Needs

Once UI exists, cover:

- Drag and drop archive input.
- File picker selection.
- Destination picker.
- Operation progress view.
- Error presentation.
- Basic app launch.

## Risk-Based Priority

The first tests should target the archive adapter before the UI.
The adapter is the highest-risk boundary because it will translate 7-Zip behavior into app-level results.

