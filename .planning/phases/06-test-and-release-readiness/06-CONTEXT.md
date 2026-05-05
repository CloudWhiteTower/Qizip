# Phase 6: Test And Release Readiness - Context

**Gathered:** 2026-05-05
**Status:** Ready for planning
**Mode:** Auto after MVP implementation

<domain>
## Phase Boundary

Add focused verification for parser and Smart Extract planner logic, plus preserve a build command that works in the Codex sandbox by using a project-local DerivedData path.

</domain>

<decisions>
## Implementation Decisions

- Use a lightweight Swift harness instead of adding a full XCTest target in this pass.
- Keep direct Xcode run support unchanged.
- Runtime validation of successful 7zz operations is pending local `7zz` installation on this machine.

</decisions>
