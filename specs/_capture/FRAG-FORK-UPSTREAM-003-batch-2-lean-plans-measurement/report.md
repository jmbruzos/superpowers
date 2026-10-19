# Batch 2 (lean plans) — levels 1 and 2, before 0.7.1 vs candidate vs reworked candidate (2026-10-18)

Measurement report for WRK-SPEC-FORK-UPSTREAM-003. Pre-registration and its
four amendments: `raw/preregistration.md` (`7e206c9` 12:15:38 +0200, before
any after-run; amendments `b6cbc2a`, `e67c665`, `c2f6dbd`, `e0d4928`). Not
code-derived: no anchors.

## Method

- **Before:** `kdd-superpowers--v0.7.1` (amendment 1).
- **After (candidate):** `b6cbc2a` — batch 2 tasks 001–003 + the 0.7.1 hook
  fix; still carries the reviewer's "Declined to judge" section, as the
  before arm does (amendment 2).
- **After′ (reworked candidate):** `b6cbc2a` + `60bfc23` cherry-picked
  (`1404006`, detached worktree) — amendment 4.
- **Fixed:** toolkit 1.13.0 (CLI and plugin root), Claude Code 2.1.302 on
  every run, `--model opus`, the harness and fixtures of the measuring commit
  copied into each arm, runs in sequence.
- **Order and times (epoch):** level 1 before r1 1792327438, after r1
  1792328420, before r2 1792329315, after r2 1792330243; level 2 B1
  1792331029, A1 1792333530, B2 1792336331, A2 1792338951; reworked level 1
  r1 1792342079, A3 1792342468, level 1 r2 1792344917, A4 1792345365.
- **Pre-flight:** `spec-graph validate` on mdm-platform `aacdae5` with toolkit
  1.13.0 — "Validation passed. No issues found. Checked 279 specs, 1431
  edges." (`raw/mdm-preflight.txt`).
