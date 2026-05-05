# Qizip

## What This Is

Qizip is a macOS-native SwiftUI archive manager inspired by NanaZip's user experience and powered in v1 by the official 7-Zip command-line tool `7zz`. It is not a Windows NanaZip port; it aims to bring a modern, simple archive browser to macOS with open, list, extract, smart extract, test, info, and basic compression workflows.

The first release is a runnable MVP for Mac: users open or drop archives, browse archive contents in a file-manager-style interface, extract safely, test archives, and compress selected files or folders into `.7z` or `.zip`.

## Core Value

Qizip must make archive open, inspect, extract, and compress workflows feel reliable and native on macOS while preserving 7-Zip's format capability.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] User can launch a macOS SwiftUI app named Qizip.
- [ ] User can see whether `7zz` is available at supported Homebrew paths.
- [ ] User can open supported archive files through an open panel or drag and drop.
- [ ] User can view archive contents in a structured table.
- [ ] User can extract an archive to a selected destination.
- [ ] User can Smart Extract without creating messy multi-item output in the selected folder.
- [ ] User can test archive integrity and see success or failure.
- [ ] User can view archive info including path, entry count, total size, and parse status.
- [ ] User can select files or folders and compress them into `.7z` or `.zip`.
- [ ] User can see all `7zz` stdout and stderr in an in-app log.
- [ ] Chinese paths, spaces, and quoted characters work because subprocess calls use `Process.executableURL` and `Process.arguments`.

### Out of Scope

- Finder right-click menu and Finder Sync — deferred until the core app workflow is stable.
- App Store release — v1 depends on local `7zz` and is a direct MVP, not a store distribution.
- Bundling or embedding 7-Zip core — v1 calls a user-installed `7zz`.
- Porting NanaZip Windows code — Qizip copies the product experience goals, not the implementation.
- Full Disk Access and proactive folder scanning — v1 only uses user-selected files from drag/drop and panels.
- Security-scoped bookmarks — v1 keeps structure open for future BookmarkManager work but does not persist access.

## Context

The current codebase is an Xcode-generated SwiftUI skeleton with `Qizip/QizipApp.swift`, `Qizip/ContentView.swift`, assets, and `Qizip.xcodeproj`. Codebase mapping lives in `.planning/codebase/` and confirms there is no archive engine, no service layer, no tests, and no product UI yet.

The repository URL supplied by the user is `https://github.com/CloudWhiteTower/Qizip.git`. The local sandbox could not write `.git/config`, so remote setup may need to be done outside this agent session.

The desired v1 structure is:

- `Qizip/Models/`
- `Qizip/Services/`
- `Qizip/Views/`
- `Qizip/Utilities/`

Important implementation decisions already made:

- Keep app and target name as Qizip.
- v1 is macOS-first.
- v1 calls local `7zz` at `/opt/homebrew/bin/7zz`, then `/usr/local/bin/7zz`.
- Subprocess invocation must use `Process.executableURL` and `Process.arguments`, never shell-string concatenation.
- No third-party Swift libraries in v1.
- Start from the smallest runnable version before filling out the entire feature set.

## Constraints

- **Platform**: macOS SwiftUI app — the product is for Mac first, even though the current Xcode target lists multiple Apple platforms.
- **Archive engine**: v1 depends on local `7zz` — keeps MVP simple but requires a clear missing-tool error.
- **Subprocess safety**: Use URL and argument arrays — required for Chinese paths, spaces, quotes, and shell-injection avoidance.
- **Permissions**: Only user-selected files — aligns with macOS privacy expectations and avoids Full Disk Access.
- **Distribution**: No App Store in v1 — avoids sandbox/distribution complexity while validating core UX.
- **Code quality**: Clear file responsibilities — avoid turning `ContentView.swift` into a large mixed-responsibility file.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| App name remains Qizip | User clarified that the existing Xcode app name is the intended product name | — Pending |
| Use local `7zz` executable for v1 | Fastest path to 7-Zip capability without embedding core or vendoring source | — Pending |
| Build minimum runnable slices | User explicitly asked to plan first and start from a minimal runnable version | — Pending |
| Defer Finder integration | Finder Sync/right-click adds macOS integration complexity not needed for MVP validation | — Pending |
| Keep file access user-driven | Avoids scanning protected folders and aligns with v1 permission principles | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-04 after initialization*
