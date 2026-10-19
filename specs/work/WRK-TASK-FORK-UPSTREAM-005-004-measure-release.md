---
id: WRK-TASK-FORK-UPSTREAM-005-004
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
title: "Pre-register, measure, decide, release"
parent: WRK-PLAN-FORK-UPSTREAM-005
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
  - DOC-FORK-GATES-001@0.4.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-005
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:48:23+02:00 }
stale_after: 2027-01-16T13:00:00+02:00
tags: [fork, upstream, brainstorming, task]
---

# WRK-TASK-FORK-UPSTREAM-005-004 — Pre-register, measure, decide, release

## Objective
Run DOC-FORK-UPSTREAM-001 §4 for batch 4 on the candidate; release only if not worse.

## Implementation Notes
**Files:** Create `specs/_capture/FRAG-FORK-UPSTREAM-005-batch-4-brainstorming-measurement/` (`raw/preregistration.md` first).
**Interfaces:** Consumes scenario 9 (task 003), `tests/claude-code/ab/`, the before tag (batch 3's release).
**Premises:** both arms get the current harness and fixtures; `KDD_FLOW_MODEL=opus`; toolkit 1.13.0.

- [ ] **Step 1: Pre-register** — arms (before = batch 3's tag, after = the candidate sha), deciding metrics and reading rule of spec *Testing*; commit; record sha and time.
- [ ] **Step 2: Level 1** — scenarios 1, 2, 3, 7, 9 × {before, after} × 2, alternating.
- [ ] **Step 3: Level 2** — RFC-PIPE-039 B1 A1 B2 A2 with the judges and one blind H1–H10 pass.
- [ ] **Step 4: Capture** — FRAG-FORK-UPSTREAM-005 with the verdicts; validate; commit.
- [ ] **Step 5: Decide and release** — worse → rework or revert, no release; cost > +20 % non-overlapping → held for the human; otherwise the four deterministic suites, version bump, release notes, local tag.

**Amendments (gate A2, binding):**
- Step 3 starts with the pre-flight: `spec-graph validate` with toolkit 1.13.0 over mdm-platform's specs at `aacdae5`, saved to `raw/mdm-preflight.txt`.
- A worse batch, and a cost rise above 20 % with non-overlapping ranges, are **held for the human's ruling** (DOC-FORK-UPSTREAM-001 §4: "with a human ruling"); the decision log says so; nothing is reworked, reverted or released on the agent's ruling alone.
- Batch 4 closes the sync's required batches: after a release, `CLAUDE.md` and `README.md` gain "derived from superpowers 6.3.0, with selected changes through 7.0.0" (DOC-FORK-UPSTREAM-001 §2, *Order*), and the batch-5 go/no-go is recorded as pending the human.

## Acceptance Criteria
- [ ] Spec AC4 and AC6.

## Test Plan
The measurement is the test; the four suites before the release commit.
