---
status: resolved
trigger: "Opening/extracting or compressing test2zip can appear stuck when same-name outputs require 7zz interaction"
created: 2026-05-05
updated: 2026-05-05
---

# Debug: v0.2 Compression And Extraction Safety

## Symptoms

- User reported QiZip can appear stuck when testing with `test2zip`.
- `test2zip/` contained an existing `压缩包.zip`, which is the kind of output path that can accidentally sit inside the source folder being compressed.
- Same-name extraction can also cause `7zz` to request overwrite confirmation if the app does not run in non-interactive mode.

## Root Cause

- Extraction used `7zz x archive -oDEST` without explicit non-interactive overwrite behavior.
- Compression used `7zz a ... output input...` without replacing an existing output archive first.
- The service allowed unsafe output paths where the destination archive is inside a selected source directory.
- The UI defaulted to `.7z` and used generic `压缩包` for multiple selected inputs, which made accidental same-name output easier.

## Fix

- Extraction asks the user before overwriting existing destination items, then uses `-y -aoa` after confirmation.
- Compression asks the user before replacing existing output archives.
- Compression asks the user before allowing an output path inside the selected source directory.
- User-approved nested output compression writes to a temporary archive first, then moves it to the requested destination.
- Compression still rejects output paths equal to selected source files or pointing at folders.
- Default compression format is `.zip`.
- Default archive base name is derived from the first selected input.

## Verification

- `CompressionSafetyHarness passed`
- `V1ArchiveWorkflowHarness passed`
- `SevenZipLocatorHarness passed`

## Files Changed

- `Qizip/Services/ArchiveService.swift`
- `Qizip/Utilities/CompressionDefaults.swift`
- `Qizip/Utilities/FileDialogs.swift`
- `Qizip/ContentView.swift`
- `Tests/CompressionSafetyHarness.swift`
- `README.md`
- `docs/MANUAL_ACCEPTANCE.md`
