---
id: WRK-PLAN-FORK-CORE-001
type: spec
layer: work-plan
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "kdd-superpowers core flow — implementation plan"
parent: WRK-SPEC-FORK-CORE-001
activates: []
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: implements
sources:
  - id: WRK-SPEC-FORK-CORE-001
    resource: specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md
  - id: UPSTREAM
    resource: https://github.com/obra/superpowers/tree/b36e082
    title: superpowers v6.3.0 (fork base)
  - id: KDD-CLI
    resource: ../knowledge-driven-development/kdd-toolkit/cli/spec-graph.mjs@ec3bc83
    title: spec-graph CLI (context/filter JSON shape verified 2026-09-17)
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-17T00:00:00+02:00
stale_after: 2026-12-16T00:00:00+01:00
tags: [kdd, superpowers, fork, plan, claude-code]
---

# WRK-PLAN-FORK-CORE-001 — kdd-superpowers core flow — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Each task is its own file `specs/work/WRK-TASK-FORK-CORE-001-<TTT>-*.md`; steps use checkbox (`- [ ]`) syntax for tracking. (This plan is executed with the *upstream* superpowers 6.3.0 skills — the fork is what is being built — so the sub-skill names above are the upstream ones. Upstream's `task-brief PLAN_FILE N` expects `Task N` headings in one file; here each task is its own file, so the controller passes the WRK-TASK file path itself as the implementer's brief and skips `task-brief`. Upstream's `sdd-workspace` keys the ledger by the plan file's basename under `.superpowers/sdd/` — acceptable scratch during bootstrapping, self-ignored, deleted after the final review.)

## Approach

**Goal:** Turn the superpowers 6.3.0 fork into `kdd-superpowers` 0.1.0: a Claude-Code-only plugin whose skills produce and consume KDD work artifacts, activate frozen knowledge, capture brownfield evidence with anchored claims, run adversarial gates, and close work through consolidation — depending on the `kdd` toolkit plugin for every deterministic and judgment operation on the graph.

**Architecture:** Deletions and identity first (Task 001), then the deterministic tooling layer — fixture, CLI locator, ID allocator, cite-check, workspace, briefs, hook (Tasks 002–008) — each with bash/node tests that run without Claude. Then the shared `kdd-conventions` skill (Task 009) that every workflow skill references, then the workflow skills one by one in pipeline order (Tasks 010–017), each with a structural content test, then docs (018), then the end-to-end headless Claude scenarios (019). Skill text changes preserve upstream's voice and tables (P10) and only replace artifacts and add activated context.

**Tech Stack:** bash (scripts, tests), Node ≥ 18 ESM (`.mjs` brief scripts, no npm dependencies), the `kdd` toolkit's `spec-graph.mjs` CLI (located at runtime), Claude Code plugin manifest, Markdown skills.

**Spec:** `specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md` — read it first; every task cites its principles (P1–P13) and sections.

**Working conventions for every task**

- Work in the fork at the repo root on branch `kdd/core-flow`. Commit after each task with the task ID: `<type>(WRK-TASK-FORK-CORE-001-<TTT>): <summary>`.
- `KDD_SPEC_GRAPH` for local development: `export KDD_SPEC_GRAPH="$(cd .. && pwd)/knowledge-driven-development/apps/spec-graph/spec-graph.mjs"` (the `kdd` plugin is not installed on the dev machine). Tests that need the CLI honour this variable and **skip with a clear message** when no CLI is found.
- `tests/scripts/run.sh` (created in Task 002) runs every `tests/scripts/test-*.sh`; run it at the end of each task from 002 onwards.
- Skill prose: keep "your human partner", keep red-flag/rationalization tables, add rows rather than rewriting them. English only.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-CORE-001-001 | Plugin identity, Claude-only cleanup, namespace rename, invariant test | — |
| WRK-TASK-FORK-CORE-001-002 | Test fixture `specs/`, `kdd-cli` locator, `tests/scripts/run.sh` | 001 |
| WRK-TASK-FORK-CORE-001-003 | `next-id` allocator | 002 |
| WRK-TASK-FORK-CORE-001-004 | `frag-cite-check` | 002 |
| WRK-TASK-FORK-CORE-001-005 | `sdd-workspace` under `.kdd/sdd/<WRK-PLAN-ID>/` (+ `review-package`, `.gitignore`) | 002 |
| WRK-TASK-FORK-CORE-001-006 | `brief-lib.mjs` + `task-brief` | 005 |
| WRK-TASK-FORK-CORE-001-007 | `review-brief` | 006 |
| WRK-TASK-FORK-CORE-001-008 | Session-start hook: `<KDD-ENVIRONMENT>` block, Claude-only output | 002 |
| WRK-TASK-FORK-CORE-001-009 | `kdd-conventions` skill + references (templates, capturing-from-code, adversarial-gates) | 003, 004 |
| WRK-TASK-FORK-CORE-001-010 | `using-superpowers` skill text | 008, 009 |
| WRK-TASK-FORK-CORE-001-011 | `brainstorming` → WRK-SPEC, gate A1, companion paths | 009 |
| WRK-TASK-FORK-CORE-001-012 | `writing-plans` → WRK-PLAN + WRK-TASKs, gate A2 | 009 |
| WRK-TASK-FORK-CORE-001-013 | `subagent-driven-development` skill + prompts, gates A3/A4/A5 | 006, 009 |
| WRK-TASK-FORK-CORE-001-014 | `executing-plans` | 013 |
| WRK-TASK-FORK-CORE-001-015 | `requesting-code-review`, `code-reviewer.md`, `receiving-code-review` | 007, 009 |
| WRK-TASK-FORK-CORE-001-016 | `finishing-a-development-branch`, gate A6 | 009 |
| WRK-TASK-FORK-CORE-001-017 | `verification-before-completion` | 009 |
| WRK-TASK-FORK-CORE-001-018 | README, CLAUDE.md, RELEASE-NOTES, `.github` templates | 001–017 |
| WRK-TASK-FORK-CORE-001-019 | Headless Claude scenario tests + full suite run | 001–018 |

