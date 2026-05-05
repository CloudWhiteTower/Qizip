# Summary 07-01: Bundled 7zz Locator And Verification

## Result

QiZip v0.2 Milestone 1 is complete. The app now bundles the official 7-Zip 26.01 macOS `7zz` executable, prefers it through `SevenZipLocator`, and displays the active source in the home view.

## Changed

- Added `Qizip/Vendor/7zz`.
- Added `Qizip/Legal/7-Zip-LICENSE.txt`.
- Added `Qizip/Legal/ThirdPartyNotices.md`.
- Updated `SevenZipLocator` with bundle-first lookup, source labels, `/usr/bin/7zz`, developer/debug fallbacks, and non-executable bundle diagnostics.
- Updated `ArchiveService` to surface locator diagnostics when 7zz is unavailable.
- Updated `EmptyHomeView` and `ContentView` to display current 7zz source and path.
- Added `Tests/SevenZipLocatorHarness.swift`.
- Updated README, manual acceptance docs, ROADMAP, STATE, and PROJECT.

## Verification

- `SevenZipLocatorHarness passed`
- `V1ArchiveWorkflowHarness passed`
- `xcodebuild ... CODE_SIGNING_ALLOWED=NO build` succeeded for macOS.
- Build product contains executable `.build/DerivedData/Build/Products/Debug/Qizip.app/Contents/Resources/7zz`.
- Bundled executable runs and reports 7-Zip 26.01 arm64.

## Notes

`.Codex/ToDo/ToDo.md` is still blocked by local permissions, so v0.2 task tracking for this phase was recorded under `.planning/phases/07-v02-bundled-sevenzip/`.
