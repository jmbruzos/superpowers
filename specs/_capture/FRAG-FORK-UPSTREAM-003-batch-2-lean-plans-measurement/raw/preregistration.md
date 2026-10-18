# Pre-registration — upstream sync batch 2 (WRK-SPEC-FORK-UPSTREAM-003), levels 1 and 2

Written 2026-10-18, before any after-run. Protocol: DOC-FORK-UPSTREAM-001 §4;
plan WRK-PLAN-FORK-UPSTREAM-003, task 004.

## Arms

- **Before:** `kdd-superpowers--v0.7.0`.
- **After:** the release candidate `4838e16` (tasks 001–003 complete; not
  tagged — 0.8.0 is tagged only if the batch is not worse, task 004 Step 5).
- **Fixed:** kdd toolkit 1.13.0 (CLI and plugin root pinned), the Claude Code
  version recorded per run, `--model opus` (`KDD_FLOW_MODEL=opus`; level 2:
  `MODEL=opus`), runs in sequence, alternating before/after. Both arms get the
  harness of `4838e16`: `tests/claude-code/test-kdd-flow.sh`, `toolkit-env.sh`,
  `plan-metrics.mjs`, `tests/claude-code/fixtures`, `tests/scripts/fixtures`.
  The scenario-4 prompt (harness) approves the saved plan in advance in both
  arms.

## Level 1 — fixture (scenarios 4, 5, 6; n=2 per side)

- **Deciding:**
  1. `impl_code_share` of scenario 4's plan (from `plan-metrics.mjs`) is lower
     in both after runs than in both before runs.
  2. Every scenario-4, -5, -6 check that passes in both before runs passes in
     both after runs; the scenario-4 checks include the new activation and
     `plan(` commit checks.
  3. Both after-run WRK-PLANs have a `## Review Focus` section reading
     `lines:<n≥1>` or `none-per-class:<n≥1>` (spec AC4).
- **Reported:** `proportion`, turns, output tokens, `total_cost_usd`, wall
  time, per scenario and arm.

## Level 2 — real task (RFC-PIPE-039 at mdm-platform `aacdae5`; B1 A1 B2 A2)

- Pre-flight: `spec-graph validate` with toolkit 1.13.0 over mdm-platform's
  specs at `aacdae5`, recorded in the report.
- Prompt: `tests/claude-code/ab/prompts/k-task.txt` + `k-wait.txt`, identical
  on both arms.
- Judges: evidence judge and neutral summary per run (prompts in
  `tests/claude-code/ab/prompts/`, paths substituted only), one blind H1–H10
  pass over the four summaries under shuffled codes.
- **Deciding:**
  1. Plan executability (evidence judge, item 3: tasks without a runnable
     test step, invalid task order, files or symbols that do not exist):
     the after arm's mean count of defects is not higher than the before
     arm's.
  2. False claims about current code in the plan and tasks (evidence judge,
     item 1): the after arm's mean per run is not 2 or more above the before
     arm's.
- **Reported:** plan + tasks length (lines and `proportion`), output tokens,
  `total_cost_usd`, turns, wall time, H1–H10 per run, knowledge violations.

## Worse, cost, decision

- Worse = a deciding metric above fails, or a behaviour check passes before
  and fails after (DOC-FORK-UPSTREAM-001 §4). Worse → rework or revert, no
  release.
- A cost rise above 20 % with non-overlapping ranges (per level, summed per
  run) → no release until the human accepts it.
- Runs lost to authentication or network errors are set aside by name and
  repeated, never averaged.

## Amendment 1 — before any after-run (2026-10-18)

`kdd-superpowers--v0.7.0` injects nothing under Claude Code (its hook
wrapper runs `session-start` in POSIX mode; batch-1 FRAG-FORK-UPSTREAM-002),
so it cannot be a before arm. Therefore:

- **Before:** `kdd-superpowers--v0.7.1` (`45ce7e0`: 0.7.0 + the wrapper fix).
- **After:** the feature-branch commit that holds batch 2's tasks 001–003
  plus the same wrapper fix (named by sha in the report; candidate
  `4838e16` + `a37a90c`). The release, if any, is cut the same way as 0.7.1:
  only these changes on top of the before tag.
- Everything else above stands.

## Amendment 2 — written after after-run 1 had executed, before its result was read (2026-10-18)

Both arms (0.7.1 and the candidate) still carry the reviewer's "Declined
to judge" section, which makes the safety classifier cut the reviewer in
about a third of scenario-5/6 runs (batch-1 FRAG, amendment 3). The batch-2
comparison stays valid (the same section in both arms), but a cut is not a
batch-2 effect. Therefore: a scenario-5 or -6 run whose reviewer transcript
has `stop_reason: refusal` is classified **cut**, set aside by name like a
network loss, and repeated on the same arm until each arm has two uncut runs
of that scenario. Scenario 4 and the level-2 runs are unaffected. The
release, if any, is built on `kdd-superpowers--v0.7.2`.

## Amendment 3 — counting rule for level-2 deciding metric 1, written after the four evidence-judge reports were read, before any count was made by the adjudicator (2026-10-18)

The pre-registration names the defect kinds but not how to count them, and
the four judge reports describe them in free text. A separate adjudicator
counts them from the four reports under neutral codes (key kept apart),
with this rule, fixed now:

- A defect is (a) a task without a runnable test step; (b) an invalid task
  order (a task uses what a later task creates); or (c) a step that, as
  written, names a file, type, method, overload, field, variable or accessor
  that does not exist at that point (neither in the code at `aacdae5` nor
  created by an earlier step), or that would not compile as written.
- Each distinct step counts once. Not counted: wrong line anchors, wrong
  descriptions of behaviour, design disagreements, knowledge violations,
  and an acceptance check that fails because the design is incomplete.

A provisional count by the controller, made while writing this rule from
the reports, already put the after arm above the before arm; the rule was not
chosen to favour either arm.
