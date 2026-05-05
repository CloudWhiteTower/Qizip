# 04-01 Summary: Compression Service And Dialogs

**Completed:** 2026-05-05

## Shipped

- Added `CompressionOptions` and `CompressionFormat`.
- Added multi-file/folder input selection via `NSOpenPanel`.
- Added `.7z` / `.zip` output selection via `NSSavePanel`.
- Added `ArchiveService.compress` using `7zz a -t7z/-tzip -mx=5`.

## Verification

- Xcode macOS build succeeded with project-local DerivedData.
