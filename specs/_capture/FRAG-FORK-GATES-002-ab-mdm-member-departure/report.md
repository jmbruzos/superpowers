# A/B: kdd-superpowers 0.2.1 vs 0.3.0 on a real mdm-platform design — 2026-09-28/29

Experiment report. Not code-derived for this repository: no anchors into
kdd-superpowers. Every figure is read from the four headless runs' JSON
results and specs under `raw/`, or from two analysis agents' reports
(summarised below; their full tables are not kept).

## Method

- **Task.** RFC-PIPE-039 of mdm-platform ("la ficha que pierde un miembro
  conserva sus datos"): when a source record leaves a golden record
  (unmerge, ForceRule, resolution closing its xref span), recompute the
  losing golden record over its remaining members and fix its lineage. The
  RFC was open, and no WRK-SPEC touched it.
- **Code.** mdm-platform at `aacdae5`, one disposable `git worktree` per run.
  The user's checkout was untouched.
- **Versions.**
  - A = kdd-superpowers 0.2.1 (`8d625a2`).
  - B = 0.3.0 (`5ff773e`), which adds code premises, a mid-tier verifier,
    A1 on the written and self-reviewed spec, a Cause column and a detail
    cap.
  - Both with the kdd toolkit 1.6.0.
- **Runs.**
  - Four headless `claude -p --model opus` runs in series: A1, B1, A2, B2.
  - Each in an isolated `CLAUDE_CONFIG_DIR`, authenticated with
    `CLAUDE_CODE_OAUTH_TOKEN`, with `bypassPermissions`.
  - Same prompt for all four: brainstorming on the architectural path,
    every design section pre-approved, the session adjudicates A1 itself,
    and it stops at the committed WRK-SPEC.
  - Scripts: `run-one.sh` and `all.sh`, kept in the session's `.kdd/abtest/`.
- **Blind cause classification.**
  - Agent: sonnet.
  - Input: each run's A1 adversary output, normalised to
    `- [RESULT] attack — scenario — evidence`. Cause columns, one-liner
    markers and breakdown lines were stripped, and the four outputs were
    shuffled under codes R1–R4.
  - Task: classify every BROKEN finding by cause (the design-gate
    definitions) and by severity (high, medium or low).
- **Evidence judge.**
  - Agent: opus.
  - Input: the four final WRK-SPECs, shuffled under codes S1–S4.
  - Task: list every claim each spec makes about how today's code behaves,
    in any section, and check each against mdm-platform at `aacdae5`
    (TRUE with `path:line`, FALSE, or UNVERIFIABLE).
  - The judge was told to weigh claims equally inside and outside a
    Code Premises section.
- **The key** (the classifier and the judge never saw it):
  - Classifier: R2=A1, R1=A2, R4=B1, R3=B2.
  - Judge: S4=A1, S2=A2, S1=B1, S3=B2.

## Observed — runs

| Run | Version | Wall | Turns (main) | Output tokens | Cost | Verifier dispatched | `## Code Premises` | FRAG written |
|---|---|---|---|---|---|---|---|---|
| A1 | 0.2.1 | 1429 s | 29 | 57.8k | $7.96 | no | no | yes (FRAG-MDM-MEMBER-DEPARTURE-001) |
| A2 | 0.2.1 | 733 s | 47 | 48.5k | $4.78 | no | no | no |
| B1 | 0.3.0 | 1199 s | 13 | 26.5k | $8.01 | yes | yes | no |
| B2 | 0.3.0 | 1496 s | 19 | 50.4k | $8.68 | yes | yes | no |

Mean cost: A $6.37, B $8.35. All four exited 0 and committed a WRK-SPEC.

## Observed — gate A1 findings (blind classifier)

| Run | BROKEN | code-reality | spec-rule | ambiguity | knowledge-gap | internal | high | medium | low |
|---|---|---|---|---|---|---|---|---|---|
| A1 | 20 | 5 | 5 | 5 | 3 | 2 | 10 | 9 | 1 |
| A2 | 12 | 0 | 3 | 4 | 3 | 2 | 7 | 4 | 1 |
| B1 | 15 | 3 | 3 | 5 | 2 | 2 | 8 | 7 | 0 |
| B2 | 22 | 5 | 4 | 6 | 3 | 4 | 14 | 7 | 1 |

Totals:
- 0.2.1: 32 BROKEN, 5 of them code-reality (16 %).
- 0.3.0: 37 BROKEN, 8 of them code-reality (22 %).

In 0.2.1, A1 attacks a draft of the design sections. In 0.3.0 it attacks
the full written WRK-SPEC (criteria, constraints, premises), a larger
artifact.

The classifier found three things recur in all runs:
- **manual-merge survivor overwritten** — spec-rule, in all four;
- **`previous` lost in the chained recompute** — three of four;
- **the undecided `orphaned` lifecycle** — the largest knowledge-gap
  cluster.

## Observed — claims about current code in the final WRK-SPEC (judge)

| Run | Claims | TRUE | FALSE | UNVERIFIABLE | FALSE that would change the design |
|---|---|---|---|---|---|
| A1 | 38 | 33 | 4 | 1 | 3 |
| A2 | 32 | 30 | 2 | 0 | 1 (weak) |
| B1 | 33 | 31 | 2 | 0 | 1 |
| B2 | 38 | 37 | 1 | 0 | 0 |

Totals:
- 0.2.1: 70 claims, 6 FALSE (8.6 %), 4 of them design-changing.
- 0.3.0: 71 claims, 3 FALSE (4.2 %), 1 design-changing.

The design-changing false claims, as the judge reported them:

- **A1:**
  - A legacy pin to the departed record "falls back to survivorship". In
    fact it matches a remaining homonym by id (`DefaultMergeEngine` 243-244).
  - `maybeEmitQualityTierChange` would emit the losing record's tier. In
    fact it reads the destination's score from ctx (`PersistenceStepHandler`
    627).
  - "A normal ingestion writes schema_version". Only `createGoldenRecord`
    does (`PersistenceStepHandler` 366).
