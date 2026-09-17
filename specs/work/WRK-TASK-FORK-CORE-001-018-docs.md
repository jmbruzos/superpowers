---
id: WRK-TASK-FORK-CORE-001-018
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "README, CLAUDE.md, RELEASE-NOTES, .github templates, docs/testing.md"
parent: WRK-PLAN-FORK-CORE-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-FORK-CORE-001
    relation: implements
sources:
  - id: WRK-SPEC-FORK-CORE-001
    resource: specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-17T00:00:00+02:00
stale_after: 2026-12-16T00:00:00+01:00
tags: [kdd, fork, task, docs]
---

# WRK-TASK-FORK-CORE-001-018 — README, CLAUDE.md, RELEASE-NOTES, `.github` templates, `docs/testing.md`

## Objective

Make the repository describe what it now is (spec *Repository cleanup*):
a Claude-Code-only plugin that depends on the `kdd` toolkit, with the
flow, the principles and the derivation from superpowers 6.3.0; replace
upstream's PR policy with the fork's contributor guide.

## Implementation Notes

**Files:**
- Replace: `README.md`, `CLAUDE.md`, `RELEASE-NOTES.md`, `docs/testing.md`, `.github/PULL_REQUEST_TEMPLATE.md`
- Modify: `.github/ISSUE_TEMPLATE/config.yml`, `.github/ISSUE_TEMPLATE/bug_report.md`, `.github/ISSUE_TEMPLATE/feature_request.md` (rename `Superpowers` → `kdd-superpowers`, drop harness fields), `LICENSE` (append derivation note), `tests/scripts/test-invariants.sh` (README/CLAUDE.md are already in its scan)
- Test: `tests/scripts/test-invariants.sh`, `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: everything built in 001–017 (the README documents it).
- Produces: the install instructions Task 019's scenario tests follow.

- [ ] **Step 1: Add the structural assertions (failing)**

```bash
# --- docs (Task 018) ---
must_contain README.md "# kdd-superpowers" "README title"
must_contain README.md "/plugin install kdd-superpowers" "README install command"
must_contain README.md "Requires the \`kdd\` toolkit plugin" "README states the dependency"
must_contain README.md "derived from" "README attributes upstream"
must_not_contain README.md "Visual companion telemetry" "README has no telemetry section"
must_contain CLAUDE.md "P13" "CLAUDE.md lists the principles"
must_contain CLAUDE.md "tests/scripts/run.sh" "CLAUDE.md says how to test"
must_not_contain CLAUDE.md "94% PR rejection rate" "CLAUDE.md is no longer upstream's PR policy"
must_contain LICENSE "obra/superpowers" "LICENSE carries the derivation note"
```

- [ ] **Step 2: Write `README.md`**

```markdown
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
```

- [ ] **Step 3: Write `CLAUDE.md`**

```markdown
# kdd-superpowers — Working in this repository

This is a Claude Code plugin: skills (Markdown), a session-start hook (bash),
and a handful of scripts (bash, Node ESM). It is derived from superpowers 6.3.0
and adapted to Knowledge-Driven Development (KDD). It depends on the `kdd`
toolkit plugin at runtime and never re-implements it.

## The design is a spec

`specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md` is the authority
for what this plugin does; its plan and tasks are next to it. Read the spec's
thirteen principles (P1–P13) before changing a skill. Two of them shape every
edit here:

- **P10** — keep superpowers' *how*: the voice ("your human partner"), the red-flag
  and rationalization tables, the approval gates, the subagent discipline. Add rows
  and sections; do not rewrite tuned prose.
- **P13** — no path contains `superpowers`. Runtime state lives under `.kdd/`.

## Layout

- `skills/<name>/SKILL.md` — one skill each; prompt templates and references beside it.
- `skills/kdd-conventions/` — shared conventions, templates and scripts (`next-id`, `frag-cite-check`, `brief-lib.mjs`).
- `skills/using-superpowers/scripts/kdd-cli` — the only place that knows where `spec-graph.mjs` is.
- `hooks/session-start` — injects `using-superpowers` + `<KDD-ENVIRONMENT>`.
- `tests/scripts/` — deterministic tests and the `specs/` fixture; `tests/hooks/`, `tests/claude-code/`, `tests/brainstorm-server/`.

