# Roadmap: Qizip

## Overview

Qizip v1 builds from the existing SwiftUI skeleton into a usable macOS archive manager in narrow, runnable slices. The roadmap starts with a walking skeleton that detects `7zz`, opens archives, parses listings, and displays contents, then layers extraction, Smart Extract, compression, UX hardening, and release/testing readiness.

Qizip v0.2 upgrades the completed MVP from a usable `7zz` GUI wrapper into a more macOS-native archive manager. The v0.2 sequence starts with bundling the official `7zz` executable, then proceeds through file association, launch routing, Archive Browser upgrades, Smart Extract refinement, quick operation panels, job queue, preferences/bookmarks, Finder Quick Actions, and legal/about documentation.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Walking Skeleton Archive List** - Detect `7zz`, open archives, list contents, and show logs.
- [x] **Phase 2: Archive Actions** - Add Extract, Test, Info, and Add placeholder actions.
- [x] **Phase 3: Smart Extract** - Implement safe extraction destination planning and Finder reveal.
- [x] **Phase 4: Compression Flow** - Compress selected files/folders into `.7z` or `.zip`.
- [x] **Phase 5: UX And Error Hardening** - Polish native UX, error handling, path edge cases, and dark mode.
- [x] **Phase 6: Test And Release Readiness** - Add focused tests and prepare a direct macOS MVP build.
- [x] **Phase 7: v0.2 Bundled SevenZip** - Bundle official `7zz`, make locator bundle-first, and show source diagnostics.
- [ ] **Phase 8: v0.2 File Association And Launch Routing** - Open archive documents into Archive Browser without auto-extracting.
- [ ] **Phase 9: v0.2 Archive Browser Upgrade** - Add search, sidebar, inspector, richer table columns, and status bar.
- [ ] **Phase 10: v0.2 Smart Extract Upgrade** - Produce richer extract plans, ignore system trash entries, and expose plan reasoning.
- [ ] **Phase 11: v0.2 Quick Operation Panel** - Add compact extract/compress operation panels for routed inputs.
- [ ] **Phase 12: v0.2 JobQueueManager** - Route list/extract/smartExtract/compress/test through a unified queue.
- [ ] **Phase 13: v0.2 Preferences And Bookmarks** - Add settings and security-scoped bookmark persistence.
- [ ] **Phase 14: v0.2 Finder Quick Actions** - Add first Finder right-click actions through a thin router.
- [ ] **Phase 15: v0.2 Legal And About** - Add app-visible 7-Zip notices and final README/manual acceptance updates.

## Phase Details

### Phase 1: Walking Skeleton Archive List
**Goal**: Qizip launches as a macOS SwiftUI app, detects local `7zz`, opens or accepts dropped archives, runs `7zz l -slt`, parses entries, displays them in a table, and streams logs without blocking the UI.
**Depends on**: Nothing (first phase)
**Requirements**: [PLAT-01, PLAT-02, PLAT-03, ENG-01, ENG-02, ENG-03, ENG-04, OPEN-01, OPEN-02, OPEN-03, OPEN-04, OPEN-05, BROW-01, BROW-02, LOG-01, LOG-02, UX-01, UX-02, UX-03, PATH-01]
**UI hint**: yes
**Canonical refs**:
  - `.planning/PROJECT.md` — product context and decisions
  - `.planning/REQUIREMENTS.md` — v1 requirements
  - `.planning/codebase/STACK.md` — current Xcode and SwiftUI setup
  - `.planning/codebase/ARCHITECTURE.md` — current skeleton and suggested boundaries
  - `.planning/codebase/CONCERNS.md` — sandbox, platform, and process risks
**Success Criteria** (what must be TRUE):
  1. User can launch Qizip and see a home view with `Open Archive`, `Compress Files...`, drop guidance, and `7zz` status.
  2. User can open or drop a supported archive and see entries in a SwiftUI table.
  3. Listing uses `Process.executableURL` and `Process.arguments`, not shell strings.
  4. stdout/stderr from `7zz` is visible in `LogView`.
  5. Missing `7zz` produces the exact install guidance without crashing.
**Plans**: 3 plans