- **A2:** implicit reliance on the same ctx-scored tier emitter (weak).
- **B1:** compare against `ctx.getGoldenRecordId()` inside Merge. That field
  is set only by Persistence (`PersistenceStepHandler` 261; `MergeStepHandler`
  203) and is null there. The claim sat in *Components*, outside the
  spec's Code Premises.
- **B2:** none. Its premises flagged both its own false premise (P7) and
  the ctx-score trap that A1 and A2 fell into.

## Inferred

- **0.3.0's final specs carried half the false claims about current code
  (3 vs 6 of about 70) and a quarter of the design-changing ones (1 vs 4).**
  The direction matches the goal of WRK-SPEC-FORK-GATES-001. n=2 per side,
  and 0.2.1 varied widely between its two runs (rests on: judge table).
- **The A1 code-reality count did not fall (8 vs 5).** It is not the right
  metric across these versions: the attacked artifact differs, a draft in
  0.2.1 and the full spec in 0.3.0. Only what survives into the final spec
  is comparable (rests on: classifier table, Method).
- **A premises list only protects what it lists.** B1's one design-changing
  error was a claim about current code in *Components*, never listed as a
  premise, so never verified. A verifier that also extracts claims from the
  design sections would have caught it (rests on: judge, B1).
- **0.3.0 cost about $2 more per architectural brainstorming (+31 %)** on
  this task, for the verifier seat and a longer spec. Output tokens were
  not higher: 26.5k and 50.4k, against 57.8k and 48.5k (rests on: runs
  table).
- **The adversary finds the same substantive design issues in both
  versions**: the manual-merge survivor, `previous`, orphaned. The premises
  change moves errors about current code, not design judgement (rests on:
  classifier observations).
