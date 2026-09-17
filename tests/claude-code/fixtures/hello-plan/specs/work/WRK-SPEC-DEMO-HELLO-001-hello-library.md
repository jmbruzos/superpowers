---
id: WRK-SPEC-DEMO-HELLO-001
type: spec
layer: work-spec
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: test
title: "Hello library"
activates: []
equips: []
activation_frozen: true
generated:
  by: claude-code/test
  at: 2026-09-17T12:00:00+02:00
stale_after: 2026-12-16T12:00:00+01:00
tags: [demo, hello]
---

# WRK-SPEC-DEMO-HELLO-001 — Hello library

## Problem Statement
A tiny ESM library is needed for exercising the execution skills end to end.

## Proposed Change
Two pure functions in `src/`: `hello()` returning `"Hello, World!"` and `goodbye(name)` returning `` `Goodbye, ${name}!` `` (default name `"World"`; empty string or null falls back to the default). Tests with `node --test`.

## Knowledge Context
No knowledge base in this project; `activates: []`.

## Constraints
- Zero dependencies; `package.json` has `"type": "module"` and `"test": "node --test"`.

## Acceptance Criteria
- [ ] `hello()` returns `"Hello, World!"`.
- [ ] `goodbye("Ana")` returns `"Goodbye, Ana!"`; `goodbye()` / `goodbye("")` / `goodbye(null)` return `"Goodbye, World!"`.
- [ ] `npm test` passes.

## Open Questions
- None.
