---
id: WRK-TASK-BILL-PRORATA-001-002
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-11
updated: 2026-09-11
owner: billing-team
title: "billing API endpoint"
parent: WRK-PLAN-BILL-PRORATA-001
activates:
  - DOM-BILL-PRORATA-001@0.9.0
equips: []
dependencies:
  - id: WRK-PLAN-BILL-PRORATA-001
    relation: implements
sources:
  - id: FRAG-BILL-ROUNDING-001
    resource: specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/
generated:
  by: claude-code/test
  at: 2026-09-11T10:00:00+02:00
stale_after: 2026-12-11T10:00:00+01:00
tags: [billing, task]
---

# WRK-TASK-BILL-PRORATA-001-002 — billing API endpoint

## Objective

Expose the calculation over HTTP.

## Implementation Notes

- [ ] Step 1: write the failing test.

## Acceptance Criteria

- [ ] `prorata(30, 15, 30)` returns `16.00`.

## Test Plan

1. Unit test with the example above.
