---
id: WRK-TASK-FORK-UPSTREAM-005-003
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Scenario 9 (opt-in)"
parent: WRK-PLAN-FORK-UPSTREAM-005
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-005
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:48:23+02:00 }
stale_after: 2027-01-16T13:00:00+02:00
tags: [fork, upstream, brainstorming, task]
---

# WRK-TASK-FORK-UPSTREAM-005-003 — Scenario 9 (opt-in)

## Objective
A regression check that a knowledge question asked outside a workflow goes to `kdd:spec-ask` and not to brainstorming.

## Implementation Notes
**Files:** Modify `tests/claude-code/test-kdd-flow.sh`, `tests/scripts/test-flow-harness.sh`.
**Interfaces:** Consumes batch 3's `want_explicit` helper and per-scenario transcript directory (`$KDD_FLOW_USAGE/scenario-<n>.transcripts`). Produces scenario 9.
**Premises:** batch 3's scenario 8 shape (`test-kdd-flow.sh`, after batch 3's release).

- [ ] **Step 1: Write the failing harness check** — `test-flow-harness.sh`: scenario 9 is guarded by `want_explicit 9` and `KDD_FLOW_USAGE`.
- [ ] **Step 2: Run** → Expected: FAIL.
- [ ] **Step 3: Implement** — project with `tests/scripts/fixtures/specs`; prompt "What do our specs say about rounding pro-rata amounts?"; checks on its own transcripts: a Skill invocation of `kdd:spec-ask`; none of `kdd-superpowers:brainstorming`; no file under `specs/work/` written.
- [ ] **Step 4: Run** — `bash tests/scripts/test-flow-harness.sh`, `bash -n tests/claude-code/test-kdd-flow.sh`, `bash tests/scripts/run.sh` → Expected: pass.
- [ ] **Step 5: Commit** — `test(WRK-TASK-FORK-UPSTREAM-005-003): scenario 9 — knowledge question routed to spec-ask (opt-in)`.

**Amendments (gate A2, binding):**
- Scenario 9 sets `USAGE_SCENARIO=9`; the project copies `tests/scripts/fixtures/specs` and removes `specs/work` (as scenario 2), so no open work is offered and "no file under `specs/work/`" means none at all.
- Scenario 2 gains a transcript check (in the same commit): inside brainstorming, discovery invokes `kdd:spec-context` and not `kdd:spec-ask` (the spec's in-workflow boundary).

## Acceptance Criteria
- [ ] Spec AC3.

## Test Plan
1. `bash tests/scripts/test-flow-harness.sh`; 2. `bash tests/scripts/run.sh`.
