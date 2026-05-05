---
last_mapped: 2026-05-04
last_mapped_commit: bcccebb58644444ab4c8bc008f1d2eeac90b9379
focus: concerns
---

# Concerns

## Summary

The current app is only a SwiftUI template, so there is little existing technical debt.
The main concerns are product-architecture gaps and future integration risks around 7-Zip, sandboxing, licensing, and macOS user experience.

## Existing Code Concerns

- `Qizip/ContentView.swift` is placeholder UI and should be replaced rather than expanded into a large mixed-responsibility view.
- `Qizip/QizipApp.swift` directly loads `ContentView`, which is fine for now but will need app-level state and command handling later.
- No tests exist, so future behavior can regress easily unless coverage is added as archive logic appears.

## Platform Configuration Concerns

- `ENABLE_APP_SANDBOX = YES` is enabled.
- `ENABLE_USER_SELECTED_FILES = readonly` may be too restrictive for extraction and compression workflows that need destination writes.
- `SUPPORTED_PLATFORMS` includes iOS, macOS, and xrOS even though the user described a Mac app. This may create unnecessary constraints unless multi-platform support is intentional.
- `MACOSX_DEPLOYMENT_TARGET = 15.7` narrows compatibility to recent macOS releases.

## 7-Zip Integration Risks

- Calling a bundled executable via `Process` is straightforward but requires reliable packaging, sandbox permissions, output parsing, cancellation, and error handling.
- Linking or vendoring source may introduce build complexity and licensing review.
- 7-Zip output is not an app-native API; parsing stdout/stderr must be robust and covered by tests.
- Password handling must avoid logging sensitive values.
- Large archives require non-blocking execution and progress updates.

## Security And Privacy Risks

- Archive extraction is a security-sensitive domain.
- The app should guard against path traversal, absolute paths, and overwrite surprises.
- Passwords should not be persisted unless explicitly designed and secured.
- Temporary files should be cleaned up reliably.
- Future crash logs or diagnostics must not include archive passwords or sensitive file paths unnecessarily.

## UX Risks

- Users expect archive tools to feel instant and predictable.
- A good macOS app needs drag/drop, Finder-friendly workflows, clear progress, cancellation, and understandable error recovery.
- NanaZip is Windows shell-focused; Qizip should learn from its usability goals without copying Windows-specific shell assumptions directly.

## Repository Concerns

- The user-provided repository URL is `https://github.com/CloudWhiteTower/Qizip.git`.
- No remote was shown by `git remote -v`, so local git configuration may still need an `origin` remote.

