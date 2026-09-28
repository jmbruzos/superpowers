# Token usage before and after WRK-SPEC-FORK-GATES-001 — headless runs, 2026-09-28

Measurement report. Not code-derived: no anchors. Every number is read from a
`claude -p --output-format json` result kept verbatim under `raw/`.

## Method

- Claude Code 2.1.283, headless (`claude -p`), authentication via
  `CLAUDE_CODE_OAUTH_TOKEN`, `--allowed-tools=all`,
  `--permission-mode bypassPermissions`, isolated `CLAUDE_CONFIG_DIR`,
  `--plugin-dir` this repo and the `kdd` toolkit 1.6.0.
- Before: skills at `f8d369c` (`.worktrees/before`, gitignored, removed after
  the runs). After: skills at `2e935eeb8718e3f3bd2371c1f83868a00e0fdde1` (HEAD
  of this task's base).
- The harness that ran the before-worktree's scenario was HEAD's
  `tests/claude-code/test-kdd-flow.sh` (the timeout fallback added by task
  006), copied into the worktree; the skills under test were the worktree's
  own, at `f8d369c`.
- Scenario 4 (writing-plans, 2 tasks, gate A2) three times per side — the
  planned two runs left the cost/output spread on the before side wider than
  the before/after difference, so a third pair was run on both sides per
  DOC-FORK-TOKENS-001 §How to measure. Scenario 7 (architectural
  brainstorming, premise verifier, gate A1) after only — it does not exist
  before this change.
- Discarded runs, not counted: one scenario-7 run where the headless session
  was not logged in (`.kdd/usage/failed-auth-s7`); one scenario-7 run and one
  before-s4 run lost to a transient "Can't reach the API server (ENOTFOUND)"
  (`.kdd/usage/failed-net-s7`, `.kdd/usage/failed-net-before-s4`); one earlier
  scenario-7 run that finished 11/12 and exposed an assertion defect in the
  test harness, fixed in `37d36e1` (`.kdd/usage/after-s7-run1`).

## Observed

| Run | Scenario | Turns | Cache write | Cache read | Output | Cost | Duration |
|---|---|---|---|---|---|---|---|
| before-s4-1 | s4 writing-plans + A2 | 47 | 105.6k | 3347.0k | 61.1k | $2.01 | 650s |
| before-s4-2 | s4 writing-plans + A2 | 44 | 115.9k | 3172.4k | 68.4k | $2.06 | 732s |
| before-s4-3 | s4 writing-plans + A2 | 44 | 80.8k | 2369.1k | 44.9k | $1.53 | 631s |
| after-s4-1 | s4 writing-plans + A2 | 50 | 98.8k | 3434.5k | 55.9k | $1.92 | 1222s |
| after-s4-2 | s4 writing-plans + A2 | 50 | 113.4k | 3913.1k | 64.8k | $2.28 | 860s |
| after-s4-3 | s4 writing-plans + A2 | 52 | 106.1k | 3735.1k | 65.3k | $2.17 | 708s |
| after-s7 | s7 architectural brainstorming, premise verifier + A1 | 36 | 89.7k | 1895.4k | 43.9k | $1.55 | 495s |

(Source: `python3 tests/claude-code/usage-summary.py <dir>` for each directory
in `.kdd/usage/`, top-line row.)

## Observed — spread

| Side | Scenario | Cost min–max | Output min–max |
|---|---|---|---|
| before | s4 | $1.53–$2.06 (Δ$0.53) | 44.9k–68.4k (Δ23.5k) |
| after | s4 | $1.92–$2.28 (Δ$0.36) | 55.9k–65.3k (Δ9.4k) |

Before mean cost $1.87, after mean cost $2.12 (Δ$0.26); before mean output
58.1k, after mean output 62.0k (Δ3.9k). Both deltas are smaller than the
before side's own spread ($0.53, 23.5k) and the output delta is smaller than
either side's spread.

## Observed — gate tables in the runs

A2 closing line, `grep -ohE '[0-9]+ attempted, [0-9]+ BROKEN( \([^)]*\))?' <dir>/scenario-4.transcripts/*.jsonl`:

- before-s4-1: `13 attempted, 10 BROKEN`
- before-s4-2: `10 attempted, 8 BROKEN`
- before-s4-3: `10 attempted, 6 BROKEN`
- after-s4-1: `13 attempted, 9 BROKEN (code-reality 1 · spec-rule 2 · ambiguity 2 · knowledge-gap 3 · internal 1)`
- after-s4-2: `12 attempted, 7 BROKEN (code-reality 0 · spec-rule 1 · ambiguity 3 · knowledge-gap 3 · internal 0)`
- after-s4-3: `13 attempted, 7 BROKEN (code-reality 1 · spec-rule 1 · ambiguity 3 · knowledge-gap 2 · internal 0)`

The before format has no Cause breakdown; it did not exist before this
plan. A1 closing line, same grep against `scenario-7.transcripts/*.jsonl`:

- after-s7: `13 attempted, 12 BROKEN (code-reality 3 · spec-rule 1 · ambiguity 2 · knowledge-gap 3 · internal 3)`

## Inferred

- On this scenario (a trivial 2-task plan) the cost and output-token
  difference between before and after is inside the before side's own
  run-to-run spread; three runs per side do not separate a skill-level
  effect from ordinary variance here. This measurement does not show a
  saving or a cost from the gate tuning on scenario 4 — it neither confirms
  nor refutes DOC-FORK-TOKENS-001's Method item 4 (output tokens as the
  expensive line) at this task size (rests on: Observed, Observed — spread).
- The A2 closing line now carries a Cause breakdown in every after run,
  which the before format lacked; this is a qualitative gain in what the
  gate records, not a token saving (rests on: Observed — gate tables).
- Scenario 7 has no before counterpart (the premise verifier and gate A1 on
  a written WRK-SPEC did not exist before this plan), so its numbers are a
  first sample, not a before/after comparison (rests on: Observed, after-s7
  row).
- Detail-cap and Cause-breakdown additions to the A1/A2 prompts did not
  visibly change scenario 4's turn count (44-47 before, 50-52 after is a
  4-8 turn shift, itself inside the noise these gates already show run to
  run) (rests on: Observed, Turns column).
