# Phase 5: UX And Error Hardening - Context

**Gathered:** 2026-05-05
**Status:** Ready for planning
**Mode:** Auto continuation

<domain>
## Phase Boundary

Harden command execution and operation state so long-running 7zz jobs do not freeze or deadlock the UI, and success/failure messages read cleanly in the macOS interface.

</domain>

<decisions>
## Implementation Decisions

- Read stdout/stderr concurrently while the process runs.
- Keep stdin closed through a pipe so 7zz cannot block waiting for terminal input.
- Disable home actions while an operation is running.
- Render success/status feedback differently from errors in the archive browser.

</decisions>
