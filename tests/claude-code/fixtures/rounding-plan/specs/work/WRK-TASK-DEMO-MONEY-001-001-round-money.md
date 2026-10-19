---
id: WRK-TASK-DEMO-MONEY-001-001
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: test
title: "roundMoney"
parent: WRK-PLAN-DEMO-MONEY-001
activates:
  - DOM-DEMO-ROUNDING-001@1.0.0
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

# WRK-TASK-DEMO-MONEY-001-001 — roundMoney

## Objective
Implement the rounding rule DOM-DEMO-ROUNDING-001 as `roundMoney`.

## Implementation Notes
**Files:** Create `src/money.js`, `test/round.test.js`
**Interfaces:** Produces `export function roundMoney(amount: number): number`.

- [ ] **Step 1: Write the failing test** — `test/round.test.js`, one `node:test` case per example of DOM-DEMO-ROUNDING-001 rules 2 and 3: `2.345 → 2.34`, `2.355 → 2.36`, `0.005 → 0`, `0.015 → 0.02`, `2.3449 → 2.34`, `2.3451 → 2.35`, `-2.345 → -2.34`, `-0.015 → -0.02`.
- [ ] **Step 2: Run it to verify it fails** — `npm test` → fails (module not found).
- [ ] **Step 3: Implement `roundMoney(amount: number): number` in `src/money.js`** — decide halves on the decimal string (`amount.toString()`), not on `amount * 100` (rule 4).
- [ ] **Step 4: Run to verify it passes** — `npm test` → 8 pass.
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(WRK-TASK-DEMO-MONEY-001-001): roundMoney"`

## Acceptance Criteria
- [ ] Every example of DOM-DEMO-ROUNDING-001 rules 2 and 3 holds (spec criterion 1).

## Test Plan
1. `npm test`.
