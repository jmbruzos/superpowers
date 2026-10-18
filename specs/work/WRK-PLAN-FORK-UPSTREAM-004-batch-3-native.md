---
id: WRK-PLAN-FORK-UPSTREAM-004
type: spec
layer: work-plan
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Upstream sync batch 3 — Native execution — implementation plan"
parent: WRK-SPEC-FORK-UPSTREAM-004
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-LEDGER-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-UPSTREAM-004
    relation: implements
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-LEDGER-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-UPSTREAM-004
    resource: specs/work/WRK-SPEC-FORK-UPSTREAM-004-batch-3-native.md
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T12:29:33+02:00
stale_after: 2027-01-16T12:30:00+02:00
tags: [fork, upstream, executing-plans, native, plan]
---

# WRK-PLAN-FORK-UPSTREAM-004 — Upstream sync batch 3: Native execution

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** implement WRK-SPEC-FORK-UPSTREAM-004 components 1–8 and meet AC1–AC6, AC8, AC9; AC7 (level 2b) waits for the human.

**Architecture:** the deterministic part first (scripts, ledger reader, their tests — task 001), then the Native skill and its knowledge-check prompt (002), the SDD / A4-prompt / orchestrator / handoff changes (003), scenario 8 (004), and measurement after batch 2's release (005). The controller runs the writing-skills pressure tests after tasks 002 and 003 (implementers never dispatch subagents).

**Tech Stack:** bash scripts, Node ESM (`kdd-status-lib.mjs`), Markdown skills, headless `claude -p`.

