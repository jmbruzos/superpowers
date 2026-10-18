# Batch 3 (Native execution) — level 1, before 0.8.0 vs candidate 1af79fe (2026-10-18)

Measurement report for WRK-SPEC-FORK-UPSTREAM-004. Pre-registration:
`raw/preregistration.md` (`a4eae76`, 2026-10-18 21:50:44 +0200, before any
after-run); amendment 1 (`de07f42`, decision log H-8: level 2b dropped by the
human, written while level 1 was running and changing nothing in it). Not
code-derived: no anchors.

## Method

- **Before:** `kdd-superpowers--v0.8.0` (`8e799d6`), detached worktree.
- **After (candidate):** `1af79fe` — tasks 001–004 and the final review's fix
  pass, detached worktree.
- **Fixed:** toolkit 1.13.0 (CLI and plugin root), Claude Code 2.1.302,
  `--model opus`; both arms run the candidate's harness
  (`test-kdd-flow.sh`, `scenario8-checks.sh`, `toolkit-env.sh`,
  `usage-lib.sh`, `plan-metrics.mjs`, both fixture trees); runs in sequence
  (`raw/chain3.sh`, start/end epochs in `raw/run-times.txt`; first run
  1792353799, last end 1792359762).
- **Order per round (×2):** scenario 8 inline-old (0.8.0) → native → sdd
  (candidate) → scenarios 4–5 on 0.8.0 → on the candidate.
- **Discarded:** none. No scenario-5 reviewer transcript holds
  `stop_reason: refusal` (0/4).

## Observed — checks

| Run | r1 | r2 |
|---|---|---|
| Scenario 8 **native** (deciding 1) | 11/11 | 11/11 |
| Scenario 8 sdd | 12/12 | 12/12 |
| Scenario 8 inline-old (0.8.0) | 7/9 — "A4 dispatched", "A4 before the task-001 complete commit" fail | 7/9 — same two |
| Scenarios 4–5, 0.8.0 | 16/16 | 16/16 |
| Scenarios 4–5, candidate (deciding 2) | 16/16 | 16/16 |

## Observed — usage (cost USD / turns / wall s)

| Run | r1 | r2 |
|---|---|---|
| s8 native | 2.59 / 4 / 90 | 2.07 / 34 / 435 |
| s8 sdd | 2.89 / 18 / 432 | 2.76 / 17 / 427 |
| s8 inline-old | 0.76 / 25 / 144 | 0.74 / 26 / 214 |
| s4, 0.8.0 | 1.33 / 20 / 279 | 1.40 / 17 / 349 |
| s4, candidate | 1.69 / 23 / 393 | 1.50 / 29 / 368 |
| s5, 0.8.0 | 1.77 / 39 / 389 | 1.69 / 36 / 376 |
| s5, candidate | 1.92 / 35 / 406 | 1.70 / 31 / 328 |

Native r1's `result.json` reports 4 turns and 90 s for a run whose
transcripts show both tasks, A4 and the final review; its cost is in line
with r2. The turn and wall figures of that one file are not read.

## Inferred

- **Not worse:** the native arm passes every scenario-8 check in both runs,
  and no scenario-4/5 check that passes at 0.8.0 fails on the candidate.
  Release 0.9.0 (amendment 1: no level 2b).
- **Cost:** scenarios 4+5 summed per run 3.10 / 3.09 → 3.61 / 3.20 USD
  (+10 %); scenario 4 alone +17 % with non-overlapping ranges, scenario 5
  +5 % overlapping — under the +20 % rule. Scenario 4 drives the changed
  handoff (two modes and a per-plan recommendation).
- **Modes on the fixture:** Native 2.07–2.59 USD vs SDD 2.76–2.89 — about
  20 % cheaper with the same gates passing; the old inline stub is cheapest
  (0.74–0.76) because it runs no A4 and no fresh final review, which the
  checks show.
- Gate (b) (knowledge check after a `Knowledge gap:` ruling) is not
  reachable by this fixture; it was observed in task 002's pressure test
  (commit `b63e2ea`), not here.
