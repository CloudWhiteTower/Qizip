# Phase 7 Context: v0.2 Bundled SevenZip

## Objective

Start QiZip v0.2 by removing the runtime dependency on a user-installed Homebrew `sevenzip`. The app should prefer an official `7zz` binary bundled inside `Qizip.app`, then fall back to Homebrew/system/developer locations.

## Scope

- Add `Qizip/Vendor/7zz` as the app-bundled executable resource.
- Upgrade `SevenZipLocator` to report source diagnostics.
- Keep all existing archive operations routed through `ArchiveService -> SevenZipLocator -> SevenZipRunner`.
- Add 7-Zip license and third-party notices.
- Update README and manual acceptance docs.
- Verify build product contains `Contents/Resources/7zz`.

## Out Of Scope

- Finder Quick Actions.
- File association / document open routing.
- JobQueueManager.
- Preferences and security-scoped bookmarks.
- Embedding or rewriting 7-Zip core.
