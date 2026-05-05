# UI-SPEC — Phase 1: Walking Skeleton Archive List

> Visual and interaction contract for frontend phase planning.

## Experience Goal

Qizip should feel like a small native macOS utility, not a marketing page and not a command-line wrapper with buttons. The first screen is the usable home state.

## Required Screens

### Empty Home

Must include:

- Clear drop target area or full-view drop acceptance.
- Text: `Drop an archive to open, or drop files to compress.`
- `Open Archive` button.
- `Compress Files...` button, disabled or marked unavailable for this phase if compression is deferred.
- Visible `7zz` status:
  - Found at `/opt/homebrew/bin/7zz`
  - Found at `/usr/local/bin/7zz`
  - Missing with exact install message.

### Archive Browser

Must include:

- Archive path or file name.
- SwiftUI `Table`.
- Columns: Name, Path, Size, Modified, Is Directory.
- Log area that can show stdout/stderr.
- Loading state while listing.
- Error state for missing `7zz`, unsupported file type, process failure, or parse failure.

## Interaction Constraints

- Do not show a landing-page hero.
- Do not use decorative cards or large marketing copy.
- Keep controls compact and macOS-like.
- Avoid nested cards.
- Support dark mode with system colors where possible.
- Text must not overflow buttons or table headers.

## Deferred UI

- Extract/Test/Info toolbar actions are Phase 2.
- Smart Extract CTA is Phase 3.
- Compression sheet is Phase 4.

