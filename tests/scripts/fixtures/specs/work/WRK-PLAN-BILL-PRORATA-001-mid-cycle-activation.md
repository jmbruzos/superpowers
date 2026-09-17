---
id: WRK-PLAN-BILL-PRORATA-001
type: spec
layer: work-plan
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-11
updated: 2026-09-11
owner: billing-team
title: "Mid-cycle activation billing — implementation plan"
parent: WRK-SPEC-BILL-PRORATA-001
activates:
  - DOM-BILL-PRORATA-001@1.0.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-BILL-PRORATA-001
    relation: implements
  - id: DOM-BILL-PRORATA-001
    relation: constrained-by
generated:
  by: claude-code/test
  at: 2026-09-11T10:00:00+02:00
stale_after: 2026-12-11T10:00:00+01:00
tags: [billing, plan]
---

# WRK-PLAN-BILL-PRORATA-001 — Implementation plan

## Approach

Add a `prorata(fee, day, daysInMonth)` function.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-BILL-PRORATA-001-001 | prorata calculation | — |
| WRK-TASK-BILL-PRORATA-001-002 | billing API endpoint | WRK-TASK-BILL-PRORATA-001-001 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| Round to 2 decimal places, half-up | DOM-BILL-PRORATA-001 | rounding helper in task 001 |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Floating point drift | Medium | Low | integer cents |

## Dependencies

- None.
