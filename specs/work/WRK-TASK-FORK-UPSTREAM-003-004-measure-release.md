---
id: WRK-TASK-FORK-UPSTREAM-003-004
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Pre-register, release 0.8.0, measure, capture"
parent: WRK-PLAN-FORK-UPSTREAM-003
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
  - DOC-FORK-GATES-001@0.4.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-003
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T11:53:39+02:00 }
stale_after: 2027-01-16T11:53:39+02:00
tags: [fork, upstream, writing-plans, task]
---

# WRK-TASK-FORK-UPSTREAM-003-004 — Pre-register, measure, decide, release

## Objective

Run DOC-FORK-UPSTREAM-001 §4 for batch 2 on the release candidate, decide on the pre-registered metrics, and only then release 0.8.0: a worse batch is never tagged, because the tag is the next batch's before arm.

## Implementation Notes

**Files:** Create `specs/_capture/FRAG-FORK-UPSTREAM-003-batch-2-lean-plans-measurement/` (`raw/preregistration.md` first; then the FRAG file, `report.md`, raw run data). Modify `RELEASE-NOTES.md` and the version files via `scripts/bump-version.sh 0.8.0`.

**Interfaces:** Consumes `tests/claude-code/plan-metrics.mjs` and the scenario-4 changes (task 003), `tests/claude-code/ab/run-one.sh` and its prompts, the before tag `kdd-superpowers--v0.7.0`. The after arm is the branch commit after tasks 001–003 (the release candidate), named by its sha.

**Premises:** both arms get the current harness — `tests/claude-code/test-kdd-flow.sh`, `toolkit-env.sh`, `plan-metrics.mjs` and the fixtures (decision log U-9); `KDD_FLOW_MODEL=opus`; toolkit 1.13.0 pinned. The spec's *Testing* says "after this batch's release"; AC5 ("it is not released as is") governs, so the after arm is the candidate commit (plan ruling).

- [ ] **Step 1: Pre-register** — `raw/preregistration.md`: arms (before `v0.7.0`, after the candidate sha), the deciding metrics of spec *Testing* (level 1: `impl_code_share` lower in both after runs than both before runs; scenarios 4–6 checks pass; level 2: plan executability not lower, false claims in the plan not ≥ 2 more per run), the behaviour checks, the reported metrics, the reading rule and the cost-acceptance rule; commit it and record its sha and time.
- [ ] **Step 2: Level 1** — scenarios 4, 5, 6 (`KDD_FLOW_SCENARIOS="4 5 6"`: 4 is writing-plans, 5–6 load the changed `code-reviewer.md`), alternating before/after, n=2, `KDD_FLOW_USAGE` per run.
- [ ] **Step 3: Level 2** — pre-flight `spec-graph validate` on mdm-platform `aacdae5` with toolkit 1.13.0; `run-one.sh` B1 A1 B2 A2; bundles, evidence judge and neutral summary per run, one blind H1–H10 pass, as `tests/claude-code/ab/README.md` says.
- [ ] **Step 4: Capture** — FRAG-FORK-UPSTREAM-003 (`files` + `integrity`) and `report.md`: the pre-registration sha and time, every run's `result.json` start time, toolkit / Claude Code / model per arm, per-run tables, the verdict per deciding metric and behaviour check, cost ranges, discarded runs by name. Validate; commit.
- [ ] **Step 5: Decide** —
  - worse (DOC-FORK-UPSTREAM-001 §4) → rework or revert, logged as a ruling; no release;
  - cost above +20 % with non-overlapping ranges → no release until your human partner accepts it (unattended: release is held and the decision log says so);
  - otherwise → Step 6.
- [ ] **Step 6: Release** — run `bash tests/scripts/run.sh`, `bash tests/hooks/test-session-start.sh`, `bash tests/claude-code/test-sdd-workspace.sh`, `(cd tests/brainstorm-server && npm test)` → all pass; `bash scripts/bump-version.sh 0.8.0`, `RELEASE-NOTES.md` entry, commit, `git tag kdd-superpowers--v0.8.0` on that commit.

## Acceptance Criteria

- [ ] Spec AC4, AC5 and AC7.

## Test Plan

The measurement is the test; the four deterministic suites before the release commit.
