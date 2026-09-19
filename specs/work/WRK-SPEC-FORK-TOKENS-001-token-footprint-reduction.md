---
id: WRK-SPEC-FORK-TOKENS-001
type: spec
layer: work-spec
scope: ephemeral
status: active
confidence: low
version: 0.2.0
created: 2026-09-19
updated: 2026-09-19
owner: jmbruzos
title: "kdd-superpowers — token footprint reduction: deterministic transition script, repeatable usage measurement"
activates: []
equips: []
activation_frozen: true
activation_resolved_at: 2026-09-19T12:15:12+02:00
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-CORE-001
    resource: specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md
    title: Operating principles P4, P10, P13 and the kdd-conventions transition table
  - id: SPIKE-TOKENS-2026-09-19
    resource: tests/claude-code/test-kdd-flow.sh
    title: Headless measurement of scenarios s0/s2/s4/s5 on 2026-09-19 (throwaway spike; numbers recorded in Problem Statement)
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-19T12:15:12+02:00
verified:
  - by: human:jmbruzos
    at: 2026-09-19T12:17:05+02:00
stale_after: 2026-12-18T00:00:00+01:00
tags: [kdd, fork, tokens, skills, kdd-conventions, testing]
---

# WRK-SPEC-FORK-TOKENS-001 — token footprint reduction

## Problem Statement

A headless measurement of the flow on 2026-09-19 (Opus 5 in the main
session, `claude -p --output-format json`) gave, for a trivial two-function
task:

| Scenario | Turns | Cache read | Output | Cost |
|---|---|---|---|---|
| control — no plugin, implement + test + commit | 8 | 157k | 5k | $0.48 |
| brainstorming bounded — up to the active WRK-SPEC | 19 | 683k | 12k | $1.23 |
| writing-plans — plan + 2 tasks + gate A2 | 20 | 976k | 53k | $3.06 |
| subagent-driven-development — 2 tasks, 5 subagents | 26 | 1.38M | 28k | $2.93 |

Two findings are actionable inside this plugin without touching the
prose superpowers tuned (P10):

1. ~~Template file size~~ — dropped after measurement. The +11k jump on the
   first `Skill` call is ~3.5k of skill prose plus ~8k of harness
   `prompt_snapshot` (system prompt and deferred tools rewritten once per
   session); `artifact-templates.md` is 5.3 KB (~1.6k tokens). Splitting it
   would save ~0.8k tokens per load — not worth five files and repointed
   citations. Recorded here so it is not re-proposed.
2. Status transitions (`status:` + `updated:` + `validate` + commit) are
   described as prose in five skills and executed ad hoc — a hand `sed`
   against the frontmatter each time — costing a turn per transition and
   a variability the conventions only guard with words.
3. `tests/claude-code/test-kdd-flow.sh` captures text only; no change to a
   skill can show a before/after in tokens.

Sections inherited verbatim from upstream superpowers (`Example Workflow`,
`Process Flow`, `Visual Companion`) stay where they are: your human partner
chose upstream mergeability over the ~2.7k tokens they would save.

## Proposed Change

### `scripts/transition` (kdd-conventions)

`transition [--specs DIR] [--verified human:<id>] [--no-commit] FILE STATUS`,
bash, next to `next-id`:

- Accepts only the transitions in the kdd-conventions table for
  WRK-SPEC / WRK-PLAN / WRK-TASK: `draft→active`, `active→completed`,
  `completed→archived`. FRAG transitions belong to the toolkit (P4) and are
  refused. A file whose current `status:` is not the expected origin exits
  non-zero and touches nothing.
- Rewrites `status:` and `updated: <today>` in the frontmatter; with
  `--verified`, appends `- by: human:<id>` / `at: <now>` under `verified:`
  (creating the key if absent). Never invents an id.
- Runs `<kdd-cli> --specs DIR validate` (kdd-cli resolved from
  `using-superpowers/scripts/kdd-cli`, never hard-coded). On a red validate
  it restores the file and exits non-zero.
- Commits the file alone with `chore(<ID>): activate|complete|archive` (the verb form the skills already use) — or
  `spec(<ID>): approved — active, human-verified` when `--verified` is
  given — unless `--no-commit`. Prints the resulting status line.

The five skills that describe the three steps (`brainstorming` User Review
Gate, `writing-plans` execution choice, `subagent-driven-development` §5,
`executing-plans` steps 6 and closing, `finishing-a-development-branch`
closing the WRK-SPEC) gain one line next to the existing text naming the
script as the way to do exactly that. The existing text stays (P10).

### Repeatable usage capture (tests)

`run_scenario` in `tests/claude-code/test-kdd-flow.sh` gains an opt-in
branch: when `KDD_FLOW_USAGE=<dir>` is set it runs with
`--output-format json`, writes `<dir>/<scenario>.json` and copies the
session transcripts, and the run ends by printing a table (turns, cache
read, cache creation, output, cost, duration per scenario) via a small
`tests/claude-code/usage-summary.py` that also calls the existing
`analyze-token-usage.py` breakdown per subagent. Assertions read the
`result` field of the JSON so they stay identical. Without the variable,
behaviour is unchanged.

## Knowledge Context

| Ref | Role |
|---|---|
| (none activated) | The graph holds no Knowledge or Agentic specs; activation is `[]`. |
| WRK-SPEC-FORK-CORE-001 (constrained-by, not activated) | P4: deterministic → script, never reimplementing `spec-graph`; P10: add lines, do not rewrite tuned prose; P13: no `superpowers` in any path. |
| kdd-conventions *Status transitions* table | The only transitions `transition` accepts; `updated:` on every move; never skip a state. |

Gaps: no formalized knowledge about the flow's token footprint exists. The
measurement branch of this spec is what will produce it; a future
consolidation may distil the numbers into a governance or reference spec.

## Acceptance Criteria

1. `tests/scripts/test-transition.sh` (new) passes against the `tests/scripts/fixtures/specs` fixture: valid transition rewrites `status`/`updated` and commits with the conventional message; invalid origin exits non-zero and leaves the file byte-identical; `--verified human:test` appends the entry and uses the `spec(...)` message; `--no-commit` leaves the tree dirty; a red validate restores the file and commits nothing; a FRAG path is refused.
2. Each of the five skills names `scripts/transition` next to its transition text; `tests/scripts/test-invariants.sh` and the full `tests/scripts/run.sh` stay green.
3. `KDD_FLOW_USAGE=<dir> bash tests/claude-code/test-kdd-flow.sh` writes one JSON per scenario and prints the summary table; without the variable the script's output is unchanged. One run after the change records the "after" numbers against the table above.
