---
id: WRK-TASK-DEMO-MONEY-001-002
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: test
title: "formatMoney"
parent: WRK-PLAN-DEMO-MONEY-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-DEMO-MONEY-001
    relation: implements
generated:
  by: claude-code/test
  at: 2026-10-18T12:00:00+02:00
stale_after: 2027-01-16T12:00:00+01:00
tags: [demo, task]
---

# WRK-TASK-DEMO-MONEY-001-002 — formatMoney

## Objective
Format an amount for display.

## Implementation Notes
**Files:** Modify `src/money.js`; create `test/format.test.js`
**Interfaces:** Consumes `roundMoney` (task 001). Produces `export function formatMoney(amount: number): string`.

- [ ] **Step 1: Write the failing test** — `formatMoney(1234.5) === "1234.50 EUR"`, `formatMoney(2.345) === "2.34 EUR"`.
- [ ] **Step 2: Run it to verify it fails** — `npm test` → fails (`formatMoney` not exported).
- [ ] **Step 3: Implement `formatMoney(amount: number): string` in `src/money.js`** — `roundMoney(amount).toFixed(2) + " EUR"`.
- [ ] **Step 4: Run to verify it passes** — `npm test` → all pass.
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(WRK-TASK-DEMO-MONEY-001-002): formatMoney"`

## Acceptance Criteria
- [ ] `formatMoney(1234.5)` returns `"1234.50 EUR"` (spec criterion 2).

## Test Plan
1. `npm test`.
