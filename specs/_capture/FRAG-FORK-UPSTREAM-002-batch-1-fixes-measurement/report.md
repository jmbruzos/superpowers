# Batch 1 (upstream fixes) — level 1, before 0.6.1 vs after 0.7.1 / 0.7.2, scenarios 1–7 (2026-10-18)

Measurement report for WRK-SPEC-FORK-UPSTREAM-002. Pre-registration and its
three amendments: `raw/preregistration.md`. Not code-derived: no anchors.

## Method

- **Before:** the two Opus passes of FRAG-FORK-UPSTREAM-001 (skills of 0.6.0
  = 0.6.1), not copied here.
- **After:** scenarios 1–4 and 7 from two passes at `kdd-superpowers--v0.7.1`
  (`45ce7e0`, epochs 1792323821 and 1792325629); scenarios 5 and 6 from two
  passes at `kdd-superpowers--v0.7.2` (`6f457a7`, epochs 1792329540 and
  1792329969) — amendment 3: 0.7.2 changes only `code-reviewer.md`, which only
  scenarios 5 and 6 load.
- **Fixed:** toolkit 1.13.0, Claude Code 2.1.302, Opus 5.5, harness and
  fixtures of the measuring commit copied into each arm.
- **Confounds:** the after passes ran with a later harness than the before
  passes: scenario 4's prompt gained "I approve the saved plan in advance and
  will not review it" and two checks (activation, `plan(` commit), so 0.7.1
  passes report 49 checks against 47 (`b6cbc2a` vs `155d911`); scenario 4's
  cost is not attributed to batch 1. The 0.7.2 passes overlapped batch 2's
  level-1 runs in time: their wall times are inflated, tokens and cost are not.
- **Discarded:** none. The two passes at `kdd-superpowers--v0.7.0` are kept as
  the observation that found regression 1 (`raw/after-070-r*-checks.log`), not
  as the after arm.

## Observed — regressions found and fixed during the measurement

1. **0.7.0 injected nothing at session start.** Scenario 1 failed in both
   0.7.0 passes (both before passes pass). Under Claude Code the hook command
   runs through `/bin/sh` (macOS: bash in POSIX mode, `BASH=/bin/sh`); upstream
   7.0's `run-hook.cmd` exec'd `$BASH`, so `session-start` ran in POSIX mode
   and stopped at a syntax error. Reproduced with an instrumented hook under
   headless Claude Code; fixed in `a37a90c` (0.7.1).
2. **The code reviewer's report was cut by the safety classifier.** Scenario 6
   failed in 0.7.1 pass 1. Diagnostics (`raw/scenario6-diagnostics.txt`):
   reviewer transcripts with `stop_reason: refusal` in 4 of 11 scenario-6 runs
   at 0.7.1 and 0 of 8 at 0.6.1; with only upstream's "Declined to judge"
   section added 5 of 5 (4 scenario failures), with only the "spec is a vision
   document" section 0 of 5. Removed in `d7c4d11` (0.7.2).

## Observed — checks (deciding)

| Scenario | Before (0.6.1) r1 / r2 | After r1 / r2 |
|---|---|---|
| 1 toolkit missing | pass / pass | pass / pass (0.7.1) |
| 2 bounded, knowledge base | pass / pass | pass / pass (0.7.1) |
| 3 no specs/, FRAG | pass / pass | pass / pass (0.7.1) |
| 4 writing-plans | pass / pass | pass / pass (0.7.1, two extra checks pass too) |
| 5 SDD | pass / pass | pass / pass (0.7.2) |
| 6 code review | pass / pass | pass / pass (0.7.2, no refusal) |
| 7 architectural | pass / pass | pass / pass (0.7.1) |

## Observed — usage (cost USD, r1 / r2)

| Scenario | Before | After |
|---|---|---|
| 2 | 0.56 / 0.48 | 0.55 / 0.59 |
| 3 | 0.64 / 0.63 | 0.52 / 0.56 |
| 4 | 1.73 / 1.61 | 2.00 / 1.88 (prompt confound) |
| 5 | 1.93 / 1.75 | 1.56 / 1.88 |
| 6 | 0.48 / 0.51 | 0.52 / 0.54 |
| 7 | 1.89 / 2.37 | 2.41 / 1.89 |
| **2–7** | **7.23 / 7.35** | **7.56 / 7.34** |

Turns, output tokens and wall time per run are in the JSON files.

## Inferred

- **Not worse** under the pre-registered rule: every check that passes in both
  before passes passes in both after passes (resting on the checks table and
  amendments 2–3). Cost moved +4.5 % / −0.1 % in total, inside the before
  spread for every scenario but 4, whose prompt changed between the passes.
- Both regressions were invisible to the deterministic suites: the hook test
  ran the wrapper under `/bin/bash`, and no test can see a classifier. Only
  the headless level-1 runs found them — the protocol's purpose.