## Testing

```bash
export KDD_SPEC_GRAPH=/path/to/spec-graph.mjs   # e.g. ../knowledge-driven-development/apps/spec-graph/spec-graph.mjs
bash tests/scripts/run.sh
bash tests/hooks/test-session-start.sh
bash tests/claude-code/test-sdd-workspace.sh
(cd tests/brainstorm-server && npm test)
bash tests/claude-code/test-kdd-flow.sh          # headless Claude; slow
```

`tests/scripts/test-skill-content.sh` asserts the anchors prompts and scripts
depend on; when you change a skill, keep it green or update it in the same
commit. `tests/scripts/test-invariants.sh` enforces P13 and the namespace.

## Changing skills

Skills are behaviour-shaping prose. Use `kdd-superpowers:writing-skills` to
develop and pressure-test changes; state in the commit what behaviour the change
targets and what you observed. Keep English.

## Versioning

`scripts/bump-version.sh <version>` updates `package.json`, `.claude-plugin/plugin.json`
and `.claude-plugin/marketplace.json`. Record changes in `RELEASE-NOTES.md`.

## Language

English for everything in the repository (skills, specs, docs). Conversation
language is whatever your human partner uses.
```

- [ ] **Step 4: Replace `RELEASE-NOTES.md`, `docs/testing.md`, `.github` templates, `LICENSE` note**

`RELEASE-NOTES.md`:

```markdown
# Release notes

## 0.1.0 — first release of kdd-superpowers

Derived from superpowers v6.3.0 (obra/superpowers, commit b36e082). Claude Code only.
Implements WRK-SPEC-FORK-CORE-001 (sub-project 1: core flow): KDD work artifacts with
frozen activation, deterministic briefs, knowledge-compliance review, adversarial gates
A1–A6, brownfield capture with anchored claims, consolidation at finish, OKF conformance
by construction. Upstream's release history is in this repository's git log before
this commit.
```

`docs/testing.md` — replace with the *Testing* section of CLAUDE.md verbatim under a `# Testing kdd-superpowers` title, plus one line: "There is no eval harness in this repository; behavioural checks are the headless scenarios in `tests/claude-code/test-kdd-flow.sh`."

`.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## What problem does this solve?

## Which principle(s) of WRK-SPEC-FORK-CORE-001 does it touch? (P1–P13)

## Skills or scripts changed

## How did you test it?
- [ ] `bash tests/scripts/run.sh`
- [ ] `bash tests/hooks/test-session-start.sh`
- [ ] headless scenarios (if a skill changed): which, and what you observed

## Authoring
Model / harness used, or "written by hand".
```

`.github/ISSUE_TEMPLATE/*.md` and `config.yml`: replace every `Superpowers` with `kdd-superpowers`; remove the "Harness / platform" field from `bug_report.md` (Claude Code only).

`LICENSE`: append at the end:

```
---
kdd-superpowers is a derivative work of superpowers (https://github.com/obra/superpowers),
Copyright (c) Jesse Vincent, distributed under the same MIT license. Modifications
Copyright (c) 2026 NFQ Advisory.
```

- [ ] **Step 5: Run the tests and commit**

Run: `bash tests/scripts/run.sh` — Expected: all ok (invariants scan README/CLAUDE.md; content assertions pass).

```bash
git add README.md CLAUDE.md RELEASE-NOTES.md docs/testing.md .github LICENSE tests/scripts/test-skill-content.sh
git commit -m "docs(WRK-TASK-FORK-CORE-001-018): README, CLAUDE.md and templates for kdd-superpowers"
```

## Acceptance Criteria

- [ ] README and CLAUDE.md describe the fork, the `kdd` dependency, install, flow, principles and testing (spec AC 13).
- [ ] No upstream PR policy or telemetry section remains; LICENSE carries the derivation note.

## Test Plan

1. `tests/scripts/test-skill-content.sh` (+9), `tests/scripts/test-invariants.sh`.
