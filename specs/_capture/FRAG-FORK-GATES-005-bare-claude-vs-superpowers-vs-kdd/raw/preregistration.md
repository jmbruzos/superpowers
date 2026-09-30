# Pre-registration — bare Claude + spec CLAUDE.md vs superpowers 6.3.0 vs kdd-superpowers 0.4.0

Written 2026-09-30, before any run of the new arm.

## Arms

- **C** — Claude Code with no plugins. mdm-platform's own CLAUDE.md, which
  every arm reads, plus the addendum in `claude-md-addendum.md`: a generic
  spec workflow with no mention of this task. C1 and C2 are new runs.
- **U** — superpowers 6.3.0. Reuses U1 and U2 from FRAG-FORK-GATES-003.
- **K** — kdd-superpowers 0.4.0 plus the kdd toolkit 1.6.0. Reuses K4 and K5
  from FRAG-FORK-GATES-004.

## Task and conditions

- The same as FRAG-FORK-GATES-003: RFC-PIPE-039, mdm-platform at `aacdae5`,
  one disposable worktree per run, headless `claude -p --model opus`,
  isolated config, bypassPermissions, and `KDD_SPEC_GRAPH` set to the 1.6.0
  CLI.
- C's worktree commits the addendum first. Its artifacts are diffed from
  that commit.
- **Prompt.** C uses the U/K prompt with one change: the sentence naming the
  skills is replaced by "Follow the workflow in CLAUDE.md …: first the
  design as a WRK-SPEC, then the implementation plan as a WRK-PLAN with its
  WRK-TASKs". It also carries the wait-for-subagents sentence, as K4 and K5
  did.
- **Known differences.**
  - U1 and U2 ran without the wait sentence.
  - U and K ran on 2026-09-29; C runs on 2026-09-30, same model alias and
    same Claude Code install.

## Metrics (the same as FRAG-FORK-GATES-003)

1. **Precision.** Hard points H1–H10, scored C/W/N by a blind judge.
2. **Hallucinations.** False claims about current code, from an evidence
   judge per run. Reported as FALSE out of claims, UNVERIFIABLE, and
   design-changing FALSE. Knowledge violations are reported alongside.
3. **Cost.** `total_cost_usd`, turns, wall time and output tokens, from
   each run's result.json.

## Judging

- The evidence judge uses the FRAG-FORK-GATES-004 prompt verbatim (only the
  bundle path changes). The bundle is the committed spec, plan and tasks,
  concatenated.
- The neutral summary is written with the same headings and word target as
  N1–N7.
- One blind H1–H10 pass runs over nine summaries: N1–N7 unchanged, plus C1
  and C2 under new shuffled codes (N8, N9, with the key kept here after
  scoring). It uses the same judge prompt as the seven-design pass.
- Earlier passes varied by about ±1 per run. The new pass is reported
  whole, and the earlier arms' scores are compared across passes.

## Reading rule, fixed now

- **Precision:** C is "comparable" to an arm if its mean is within 1 point
  of that arm's mean in the same pass. H1 is reported separately.
- **Hallucinations:** differences below 2 false claims per run are not
  called a difference.
- **Cost:** reported as it is, with each arm's range.
