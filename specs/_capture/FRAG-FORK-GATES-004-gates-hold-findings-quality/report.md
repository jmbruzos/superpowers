# kdd-superpowers 0.4.0 vs 0.3.0 — design + plan on mdm-platform, 2026-09-29

Study report, and acceptance criterion 9 of WRK-SPEC-FORK-GATES-002. It is not
derived from this repository's code, so it has no anchors. The figures come
from two headless runs' JSON results and artifacts (`raw/`) and from the judge
agents' reports, summarised here. The comparison runs, the method and the ten
hard points are those of FRAG-FORK-GATES-003, whose `raw/preregistration.md`
fixed them before any run.

## Method

- **Arm.** kdd-superpowers with the WRK-SPEC-FORK-GATES-002 skills (skills
  at `d8e82ee`, loaded from the repository root at `c520470`), and the kdd
  toolkit 1.6.0.
- **Task and prompt.** Both are the same as FRAG-FORK-GATES-003's K3:
  RFC-PIPE-039 of mdm-platform at `aacdae5`, the neutral prompt, and the
  added sentence "This is a non-interactive run: never end your turn while a
  subagent you dispatched is still running — wait for its result and act on
  it before you continue or stop."
- **Runs.** K4, then K5, in series. Both are headless `claude -p --model
  opus` runs with an isolated config.
- **Judges.** Same prompts and models as FRAG-FORK-GATES-003.
  - An evidence judge per run.
  - A neutral summary per run, with the process vocabulary removed.
  - A single blind H1–H10 pass over all seven summaries: U1, U2, K1–K3 from
    FRAG-FORK-GATES-003, plus K4 and K5, under shuffled codes. The key is
    K2 = N1, U1 = N2, K1 = N3, U2 = N4, K3 = N5, K4 = N6, K5 = N7.

## Observed — runs

| Run | Skills | Wall | Turns | Output tokens | Cost | Tasks | Gates run | Plan committed |
|---|---|---|---|---|---|---|---|---|
| K4 | 0.4.0 | 2419 s | 63 | 133.8k | $16.88 | 4 | verifier, A1, A2 | yes |
| K5 | 0.4.0 | 2520 s | 90 | 168.1k | $20.47 | 8 | verifier, A1, A2 | yes |

For reference, FRAG-FORK-GATES-003's K runs (0.3.0) cost $18.38–$19.70 and
took 2687–3029 s.

## Observed — evidence judges

| Run | Claims about current code | FALSE | UNVERIFIABLE | FALSE that change the design | Knowledge violations |
|---|---|---|---|---|---|
| K4 | 55 | 2 | 1 | 0 | 4 |
| K5 | 62 | 1 | 1 | 0 | 6 |

K4 and K5 together have 3 FALSE claims out of 117 (2.6 %). The 0.3.0 runs
had 9 of 192 (4.7 %), and superpowers 6.3.0 had 10 of 110 (9.1 %).

## Observed — blind hard-point judge (C = correct, W = wrong, N = not addressed)

| Run | H1 | H2 | H3 | H4 | H5 | H6 | H7 | H8 | H9 | H10 | C |
|---|---|---|---|---|---|---|---|---|---|---|---|
| U1 | W | W | C | C | C | C | C | C | C | W | 7 |
| U2 | W | W | C | C | C | C | N | C | C | W | 6 |
| K1 | W | C | C | C | C | C | C | C | C | C | 9 |
| K2 | W | W | W | W | C | C | C | C | C | W | 5 |
| K3 | W | W | W | C | C | C | C | C | C | W | 6 |
| K4 | C | C | C | C | C | W | N | C | C | C | 8 |
| K5 | C | C | C | C | C | C | C | C | C | W | 9 |

- The five earlier runs got the same totals in this pass as in
  FRAG-FORK-GATES-003's last pass. A few cells changed between W and N, or
  moved between points, with the totals unchanged.
- **H1** (the manual-merge survivor is not overwritten): only K4 and K5 get
  it right. Both re-resolve only the fields the departed record had won.
  All five earlier runs recompute the survivor in full.
- **H2** (`previous` is kept): K1, K4 and K5.
- **H3** (the orphaned record is kept as read-only history): K4 and K5 get
  it right. K2 and K3 empty it.
- **H10 vs H6:**
  - K4 emits no `golden_record.updated` for the orphaned record, so it
    does not propagate (H10 C). Other pods' L1 caches then keep it as
    active (H6 W).
  - K5 emits the event (H6 C, H10 W). It records the conflict as
    `Knowledge gap: contested rule` instead of resolving it.
  - Only K1 satisfies both.
- **H7:** K4 excludes review resolution without giving a reason.

## Observed — how 0.4.0 handled the H1 and H3 findings

- **K5, gate A1:** gate A1 flagged the full recompute of the manual-merge
  survivor as `spec-rule` (PROD-MDM-STEWARDSHIP-001 §3.8.5). The ruling was:
  "Aceptado (sin cita que lo permita): recálculo parcial de los campos del
  registro que salió; AC11; […] Knowledge gap: contested rule".
- **K4, gate A1:** gate A1 flagged that the full fold rebuilds `previous`
  and discards the steward's result. The rulings were:
  - "Accepted — design changed to per-field re-resolution";
  - "Accepted — per-field scope leaves every field X did not win
    untouched";
  - for orphan propagation: "Accepted — no event on orphan".
- **Rejected findings:**
  - Neither run rejected a `spec-rule` finding. Each finding without a
    permitting quote was accepted.
  - Where the author still disagreed, the finding was recorded as
    `Knowledge gap: contested rule`: 3 in K4 and 3 in K5.
  - The only rejection in either run is K4's A2 row 6, which is `internal`.
- **Waiting:** both runs waited for every gate and committed the plan.

In FRAG-FORK-GATES-003, K1 and K2 rejected or "kept" the same H1 finding by
narrowing the rule's scope.

## Inferred

- **The permitting-quote rule turned the H1 finding into a design change.**
  - All five earlier runs lost H1, including three 0.3.0 runs whose gates
    had flagged it.
  - Both 0.4.0 runs accepted the finding and changed the design, and both
    got H1 right.
  - n = 2 (rests on: blind judge table, H1/H3 handling).
- **Hard points improve on the mean.**
  - 0.4.0: mean 8.5 (8, 9).
  - 0.3.0: 6.7 (9, 5, 6), or 7.5 excluding the truncated K2.
  - superpowers: 6.5.
  - The judge varies by about ±1 per run (FRAG-FORK-GATES-003).
  - 0.4.0's best run equals 0.3.0's best (K1, 9). What changed is the
    floor: 8 against 5–6 (rests on: blind judge table).
- **Accepting a contested finding can move the error elsewhere.**
  - K5 accepted the `spec-rule` finding on orphan propagation only as a
    contested rule and kept the event, so it lost H10.
  - K4 dropped the event and lost H6 instead.
  - The rule records the disagreement but does not resolve two activated
    rules that pull in different directions. That still needs a human
    change to a spec (rests on: H6/H10 cells, K5 E6).
- **Cost did not rise on this task.**
  - 0.4.0: mean $18.68 and about 41 min.
  - 0.3.0: mean $19.18 and about 47 min.
  - n = 2 against 3, within run-to-run spread. The +8 % measured on
    scenario 7 (FRAG-FORK-TOKENS-003) is not visible at this size (rests
    on: runs table).
- **False claims about code stay low.** 2.6 % against 4.7 % (0.3.0) and
  9.1 % (superpowers). None changed the design (rests on: evidence judges
  table).
