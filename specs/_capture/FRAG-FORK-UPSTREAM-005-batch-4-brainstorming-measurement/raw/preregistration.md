# Pre-registration — upstream sync batch 4 (WRK-SPEC-FORK-UPSTREAM-005), levels 1 and 2

Written 2026-10-19, before any after-run. Protocol: DOC-FORK-UPSTREAM-001 §4
as narrowed by the human (decision log H-8); plan WRK-PLAN-FORK-UPSTREAM-005,
task 004; ledger ruling R1.

## Arms

- **Before:** `kdd-superpowers--v0.9.0` (`598c1bd`).
- **After (candidate):** the feature-branch commit after tasks 001–003 and the
  final whole-branch review's fix pass, named by sha in the report. The
  release, if any, is cut on the before tag with batch 4's commits only.
- **Fixed:** toolkit 1.13.0, the Claude Code version recorded per run,
  `--model opus`, runs in sequence; both arms run the candidate's harness
  and fixtures.

## Level 1 — fixture (n=1 per side, H-8)

- Scenarios 1, 2, 3, 7, 9 on 0.9.0, then on the candidate.
- **Deciding:** (1) every check that passes on 0.9.0 passes on the
  candidate — a failure on the candidate of a check that passed on 0.9.0 is
  re-run once on both arms and decides on the pair; (2) scenario 9 routes to
  `kdd:spec-ask` on the candidate. Scenario 9 on 0.9.0 is a regression
  reference: a pass there credits nothing to the new row.
- **Reported:** cost, turns, output tokens, wall time per scenario.

## Level 2 — real task (RFC-PIPE-039 at mdm-platform `aacdae5`)

- B1 A1 B2 A2 with `tests/claude-code/ab/run-one.sh` and the same prompt;
  pre-flight `spec-graph validate` (toolkit 1.13.0) saved to
  `raw/mdm-preflight.txt`.
- Evidence judge per run (`tests/claude-code/ab/prompts/evidence-judge.txt`,
  paths substituted; full return also written to a file). No neutral
  summaries, no blind H1–H10 pass (H-8).
- **Deciding:** (1) false claims about current code: the after mean is not
  2 or more above the before mean; (2) executability defects, counted under
  FRAG-FORK-UPSTREAM-003 amendment 3's rule by a separate adjudicator over
  the four reports under neutral codes: the after mean is not higher than
  the before mean.
- **Reported:** design-changing false claims, knowledge violations, plan +
  tasks length, cost, turns, wall time.

## Worse, cost, decision

- Worse = a deciding metric fails. Held for the human's ruling, not
  reworked or released on the agent's ruling alone (task 004 amendment).
- Cost above +20 % with non-overlapping ranges (level 2, per run) → held for
  the human.
- Not worse → release 0.10.0; then the sync's closing steps and publishing
  (decision log H-9).
