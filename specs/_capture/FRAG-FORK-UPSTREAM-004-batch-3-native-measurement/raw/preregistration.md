# Pre-registration — upstream sync batch 3 (WRK-SPEC-FORK-UPSTREAM-004), levels 1 and 2b

Written 2026-10-18, before any after-run. Protocol: DOC-FORK-UPSTREAM-001 §4;
plan WRK-PLAN-FORK-UPSTREAM-004, task 005.

## Arms

- **Before:** `kdd-superpowers--v0.8.0` (`8e799d6`).
- **After (candidate):** the feature-branch commit after tasks 001–004 and the
  final whole-branch review's fix pass (named by sha in the report; `755887e`
  if the final review needs no fix). The release, if any, is cut as 0.8.0 was:
  only batch 3's commits on top of the before tag.
- **Fixed:** toolkit 1.13.0 (CLI and plugin root), the Claude Code version
  recorded per run, `--model opus` (`KDD_FLOW_MODEL=opus`), runs in sequence.
  Both arms get the candidate's harness: `tests/claude-code/test-kdd-flow.sh`,
  `scenario8-checks.sh`, `toolkit-env.sh`, `usage-lib.sh`, `plan-metrics.mjs`,
  `tests/claude-code/fixtures`, `tests/scripts/fixtures`.

## Level 1 — fixture

- Scenario 8 (rounding-plan fixture, stops before finishing), n=2 per arm,
  arms run alternately: `inline-old` on 0.8.0 (its executing-plans prompted to
  run inline without subagents), `native` on the candidate, `sdd` on the
  candidate.
- Scenarios 4 and 5, n=2 per release (0.8.0, candidate), alternating.
- **Deciding:**
  1. The `native` arm passes every scenario-8 check in both runs.
  2. Every scenario-4 and scenario-5 check that passes in both 0.8.0 runs
     passes in both candidate runs.
- **Reported, not deciding:** the `inline-old` and `sdd` arms' checks (an
  `inline-old` A4 failure is expected: its skill has no A4); cost, turns,
  output tokens, wall time per arm and scenario.
- A scenario-5 run whose reviewer transcript has `stop_reason: refusal` is
  set aside by name and repeated (batch-2 amendment 2's rule); runs lost to
  authentication or network errors likewise.

## Level 2b — real execution (indicative, n=1 per mode; §4)

- Plan: `WRK-PLAN-MDM-LOSING-MEMBER-001` as committed by batch 2's level-2
  run A3 (mdm-platform `f372785`, 5 tasks; the best-scored after-run plan:
  H1–H10 10/10, 0 executability defects — FRAG-FORK-UPSTREAM-003).
- Two runs on the candidate, in sequence, each from a fresh detached worktree
  of mdm-platform at `f372785`: Native, then Subagent-driven. Prompt: the plan
  is approved by the human (named), activate and execute it in the named
  mode, work on the current branch, stop after the final review and its fixes.
- **Reported (not deciding, n=1):** tasks completed; the final test command
  and its result; A4 dispatches and their order against each task's
  completion commit; implementer dispatches; final review model and
  findings; fix-pass result; "Rulings I made"; cost, turns, output tokens,
  wall time. Cost confirmed by the human in advance (decision log H-7).
- A Native run that skips a §3.4 gate the run shows was due (A4 on a task
  whose condition holds, the final review) is reported as a defect of the
  batch and enters the decision below even though level 2b does not decide
  by metric.

## Worse, cost, decision

- Worse = a level-1 deciding metric fails, or a level-2b Native run skips a
  due §3.4 gate. Worse → rework or revert, no release (DOC-FORK-UPSTREAM-001
  §4).
- Scenario 4/5 cost above +20 % with non-overlapping ranges → no release
  until the human accepts it.
- Not worse → release 0.9.0 after level 2b has run (spec AC7, AC9).