- **Judges:** evidence judge per run, neutral summary per run, blind H1–H10
  — prompts of `tests/claude-code/ab/prompts/`, paths substituted. Two
  further changes, neither touching what is judged: the blind prompt names
  four (pass 1) and six (pass 2) summaries instead of nine; the judges after
  A2 were asked to also write their full return to a file, because results
  were being truncated in transit (A2's judge was asked after the fact).
  Executability defects were counted by a separate adjudicator under neutral
  codes with amendment 3's rule — once over the four first reports, once over
  all six (keys in `raw/*-key.txt`).
- **Discarded:** by amendment 2, scenario-6 runs whose reviewer transcript
  holds `stop_reason: refusal` — before r2 (1 refusal, checks passed) and
  after r1 (2 refusals, 3 checks failed) — set aside and repeated once each
  (`raw/l1-*-s6-repeat-*`), both clean.
- **Confounds:** the reworked arm ran 3–4 hours after the before arm; its
  before comparison is the same B1/B2 and level-1 before runs (amendment 4).
  `plan-metrics` before `60f74f1` read after r1's numbered Review Focus as
  `lines:0`; rebuilt from the transcript and re-read with the fixed reader,
  it has 5 lines (decision log U-21 said 4: corrected here).

## Observed — level 1 (fixture, scenarios 4–6)

| | before r1 / r2 | after r1 / r2 | after′ r1 / r2 (scenario 4 only) |
|---|---|---|---|
| `impl_code_share` (deciding 1) | 0.206 / 0.196 | 0 / 0.033 | 0.022 / 0 |
| Review Focus (deciding 3) | absent / absent | lines:5 (read as 0 before the fix) / lines:5 | lines:5 / lines:2 |
| `proportion` | 12.5 / 13.79 | 10.07 / 9.68 | 11.32 / 9.36 |
| Checks, scenarios 4–6 (deciding 2) | 19/19 / 19/19 | 19/19 after the s6 repeat / 19/19 | scenario 4: 8/8 / 8/8 |
| Scenario 4 cost USD | 1.85 / 1.83 | 1.83 / 1.29 | 1.65 / 1.65 |
| Scenario 5 cost USD | 1.60 / 1.89 | 1.58 / 1.51 | — |
| Scenario 6 cost USD (uncut) | 0.50 / 0.52 | 0.51 / 0.54 | — |

## Observed — level 2 (RFC-PIPE-039 at mdm-platform `aacdae5`)

| Run | Arm | Tasks | Bundle lines | Turns | Output tokens | Cost USD | Wall min |
|---|---|---|---|---|---|---|---|
| B1 | before | 4 | 2393 | 117 | 159 523 | 17.16 | 41 |
| B2 | before | 5 | 2553 | 107 | 166 620 | 17.63 | 43 |
| A1 | after | 7 | 1725 | 117 | 153 103 | 15.70 | 46 |
| A2 | after | 6 | 1303 | 117 | 127 838 | 14.35 | 38 |
| A3 | after′ | 5 | 1290 | 118 | 140 279 | 14.42 | 40 |
| A4 | after′ | 4 | 1202 | 98 | 134 285 | 13.99 | 38 |

| Run | Claims | FALSE (design-changing) | UNVERIF. | Violations | Defects, adjudication 1 | Defects, adjudication 2 | H1–H10 C/W/N pass 1 | pass 2 |
|---|---|---|---|---|---|---|---|---|
| B1 | 55 | 3 (0) | 1 | 5 | 1 | 1 | 8/1/1 | 7/2/1 |
| B2 | 65 | 6 (1) | 0 | 3 | 1 | 1 | 6/2/2 | 5/3/2 |
| A1 | 55 | 2 (0) | 0 | 5 | 2 | 3 | 6/2/2 | 7/1/2 |
| A2 | 48 | 2 (0) | 0 | 3 | 2 | 2 | 6/1/3 | 6/2/2 |
| A3 | 60 | 2 (0) | 1 | 5 | — | 0 | — | 10/0/0 |
| A4 | 67 | 5 (1) | 4 | 4 | — | 0 | — | 7/1/2 |

Defects counted: B1 a missing import; B2 a javadoc link to a type a later
task creates; A1 a nonexistent 6-arg overload, a helper shadowing a static
import, undefined sketch variables; A2 nonexistent accessors, a nonexistent
local. A3/A4: none under the rule (A4 has a test asserting a raw override
value the code normalizes — wrong behaviour, not counted).

## Observed — verdict per deciding metric

| Metric | after (candidate) | after′ (reworked) |
|---|---|---|
| L1-1 `impl_code_share` lower in both runs | pass | pass |
| L1-2 checks 4–6 | pass | pass (scenario 4 re-run; 5–6 unchanged skill) |
| L1-3 Review Focus present | pass | pass |
| L2-1 executability defects mean not higher (before 1.0) | **fail** (2.0; 2.5 in adjudication 2) | pass (0) |
| L2-2 false claims not ≥ 2 more (before 4.5) | pass (2.0) | pass (3.5) |
| Cost not > +20 % | pass (lower) | pass (lower) |

## Inferred

- **The candidate as first measured was worse** (L2-1) and was not released
  (decision log U-22). **The reworked candidate is not worse** on any
  deciding metric and cheaper on both levels: release 0.8.0 with `60bfc23`.
- The rework's cause attribution is weak: n=2 per arm, counts of 0–3, and
  the adjudicator's own count of A1 moved 2 → 3 between passes. The reading
  that holds is the shape: every after-arm defect was test code naming
  something absent, and after the rework none was counted.
- The blind pass is reported, not deciding; its scores moved by one point
  for the same summary between passes (B1 8 → 7, A1 6 → 7), the size of
  most differences here. A3's 10/10 is one run.
- Level 2 does not execute plans: batch 3's level 2b is the first execution
  of a lean plan from a real task.
