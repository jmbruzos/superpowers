---
id: WRK-PLAN-FORK-GATES-002
type: spec
layer: work-plan
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-29
updated: 2026-09-29
owner: jmbruzos
title: "Gates hold their findings — implementation plan"
parent: WRK-SPEC-FORK-GATES-002
activates:
  - DOC-FORK-GATES-001@0.2.0
  - DOC-FORK-TOKENS-001@0.2.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-GATES-002
    relation: implements
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-GATES-002
    resource: specs/work/WRK-SPEC-FORK-GATES-002-gates-hold-their-findings.md
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-29T12:00:00Z
stale_after: 2026-12-28T12:00:00Z
tags: [fork, gates, plan]
---

# WRK-PLAN-FORK-GATES-002 — Gates hold their findings

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** implement WRK-SPEC-FORK-GATES-002 §1–§4 and meet AC1–AC10.

**Architecture:** prose changes to the skills and to the gate contract, the
test anchors that guard them, three scenario-7 assertions, then the two
measurements and the release. The plan has one task, by the human partner's
instruction ("a plan that doesn't need decomposing — be executive"). Gate A2
is skipped by the same instruction: with a single task, the plan-level
attacks (interfaces, order, out-of-set activation) have nothing to find.
Execution is inline, on branch `feat/fork-gates-002`, followed by one final
whole-branch review.

**Tech Stack:** Markdown skills, bash tests, headless Claude Code, kdd
toolkit 1.6.0.

**Spec:** `specs/work/WRK-SPEC-FORK-GATES-002-gates-hold-their-findings.md`
— the plan argues from the spec, so executors read both.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-GATES-002-001 | Everything in WRK-SPEC-FORK-GATES-002 §1–§4 | — |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "it relaxes no existing discipline" | WRK-SPEC-FORK-CORE-001 P10 | Only add sentences and rows. "a broken attack on an activated rule changes the design" stays. |
| "No path contains `superpowers`." | WRK-SPEC-FORK-CORE-001 P13 | The new file lives at `.kdd/brainstorm/<topic>-design.md`. |
| "Re-measure after any change to a workflow skill, a prompt template … append the run to a new FRAG that `supersedes` the latest one" | DOC-FORK-TOKENS-001 §Maintenance | FRAG-FORK-TOKENS-003, from scenario 7 run twice per side. |
| "To compare plugin versions, repeat the FRAG-FORK-GATES-002 method" | DOC-FORK-GATES-001 §Maintenance | K arm with 0.4.0, recorded in FRAG-FORK-GATES-004. |
| "Every BROKEN finding, full row or one-liner, is adjudicated." | adversarial-gates.md | Unchanged; the permitting-quote rule narrows how a rejection is made. |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Measurement noise (n=2) | High | Medium | Report the spread and the direction; do not claim more than the spread allows. |
| Headless runs lost to auth or network | Medium | Low | `CLAUDE_CODE_OAUTH_TOKEN` in `~/.zshenv`; set aside lost runs and re-run them. |

## Dependencies

- kdd toolkit 1.6.0. Headless credentials via `CLAUDE_CODE_OAUTH_TOKEN`.
- The FRAG-FORK-GATES-003 harness in `.kdd/abtest2/` (gitignored).

---