Plans:
- [x] 01-01: Create models, locator, runner, parser, and file dialog utility.
- [x] 01-02: Build home, archive browser, and log views around a minimal async state flow.
- [x] 01-03: Wire `ContentView`, drag/drop, open-panel flow, path-safe listing, and manual verification.

### Phase 2: Archive Actions
**Goal**: The archive browser exposes toolbar actions for Extract, Test, Info, and an Add placeholder.
**Depends on**: Phase 1
**Requirements**: [BROW-03, BROW-04, EXT-01, EXT-02, TEST-01, TEST-02, INFO-01]
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. User can extract the opened archive to a chosen output folder.
  2. User can test archive integrity and see success or failure.
  3. User can open Info and see path, file count, total size, and parse status.
  4. Add clearly communicates that it is deferred.
**Plans**: 2 plans

Plans:
- [x] 02-01: Add archive operation APIs for extract, test, and info data.
- [x] 02-02: Add toolbar actions, sheets/alerts, and action log states.

### Phase 3: Smart Extract
**Goal**: Qizip prevents messy multi-item extraction by planning a safe destination before running extraction.
**Depends on**: Phase 2
**Requirements**: [EXT-03, EXT-04, EXT-05, EXT-06, EXT-07]
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Smart Extract extracts single-top-level archives into the selected folder.
  2. Smart Extract extracts multi-top-level archives into an archive-named folder.
  3. Existing destination folders produce numbered alternatives.
  4. Successful extraction offers `Reveal in Finder`.
**Plans**: 2 plans

Plans:
- [x] 03-01: Implement `SmartExtractionPlanner` and unit-style validation cases.
- [x] 03-02: Wire Smart Extract UI, extraction destination, and Finder reveal.

### Phase 4: Compression Flow
**Goal**: User can select files/folders and compress them into `.7z` or `.zip` with visible logs.
**Depends on**: Phase 1
**Requirements**: [COMP-01, COMP-02, COMP-03, COMP-04, COMP-05]
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. User can choose multiple files or folders for compression.
  2. User can choose `.7z` or `.zip` output through a save panel.
  3. Qizip calls the correct `7zz a` arguments for each output type.
  4. Compression logs and failures are visible without UI freeze.
**Plans**: 2 plans

Plans:
- [x] 04-01: Add compression options, input selection, save panel, and service method.
- [x] 04-02: Add compression sheet/home integration and manual verification.

### Phase 5: UX And Error Hardening
**Goal**: Qizip feels like a small native macOS utility and handles common archive and path failures cleanly.
**Depends on**: Phases 2, 3, 4
**Requirements**: [ENG-04, LOG-01, LOG-02, UX-03, PATH-01]
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Errors are normalized into readable messages.
  2. Chinese paths and paths with spaces work across open, list, extract, test, and compress.
  3. Dark mode layout remains readable.
  4. Long-running operations keep controls and logs coherent.
**Plans**: 2 plans

Plans:
- [x] 05-01: Normalize errors and operation state handling.
- [x] 05-02: Polish layout, dark mode, and edge-case manual verification.

### Phase 6: Test And Release Readiness
**Goal**: The MVP has focused verification coverage, Chinese user-facing copy, and can be built as a direct macOS app outside the App Store.
**Depends on**: Phase 5
**Requirements**: [PLAT-01, ENG-03, OPEN-05, EXT-04, EXT-05, EXT-06, COMP-04, COMP-05, PATH-01]
**Success Criteria** (what must be TRUE):
  1. Parser and Smart Extract planner have focused tests or testable harness coverage.
  2. Manual acceptance checklist covers all v1 workflows.
  3. Build settings and README explain local `7zz` dependency.
  4. MVP is ready for direct run from Xcode.
**Plans**: 3 plans

Plans:
- [x] 06-01: Add tests or test harnesses for parser and planner logic.
- [x] 06-02: Add manual acceptance documentation and release-readiness cleanup.
- [x] 06-03: Localize user-facing copy and docs for Chinese v1.

