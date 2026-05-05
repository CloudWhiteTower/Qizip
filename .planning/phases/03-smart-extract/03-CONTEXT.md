# Phase 3: Smart Extract - Context

**Gathered:** 2026-05-05
**Status:** Ready for planning
**Mode:** Auto from user-provided MVP requirements

<domain>
## Phase Boundary

Implement Smart Extract so Qizip avoids dumping multiple archive top-level items directly into the selected folder.

</domain>

<decisions>
## Implementation Decisions

- If the archive has one top-level item, extract directly into the selected folder.
- If it has multiple top-level items, extract into an archive-named folder inside the selected folder.
- Strip archive extensions from the generated folder name.
- If the destination exists, use `ArchiveName 2`, `ArchiveName 3`, and so on.
- After successful extraction, offer `Reveal in Finder`.

</decisions>
