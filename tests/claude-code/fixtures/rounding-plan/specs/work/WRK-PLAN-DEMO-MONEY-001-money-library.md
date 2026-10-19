---
id: WRK-PLAN-DEMO-MONEY-001
type: spec
layer: work-plan
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: test
title: "Money library — implementation plan"
parent: WRK-SPEC-DEMO-MONEY-001
activates:
  - DOM-DEMO-ROUNDING-001@1.0.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-DEMO-MONEY-001
    relation: implements
  - id: DOM-DEMO-ROUNDING-001
    relation: constrained-by
generated:
  by: claude-code/test
  at: 2026-10-18T12:00:00+02:00
stale_after: 2027-01-16T12:00:00+01:00
tags: [demo, plan]
---

# WRK-PLAN-DEMO-MONEY-001 — Money library — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file; steps use checkbox (`- [ ]`) syntax.

## Approach
**Goal:** round and format money. **Architecture:** one module, one test file per function. **Tech Stack:** Node ESM, node --test (`package.json` exists).

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-DEMO-MONEY-001-001 | roundMoney | — |
| WRK-TASK-DEMO-MONEY-001-002 | formatMoney | WRK-TASK-DEMO-MONEY-001-001 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "An amount exactly halfway between two cents rounds to the even cent (banker's rounding)" | DOM-DEMO-ROUNDING-001 rule 2 | task 001 implements it; task 002 must call `roundMoney`, never round itself |
| "'Exactly halfway' is judged on the decimal amount as written (`2.345`), not on its binary floating-point approximation." | DOM-DEMO-ROUNDING-001 rule 4 | task 001 |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| float halves (`2.345 * 100` is `234.49999…`) | high | wrong cent | rule 4 cases in task 001's tests |

## Dependencies

- None.

## Execution Log
