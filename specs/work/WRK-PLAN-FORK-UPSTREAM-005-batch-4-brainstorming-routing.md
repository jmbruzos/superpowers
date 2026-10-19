---
id: WRK-PLAN-FORK-UPSTREAM-005
type: spec
layer: work-plan
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
title: "Upstream sync batch 4 — brainstorming ideas and routing — implementation plan"
parent: WRK-SPEC-FORK-UPSTREAM-005
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-UPSTREAM-005
    relation: implements
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-UPSTREAM-005
    resource: specs/work/WRK-SPEC-FORK-UPSTREAM-005-batch-4-brainstorming-routing.md
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T12:48:23+02:00
stale_after: 2027-01-16T13:00:00+02:00
tags: [fork, upstream, brainstorming, using-superpowers, plan]
---

# WRK-PLAN-FORK-UPSTREAM-005 — Upstream sync batch 4: brainstorming ideas and routing

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** implement WRK-SPEC-FORK-UPSTREAM-005 components 1–5 and meet AC1–AC6.

**Architecture:** prose rows in brainstorming (001) and using-superpowers (002), each with its anchors and a controller-run pressure test; scenario 9 (003); measurement and release after batch 3's release (004).

**Tech Stack:** Markdown skills, bash tests, headless `claude -p`.

**Spec:** `specs/work/WRK-SPEC-FORK-UPSTREAM-005-batch-4-brainstorming-routing.md`. Upstream text: `git show upstream/main:skills/brainstorming/SKILL.md` (`:52` Get them describing, `:57` How it gets made, `:120` guesses).

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-UPSTREAM-005-001 | brainstorming: how it gets made, open questions first, guesses marked, companion offer | batch 3 released |
| WRK-TASK-FORK-UPSTREAM-005-002 | using-superpowers: spec-ask and spec-tui routes, the unavailable row | 001 |
| WRK-TASK-FORK-UPSTREAM-005-003 | scenario 9 (opt-in) | 002 |
| WRK-TASK-FORK-UPSTREAM-005-004 | pre-register, measure levels 1 and 2, decide, release | 001–003 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "Add rows and sections; do not rewrite tuned prose. An adapted rewrite is pressure-tested with writing-skills, and its commit states the targeted and the observed behaviour." | DOC-FORK-UPSTREAM-001 §3.1 | tasks 001, 002: added lines only except the two the spec names; pressure tests per spec AC5 |
| "`test-skill-content.sh` changes in the same commit as the prose it anchors" | DOC-FORK-UPSTREAM-001 §3.7 | tasks 001, 002 |
| A1 "the written, self-reviewed WRK-SPEC" | DOC-FORK-GATES-001, The gates | task 001 leaves A1 and its order checks untouched |
| "Re-measure after any change to a workflow skill" | DOC-FORK-TOKENS-001, Maintenance | task 004: scenarios 1, 2, 3, 7, 9 |

## Review Focus

none — every input class the spec implies is tested:
- a request that names no platform → WRK-TASK-FORK-UPSTREAM-005-001: pressure test (a)
- a knowledge question asked outside a workflow → WRK-TASK-FORK-UPSTREAM-005-003: scenario 9
- a session whose probe lines read `unavailable` → WRK-TASK-FORK-UPSTREAM-005-002: pressure test (c)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| "open questions first" lengthens interactive brainstorming | medium | time | not observable headless (every prompt says "I will not answer questions"); accepted, noted in the FRAG |
| Level-2 cost | — | ≈ $70–80 | protocol |

## Dependencies

- Batch 3 released (its tag is this batch's before arm; scenario 9 uses batch 3's opt-in helper).

## Execution Log

## Adversarial Review

Gate A2, 2026-10-18 (most capable model): `18 attempted, 13 BROKEN (code-reality 3 · spec-rule 4 · ambiguity 3 · knowledge-gap 0 · internal 3)`. Adjudicated unattended (decision log U-17); all accepted as binding amendments in the tasks, one also amending the spec.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 · pressure tests have no baseline | spec-rule | writing-skills SKILL.md:16,39 | accepted: baseline first (tasks 001, 002) |
| 1 · a failed pressure test still completes the task | ambiguity | tasks 001/002 Step 5 | accepted: fix loop to the cap |
| 2 · scenario 9 without `USAGE_SCENARIO` writes to the wrong dir | code-reality | `usage-lib.sh:26-28` | accepted: `USAGE_SCENARIO=9` |
| 3 · the in-workflow boundary (spec-context) untested | internal | spec component 5 | accepted: scenario 2 check |
| 3 · level-2 pre-flight missing | spec-rule | DOC-FORK-UPSTREAM-001 §4 | accepted: task 004 |
| 5 · the fixture's open work competes with spec-ask | ambiguity | `using-superpowers/SKILL.md:46` | accepted: `specs/work` removed |
| 6 · amend timing | internal | WRK-PLAN-FORK-UPSTREAM-004 + 6 | accepted: before fix rounds and the complete commit |
| 7 · the `unavailable` row's relative kdd-cli path | code-reality | `hooks/session-start:51` | accepted: the hook names the absolute path; spec amended |
| + 3 · worse batch reworked without a human | spec-rule | §4 | accepted: held for the human |
| + 3 · closing the sync (CLAUDE.md/README, batch 5) | spec-rule | §2 | accepted: task 004, batch 5 pending the human |
| + 1 · spike clause unanchored | ambiguity | spec component 1 | accepted: dropped |
| + 1 · pressure test (c) passes on a false NOT FOUND | code-reality | `kdd-cli:28` | accepted: passes only on "found" |
| + 5 · the interactive-length risk is unobservable headless | internal | prompts | accepted: noted, not measured |
