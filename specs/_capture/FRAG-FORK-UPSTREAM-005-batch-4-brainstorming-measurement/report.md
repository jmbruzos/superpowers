# Batch 4 (brainstorming ideas and routing) — levels 1 and 2, before 0.9.0 vs candidate 0705247 (2026-10-19)

Measurement report for WRK-SPEC-FORK-UPSTREAM-005. Pre-registration:
`raw/preregistration.md` (`dfa6bb6`, 2026-10-19 00:04:25 +0200, before any
after-run), protocol narrowed by the human (decision log H-8; the WRK-SPEC's
measurement amendment `478133a`). Not code-derived: no anchors.

## Method

- **Before:** `kdd-superpowers--v0.9.0` (`598c1bd`), detached worktree.
- **After (candidate):** `0705247` — tasks 001–003 and the final review's
  fix pass (records only: pressure-test baselines, the spec amendment).
- **Fixed:** toolkit 1.13.0, Claude Code 2.1.302, `--model opus`, the
  candidate's harness and fixtures in both arms, runs in sequence
  (`raw/chain4.sh`; epochs in `raw/run-times.txt`, first start 1792361812,
  last end 1792372328).
- **Level 1:** scenarios 1, 2, 3, 7, 9, n=1 per side. **Level 2:** RFC-PIPE-039
  at mdm-platform `aacdae5`, B1 A1 B2 A2; pre-flight `spec-graph validate`
  "Validation passed. No issues found. Checked 279 specs, 1431 edges."
  (`raw/mdm-preflight.txt`); one evidence judge per run (opus, prompt paths
  substituted, full return also written to a file); executability defects
  counted by a separate adjudicator under neutral codes (key in
  `raw/l2-exec-adjudication-key.txt`) with FRAG-FORK-UPSTREAM-003
  amendment 3's rule. No neutral summaries, no blind pass (H-8).
- **Pressure tests** (AC5) with their baselines: `raw/pressure-tests.md`.
- **Discarded:** none.

## Observed — level 1

| Scenario | 0.9.0 | candidate |
|---|---|---|
| 1, 3, 7 | all checks pass | all checks pass |
| 2 | one FAIL: "discovery invokes kdd:spec-context" (the check this batch adds) | all pass |
| 9 | spec-ask invoked, no brainstorming, no `specs/work` | same |
| total | 34/35 | 35/35 |

Cost USD / turns / wall s: s2 0.52/13/97 → 0.56/15/112; s3 0.50/14/84 →
0.58/17/97; s7 2.11/29/488 → 2.61/37/566; s9 0.17/5/21 → 0.17/5/28
(scenario 1 runs without the toolkit and records no usage).

## Observed — level 2

| Run | Arm | Tasks | Bundle lines | Turns | Cost USD | Wall min | Claims | FALSE (design-changing) | Violations | Exec. defects |
|---|---|---|---|---|---|---|---|---|---|---|
| B1 | before | 6 | 1117 | 88 | 11.24 | 31 | 80 | 2 (1) | 3 | 1 |
| B2 | before | 6 | 953 | 79 | 12.36 | 35 | 69 | 7 (2) | 3 | 0 |
| A1 | after | 6 | 1346 | 80 | 14.26 | 44 | 78 | 9 (2) | 5 | 1 |
| A2 | after | 4 | 1012 | 95 | 12.71 | 39 | 67 | 3 (0) | 6 | 0 |

Defects counted: B1 a coverage check reading a jacoco report no module
generates; A1 a step copying from an IT file that does not exist. Six of
A1's nine FALSE claims are line anchors that drifted. Not counted under the
rule, but changing the design in three runs (B2, A1, and A1's parity test):
integration tests expecting un-normalised values the schema rewrites.

## Observed — verdicts

| Deciding metric | Before | After | Result |
|---|---|---|---|
| L1: every check passing on 0.9.0 passes on the candidate | 34 | 35 (all 34 + the new one) | pass |
| L1: scenario 9 routes to `kdd:spec-ask` on the candidate | — | yes | pass |
| L2: false claims, after mean not ≥ 2 above | 4.5 | 6.0 (+1.5) | pass |
| L2: executability defects, after mean not higher | 0.5 | 0.5 | pass |
| Cost (L2 per run, +20 % non-overlapping) | 11.24–12.36 | 12.71–14.26 (+14 %) | pass |

## Inferred

- **Not worse** on every deciding metric: release 0.10.0.
- Level 1 shows the batch-4 rows working (the new scenario-2 check passes
  only on the candidate) but credits nothing to the spec-ask row (scenario 9
  passes on both arms, as the spec anticipated). The pressure-test
  baselines agree: two of five targets change behaviour against the before
  text (open questions first; the `unavailable` row), three show no change.
- Level 2 false claims vary as much within an arm (2–7, 3–9) as between
  arms; the +1.5 is inside that noise and below the threshold.
