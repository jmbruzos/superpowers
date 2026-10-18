---
id: WRK-TASK-FORK-UPSTREAM-004-005
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Pre-register, measure level 1 after 0.8.0, hold for level 2b"
parent: WRK-PLAN-FORK-UPSTREAM-004
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-004
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:30:39+02:00 }
stale_after: 2027-01-16T12:30:00+02:00
tags: [fork, upstream, executing-plans, task]
---

# WRK-TASK-FORK-UPSTREAM-004-005 — Pre-register, measure level 1 after 0.8.0, hold for level 2b

## Objective
Measure batch 3 at level 1 against `kdd-superpowers--v0.8.0`, record it, and hold the release until level 2b has run with the human's cost confirmation.

## Implementation Notes
**Files:** Create `specs/_capture/FRAG-FORK-UPSTREAM-004-batch-3-native-measurement/` (`raw/preregistration.md` first).

**Interfaces:** Consumes scenario 8 and its arms (task 004), the before tag `kdd-superpowers--v0.8.0`, the candidate sha after tasks 001–004.

**Premises:** batch 2 released (`git tag -l kdd-superpowers--v0.8.0` non-empty); both arms get the current harness (script, toolkit-env.sh, plan-metrics.mjs, fixtures); `KDD_FLOW_MODEL=opus`.

- [ ] **Step 1: Pre-register** — arms, deciding metrics (Native passes every scenario-8 check in both runs; scenarios 4 and 5 do not regress), reported metrics; commit; record sha and time.
- [ ] **Step 2: Level 1** — scenario 8 × {inline-old on 0.8.0, native on the candidate, sdd on the candidate} × 2; scenarios 4 and 5 × {0.8.0, candidate} × 2; in sequence.
- [ ] **Step 3: Capture** — FRAG-FORK-UPSTREAM-004 report: per-run tables, verdicts, pre-registration sha/time, run start times; validate; commit.
- [ ] **Step 4: Hold** — decision log entry: level 2b and the release wait for the human (spec AC7).

**Amendments (gate A2, binding):**
- Before Step 1: the deterministic suites (all four) pass on the candidate; the release itself (spec AC9: notes and tag) is held with AC7 and done only after level 2b.

## Acceptance Criteria
- [ ] Spec AC6 (measurement part); AC7 and AC9 (release) recorded as pending the human.

## Test Plan
The measurement is the test.
