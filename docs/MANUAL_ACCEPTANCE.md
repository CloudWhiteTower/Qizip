# Qizip Manual Acceptance

Run these checks on a Mac with `7zz` installed at `/opt/homebrew/bin/7zz` or `/usr/local/bin/7zz`.

For repository-local testing, set:

```bash
export QIZIP_SEVENZIP_PATH=/Users/cloud/code/CodeRepository/xcode_programmes/Qizip/Qizip/.build/tools/7zip/7zz
```

## Setup

1. Build and run Qizip from Xcode.
2. Prepare archives with ordinary paths, paths containing spaces, and paths containing Chinese characters.
3. Prepare one archive with a single top-level folder.
4. Prepare one archive with multiple top-level files or folders.

## Checks

- Launch: home view shows `Drop an archive to open, or drop files to compress.`
- Tool detection: home view shows the detected `7zz` path, or the exact missing-tool message.
- Open: `Open Archive` accepts `7z`, `zip`, `rar`, `tar`, `gz`, `bz2`, `xz`, `zst`, `iso`, `dmg`, `cab`, and `wim` extensions.
- Drop: dropping one supported archive opens it.
- Browse: archive entries appear in the table with Name, Path, Size, Modified, and Is Directory.
- Add: Add shows `Add will be implemented in the next milestone`.
- Extract: Extract asks for a destination folder and runs successfully.
- Smart Extract single root: an archive with one top-level item extracts into the selected folder.
- Smart Extract multiple roots: an archive with multiple top-level items extracts into an archive-named folder.
- Smart Extract conflicts: if that archive-named folder exists, Qizip chooses `ArchiveName 2`, then `ArchiveName 3`, and so on.
- Reveal: successful Extract and Smart Extract offer `Reveal in Finder`.
- Test: Test reports success for a valid archive and failure for a corrupt archive.
- Info: Info shows archive path, file count, total size, and parse status.
- Compress: `Compress Files...` lets the user select files or folders and save `.7z`.
- Compress zip: changing the output extension to `.zip` creates a zip archive.
- Logs: every 7zz command displays stdout/stderr in `LogView`.
- Path safety: archives and inputs with spaces, quotes, and Chinese characters work because Qizip uses `Process.executableURL` and `Process.arguments`.

## Known Local Validation Gap

In the current Codex workspace, `7zz` was not found at either supported path. Build and pure logic validation passed, but successful 7zz runtime operations need to be checked after installing SevenZip.