### Phase 7: v0.2 Bundled SevenZip
**Goal**: Qizip no longer requires Homebrew sevenzip for the default path; the app bundle contains official `7zz`, `SevenZipLocator` prefers it, and the UI shows which source is active.
**Depends on**: Phase 6
**Requirements**: [V02-7Z-01, V02-7Z-02, V02-7Z-03, V02-7Z-04, V02-LEGAL-01]
**Success Criteria** (what must be TRUE):
  1. `Qizip.app/Contents/Resources/7zz` exists in the macOS build product and is executable.
  2. Locator search order is bundle, `/opt/homebrew/bin/7zz`, `/usr/local/bin/7zz`, `/usr/bin/7zz`, then developer/debug fallbacks.
  3. Home view shows source as `Bundled 7zz`, `Homebrew 7zz`, `System 7zz`, or `Not Found`.
  4. Missing or non-executable `7zz` produces clear UI-visible diagnostics without crashing.
  5. Open/list/test/extract/compress still use the same locator and continue to support Chinese and space paths.
**Plans**: 1 plan

Plans:
- [x] 07-01: Add bundled 7zz resource, locator source diagnostics, docs, and focused verification.

### Phase 8: v0.2 File Association And Launch Routing
**Goal**: Double-clicking supported archive files opens QiZip's Archive Browser by default and never auto-extracts unless the user changes settings later.
**Depends on**: Phase 7
**Plans**: 1 plan

### Phase 9: v0.2 Archive Browser Upgrade
**Goal**: Make the browser feel closer to a modern macOS file manager with search, sidebar, inspector, richer table metadata, and a status bar.
**Depends on**: Phase 8
**Plans**: 1 plan

### Phase 10: v0.2 Smart Extract Upgrade
**Goal**: Upgrade Smart Extract into a reasoned planner that ignores system trash entries and returns a detailed `ExtractPlan`.
**Depends on**: Phase 9
**Plans**: 1 plan

### Phase 11: v0.2 Quick Operation Panel
**Goal**: Add compact macOS operation panels for archive and regular file inputs before Finder Quick Actions are wired.
**Depends on**: Phase 10
**Plans**: 1 plan

### Phase 12: v0.2 JobQueueManager
**Goal**: Centralize list, extract, smart extract, compress, and test operations in a queue with per-job logs and statuses.
**Depends on**: Phase 11
**Plans**: 1 plan

### Phase 13: v0.2 Preferences And Bookmarks
**Goal**: Add settings and security-scoped bookmarks for default locations without requesting Full Disk Access.
**Depends on**: Phase 12
**Plans**: 1 plan

### Phase 14: v0.2 Finder Quick Actions
**Goal**: Add first Finder Quick Actions as thin entry points that hand selected URLs to the main app.
**Depends on**: Phase 13
**Plans**: 1 plan

### Phase 15: v0.2 Legal And About
**Goal**: Finish app-visible third-party notices and update README/manual acceptance for the v0.2 release.
**Depends on**: Phase 14
**Plans**: 1 plan

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6, then v0.2 continues with 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 15.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Walking Skeleton Archive List | 3/3 | Complete | 2026-05-05 |
| 2. Archive Actions | 2/2 | Complete | 2026-05-05 |
| 3. Smart Extract | 2/2 | Complete | 2026-05-05 |
| 4. Compression Flow | 2/2 | Complete | 2026-05-05 |
| 5. UX And Error Hardening | 2/2 | Complete | 2026-05-05 |
| 6. Test And Release Readiness | 3/3 | Complete | 2026-05-05 |
| 7. v0.2 Bundled SevenZip | 1/1 | Complete | 2026-05-05 |
| 8. v0.2 File Association And Launch Routing | 0/1 | Next | — |
| 9. v0.2 Archive Browser Upgrade | 0/1 | Planned | — |
| 10. v0.2 Smart Extract Upgrade | 0/1 | Planned | — |
| 11. v0.2 Quick Operation Panel | 0/1 | Planned | — |
| 12. v0.2 JobQueueManager | 0/1 | Planned | — |
| 13. v0.2 Preferences And Bookmarks | 0/1 | Planned | — |
| 14. v0.2 Finder Quick Actions | 0/1 | Planned | — |
| 15. v0.2 Legal And About | 0/1 | Planned | — |
