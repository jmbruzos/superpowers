---
id: WRK-TASK-FORK-UPSTREAM-003-003
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Scenario-4 plan metrics in the harness"
parent: WRK-PLAN-FORK-UPSTREAM-003
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-003
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T11:53:39+02:00 }
stale_after: 2027-01-16T11:53:39+02:00
tags: [fork, upstream, writing-plans, task]
---

# WRK-TASK-FORK-UPSTREAM-003-003 — Scenario-4 plan metrics and checks in the harness

## Objective

Measure what batch 2 claims to change, the same way on both arms: a deterministic script computes, for a WRK-PLAN and its WRK-TASKs, the implementation-code share, the proportion against the WRK-SPEC, and the Review Focus form. Scenario 4 of `test-kdd-flow.sh` prints it, records it beside the run's usage, approves the saved plan in its prompt, and checks the activation commit.

## Implementation Notes

**Files:** Create `tests/claude-code/plan-metrics.mjs`, `tests/scripts/test-plan-metrics.sh`. Modify `tests/claude-code/test-kdd-flow.sh` (scenario 4).

**Interfaces:** Produces `node tests/claude-code/plan-metrics.mjs <WRK-PLAN file>` → one JSON line on stdout: `{"plan":"<ID>","tasks":<n>,"impl_code_share":<0..1, 3 decimals>,"proportion":<number, 2 decimals>,"review_focus":"absent"|"lines:<n>"|"none-per-class:<n>"|"none-bare"}`; exit 2 on usage, 3 when the file has no `layer: work-plan` frontmatter. Tasks are the `*.md` files in the plan's directory whose frontmatter `parent:` is the plan's `id:`; the spec is the file there whose `id:` is the plan's `parent:`.
- `impl_code_share`: per WRK-TASK, the lines of fenced blocks (delimiters included, at any indentation) that follow a step line — `- [ ] **Step …**` — whose title contains "implement" (case-insensitive) and not "test", up to the next step line; divided by the task's body lines (frontmatter excluded); mean over the tasks.
- `proportion`: (plan body lines + Σ task body lines) / spec body lines.
- `review_focus`: the plan's `## Review Focus` section — `absent`; `none-per-class:<n>` when its first non-empty line starts `none — every input class` and `<n>` ≥ 1 `- ` bullets follow; `none-bare` when it starts `none` otherwise; `lines:<n>` counting `- ` bullets.

**Premises:** frontmatter is the block between the first two `---` lines (as `brief-lib.mjs` `parseFrontmatter`); scenario 4's plan is found with the glob `$p4/specs/work/WRK-PLAN-BILL-PRORATA-*.md` (`test-kdd-flow.sh:111`); real fork tasks title steps "Step 3: Write the failing unit tests", "Step 4: Implement …" (FRAG-FORK-GATES-004 `raw/K5-bundle.txt:1993, 2891`), so the step number cannot identify the implementation step.

- [ ] **Step 1: Write the failing test** — `tests/scripts/test-plan-metrics.sh`:
  - `hello-plan` fixture plan → `impl_code_share` > 0 (its "Step 3: Minimal implementation" carries code), `review_focus` `absent`;
  - `rounding-plan` fixture plan → `impl_code_share` = 0 (its "Step 3: Implement …" has no fence);
  - a temp plan copy whose task has "Step 3: Write the failing unit tests" with a fenced test and "Step 4: Implement `f`" with a two-space-indented fenced body of 4 lines → only the Step-4 fence is counted;
  - Review Focus variants in temp copies: two bullets → `lines:2`; `none — every input class the spec implies is tested:` + one bullet → `none-per-class:1`; `none` alone → `none-bare`;
  - a non-plan file → exit 3; no arguments → exit 2.
- [ ] **Step 2: Run it** — `bash tests/scripts/test-plan-metrics.sh` → Expected: FAIL (script missing).
- [ ] **Step 3: Implement `plan-metrics.mjs`** (Node ESM, no dependencies).
- [ ] **Step 4: Wire scenario 4** —
  - prompt, both arms: after "Two tasks are enough." add "I approve the saved plan in advance and will not review it." (the before arm's skill ignores it; the after arm's needs it — WRK-SPEC component 7);
  - after its checks: `plan4="$(ls "$p4"/specs/work/WRK-PLAN-BILL-PRORATA-*.md 2>/dev/null | head -1)"`; `echo "  plan-metrics: $(node "$SCRIPT_DIR/plan-metrics.mjs" "$plan4")"`; with `KDD_FLOW_USAGE` set, the same line to `$KDD_FLOW_USAGE/scenario-4.plan-metrics.txt` (`.txt`: `usage-summary.py` reads every `*.json` there as a run result);
  - new checks: the plan and every task are `status: active`; `git log` has a commit whose subject starts `plan(WRK-PLAN-BILL-PRORATA-` (`grep -c … >/dev/null`, no `grep -q` in a pipe).
- [ ] **Step 5: Run** — `bash tests/scripts/run.sh`; `bash -n tests/claude-code/test-kdd-flow.sh` → Expected: `ok`, syntax clean.
- [ ] **Step 6: Commit** — `test(WRK-TASK-FORK-UPSTREAM-003-003): plan metrics and activation checks for scenario 4`.

## Acceptance Criteria

- [ ] The metrics spec AC4 and the pre-registration rely on exist, are deterministic and tested on full-code, lean, fork-shaped and indented tasks and on every Review Focus form.
- [ ] Scenario 4 checks activation and commit on both arms.

## Test Plan

1. `bash tests/scripts/test-plan-metrics.sh`; 2. `bash tests/scripts/run.sh`.
