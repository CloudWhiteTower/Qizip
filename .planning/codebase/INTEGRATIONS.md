---
last_mapped: 2026-05-04
last_mapped_commit: bcccebb58644444ab4c8bc008f1d2eeac90b9379
focus: tech
---

# Integrations

## Summary

The current codebase has no runtime integrations beyond Apple platform frameworks included by the Xcode app template.
The intended product direction will require careful integration with a 7-Zip implementation for archive operations and macOS file access APIs.

## Repository

- User-provided repository URL: `https://github.com/CloudWhiteTower/Qizip.git`
- No git remote output was present when `git remote -v` was checked locally.
- The repo currently contains local project files but no remote-tracking metadata was visible from the command output.

## Apple Platform Integrations

- `SwiftUI` is used for the app entry and placeholder UI.
- Sandbox is enabled through `ENABLE_APP_SANDBOX = YES` in `Qizip.xcodeproj/project.pbxproj`.
- Hardened Runtime is enabled through `ENABLE_HARDENED_RUNTIME = YES`.
- User-selected file access is currently read-only through `ENABLE_USER_SELECTED_FILES = readonly`.

## Archive Engine Integration

- No 7-Zip integration exists yet.
- No NanaZip code or Windows shell integration code exists locally.
- No vendored source, binary, or package metadata exists for:
  - `7zz`
  - `7z`
  - `p7zip`
  - `7-Zip`
  - NanaZip

## Planned Integration Questions

- Decide whether Qizip will call a bundled `7zz` executable via `Process`, link a library wrapper, or use a package that wraps 7-Zip behavior.
- Decide how to comply with sandbox file access when reading archive inputs and writing extracted/compressed outputs.
- Decide whether to expose Finder integration through document types, Services/Quick Actions, share extensions, or a later helper app.
- Decide how to distribute any 7-Zip binary and satisfy license attribution requirements.

## Current External Services

- No network APIs.
- No database.
- No authentication provider.
- No telemetry, analytics, crash reporting, or update service.
- No webhooks.

## Current Build And Release Integrations

- No GitHub Actions workflows are present.
- No Fastlane, Sparkle, Homebrew cask, notarization script, or release automation exists.
- Xcode automatic signing is configured, but there is no explicit distribution profile or export options plist.

