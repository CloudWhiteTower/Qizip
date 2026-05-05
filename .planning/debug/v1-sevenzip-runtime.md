---
status: resolved
trigger: "brew installed sevenzip at /opt/homebrew/bin/7zz but app still reports not found; verify v1 compression/extraction with test2zip"
created: 2026-05-05
updated: 2026-05-05
---

# Debug Session: v1-sevenzip-runtime

## Current Focus

- hypothesis: macOS App Sandbox prevents the app from seeing/executing Homebrew `7zz`, and read-only user-selected file entitlement is too restrictive for extraction/compression destinations.
- test: verify `/opt/homebrew/bin/7zz`, inspect Xcode sandbox settings, disable sandbox for direct-distribution v1, then run service-level v1 archive workflow against `test2zip`.
- expecting: locator finds `/opt/homebrew/bin/7zz`; archive service can compress, list, test, smart-plan, and extract the folder contents.
- next_action: update build settings and add a repeatable v1 runtime harness.

## Evidence

- `/opt/homebrew/bin/7zz` exists as a symlink to Homebrew sevenzip 26.01.
- `/opt/homebrew/bin/7zz` runs successfully from the terminal.
- `test2zip` contains `test1.txt`, `test2.txt`, and `测试3.txt`.
- Xcode project had `ENABLE_APP_SANDBOX = YES` and `ENABLE_USER_SELECTED_FILES = readonly`.

## Resolution

- root_cause: v1 需要执行 Homebrew 外部二进制 `/opt/homebrew/bin/7zz`，但 Xcode target 仍开启 App Sandbox；同时 user-selected file entitlement 是 `readonly`，不适合解压/压缩写入目标路径。
- fix: 将 Debug/Release 的 `ENABLE_APP_SANDBOX` 改为 `NO`，将 `ENABLE_USER_SELECTED_FILES` 改为 `readwrite`；新增 `Tests/V1ArchiveWorkflowHarness.swift` 验证完整 v1 工作流。
- verification: `V1ArchiveWorkflowHarness passed`，实际使用 `/opt/homebrew/bin/7zz` 压缩并解压 `test2zip` 内的 `test1.txt`、`test2.txt`、`测试3.txt`；Xcode macOS build passed；ParserPlannerHarness passed。
- files_changed:
  - `Qizip.xcodeproj/project.pbxproj`
  - `Tests/V1ArchiveWorkflowHarness.swift`
  - `README.md`
  - `docs/MANUAL_ACCEPTANCE.md`
