# superpowers 6.3.0 vs kdd-superpowers 0.3.0 — design + plan on mdm-platform, 2026-09-29

Study report. Not code-derived for this repository: no anchors into
kdd-superpowers. Figures come from five headless runs' JSON results and
artifacts (`raw/`) and from judge agents' reports, which are summarised
here; their full tables are not kept. The metrics and the ten hard points
were fixed before any run (`raw/preregistration.md`).

## Method

- **Arms.**
  - U = superpowers 6.3.0 (tag v6.3.0, commit b36e082), loaded alone.
  - K = kdd-superpowers 0.3.0 (5ff773e) with the kdd toolkit 1.6.0.
- **Task.** RFC-PIPE-039 of mdm-platform, at `aacdae5`, in disposable
  worktrees. One neutral prompt names the skills by their shared short
  names (brainstorming, then writing-plans). Every approval is granted in
  advance, and the run stops at the committed plan.
- **Runs.** U1, K1, U2 and K2 ran in series, then K3.
  - K2's headless session ended its turn while gate A2 was still running
    in the background. Its plan was never adjudicated or committed, so it
    was rebuilt from the transcript by replaying the Write and Edit calls
    (`raw/K2-bundle.txt`).
  - K3 re-ran K2 with one added sentence: never end the turn while a
    dispatched subagent is running. K3 adjudicated A2 and committed.
- **Setup notes.**
  - Headless `claude -p --model opus` with an isolated config and
    `CLAUDE_CODE_OAUTH_TOKEN`.
  - mdm-platform's own CLAUDE.md and repository teach the KDD artifact
    conventions, so the U runs also wrote WRK-SPEC, WRK-PLAN and WRK-TASK
    files in `specs/work/`. The comparison is superpowers in a KDD project
    against kdd-superpowers, not KDD against no KDD.
- **Judging.**
  - **Evidence judges** (opus), one per run, on each bundle (spec + plan +
    tasks). They check claims about current code (TRUE, FALSE or
    UNVERIFIABLE, against aacdae5), knowledge violations (quoted rules of
    mdm-platform specs) and executability. Not blind: the format reveals the
    arm.
  - **Neutral summaries** (sonnet): one per run, with format, IDs and
    process vocabulary removed (`raw/*-neutral-summary.md`).
  - **Blind H1–H10 judge** (opus): scores the five summaries under shuffled
    codes, with the same bar for all, against the code and specs. A first
    pass over the four original summaries gave the same scores for those
    four.

## Observed — runs

| Run | Arm | Wall | Turns | Output tokens | Cost | Tasks | Gates run |
|---|---|---|---|---|---|---|---|
| U1 | superpowers 6.3.0 | 912 s | 79 | 103.4k | $6.03 | 4 | none |
| U2 | superpowers 6.3.0 | 1302 s | 65 | 117.1k | $8.17 | 4 | none (one exploration subagent) |
| K1 | kdd-superpowers 0.3.0 | 2687 s | 67 | 141.6k | $19.45 | 5 | verifier, A1, A2 |
| K2 | kdd-superpowers 0.3.0 | 3029 s | 57 | 105.5k | $19.70 | 6 | verifier, A1, A2 (not adjudicated) |
| K3 | kdd-superpowers 0.3.0 | 2772 s | 94 | 158.6k | $18.38 | 4 | verifier, A1, A2 |

## Observed — evidence judges

| Run | Claims about current code | FALSE | UNVERIFIABLE | FALSE that change the design | Knowledge violations | Tasks without a runnable test | Order valid |
|---|---|---|---|---|---|---|---|
| U1 | 51 | 5 | 0 | 0 | 6 | 0 | yes |
| U2 | 59 | 5 | 1 | 0 | 5 | 0 | yes |
| K1 | 74 | 3 | 2 | 0 | 6 | 0 | yes |
| K2 | 64 | 2 | 1 | 0 | 5 | 0 | yes |
| K3 | 56 | 3 | 0 | 0 | 8 | 0 | yes |

