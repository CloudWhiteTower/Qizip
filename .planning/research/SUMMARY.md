# Research Summary: Qizip

**Date:** 2026-05-04
**Scope:** macOS SwiftUI archive manager inspired by NanaZip and powered by local `7zz`.

## Key Findings

**Stack:** SwiftUI plus a small service layer is sufficient for v1. The risky boundary is not UI technology; it is the `7zz` process adapter, output parsing, path handling, and non-blocking operation state.

**Table stakes:** Archive apps must open archives, list contents, extract, compress, test integrity, show progress/log output, and explain missing tools or failures. For Qizip, Smart Extract is a core differentiator because it prevents multi-item archives from dumping many files into a destination folder.

**Watch out for:** Shell-string command construction, blocking the main actor, weak parsing of `7zz l -slt`, missing output directory handling, password/error leakage in logs, and accidental scope expansion into Finder integration before the app workflow works.

## Source Notes

- 7-Zip command-line behavior should be treated as the engine contract for v1: `l -slt` for technical listing, `x -o...` for extraction, `t` for archive testing, and `a -t7z/-tzip -mx=5` for compression.
- NanaZip should inform UX priorities: modern native shell/app feel, less friction around common archive tasks, and Smart Extraction. Windows-specific shell extension implementation is not a Qizip design constraint.

## Suggested Phase Shape

1. Walking skeleton with 7zz detection, open archive, list parsing, table, and log.
2. Archive actions: Extract, Test, Info, and Add placeholder.
3. Smart Extract planner and reveal-in-Finder completion UX.
4. Compression flow from selected files/folders to `.7z` or `.zip`.
5. UX polish, error normalization, dark mode checks, path edge cases.
6. Test and release hardening.

## References

- 7-Zip official site and command-line documentation: https://www.7-zip.org/
- NanaZip repository: https://github.com/M2Team/NanaZip

