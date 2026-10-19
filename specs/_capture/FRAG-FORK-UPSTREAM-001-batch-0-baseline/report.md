# Batch-0 baseline — fork 0.6.0 skills on toolkit 1.13.0, `test-kdd-flow.sh` scenarios 1–7 (2026-10-18)

Measurement report for WRK-SPEC-FORK-UPSTREAM-001 (batch 0 of
DOC-FORK-UPSTREAM-001). Not code-derived: no anchors, no `frag-cite-check`.

## Method

- **Arm:** skills of `kdd-superpowers--v0.6.0` (`acca006`; 0.6.1 ships the
  same skills), in a `git worktree`, with the harness of the measuring
  commit copied in: `tests/claude-code/test-kdd-flow.sh`, `toolkit-env.sh`
  and the fixtures (`tests/scripts/fixtures`, `tests/claude-code/fixtures`)
  — decision log U-9.
- **Fixed:** kdd toolkit 1.13.0 (`KDD_SPEC_GRAPH` and `KDD_TOOLKIT_DIR` on the
  installed plugin), Claude Code 2.1.302, `KDD_FLOW_MODEL=opus`, runs in
  sequence, `KDD_FLOW_USAGE` per run.
- **Runs:** two Opus passes (`opus-r1`, `opus-r2`), started 2026-10-18 at
  epoch 1792316974 and 1792320224 (alternating with batch 1's after arm,
  FRAG-FORK-UPSTREAM-002).
- **Supplementary, not an arm:** two earlier passes ran on
  `claude-sonnet-5-5` because the harness then passed no `--model` and the
  account default had moved from Opus (decision log U-11). Kept as
  `sonnet-r*`.
- **Harness defects found by these runs and fixed before the Opus passes:**
  the scenario-4 fixture's WRK-SPEC criterion contradicted its DOM rule
  (`16bc221`); piped `grep -q` under `pipefail` scored scenario 5's task-ID
  and execution-log checks as failures although the commits existed
  (`40e4673`); the model was not pinned (`155d911`).
- Scenario 1 records no usage JSON (it runs `claude -p` inline, not through
  `run_scenario`); its checks are in the check logs.
- Discarded runs: none.

## Observed — checks

| Pass | Checks passed | Failed |
|---|---|---|
| opus-r1 | 47 | none |
| opus-r2 | 47 | none |
| sonnet-r1 (supplementary) | 39 | scenario 4: WRK-PLAN, WRK-TASK files, Architecture Impact (the agent stopped to ask about the fixture contradiction); scenario 5: ledger, task IDs (the `grep -q` defect) |
| sonnet-r2 (supplementary) | 45 | scenario 5: ledger, task IDs (`grep -q` defect); scenario 7: "BROKEN table has M rows (closing M=15, table rows=19)" |

## Observed — usage (Opus passes)

| Scenario | Turns r1 / r2 | Output tokens r1 / r2 | Cost r1 / r2 (USD) | Wall r1 / r2 |
|---|---|---|---|---|
| 2 brainstorming, bounded, knowledge base | 14 / 12 | 9.0k / 7.4k | 0.56 / 0.48 | 118 s / 75 s |
| 3 brainstorming, no specs/, FRAG | 19 / 20 | 9.3k / 9.7k | 0.64 / 0.63 | 101 s / 120 s |
| 4 writing-plans | 31 / 24 | 38.1k / 36.0k | 1.73 / 1.61 | 403 s / 330 s |
| 5 SDD, hello plan | 39 / 32 | 36.1k / 33.6k | 1.93 / 1.75 | 427 s / 408 s |
| 6 code review | 6 / 6 | 9.8k / 10.7k | 0.48 / 0.51 | 89 s / 109 s |
| 7 brainstorming, architectural | 26 / 31 | 44.8k / 55.4k | 1.89 / 2.37 | 419 s / 596 s |
| **Pass total (2–7)** | | | **7.23 / 7.35** | |

Per-model splits are in `raw/opus-r*-scenario-*.json` (`modelUsage`): the
main session is Opus 5.5; SDD subagents run Haiku 5.5 and Sonnet 5.5;
scenario 7's gates run Sonnet 5.5.

## Inferred

- On toolkit 1.13.0 and Opus 5.5 the 0.6.0 flow passes every scenario check
  in both passes: this is the before arm for batch 1 and the reference for
  later batches. It rests on the observed checks table only.
- Compared with FRAG-FORK-TOKENS-003's scenario 7 (toolkit 1.6.0,
  $1.78–1.86), scenario 7 now costs $1.89–2.37; the toolkit, Claude Code and
  model versions all differ, so the difference is not attributed (DOC-FORK-
  TOKENS-001: compare runs only within one fragment).
- Sonnet as the main model fails scenario 4 by stopping to ask about a real
  contradiction that Opus planned around; after the fixture fix that
  behaviour is not observed on Opus. One supplementary pass per case only.
