---
id: WRK-TASK-FORK-UPSTREAM-004-004
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Scenario 8 (opt-in) in test-kdd-flow.sh"
parent: WRK-PLAN-FORK-UPSTREAM-004
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
  - DOC-FORK-GATES-001@0.4.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-004
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:30:39+02:00 }
stale_after: 2027-01-16T12:30:00+02:00
tags: [fork, upstream, executing-plans, task]
---

# WRK-TASK-FORK-UPSTREAM-004-004 — Scenario 8 (opt-in) in test-kdd-flow.sh

## Objective
Add the scenario that measures Native against the old inline mode and SDD on the rounding fixture, run only when asked for.

## Implementation Notes
**Files:** Modify `tests/claude-code/test-kdd-flow.sh`, `tests/scripts/test-flow-harness.sh`.

**Interfaces:** Consumes the rounding fixture (`tests/claude-code/fixtures/rounding-plan`, plan `WRK-PLAN-DEMO-MONEY-001`, tasks `…-001` (activates DOM-DEMO-ROUNDING-001) and `…-002`), `kdd-status` (`skills/kdd-conventions/scripts/kdd-status`). Produces scenario 8 with `KDD_FLOW_ARM8=native|inline-old|sdd` (default `native`) selecting the prompt; usage name `scenario-8-<arm>`.

**Premises:** `want()` at `test-kdd-flow.sh:58` runs every scenario when the list is empty; transcripts are copied only with `KDD_FLOW_USAGE` (`usage-lib.sh:25,36-39`); scenario 7's transcript checks recognise dispatches by description or prompt opening line (`test-kdd-flow.sh` after its `# Transcript checks` comment); `kdd-status` prints JSON (`skills/kdd-conventions/scripts/kdd-status --help`).

- [ ] **Step 1: Write the failing harness checks** in `tests/scripts/test-flow-harness.sh`: `test-kdd-flow.sh` has a `want_explicit` helper that is true only when `KDD_FLOW_SCENARIOS` names the scenario; scenario 8 is guarded by it and by `KDD_FLOW_USAGE`; the three arm prompts exist; no piped `grep -q` (existing check).
- [ ] **Step 2: Run** — `bash tests/scripts/test-flow-harness.sh` → Expected: FAIL.
- [ ] **Step 3: Implement scenario 8** — project from the fixture (as scenario 5 does from hello-plan); prompts: native "Use kdd-superpowers:executing-plans to execute specs/work/WRK-PLAN-DEMO-MONEY-001-money-library.md on this branch (I consent). Run through the final review and its fixes, then stop: do not start finishing-a-development-branch."; inline-old: the same naming kdd-superpowers:executing-plans plus "Execute every task yourself in this session; do not dispatch subagents."; sdd: the same naming kdd-superpowers:subagent-driven-development. Checks (all arms unless noted): `npm test` green; both tasks `status: completed`; `kdd-status` from the project reports the plan's ledger `used` and the ledger holds both completion lines; A4 (test adversary, recognised by description or prompt opening line) dispatched, and its first dispatch timestamp earlier than the commit time of `chore(WRK-TASK-DEMO-MONEY-001-001): complete`; Native arm: no implementer dispatch; a final review dispatched with an Opus model; the result text contains "Rulings I made".
- [ ] **Step 4: Run** — `bash tests/scripts/test-flow-harness.sh`, `bash -n tests/claude-code/test-kdd-flow.sh`, `bash tests/scripts/run.sh` → Expected: pass. Do not run scenario 8 itself.
- [ ] **Step 5: Commit** — `test(WRK-TASK-FORK-UPSTREAM-004-004): scenario 8 — Native vs old inline vs SDD on the rounding fixture (opt-in)`.

**Amendments (gate A2, binding):**
- The checks live in `tests/claude-code/scenario8-checks.sh <project dir> <transcripts dir> <arm>` (one `[PASS]`/`[FAIL]` line per check, exit 1 on any FAIL), called by scenario 8, and tested deterministically by `tests/scripts/test-scenario8-checks.sh` on a synthetic project (git repo with the two `chore(…): complete` commits at known times) and synthetic transcript JSONL lines: A4 before vs after the commit, an implementer dispatch present vs absent, an Opus vs non-Opus final review, "Rulings I made" present vs absent — each check seen failing and passing.
- Scenario 8 reads only its own run's transcripts (`$KDD_FLOW_USAGE/scenario-8-<arm>.transcripts`), never `$CONFIG_DIR/projects`, so scenarios 4–5 in the same invocation cannot leak into it.

## Acceptance Criteria
- [ ] Spec AC6's harness part (scenario exists, opt-in, the checks).

## Test Plan
1. `bash tests/scripts/test-flow-harness.sh`; 2. `bash tests/scripts/run.sh`.
