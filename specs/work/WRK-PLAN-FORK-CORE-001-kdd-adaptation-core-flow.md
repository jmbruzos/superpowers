---
id: WRK-PLAN-FORK-CORE-001
type: spec
layer: work-plan
scope: ephemeral
status: completed
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

## Execution Log

Executed 2026-09-17 with upstream superpowers 6.3.0 (subagent-driven-development), 19 tasks, 25 commits (551f06e..4a9bf04), one final-review fix wave. Ledger transcribed here before the workspace was deleted.

### Rulings
- Ruling: execute in the existing checkout on branch kdd/core-flow, not a worktree — the plan's conventions and tests resolve the KDD CLI via `../knowledge-driven-development`, which a worktree under .worktrees/ would break; the branch already isolates from main — costs if wrong: none beyond having to move to a worktree later.
- Ruling: upstream task-brief is skipped; each WRK-TASK file is handed to the implementer as its brief (plan header documents this) — costs if wrong: none.
- Ruling: KDD_SPEC_GRAPH for every dispatch = /home/bruzos/Documentos/projects/knowledge-driven-development/apps/spec-graph/spec-graph.mjs (kdd plugin not installed) — costs if wrong: tests skip instead of running.
- Ruling: rototill design docs are not restored (upstream design history removed by design); the three assertions referencing them were dropped — costs if wrong: none (docs remain in git history).
- Ruling: sourceIds fragility (brief-mandated code) fixed now rather than deferred, because review-brief and skills reuse brief-lib — costs if wrong: none.
- Ruling: probe rewritten to a frontmatter index (brief code violated the spec's "frontmatter layer/status" constraint) — costs if wrong: none.
- Ruling: work count enumerates work-spec|work-plan|work-task exactly (KDD anatomy enum), not a work- prefix — costs if wrong: a future work-* layer would need adding here.
- Ruling: implementer's minimal rewording of two environment-table cells accepted (the brief's assertions could not match its own table markup) — costs if wrong: none.
- Ruling: Final Review must not restate workspace deletion/hand-off; it defers to ## Finish so rulings are collected before deletion — costs if wrong: none.
- Ruling (Task 019): nested `claude -p` runs must unset CLAUDECODE/CLAUDE_CODE_* inherited from this session (env -u) — the brief's script did not anticipate running inside Claude Code — costs if wrong: none.
- Ruling (C1): SDD no longer deletes the workspace; finishing deletes .kdd/sdd/<PLAN-ID>/ after Step 3d (Execution Log committed) — costs if wrong: stale scratch dirs.
- Ruling (I2): bounded brainstorming gets a short review gate of the written compact WRK-SPEC before `verified` (P6 over ceremony) — costs if wrong: one extra question per bounded task.
- Ruling (I3): finishing gains a bounded branch (no plan: skip task/plan checks; Execution Log into the WRK-SPEC); "this plan" = the WRK-PLAN named in conversation/ledger, else ask — costs if wrong: none.
- Ruling (I4): A1/A2 BROKEN rows + rulings persist in a `## Adversarial Review` section of the WRK-SPEC (A1) / WRK-PLAN (A2); finishing harvests them; A1 draft scratch at .kdd/brainstorm/<ID>-draft.md — costs if wrong: an extra body section validate tolerates.
- Ruling (I5): A4 may modify implementation files in the worktree, restored with git stash/checkout, never committed — costs if wrong: none.
- Ruling (I7): frag-cite-check warns on working-tree fallback and gains --strict (used by capturing-from-code step 6) — costs if wrong: none.

### Rulings made during fix loops and the final review
- Final: parked — task-brief/review-brief print the sdd-workspace error twice on failure — Ruling: real but cosmetic, deferred (no second fix wave).
- Final: parked — brainstorming A1 draft is named with the WRK-SPEC ID before next-id allocates it in step 9 — Ruling: the ID is proposed and human-confirmed in the Knowledge activation section (step 7), so the draft can use it; next-id only confirms the number; wording to tighten in sub-project 2.
- Final: parked — finishing Step 3b commit subject has no bounded variant; Step 3d parenthetical about bounded archive is confusing — Ruling: cosmetic, deferred.
- Final: parked — verification-before-completion cites frag-cite-check without --strict — Ruling: deferred; the capture reference (authoritative) uses --strict.

