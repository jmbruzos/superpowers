# Pre-registration — upstream sync batch 1 (WRK-SPEC-FORK-UPSTREAM-002), level 1

Written 2026-10-18, before any after-run. Protocol: DOC-FORK-UPSTREAM-001 §4.

## Arms

- **Before:** `kdd-superpowers--v0.6.1` (skills identical to 0.6.0). Its runs
  are the batch-0 baseline, FRAG-FORK-UPSTREAM-001: scenarios 1–7 × 2, with
  scenarios 4 and 5 re-run × 2 on the fixed harness (decision log U-7); the
  earlier scenario-4/5 figures are superseded, not averaged.
- **After:** `kdd-superpowers--v0.7.0` (this batch's release).
- **Fixed:** kdd toolkit 1.13.0 (CLI and plugin root pinned through
  `KDD_SPEC_GRAPH` / `KDD_TOOLKIT_DIR`), Claude Code 2.1.302, `--model opus`,
  runs in sequence, the harness `tests/claude-code/test-kdd-flow.sh` of the
  after commit copied into the before worktree.

## Hypotheses

1. No scenario check regresses: the hook change is invisible with a normal
   PATH (its KDD-ENVIRONMENT block is byte-identical to 0.6.0's, tested), and
   the prose additions (TDD paragraph, two code-reviewer sections, one
   kdd-conventions paragraph) add instructions without removing any.
2. Cost stays within the spread: the prose additions are about 0.6k tokens
   per load of the skills that carry them (TDD in scenario 5's implementers,
   code-reviewer in scenarios 5–6).

## Metrics

- **Deciding:** per scenario, every check that passed in both before runs
  must pass in both after runs. A check that fails in an after run where it
  passed in both before runs is a regression and needs a ruling. Checks that
  passed in only one before run are reported as unstable, not decisive.
- **Reported, not decisive** (a fix batch): turns, output tokens,
  `total_cost_usd`, wall time per scenario, each arm's range. A cost rise
  above 20 % with non-overlapping ranges is flagged for the human's
  acceptance (DOC-FORK-UPSTREAM-001 §4).

## Reading rule

Ranges of n=2 per side; a difference is claimed only where the ranges do not
overlap. Runs lost to authentication or network errors are set aside by
name and repeated, never averaged.

## Amendment 1 — before any after-run (2026-10-18)

The batch-0 baseline runs ran on `claude-sonnet-5-5`: `test-kdd-flow.sh`
passed no `--model` and the account default had moved from Opus. The harness
now pins `--model "$KDD_FLOW_MODEL"` (default `opus`, `155d911`). Therefore:

- **Before** is re-run in full on Opus: scenarios 1–7 × 2 at
  `kdd-superpowers--v0.6.1` with the current harness and fixtures copied in.
  The Sonnet runs are kept in FRAG-FORK-UPSTREAM-001 as supplementary data,
  not as an arm.
- **After** is scenarios 1–7 × 2 at `kdd-superpowers--v0.7.0` with the same
  harness copied in (the tag predates `155d911`).
- Everything else above stands.

## Amendment 2 — after the first after-runs, before the re-run (2026-10-18)

The two after-runs at `kdd-superpowers--v0.7.0` failed scenario 1 in both
(passed in both before runs): a regression by the deciding rule. Root cause,
reproduced: 0.7.0's `run-hook.cmd` exec'd `$BASH` (`/bin/sh` under Claude
Code on macOS), so `session-start` ran in POSIX mode and injected nothing.
Fixed in `a37a90c`, released as `kdd-superpowers--v0.7.1`. Therefore:

- The 0.7.0 after-runs are kept in the FRAG as the observation that found
  the regression; they are not the after arm.
- **After** is re-run at `kdd-superpowers--v0.7.1`: scenarios 1–7 × 2, same
  harness, same fixed conditions. **Before** stays the two 0.6.1 runs already
  taken.
- Deciding metric and reading rule unchanged.

(Note: the tag `kdd-superpowers--v0.7.1` is `45ce7e0` on `release/0.7.1` = `v0.7.0` + the fix + the bump only; a first tag at `b97cfef` on the feature branch also carried batch-2 commits and was deleted before any run used it.)

## Amendment 3 — after the 0.7.1 after-runs (2026-10-18)

The 0.7.1 after-runs failed scenario 6 in run 1 (passed in run 2). Cause,
measured: the reviewer's report is cut by the safety classifier
(`stop_reason: refusal`) when `code-reviewer.md` carries upstream's
"Declined to judge" section — 4 of 11 scenario-6 runs at 0.7.1, 0 of 8 at
0.6.1; bisection 5/5 with that section alone, 0/5 with the vision-document
section alone (`scratchpad` diagnostics, reported in the FRAG). Removed in
`d7c4d11`, released as `kdd-superpowers--v0.7.2` (`6f457a7`). Therefore:

- **After** for scenarios 1–4 and 7 stays the two 0.7.1 passes: the files
  those scenarios load are identical in 0.7.2 (the only change is
  `code-reviewer.md`, loaded by scenarios 5 and 6).
- **After** for scenarios 5 and 6 is re-run at 0.7.2, n=2.
- Deciding rule unchanged; the 0.7.1 scenario-5/6 runs and the diagnostics
  are reported as the evidence for the fix.
