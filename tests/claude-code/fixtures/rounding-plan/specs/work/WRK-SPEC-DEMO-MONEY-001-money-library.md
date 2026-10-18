---
id: WRK-SPEC-DEMO-MONEY-001
type: spec
layer: work-spec
scope: ephemeral
status: active
confidence: medium
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: test
title: "Money library — roundMoney and formatMoney"
activates:
  - DOM-DEMO-ROUNDING-001@1.0.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-18T12:00:00+02:00
dependencies:
  - id: DOM-DEMO-ROUNDING-001
    relation: constrained-by
generated:
  by: claude-code/test
  at: 2026-10-18T12:00:00+02:00
verified:
  - by: human:test
    at: 2026-10-18T12:00:00+02:00
stale_after: 2027-01-16T12:00:00+01:00
tags: [demo, money]
---

# WRK-SPEC-DEMO-MONEY-001 — Money library

## Problem Statement
The project needs one place that rounds and formats amounts.

## Proposed Change
`src/money.js` exports `roundMoney(amount: number): number` and
`formatMoney(amount: number): string`; zero dependencies, Node ESM,
`node --test`.

## Knowledge Context
| Activated Spec | Role in this work |
|---|---|
| DOM-DEMO-ROUNDING-001@1.0.0 | the rounding rule `roundMoney` implements |

## Acceptance Criteria
1. `roundMoney` follows DOM-DEMO-ROUNDING-001 rules 1–4.
2. `formatMoney(1234.5)` returns `"1234.50 EUR"`; it rounds with `roundMoney`.