Violations shared across both arms:
- running computation inside Persistence (DOM-MDM-PIPELINE-001 §6.5);
- `orphaned` where §10.8.4 says `absorbed`;
- the thin `GoldenRecordUpdated` payload (DOM-MDM-LINEAGE-001 §3.1.2).

Violations specific to one arm:
- **U:** both U runs claimed RFC-PIPE-039 was already `accepted` (false);
  U1 carved an exception to ADR-001's "no JPA outside mdm-persistence".
- **K:** K3 added the same JPA exception and a new `EMPTIED` active-without-
  members state; K1's test commands would fail without Surefire's
  `failIfNoSpecifiedTests=false` (reasoned, not run).

## Observed — blind hard-point judge (C = correct, W = wrong, N = not addressed)

| Run | H1 | H2 | H3 | H4 | H5 | H6 | H7 | H8 | H9 | H10 | C |
|---|---|---|---|---|---|---|---|---|---|---|---|
| U1 | W | W | C | C | C | C | C | C | C | W | 7 |
| U2 | W | W | C | C | C | C | C | C | C | W | 7 |
| K1 | W | C | C | C | C | C | C | C | C | C | 9 |
| K2 | W | W | W | W | C | C | C | C | C | W | 5 |
| K3 | W | W | W | C | C | C | C | C | C | W | 6 |

Key: U1 = N2, U2 = N4, K1 = N3, K2 = N1, K3 = N5.

What separates the runs:
- **H2 (`previous` backfilled from persisted lineage)** and **H10 (the
  orphan kept out of the update stream)**: only K1 gets them right.
- **H3:** K2 and K3 empty the orphaned record, against "read-only history".
- **H4:** K2 leaves stale pins active.
- **H1** (the manual-merge survivor recomputed): all five get it wrong.

## Observed — how K runs handled the H1 and H3 findings

Gate A1 flagged the manual-merge survivor as a `spec-rule` BROKEN finding in
K1 and K2, and K2's A1 also flagged emptying the orphan. In each case the
author rejected or "kept" the design by reinterpreting the rule's scope:

- **K1:** "rejected como violación (el filtro acota "ambas rutas" de
  administración)".
- **K2:** "Se mantiene el recálculo, justificado en Componentes 3"; and for
  the orphan, "Se mantiene: el requisito es que el linaje deje de apuntar al
  registro que salió".

The blind judge scored those decisions W against the same rules.

## Inferred

- **Design quality is not better with kdd-superpowers on this task.**
  - Mean hard points: U 7.0, K 6.7 (7.5 excluding truncated K2).
  - K produced the best design (K1, 9/10) and the two weakest (K2 5, K3 6).
  - n = 2 or 3 per arm (rests on: blind judge table).
- **kdd-superpowers halves false claims about current code.**
  - K: 8 of 194 (4.1 %); U: 10 of 110 (9.1 %).
  - Consistent with FRAG-FORK-GATES-002. None was design-changing here, in
    either arm (rests on: evidence judges table).
- **It costs about 2.7× and takes about 2.7× the time.**
  - K: mean $19.18 and about 47 min; U: $7.10 and about 18 min (rests on:
    runs table).
- **The adversarial gates find the right problems, but authors override
  them.** K runs lost H1 and H3 by rejecting `spec-rule` findings through
  their own reading of the rule. That is where the gates' value leaks
  (rests on: the H1/H3 handling section and the blind judge table).
- **A gate dispatched in the background can be lost.** In a non-interactive
  run, ending the turn with a gate pending loses its adjudication. K2 did,
  and K3 with an explicit wait did not (rests on: runs table, Method).
- **Project context narrows the gap.** A KDD-organised repository makes
  plain superpowers produce KDD-shaped artifacts. What kdd-superpowers adds
  over that is activation, verified premises, gates and ledgers; format
  alone is not the difference (rests on: Method, U artifacts).
