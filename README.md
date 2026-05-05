# Qizip

Qizip is a macOS-native SwiftUI archive manager inspired by NanaZip's core user experience. It is not a Windows NanaZip port. The v1 MVP focuses on opening archives, browsing their contents, extracting safely, testing integrity, and compressing selected files or folders.

## Requirements

- macOS with Xcode
- Local 7-Zip command line tool `7zz`

Qizip looks for `7zz` in this order:

1. `/opt/homebrew/bin/7zz`
2. `/usr/local/bin/7zz`

If neither path exists, the app shows:

```text
7zz was not found. Please install it with: brew install sevenzip
```

Install 7-Zip with:

```bash
brew install sevenzip
```

For local development, you can also point Qizip at a project-local `7zz`:

```bash
export QIZIP_SEVENZIP_PATH=/Users/cloud/code/CodeRepository/xcode_programmes/Qizip/Qizip/.build/tools/7zip/7zz
```

Debug builds also check `.build/tools/7zip/7zz` relative to the current working directory, which is useful for command-line testing from the repository root.

## Build

Open `Qizip.xcodeproj` in Xcode and run the `Qizip` scheme on macOS.

For command-line verification inside this repo:

```bash
xcodebuild -project Qizip.xcodeproj -scheme Qizip -destination 'platform=macOS' -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build
```

## Test Harness

Parser and Smart Extract planner logic can be checked with:

```bash
swiftc -module-cache-path .build/ModuleCache Qizip/Models/ArchiveEntry.swift Qizip/Services/ArchiveListParser.swift Qizip/Services/SmartExtractionPlanner.swift Tests/ParserPlannerHarness.swift -o .build/parser-planner-harness
.build/parser-planner-harness
```

## v1 Scope

Included:

- Open or drop archives.
- Browse archive entries in a SwiftUI table.
- Extract to a chosen folder.
- Smart Extract to avoid dumping many top-level items into one folder.
- Test archive integrity.
- Show archive info.
- Compress selected files or folders to `.7z` or `.zip`.
- Show stdout and stderr in the app log.

Deferred:

- Finder right-click menu.
- Finder Sync.
- App Store distribution.
- Embedded 7-Zip core.
- Full Disk Access.
- Persistent security-scoped bookmarks.
