# Phase 4: Compression Flow - Context

**Gathered:** 2026-05-05
**Status:** Ready for planning
**Mode:** Auto from user-provided MVP requirements

<domain>
## Phase Boundary

Enable selecting files or folders and compressing them into `.7z` or `.zip` through local `7zz`.

</domain>

<decisions>
## Implementation Decisions

- Use `NSOpenPanel` for user-selected input files/folders.
- Use `NSSavePanel` for the output archive URL.
- `.7z` uses `7zz a -t7z -mx=5 output.7z input1 input2 ...`.
- `.zip` uses `7zz a -tzip -mx=5 output.zip input1 input2 ...`.
- No Finder integration, Full Disk Access, bookmarks, embedded core, or third-party libraries in v1.

</decisions>