Execution order is the table order. Tasks 003, 004, 005 and 008 are independent of each other and may be batched by the controller if desired; everything from 009 on is sequential.

## Architecture Impact

Constraints inherited from the WRK-SPEC (no knowledge specs are activated; these are the spec's own *Constraints*, copied verbatim):

| Constraint | Source | Impact on plan |
|---|---|---|
| IDs must match `spec-graph`'s `ID_PATTERNS` (`^PREFIX(-[A-Z0-9]+)*-\d{3}$`) — the semantic-path rule places the number last for this reason | WRK-SPEC-FORK-CORE-001 → KDD-CLI-IDS | `next-id` (003) validates the path grammar and allocates the trailing number; all fixture and template IDs follow it |
| `activates` accepts only Knowledge-axis references, `equips` only Agentic-axis references; `FRAG-*` and `lifecycle: deliverable` projections are never activated | WRK-SPEC-FORK-CORE-001 → KDD-MANIFESTS | brief scripts (006, 007) read FRAGs from `sources`, never from `activates`; templates (009) say so |
| Trust family: `generated.by` / `verified[].by` follow the actor convention; `verified` is recorded only after an explicit human confirmation | WRK-SPEC-FORK-CORE-001 → KDD-ANATOMY | templates (009); brainstorming (011) and finishing (016) write `verified` only on approval |
| Fragment `source_type` has no `code` value; code-derived FRAGs use `report` | WRK-SPEC-FORK-CORE-001 → KDD-ANATOMY | fixture FRAG (002) and `capturing-from-code.md` (009) use `source_type: report` |
| Fork skills invoke toolkit skills as `kdd:spec-context`, `kdd:spec-consolidate`; the CLI is invoked only through `scripts/kdd-cli` | WRK-SPEC-FORK-CORE-001 → KDD-TOOLKIT | `kdd-cli` (002) is the only place that knows where `spec-graph.mjs` lives |
| No path in the plugin or in projects it operates on contains `superpowers` (the plugin name and skill directory names are identifiers, not project paths) | WRK-SPEC-FORK-CORE-001 P13 | invariant test (001); workspace (005) and companion (011) move to `.kdd/` |
| Claude Code is the only supported harness | WRK-SPEC-FORK-CORE-001 | cleanup (001); hook emits only the Claude Code JSON shape (008) |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `spec-graph` JSON shapes change in a future toolkit version | Low | Medium | brief scripts depend only on `filter --format json` fields `id`, `file`, `version`, `body` (verified on toolkit @ec3bc83); tests pin the fixture |
| Skill prose edits drift from upstream voice and weaken behaviour | Medium | High | every skill task adds sections/rows instead of rewriting; structural tests assert the upstream anchors are still present; headless scenarios (019) check triggering |
| Headless Claude tests are slow/flaky | Medium | Low | scenario tests live only in 019 and `tests/claude-code/`; everything else is deterministic bash/node |
| Toolkit not installed on a machine | High | Medium | `kdd-cli` search order + `KDD_SPEC_GRAPH`; hook reports `NOT FOUND`; tests skip with a message |

## Dependencies

- `kdd` toolkit CLI at `../knowledge-driven-development/apps/spec-graph/spec-graph.mjs` (dev machine) — `npm install` already done there.
- `node` ≥ 18, `bash`, `git`, `sha256sum`, `jq` (only `scripts/bump-version.sh` uses jq, as upstream).
- Claude Code CLI for Task 019 only.
