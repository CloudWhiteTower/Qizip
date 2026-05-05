# Roadmap: Qizip

## Overview

Qizip v1 builds from the existing SwiftUI skeleton into a usable macOS archive manager in narrow, runnable slices. The roadmap starts with a walking skeleton that detects `7zz`, opens archives, parses listings, and displays contents, then layers extraction, Smart Extract, compression, UX hardening, and release/testing readiness.

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
**Goal**: The MVP has focused verification coverage and can be built as a direct macOS app outside the App Store.
**Depends on**: Phase 5
**Requirements**: [PLAT-01, ENG-03, OPEN-05, EXT-04, EXT-05, EXT-06, COMP-04, COMP-05, PATH-01]
**Success Criteria** (what must be TRUE):
  1. Parser and Smart Extract planner have focused tests or testable harness coverage.
  2. Manual acceptance checklist covers all v1 workflows.
  3. Build settings and README explain local `7zz` dependency.
  4. MVP is ready for direct run from Xcode.
**Plans**: 2 plans

Plans:
- [x] 06-01: Add tests or test harnesses for parser and planner logic.
- [x] 06-02: Add manual acceptance documentation and release-readiness cleanup.

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Walking Skeleton Archive List | 3/3 | Complete | 2026-05-05 |
| 2. Archive Actions | 2/2 | Complete | 2026-05-05 |
| 3. Smart Extract | 2/2 | Complete | 2026-05-05 |
| 4. Compression Flow | 2/2 | Complete | 2026-05-05 |
| 5. UX And Error Hardening | 2/2 | Complete | 2026-05-05 |
| 6. Test And Release Readiness | 2/2 | Complete | 2026-05-05 |
