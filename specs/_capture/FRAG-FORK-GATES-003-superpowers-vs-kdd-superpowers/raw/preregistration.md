# Pre-registration — superpowers 6.3.0 vs kdd-superpowers 0.3.0 (design + plan)

Written 2026-09-29, before any run of this study.

## Arms

- U = superpowers 6.3.0 (tag v6.3.0, 86babb6), loaded alone.
- K = kdd-superpowers 0.3.0 (5ff773e), plus the kdd toolkit 1.6.0 it depends on.
- 2 runs each, in series: U1, K1, U2, K2.

## Task and conditions

- mdm-platform at aacdae5, one disposable worktree per run.
- Headless `claude -p --model opus`, isolated config, bypassPermissions, `CLAUDE_CODE_OAUTH_TOKEN`.
- One neutral prompt for both arms. It names the skills by their shared
  short names, brainstorming then writing-plans.
- Every approval is granted in advance, and the run stops once the
  implementation plan is committed, before execution.

## Metrics (fixed now)

1. **False claims about current code.** Across the design artifact and the
   plan (tasks included), every factual claim about how today's code
   behaves, verified against aacdae5 (TRUE, FALSE or UNVERIFIABLE). Count
   the FALSE claims, and separately those that would change the design or
   the implementation.
2. **Violations of the project's knowledge.** Design or plan choices that
   contradict a rule in mdm-platform's specs (DOM, ARCH, ADR, FEAT, PROD),
   each quoting the rule with its ID and section.
3. **Coverage of hard points.** Each is scored addressed-correctly,
   addressed-wrongly, or not addressed:
   - H1. The manual-merge survivor's golden_data is not overwritten by the
     recompute (steward decision preserved).
   - H2. Field lineage stops pointing at the departed record, and `previous`
     is not silently lost.
   - H3. The case where the last member leaves (orphaned or empty
     lifecycle) is defined, including what is emitted downstream.
   - H4. Pins, overrides and ForceRules that reference the departed record
     are handled.
   - H5. Concurrency: the losing record is locked, and the ordering and
     retries (optimistic locking, back to Merge) are defined.
   - H6. Events and cache: L1/L2 invalidation for the losing record, and the
     quality-tier event computed from the losing record's own score.
   - H7. Triggers: unmerge, ForceRule and resolution are each covered, or
     scoped out with a reason (note that review resolution closes no spans
     today).
   - H8. Tests reach the ForceRule path (no production code creates
     SOURCE_TO_GOLDEN rules, so tests must seed them).
   - H9. The quality score is recomputed for the losing record.
   - H10. Downstream propagation of an orphaned record follows the project's
     rules.
4. **Plan executability.**
   - Tasks name real files and symbols (counted under metric 1).
   - Each task has a runnable test step.
   - The task order is valid.
5. **Cost, turns, wall time and output tokens** per run.

## Judging

- Different formats reveal the arm, so the judge cannot be blind.
  Mitigations:
  - Every metric needs a verifiable citation: `path:line` or a rule ID and
    section.
  - H1–H10 are fixed above.
  - The same judge prompt is used for all four runs.
- A second, independent judge pass scores H1–H10 only, from a
  version-neutral summary of each run's design and plan. The summary is
  written by a separate agent told to drop format, IDs and KDD vocabulary.
