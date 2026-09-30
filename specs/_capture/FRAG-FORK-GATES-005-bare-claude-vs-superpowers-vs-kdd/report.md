# Bare Claude with a spec CLAUDE.md vs superpowers 6.3.0 vs kdd-superpowers 0.4.0 — design + plan on mdm-platform, 2026-09-30

Study report. It is not derived from this repository's code, so it has no
anchors into kdd-superpowers. The figures come from two new headless runs
(`raw/`), from four runs kept in FRAG-FORK-GATES-003 and -004, and from the
judge agents' reports summarised here. `raw/preregistration.md` fixed the
arms, metrics and reading rule before either new run.

## Method

- **Arms:**
  - **C:** Claude Code with no plugin. It reads mdm-platform's own
    CLAUDE.md plus `raw/claude-md-addendum.txt`, a generic spec workflow
    that does not mention this task:
    1. find the specs and quote their rules;
    2. check every claim about today's code, with `path:line`;
    3. change the design, never reinterpret a rule;
    4. write the WRK-SPEC;
    5. write the WRK-PLAN with its WRK-TASKs.

    C1 and C2 are new runs.
  - **U:** superpowers 6.3.0. Reuses U1 and U2 from FRAG-FORK-GATES-003.
  - **K:** kdd-superpowers 0.4.0 with the kdd toolkit 1.6.0. Reuses K4 and
    K5 from FRAG-FORK-GATES-004.
- **Task.** RFC-PIPE-039 at mdm-platform `aacdae5`, run headless as
  `claude -p --model opus` with an isolated config. The run stops at the
  committed plan.
  - C's worktree commits the addendum first. Its artifacts are diffed from
    that commit.
  - C's prompt (`raw/C-prompt.txt`) is the U/K prompt with one change: the
    sentence that named the skills now points to the CLAUDE.md workflow.
    Like K4 and K5, it carries the wait-for-subagents sentence.
- **Judges.** Same prompts and model as FRAG-FORK-GATES-004:
  - An evidence judge per run.
  - A neutral summary per run.
  - One blind H1–H10 pass over all nine summaries (U1, U2, K1–K5, C1, C2),
    under shuffled codes, with the key kept outside the judge's reach.
- **Conditions that differ between arms:**
  - U1 and U2 ran without the wait sentence.
  - C ran a day after U and K.
  - C1 and C2 overlapped by about 10 minutes, which inflates C1's wall time
    but not its cost.
  - C1's run script was edited while C1 was still running. Its
    post-processing (transcripts, commit list, artifacts) was recovered by
    hand from the intact worktree and config directory. `result.json` was
    written by the run itself.

## Observed — runs

| Run | Arm | Wall | Turns | Output tokens | Cost | Tasks | Subagents |
|---|---|---|---|---|---|---|---|
| C1 | bare Claude + CLAUDE.md | 3154 s | 137 | 188.8k | $25.69 | 8 | code map; adversarial review of the spec; of the plan |
| C2 | bare Claude + CLAUDE.md | 1921 s | 60 | 117.0k | $16.87 | 7 | two code maps; adversarial review of the spec; of the plan |

For reference:
- U1 and U2: $6.03 and $8.17, 912–1302 s.
- K4 and K5: $16.88 and $20.47, 2419–2520 s.

Neither C run used a skill. Both dispatched an adversarial review of their
own spec and plan, which the addendum does not ask for. Both recorded the
rulings in a `## Adversarial Review` section: C1 recorded "24 ataques, 13
BROKEN" for the spec and "28 ataques, 3 BROKEN" for the plan. The
repository's existing WRK-SPECs and WRK-PLANs carry that section.

## Observed — evidence judges

| Arm | Run | Claims about current code | FALSE | UNVERIFIABLE | FALSE that change the design | Knowledge violations |
|---|---|---|---|---|---|---|
| C | C1 | 87 | 2 | 1 | 0 | 9 |
| C | C2 | 46 | 4 | 1 | 0 | 5 |
| U | U1, U2 | 51, 59 | 5, 5 | 0, 1 | 0 | 6, 5 |
| K 0.4.0 | K4, K5 | 55, 62 | 2, 1 | 1, 1 | 0 | 4, 6 |

- **False claims per arm:** C 6/133 (4.5 %), U 10/110 (9.1 %), K 0.4.0
  3/117 (2.6 %).