**Spec:** `specs/work/WRK-SPEC-FORK-UPSTREAM-004-batch-3-native.md`. Upstream sources: `git show v6.4.1:skills/executing-plans/SKILL.md`, `git show upstream/main:skills/executing-plans/scripts/{task-start,task-done}`, `git show upstream/main:tests/claude-code/test-executing-plans-scripts.sh`, `git show upstream/main:skills/subagent-driven-development/SKILL.md` (when-to-use), `git show upstream/main:skills/using-superpowers/references/claude-code-tools.md`, `git show upstream/main:skills/writing-plans/SKILL.md` (handoff).

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-UPSTREAM-004-001 | task-start / task-done, their test, kdd-status-lib header and test-kdd-status cases | batch 2 released (\`kdd-superpowers--v0.8.0\`) |
| WRK-TASK-FORK-UPSTREAM-004-002 | executing-plans as Native, knowledge-check prompt | 001 |
| WRK-TASK-FORK-UPSTREAM-004-003 | SDD when-to-use / ID identity / exit 3, A4 prompt sentence, orchestrator, writing-plans handoff | 002 |
| WRK-TASK-FORK-UPSTREAM-004-004 | scenario 8 (opt-in) in test-kdd-flow.sh | 001, 002 |
| WRK-TASK-FORK-UPSTREAM-004-005 | pre-register, measure level 1 after 0.8.0, hold for level 2b | 001–004; batch 2 released |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "An execution mode keeps every gate SDD gives a task, before the task is marked complete. For Native: the task's final test run, A4 when its condition holds, and — after a `Knowledge gap:` ruling on an activated rule — a knowledge-compliance review of that task, all run before the task's `transition … completed` and its ledger completion line; A3 and A5 run in the whole-branch review." | DOC-FORK-UPSTREAM-001 §3.4 | task 002 (skill order), task 001 (task-done transitions only on a passing final run), task 004 (A4 before the complete commit) |
| "a new form or writer changes `kdd-status-lib.mjs` and `test-kdd-status.sh` in the same commit" | DOC-FORK-UPSTREAM-001 §3.5 | task 001 |
| "Claude Code only." | DOC-FORK-UPSTREAM-001 §3.8 | task 002 drops the no-subagent paths |
| "A finished task is a line starting `Task <task>: complete`, always followed by a parenthesised suffix … Readers match the prefix, never the whole line." | DOC-FORK-LEDGER-001, Completion | task 001 |
| "Dispatched gates are synchronous." | DOC-FORK-GATES-001 (via adversarial-gates.md) | task 002: A4 and the knowledge check are waited for |
| "Re-measure after any change to a workflow skill" | DOC-FORK-TOKENS-001, Maintenance | task 005: scenarios 4, 5, 8 |

## Review Focus

- `task-done` re-run after an interruption between the transition commit and the ledger append: the line must appear once with the original range — task 001's re-run case.
- `task-start` given a WRK-TASK of another plan, or a ledger whose line 1 names another plan ID: refused, nothing written — task 001.
- A task whose steps produced no commit reaching `task-done`: refused before the tests run — task 001's empty-range case.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Upstream Native prose reworded beyond the listed adaptations | medium | P10 | task 002 AC: `git diff` against `v6.4.1`'s text limited to the listed adaptations |
| Scenario 8 transcript checks brittle (paraphrased dispatch descriptions) | medium | false failures | recognise gates by description or prompt opening line, as scenario 7 does |
| Level-1 cost (three arms × 2 + scenarios 4, 5 × 2 × 2) | — | ≈ $20–35 on Opus | protocol |

## Dependencies

- Batch 2 released as `kdd-superpowers--v0.8.0` **before task 001 starts**: every batch-3 commit lands after that tag, so the tag (task 005's before arm) holds no batch-3 change. Level 2b and the release wait for the human (spec AC7).
- Pressure tests (tasks 002, 003): the controller runs them after the implementer's commit and before the task's transition commit; the implementer then amends its own HEAD commit's message.

## Execution Log

## Adversarial Review

Gate A2, 2026-10-18 (most capable model): `31 attempted, 26 BROKEN (code-reality 4 · spec-rule 6 · ambiguity 9 · knowledge-gap 0 · internal 7)`. Adjudicated unattended (decision log U-15); all accepted, recorded as binding amendments in the tasks.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 · upstream's "Without a subagent tool" final review survives | spec-rule | §3.8; v6.4.1:253-258 | accepted: task 002 amendment, must_not anchor |
| 1 · gates' order unanchored; gate (b) never triggered | spec-rule | §3.4 | accepted: order and waiting anchors; (b) in the controller's pressure test, a known gap of scenario 8 |
| 1 · skill prose adds ledger note forms without the lib in the same commit | spec-rule | DOC-FORK-LEDGER-001 Maintenance | accepted: task 002 updates the lib header and test-kdd-status |
| 2 · SDD resumes by line, Native by frontmatter; duplicate line | internal | SDD:149 | accepted: SDD's resume rule changes too (task 003); task-done handles "active + line present" (task 001) |
| 2 · tests pass, transition fails: exit undefined | ambiguity | transition:21-23 | accepted: exit 4, nothing recorded, tested |
| 2 · Native's cost sentence says "no independent review until the end" | internal | upstream handoff:192 | accepted: adapted sentence (task 003) |
| 3 · AC9 in no task | internal | plan | accepted: task 005, held with AC7 |
| 3 · AC1's "fails against a stub" never run | ambiguity | spec AC1 | accepted: stub run in task 001 Step 2 |
| 4 · task 002 writes ledger rules without DOC-FORK-LEDGER-001 | internal | task 002 | accepted: activation added (inside the spec's set) |
| 5 · scenario 8's checks first run in the paid measurement | ambiguity | task 004 | accepted: checks in a script tested deterministically |
| 5 · the P10 diff check has no criterion | ambiguity | task 002 Step 5 | accepted: every hunk mapped to a named adaptation |
| 6 · 0.8.0 tag would contain batch-3 commits | code-reality | `git tag -l`; plan | accepted: task 001 waits for the 0.8.0 tag |
| 7 · Native never completes the WRK-PLAN | code-reality | finishing:46-48 | accepted: transition after a clean final review (task 002) |
| 7 · `task-done` transition without `--specs` from another cwd | code-reality | transition:7,26 | accepted: `--specs <root>/specs`, tested from a subdirectory |
| + 1 · SDD node "or no subagent tool?" | spec-rule | §3.8 | accepted: "Partner chose Native?" |
| + 1 · diagram node deletes the workspace | ambiguity | v6.4.1:87 | accepted: replaced, must_not |
| + 1 · Setup compares by plan file | ambiguity | v6.4.1:131-139 | accepted: by ID, anchored |
| + 1 · only `-- true` tested | ambiguity | task 001 | accepted: `-- echo ok` case |
| + 1 · synchronous gates unanchored | spec-rule | plan row | accepted: anchor |
| + 1 · root tested from a same-branch worktree only | spec-rule | §3.5 | accepted: plus a `main` checkout case |
| + 1 · A4 BROKEN handling unanchored | ambiguity | spec 1(a) | accepted: anchors |
| + 3 · other suites not run | internal | §3.7 | accepted: tasks 002, 003, 005 |
| + 4 · task 004 checks GATES rules without activating GATES | internal | task 004 | accepted: activation added |
| + 6 · pressure-test amend timing | internal | plan | accepted: before the transition commit, on the implementer's HEAD |
| + 7 · PIN DRIFT handling dropped | code-reality | executing-plans:30 | accepted: kept as an adaptation |
| + 7 · shared CONFIG_DIR leaks transcripts | ambiguity | test-kdd-flow.sh:37 | accepted: per-scenario transcripts dir |
