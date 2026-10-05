---
id: WRK-PLAN-FORK-MODS-001
type: spec
layer: work-plan
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
title: "kdd-work mod — implementation plan"
parent: WRK-SPEC-FORK-MODS-001
activates: []
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-MODS-001
    relation: implements
sources:
  - id: WRK-SPEC-FORK-MODS-001
    resource: specs/work/WRK-SPEC-FORK-MODS-001-kdd-work-mod.md
  - id: FRAG-FORK-LEDGER-001
    resource: specs/_capture/FRAG-FORK-LEDGER-001-sdd-ledger-line-forms/
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-05T13:30:00+02:00
stale_after: 2027-01-03T13:30:00+01:00
tags: [fork, mods, plan]
---

# WRK-PLAN-FORK-MODS-001 — kdd-work mod

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** an optional Claude Code mod, `kdd-work`, that shows open KDD work live (pane, status line) and keeps pending consolidation visible (band), fed by a deterministic `kdd-status` script.

**Architecture:** `skills/kdd-conventions/scripts/kdd-status` (+ a pure `kdd-status-lib.mjs`) computes the state of open work as JSON through `kdd-cli`, reading only the SDD ledgers itself. `mods/kdd-work/` is a separate plugin of function hooks that locates the main plugin, runs `kdd-status` on relevant events, keeps the result in `$.state` and draws it. Formatting lives in pure functions so it is testable apart from the engine.

**Tech Stack:** Node ESM (no dependencies) and bash tests for the script; TypeScript/TSX function hooks for Claude Code build 2.1.289 (`claude-code` and `claude-code/testing` modules), `claude plugin validate|test`, `tsc`.

**Spec:** `specs/work/WRK-SPEC-FORK-MODS-001-kdd-work-mod.md` — the plan argues from the spec, so executors read both.

**Mod API authority:** the engine's declaration file. Before the mod has loaded: `/private/tmp/claude-501/bundled-skills/2.1.289/b0610be21fa2b284bc6b23b836f226b9/plugin-authoring/types/claude-code.d.ts` (re-written each time the `plugin-authoring` skill loads; after a restart, load that skill to get the current path). After the engine has loaded the mod: `mods/kdd-work/.claude-plugin/types/claude-code/index.d.ts`. The code in tasks 002–003 is written against build 2.1.289; where `tsc` or `claude plugin validate` disagrees with a name in this plan, the declaration file wins — keep the behaviour and the assertion, change the spelling, and ledger the deviation.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-MODS-001-001 | `kdd-status` + `kdd-status-lib.mjs` + `tests/scripts/test-kdd-status.sh` | — |
| WRK-TASK-FORK-MODS-001-002 | Mod core: manifest, contract, root location, refresh, status line, skill recording, tests | 001 |
| WRK-TASK-FORK-MODS-001-003 | Mod UI: `/kdd-work` pane, consolidation band, `/kdd-work dismiss`, tests | 002 |
| WRK-TASK-FORK-MODS-001-004 | Packaging: marketplace entry, invariants, `.gitignore`, release notes, README, manual check | 003 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "Deterministic → CLI; judgment → toolkit skill." | WRK-SPEC-FORK-CORE-001 P4 | All state computation is in task 001's script; the mod (002–003) formats and draws only |
| "No path contains `superpowers`." | WRK-SPEC-FORK-CORE-001 P13 | New paths: `skills/kdd-conventions/scripts/kdd-status`, `kdd-status-lib.mjs`, `mods/kdd-work/`; the mod writes nothing into projects |
| "The only place in kdd-superpowers that knows where spec-graph.mjs lives" | `skills/using-superpowers/scripts/kdd-cli` header | `kdd-status` calls `kdd-cli`; it never names `spec-graph` nor parses spec frontmatter |
| `# SDD ledger — plan: <WRK-PLAN-ID> (<plan file path>)` | FRAG-FORK-LEDGER-001, `subagent-driven-development/SKILL.md:155-155@85acb22` | ledger used only when line 1 starts with `# SDD ledger — plan: <plan id> ` |
| `Task <WRK-TASK-ID>: complete (commits <base7>..<head7>, review clean)` and `[Ledger: Task 1: complete (commits a1b2c3d..d4e5f6a, review clean)]` | FRAG-FORK-LEDGER-001, `SKILL.md:475-475`, `SKILL.md:592-592` | completion by prefix, by id or by position |
| "TTT = position in the plan's Task Breakdown" | kdd-conventions/SKILL.md:24 | `Task <n>` maps to the task whose id ends in `-<n zero-padded to 3>` |
| `collect every ledger line containing` `Ruling:` | FRAG-FORK-LEDGER-001, `SKILL.md:535-535` | ledger tail by containment of `Ruling:` / `Knowledge gap:` |
| finishing requires an `active` WRK-SPEC; a closed-without-archiving one stays pending "until `kdd:spec-consolidate` runs" | `finishing-a-development-branch/SKILL.md:47, 146-148` | band text `run kdd:spec-consolidate <id>` |
| `bump-version.sh` writes `plugins.0.version` only | `.version-bump.json` | `kdd-work` is `plugins[1]`; its versions are bumped by hand; invariant asserts they match |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Mod API names in this plan differ from the build that runs the tests (early access) | medium | task 002/003 stalls on type errors | declaration file is the authority (see Approach); `claude plugin validate` and `tsc` run in each task before tests |
| `claude plugin test` cannot raise `session.start`/`turn.complete` directly | medium | refresh tested only through `tool.call` | tests drive refresh via `$.tool.call` (documented path); the other triggers are covered by the manual check in 004 |
| A real ledger writes lines with a list bullet (`- Task …`) | low | completion missed | lib strips a leading `- ` / `* ` before matching; test covers it |
| `kdd-cli filter` output is large (bodies) | low | slow refresh on big graphs | three `--layer` calls; refresh only on events, debounced |

## Dependencies

- `kdd` toolkit (`spec-graph`) reachable through `kdd-cli` (tests set `KDD_SPEC_GRAPH`).
- Claude Code build with function hooks (2.1.289 used to write this plan); `claude` and `tsc` on PATH for tasks 002–004 (`npx -y -p typescript tsc` when `tsc` is not installed).

## Execution Log

## Adversarial Review
