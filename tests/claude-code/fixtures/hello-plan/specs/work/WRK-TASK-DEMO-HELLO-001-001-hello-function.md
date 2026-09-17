---
id: WRK-TASK-DEMO-HELLO-001-001
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: test
title: "hello function"
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

# WRK-TASK-DEMO-HELLO-001-001 — hello function

## Objective
Create the package and `hello()`.

## Implementation Notes
**Files:** Create `package.json`, `src/hello.js`, `test/hello.test.js`
**Interfaces:** Produces `export function hello(): string`.

- [ ] **Step 1: Write the failing test**
```js
// test/hello.test.js
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { hello } from '../src/hello.js';
test('hello returns the greeting', () => { assert.equal(hello(), 'Hello, World!'); });
```
- [ ] **Step 2: Run it to verify it fails** — `npm test` → fails (module not found). Create `package.json` first: `{ "name": "hello-lib", "version": "0.0.1", "type": "module", "scripts": { "test": "node --test" } }`.
- [ ] **Step 3: Minimal implementation**
```js
// src/hello.js
export function hello() { return 'Hello, World!'; }
```
- [ ] **Step 4: Run to verify it passes** — `npm test` → 1 pass.
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(WRK-TASK-DEMO-HELLO-001-001): hello()"`

## Acceptance Criteria
- [ ] `hello()` returns `"Hello, World!"` (spec criterion 1).

## Test Plan
1. `npm test`.
