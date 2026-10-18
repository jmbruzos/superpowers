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
