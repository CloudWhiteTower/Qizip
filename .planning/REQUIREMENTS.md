# Requirements: Qizip

**Defined:** 2026-05-04
**Core Value:** Qizip must make archive open, inspect, extract, and compress workflows feel reliable and native on macOS while preserving 7-Zip's format capability.

## v1 Requirements

### Platform

- [ ] **PLAT-01**: User can run Qizip as a macOS SwiftUI app.
- [ ] **PLAT-02**: Qizip keeps the existing app/target name Qizip.
- [ ] **PLAT-03**: Qizip v1 does not require App Store distribution, Finder Sync, or Full Disk Access.

### Engine

- [ ] **ENG-01**: Qizip detects `7zz` at `/opt/homebrew/bin/7zz` first and `/usr/local/bin/7zz` second.
- [ ] **ENG-02**: If `7zz` is missing, Qizip shows `7zz was not found. Please install it with: brew install sevenzip`.
- [ ] **ENG-03**: Qizip invokes `7zz` with `Process.executableURL` and `Process.arguments`, not shell strings.
- [ ] **ENG-04**: Qizip captures stdout, stderr, and non-zero exit status without crashing.

### Opening Archives

- [ ] **OPEN-01**: User can open an archive with `NSOpenPanel`.
- [ ] **OPEN-02**: User can drop an archive onto the home view to open it.
- [ ] **OPEN-03**: Qizip accepts at least `7z`, `zip`, `rar`, `tar`, `gz`, `bz2`, `xz`, `zst`, `iso`, `dmg`, `cab`, and `wim`.
- [ ] **OPEN-04**: Qizip runs `7zz l -slt archivePath` for archive listing.
- [ ] **OPEN-05**: Qizip parses listing output into `[ArchiveEntry]`.

### Browsing

- [ ] **BROW-01**: User can view archive entries in a SwiftUI `Table`.
- [ ] **BROW-02**: The table shows Name, Path, Size, Modified, and Is Directory.
- [ ] **BROW-03**: Archive browser toolbar shows Add, Extract, Smart Extract, Test, and Info.
- [ ] **BROW-04**: Add is a v1 placeholder that states `Add will be implemented in the next milestone`.

### Extraction

- [ ] **EXT-01**: User can choose an output folder and run Extract.
- [ ] **EXT-02**: Extract calls `7zz x archive -o<outputDirectory>`.
- [ ] **EXT-03**: User can run Smart Extract.
- [ ] **EXT-04**: Smart Extract extracts to the selected folder when the archive has one top-level item.
- [ ] **EXT-05**: Smart Extract creates an archive-named folder when the archive has multiple top-level items.
- [ ] **EXT-06**: Smart Extract creates `ArchiveName 2`, `ArchiveName 3`, etc. if the destination folder already exists.
- [ ] **EXT-07**: After successful extraction, user can click `Reveal in Finder`.

### Testing And Info

- [ ] **TEST-01**: User can test archive integrity with `7zz t archive`.
- [ ] **TEST-02**: Qizip displays test success or failure.
- [ ] **INFO-01**: User can view archive path, file count, total size, and parse status.

### Compression

- [ ] **COMP-01**: User can click `Compress Files...` from the home view.
- [ ] **COMP-02**: User can select multiple files or folders through `NSOpenPanel`.
- [ ] **COMP-03**: User can choose output archive path through `NSSavePanel`.
- [ ] **COMP-04**: Qizip supports `.7z` output with `7zz a -t7z -mx=5 output.7z input1 input2 ...`.
- [ ] **COMP-05**: Qizip supports `.zip` output with `7zz a -tzip -mx=5 output.zip input1 input2 ...`.

### Logging And UX

- [ ] **LOG-01**: All `7zz` stdout and stderr appears in `LogView`.
- [ ] **LOG-02**: Long-running `7zz` operations do not block the UI.
- [ ] **UX-01**: Home view says `Drop an archive to open, or drop files to compress.`
- [ ] **UX-02**: Home view exposes `Open Archive` and `Compress Files...`.
- [ ] **UX-03**: UI follows a simple macOS-native style and supports dark mode.
- [ ] **PATH-01**: Chinese paths and paths containing spaces work for open, list, extract, test, and compress operations.

## v2 Requirements

### Finder Integration

- **FIND-01**: User can access Qizip actions from Finder right-click menus.
- **FIND-02**: Qizip can add Finder Sync or Quick Action integration if justified.

### Engine Packaging

- **PACK-01**: Qizip can bundle or guide installation of 7-Zip more smoothly.
- **PACK-02**: Qizip can evaluate embedding 7-Zip core or a library wrapper.

### Access Persistence

- **BOOK-01**: Qizip can persist user-approved locations through security-scoped bookmarks.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Finder right-click menu | Deferred until app workflow validates core value |
| Finder Sync extension | Separate macOS integration surface; not required for MVP |
| App Store release | v1 uses local `7zz` and focuses on runnable MVP |
| Embedded 7-Zip core | Higher integration and licensing/build complexity |
| Porting NanaZip Windows code | Product goal is macOS-native UX inspired by NanaZip, not code migration |
| Full Disk Access | v1 only uses user-selected files |
| Security-scoped bookmarks | Design should allow later BookmarkManager, but v1 does not persist access |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PLAT-01 | Phase 1 | Pending |
| PLAT-02 | Phase 1 | Pending |
| PLAT-03 | Phase 1 | Pending |
| ENG-01 | Phase 1 | Pending |
| ENG-02 | Phase 1 | Pending |
| ENG-03 | Phase 1 | Pending |
| ENG-04 | Phase 1 | Pending |
| OPEN-01 | Phase 1 | Pending |
| OPEN-02 | Phase 1 | Pending |
| OPEN-03 | Phase 1 | Pending |
| OPEN-04 | Phase 1 | Pending |
| OPEN-05 | Phase 1 | Pending |
| BROW-01 | Phase 1 | Pending |
| BROW-02 | Phase 1 | Pending |
| LOG-01 | Phase 1 | Pending |
| LOG-02 | Phase 1 | Pending |
| UX-01 | Phase 1 | Pending |
| UX-02 | Phase 1 | Pending |
| UX-03 | Phase 1 | Pending |
| PATH-01 | Phase 1 | Pending |
| BROW-03 | Phase 2 | Pending |
| BROW-04 | Phase 2 | Pending |
| EXT-01 | Phase 2 | Pending |
| EXT-02 | Phase 2 | Pending |
| TEST-01 | Phase 2 | Pending |
| TEST-02 | Phase 2 | Pending |
| INFO-01 | Phase 2 | Pending |
| EXT-03 | Phase 3 | Pending |
| EXT-04 | Phase 3 | Pending |
| EXT-05 | Phase 3 | Pending |
| EXT-06 | Phase 3 | Pending |
| EXT-07 | Phase 3 | Pending |
| COMP-01 | Phase 4 | Pending |
| COMP-02 | Phase 4 | Pending |
| COMP-03 | Phase 4 | Pending |
| COMP-04 | Phase 4 | Pending |
| COMP-05 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 37 total
- Mapped to phases: 37
- Unmapped: 0

---
*Requirements defined: 2026-05-04*
*Last updated: 2026-05-04 after roadmap creation*

