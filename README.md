# kdd-superpowers

Knowledge-Driven Development for Claude Code: the superpowers development
discipline — brainstorm → spec → plan → subagent-driven execution → review →
finish — producing and consuming **KDD artifacts**. Every piece of work is a
`WRK-SPEC` that activates knowledge, freezes that activation, is executed
against it, is reviewed against it, and returns what it learned to the
knowledge base.

`kdd-superpowers` is derived from [superpowers](https://github.com/obra/superpowers)
v6.3.0 by Jesse Vincent (MIT). Claude Code is the only supported harness.

## Requirements

- Claude Code.
- **Requires the `kdd` toolkit plugin** (`kdd-toolkit`): the `spec-graph` CLI and the
  `/kdd:spec-*` skills. kdd-superpowers never re-implements what the toolkit does; it
  calls it. Without it, the session bootstrap reports `toolkit: NOT FOUND` and the
  workflow skills stop before doing anything.
- Node ≥ 18 (for the toolkit CLI and two brief scripts). No npm dependencies of its own.

## Installation

Uninstall upstream `superpowers` first — both inject a session bootstrap and
they would fight:

```
/plugin uninstall superpowers
/plugin marketplace add <owner>/superpowers
/plugin install kdd-superpowers
```

Install the toolkit from its own marketplace (`/plugin install kdd`), or point
`KDD_SPEC_GRAPH` at a `spec-graph.mjs` checkout.

## How it works

At session start the bootstrap injects the `using-superpowers` skill plus a
`<KDD-ENVIRONMENT>` probe: where the toolkit is, whether the project has a
`specs/` directory, which work is open, which OKF bundles are waiting to be
imported.

When you ask to build or change something:

1. **brainstorming** discovers the relevant knowledge (`kdd:spec-context`), captures
   what the code embodies when no spec does (anchored `FRAG-*`, never from memory),
   asks its questions, presents the design — and its last section, *Knowledge
   activation*, is the one you approve to **freeze** which specs this work depends on.
   A red-team subagent attacks the draft. The result is a `WRK-SPEC` under
   `specs/work/`, validated, `active` and human-verified.
2. **writing-plans** turns it into a `WRK-PLAN` and one `WRK-TASK` file per task, each
   with the 2–5 specs it touches and the rules copied verbatim.
3. **subagent-driven-development** dispatches a fresh implementer per task with a
   deterministic brief (task + constraints + activated specs + evidence), then a
   reviewer that returns three verdicts: spec, **knowledge**, quality. Violating an
   activated rule is blocking. Selected tasks get a test adversary.
4. **finishing-a-development-branch** refuses to offer merge until the graph validates,
   every task is `completed` and `export-okf` runs; it persists the execution log into
   the plan and consolidates (`kdd:spec-consolidate`) — ADRs, spec deltas, fragments
   distilled after an adversary — so the knowledge change ships with the code change.

Identifiers read as paths: `WRK-SPEC-RISK-VAR-ENGINE-001` → `WRK-PLAN-RISK-VAR-ENGINE-001`
→ `WRK-TASK-RISK-VAR-ENGINE-001-003`. Runtime state lives under `.kdd/` (git-ignored);
no path contains `superpowers`.

## Principles

| # | Principle |
|---|---|
| P1 | Work artifacts are KDD specs, not documents |
| P2 | Every piece of work declares the knowledge it activates — `activates: []` is said out loud |
| P3 | Activation is decided once, with a human, and frozen |
| P4 | Deterministic → CLI; judgment → toolkit skill |
| P5 | Three layers of authority: WRK-SPEC, WRK-PLAN, activated specs |
| P6 | Everything written carries the trust family; a skill never verifies its own output |
| P7 | No work closes without returning knowledge |
| P8 | OKF by construction, not by extra steps |
| P9 | Same methodology with or without `specs/` |
| P10 | KDD changes the *what* and the *with which context*; superpowers keeps the *how* |
| P11 | In brownfield, code is the source of knowledge — captured, not ignored |
| P12 | A FRAG extracted from code contains only what can be pointed at |
| P13 | No path contains `superpowers` |

The full design is the work spec that produced this plugin:
`specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md`.

## What's inside

| Skill | Role |
|---|---|
| `using-superpowers` | bootstrap; reads the KDD environment; routes knowledge specs to `kdd:*` and work to brainstorming |
| `kdd-conventions` | IDs, locations, transitions, trust family, templates, capturing from code, adversarial gates |
| `brainstorming` | design → `WRK-SPEC` with frozen activation; gate A1 |
| `writing-plans` | `WRK-PLAN` + `WRK-TASK`s; gate A2 |
| `subagent-driven-development` / `executing-plans` | execution with deterministic briefs; gates A3, A4, A5 |
| `requesting-code-review` / `receiving-code-review` | three review modes; knowledge compliance; capture candidates |
| `finishing-a-development-branch` | knowledge integrity, execution log, consolidation; gate A6 |
| `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `using-git-worktrees`, `dispatching-parallel-agents`, `writing-skills` | as upstream (verification lists the KDD evidence) |

## Testing

- `bash tests/scripts/run.sh` — deterministic suite (no Claude): scripts, fixture, invariants, skill content. Set `KDD_SPEC_GRAPH` to a `spec-graph.mjs` to run the CLI-backed tests.
- `bash tests/hooks/test-session-start.sh`, `bash tests/claude-code/test-sdd-workspace.sh`, `cd tests/brainstorm-server && npm test`.
- `bash tests/claude-code/test-kdd-flow.sh` — headless Claude scenarios (slow; needs Claude Code and the toolkit).

## License

MIT. See `LICENSE` — this project is a derivative work of superpowers.