### Knowledge gaps
- none — this work activates no knowledge specs (`activates: []`); framework gaps are recorded in the WRK-SPEC's Open Questions (`source_type: code` for fragments; SDD ledger vs RFC-KDD-003 flow runs; activation manifests; opencode).

### Attacks broken and adjudicated
- none — no adversarial gates ran during this execution (the gates are what this work builds; they apply from the next sub-project on).

### Capture candidates (pending)
- none.

### Parked / deferred
- Task 002: minor (deferred): kdd-cli falls through silently when KDD_SPEC_GRAPH points at a missing file
- Task 002: minor (deferred): test-kdd-cli.sh does not assert exit-code pass-through of the underlying node process
- Task 003: minor (deferred): --prefer not validated numeric (crashes exit 1 on `--prefer abc`); `WRK-TASK-001` (digits-only segment) passes grammar
- Task 004: minor (deferred): working-tree fallback resolves paths relative to $PWD (documented: run from repo root); anchor paths containing ':' are silently skipped
- Task 005: minor (deferred): CRLF plan files fall back to basename (awk compares first line to "---")
- Task 007: minor (deferred): child-plan pick order follows readdir order (toolkit, unsorted); exit-4 path and empty-activates placeholder untested
- Task 008: minor (deferred): frontmatter without a closing --- is still indexed (reads to EOF)
- Task 010: minor (deferred): toolkit row phrasing slightly redundant ("When `toolkit: NOT FOUND`: before …")
- Task 011: minor (deferred): server.cjs isTruthyEnv() is dead code; branding.test.js IIFE has no top-level catch
- Task 012: minor (deferred): skills/writing-plans/plan-document-reviewer-prompt.md is an upstream orphan (unreferenced) — remove in the final wave
- Task 014: minor (deferred): the whole-file replacement dropped the upstream Remember bullet "Never start implementation on main/master branch without explicit user consent" — restore in the final wave
- Task 017: minor (deferred): new red-flag bullet is quote+rebuttal shaped, unlike the gerund bullets around it
- Task 015: minor (deferred): code-reviewer.md "**Reviewer returns:**" one-liner and Example Output do not mention the four new sections; no explicit "Requirements Compliance" verdict line (asymmetric with task-reviewer)
- Task 016: minor (deferred): finishing never states how "this plan" is resolved (the WRK-PLAN being finished); "confirmed the close explicitly" has no crisp trigger — candidates for the final wave
- Task 018: minor (deferred): README install uses `<owner>` placeholder (repo is jmbruzos/superpowers); feature_request.md still has harness fields
- Task 019: minor (deferred): env -u block duplicated in two call sites; Scenario 5 fallback grep hardcodes the fixture plan ID; shellcheck not installed (bash -n used)
- Final: parked — task-brief/review-brief print the sdd-workspace error twice on failure — Ruling: real but cosmetic, deferred (no second fix wave).
- Final: parked — brainstorming A1 draft is named with the WRK-SPEC ID before next-id allocates it in step 9 — Ruling: the ID is proposed and human-confirmed in the Knowledge activation section (step 7), so the draft can use it; next-id only confirms the number; wording to tighten in sub-project 2.
- Final: parked — finishing Step 3b commit subject has no bounded variant; Step 3d parenthetical about bounded archive is confusing — Ruling: cosmetic, deferred.
- Final: parked — verification-before-completion cites frag-cite-check without --strict — Ruling: deferred; the capture reference (authoritative) uses --strict.

### Review record
- Per-task reviews: 001 (1 fix round), 002, 003+004 (batched), 005, 006 (1 fix round), 007, 008 (2 fix rounds), 009, 010, 011, 012, 013 (1 fix round), 014+017 (batched), 015, 016, 018, 019 — all clean.
- Final whole-branch review (opus): 1 Critical (SDD deleted the ledger before finishing could persist it), 9 Important, 11 Minor → one fix wave (4a9bf04) → scoped re-review: all addressed, ready to merge.
- Headless scenarios (tests/claude-code/test-kdd-flow.sh): 6/6 PASS in ~26 min; deterministic suites green.
