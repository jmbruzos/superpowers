---
id: WRK-TASK-DEMO-HELLO-001-002
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: test
title: "goodbye function"
parent: WRK-PLAN-DEMO-HELLO-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-DEMO-HELLO-001
    relation: implements
generated:
  by: claude-code/test
  at: 2026-09-17T12:00:00+02:00
stale_after: 2026-12-16T12:00:00+01:00
tags: [demo, task]
---

# WRK-TASK-DEMO-HELLO-001-002 — goodbye function

## Objective
Create `goodbye(name)`.

## Implementation Notes
**Files:** Create `src/goodbye.js`, `test/goodbye.test.js`
**Interfaces:** Produces `export function goodbye(name?: string): string`.

- [ ] **Step 1: Write the failing test**
```js
// test/goodbye.test.js
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { goodbye } from '../src/goodbye.js';
test('goodbye with a name', () => { assert.equal(goodbye('Ana'), 'Goodbye, Ana!'); });
test('goodbye with no argument defaults to World', () => { assert.equal(goodbye(), 'Goodbye, World!'); });
test('goodbye with empty string defaults to World', () => { assert.equal(goodbye(''), 'Goodbye, World!'); });
test('goodbye with null defaults to World', () => { assert.equal(goodbye(null), 'Goodbye, World!'); });
```
- [ ] **Step 2: Run it to verify it fails** — `npm test` → fails (module not found).
- [ ] **Step 3: Minimal implementation**
```js
// src/goodbye.js
export function goodbye(name) {
  if (!name) name = 'World';
  return `Goodbye, ${name}!`;
}
```
- [ ] **Step 4: Run to verify it passes** — `npm test` → all pass.
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(WRK-TASK-DEMO-HELLO-001-002): goodbye()"`

## Acceptance Criteria
- [ ] `goodbye("Ana")` returns `"Goodbye, Ana!"` (spec criterion 2).
- [ ] `goodbye()` / `goodbye("")` / `goodbye(null)` return `"Goodbye, World!"` (spec criterion 3).

## Test Plan
1. `npm test`.
