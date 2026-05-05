---
phase: 01
slug: walking-skeleton-archive-list
date: 2026-05-04
---

# Validation Strategy — Phase 1: Walking Skeleton Archive List

## Critical Behaviors

- Qizip launches.
- Home view shows required controls, guidance copy, and `7zz` status.
- Supported archive can be opened from `NSOpenPanel`.
- Supported archive can be dropped onto the app.
- `7zz l -slt` is invoked through `Process.executableURL` and `Process.arguments`.
- Entries render in a SwiftUI `Table`.
- stdout/stderr appears in `LogView`.
- Missing `7zz` produces exact install guidance without crashing.

## Automated Verification

Existing infrastructure does not yet include tests. Phase 1 should at minimum run:

- `xcodebuild -project Qizip.xcodeproj -scheme Qizip -destination 'platform=macOS' build`
- Static grep checks for `Process.executableURL`, `Process.arguments`, and absence of `/bin/sh`.

## Manual Verification

Use a small archive with nested files. Also test an archive path containing spaces and, if available, Chinese characters.

Manual checks:

1. Launch app in Xcode.
2. Confirm home view copy and `7zz` status.
3. Open a `.zip` or `.7z`.
4. Confirm entries populate Name, Path, Size, Modified, Is Directory.
5. Confirm log output appears.
6. Drag the same archive onto the home view and confirm it opens.

## Known Gaps

- No parser unit tests until a test target exists.
- Missing `7zz` behavior may require code review if the local development machine has `7zz` installed.

