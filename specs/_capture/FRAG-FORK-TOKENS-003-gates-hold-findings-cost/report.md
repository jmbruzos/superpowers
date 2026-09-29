# Token usage before and after WRK-SPEC-FORK-GATES-002 — headless scenario 7, 2026-09-29

Measurement report. Not code-derived: no anchors. Every number is read from
a `claude -p --output-format json` result kept verbatim under `raw/`.

## Method

- **Tooling:** Claude Code 2.1.283, headless, isolated `CLAUDE_CONFIG_DIR`,
  authenticated with `CLAUDE_CODE_OAUTH_TOKEN`, kdd toolkit 1.6.0.
- **Scenario:** `tests/claude-code/test-kdd-flow.sh` scenario 7:
  architectural brainstorming on a small billing fixture with code and
  specs, up to the committed WRK-SPEC. It exercises the premise verifier and
  gate A1.
- **Before:** skills at `5ff773e` (0.3.0), taken from a worktree. The worktree
  used the current harness, copied in, so harness changes do not confound
  the skills under test.
- **After:** skills at `d8e82ee` (the WRK-SPEC-FORK-GATES-002 change).
- **Runs:** two per side, interleaved and one at a time (before-1, after-1,
  before-2, after-2).
- **Assertion results in the logs** come from the harness before commit
  `c11df88`, which fixed three transcript checks. Those failures are harness
  defects, not skill behaviour, and are not part of this measurement.

## Observed

| Run | Skills | Turns | Cache write | Cache read | Output | Cost | Duration |
|---|---|---|---|---|---|---|---|
| before-s7-1 | 0.3.0 | 44 | 87.8k | 2596.4k | 39.5k | $1.65 | 527 s |
| before-s7-2 | 0.3.0 | 49 | 101.8k | 2768.3k | 41.5k | $1.72 | 523 s |
| after-s7-1 | GATES-002 | 44 | 98.2k | 2603.4k | 44.6k | $1.86 | 604 s |
| after-s7-2 | GATES-002 | 42 | 97.1k | 2622.2k | 42.0k | $1.78 | 594 s |

## Observed — spread

| Side | Cost min–max | Output min–max | Duration min–max |
|---|---|---|---|
| before | $1.65–$1.72 (Δ$0.07) | 39.5k–41.5k | 523–527 s |
| after | $1.78–$1.86 (Δ$0.08) | 42.0k–44.6k | 594–604 s |

- **Cost:** mean $1.685 before and $1.82 after (+$0.135, +8 %).
- **Output tokens:** mean 40.5k before and 43.3k after (+2.8k, +7 %).
- **Duration:** mean 525 s before and 599 s after (+74 s, +14 %).
- The two sides do not overlap on any of these three metrics.

## Inferred

- **The change adds a small, consistent cost to architectural
  brainstorming.** It is about 8 % in cost and 14 % in wall time on this
  fixture. The ranges do not overlap on cost, output tokens or duration, and
  each difference exceeds either side's spread. The plausible sources are
  the design file the author writes and the verifier's extra extraction
  pass over it. n = 2 per side (rests on: Observed, Observed — spread).
- **The cost of the seat did not change.** Turns were similar: 42–44 after
  and 44–49 before. The added cost is in output and time, not in extra
  turns (rests on: Observed).
