# 05-01 Summary: Error And Operation Hardening

**Completed:** 2026-05-05

## Shipped

- Updated `SevenZipRunner` to drain stdout and stderr while `7zz` runs.
- Added a stdin pipe so subprocesses do not wait on terminal input.
- Preserved executable URL plus argument-array subprocess invocation.
- Improved archive browser status rendering so successful messages are not shown as warnings.

## Verification

- Xcode macOS build succeeded with project-local DerivedData.