- **C1's knowledge violations:**
  - Most are deviations the spec itself acknowledges: `absorbed` against
    `orphaned`, computation and event emission in Persistence, and new
    attributes on events and lineage edges.
  - It also cites DOC-MDM-CONVENTIONS-001 §5 for a lock-ordering rule that
    spec does not contain.
- **C2's FALSE claims:**
  - the unmerge preview's evaluation instant;
  - a retired parity test named as the regression net;
  - the order of two events;
  - RFC-PIPE-039 described as `accepted`, when it is `draft`.

## Observed — blind hard-point judge (C = correct, W = wrong, N = not addressed)

| Run | H1 | H2 | H3 | H4 | H5 | H6 | H7 | H8 | H9 | H10 | C |
|---|---|---|---|---|---|---|---|---|---|---|---|
| U1 | W | W | C | C | C | C | C | C | C | W | 7 |
| U2 | W | W | C | C | C | N | N | C | C | W | 5 |
| K1 (0.3.0) | W | C | C | C | C | C | C | C | C | C | 9 |
| K2 (0.3.0) | W | W | W | W | C | C | C | C | C | N | 5 |
| K3 (0.3.0) | W | W | W | C | C | C | C | C | C | W | 6 |
| K4 (0.4.0) | C | C | C | C | C | W | C | C | C | C | 9 |
| K5 (0.4.0) | C | C | C | C | C | C | C | C | C | W | 9 |
| C1 | C | W | C | C | C | C | C | C | C | N | 8 |
| C2 | C | W | C | C | C | C | C | C | C | W | 8 |

- **Totals:** in FRAG-FORK-GATES-004's pass, U2 scored 6 and K4 8; here
  they score 5 and 9. The other five earlier runs kept their totals.
- **H1** (the manual-merge survivor is not overwritten): both C runs are
  right. C1 uses a "stripped" mode and C2 prunes the survivor instead of
  recomputing it. The K 0.4.0 runs are also right, and all U and K 0.3.0
  runs are wrong.
- **H2** (the real prior `previous` is kept): both C runs rebuild lineage
  from the replay chain and lose it. K1, K4 and K5 keep it.
- **H10** (an orphaned record does not propagate downstream): C1 does not
  address it, and C2 emits `golden_record.updated` knowing the rule says it
  should not. The conflict between mdm-platform's specs recorded in
  FRAG-FORK-GATES-004 is unchanged.
- **H3:** C1 follows DOM-MDM-PIPELINE-001 §10.8.4 (`absorbed`) and notes
  the conflict with DOM-MDM-SURVIVORSHIP-001 §3.2. The judge scored that C.

## Inferred

- **In a repository that already teaches KDD, a spec-focused CLAUDE.md gets
  plain Claude close to kdd-superpowers 0.4.0.**
  - Mean hard points: C 8.0, K 0.4.0 9.0, U 6.0.
  - Under the pre-registered rule (within 1 point), C is comparable to
    K 0.4.0, and it is 2 points above U.
  - n = 2 per arm, one task, and the judge varies by about ±1 per run
    (rests on: blind judge table).
- **The two arms differ on H2.** Both C runs lost the persisted `previous`
  when rebuilding lineage; both K 0.4.0 runs kept it (rests on: blind judge
  table).
- **The repository's artifacts carry the method.** Neither C run was told to
  red-team its work, yet both ran adversarial reviews of the spec and the
  plan and recorded the rulings. That is the practice visible in
  mdm-platform's existing work artifacts. This study cannot say how C would
  do in a project without that history (rests on: runs table,
  observations).
- **False claims:**
  - C made 3 per run on average, against 1.5 for K 0.4.0 and 5 for U.
  - Under the pre-registered rule (fewer than 2 per run is not a
    difference), C and K 0.4.0 do not differ. C and U differ by exactly the
    threshold.
  - No arm had a design-changing false claim (rests on: evidence judges
    table).
- **Cost:**
  - C is the most expensive arm and the most variable: $16.87–25.69, mean
    $21.28.
  - K 0.4.0: $16.88–20.47, mean $18.68.
  - U: $6.03–8.17, mean $7.10.
  - The method, not the plugin, is what costs: C pays for the same verifier
    and review seats without being asked to (rests on: runs table).
- **What this study does not measure:** activation pinning, verified
  premises as a separate section, consolidation, and the ledger.
  kdd-superpowers provides those and a CLAUDE.md does not.
