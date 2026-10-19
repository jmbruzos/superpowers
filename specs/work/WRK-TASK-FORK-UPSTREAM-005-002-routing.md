---
id: WRK-TASK-FORK-UPSTREAM-005-002
type: spec
layer: work-task
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
title: "using-superpowers: spec-ask, spec-tui, unavailable"
parent: WRK-PLAN-FORK-UPSTREAM-005
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-005
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:48:23+02:00 }
stale_after: 2027-01-16T13:00:00+02:00
tags: [fork, upstream, brainstorming, task]
---

# WRK-TASK-FORK-UPSTREAM-005-002 — using-superpowers: spec-ask, spec-tui, unavailable

## Objective
WRK-SPEC component 5 in `skills/using-superpowers/SKILL.md`, anchored.

## Implementation Notes
**Files:** Modify `skills/using-superpowers/SKILL.md`, `tests/scripts/test-skill-content.sh`.
**Interfaces:** Produces the two *Skill Priority* rows and the environment-table row the spec quotes.
**Premises:** *Skill Priority* at `using-superpowers/SKILL.md:26-34`, environment table at `:36-49` — spec premise 7; the hook's `unavailable (no PATH at session start)` text — premise 9.

- [ ] **Step 1: Write the failing anchors**: must_contain "→ `kdd:spec-ask`", "asked outside a workflow skill", "→ `kdd:spec-tui`", "you never run the viewer", "unavailable (no PATH at session start)", "any other result: NOT FOUND".
- [ ] **Step 2: Run** → Expected: the new lines FAIL.
- [ ] **Step 3: Edit** the two places with the spec's text; the hook injects this file, so `bash tests/hooks/test-session-start.sh` must stay green.
- [ ] **Step 4: Run** — `bash tests/scripts/run.sh`, `bash tests/hooks/test-session-start.sh` → Expected: pass.
- [ ] **Step 5: Commit** — `feat(WRK-TASK-FORK-UPSTREAM-005-002): using-superpowers routes knowledge questions to spec-ask, browsing to spec-tui, and handles an unavailable probe`. The controller pressure-tests — (a) a knowledge question outside a workflow → spec-ask; (b) "browse the specs" → spec-tui prepared, not run; (c) a session start whose four lines read `unavailable` → `kdd-cli --path` run before the first workflow skill — and resumes you to amend the message.

**Amendments (gate A2, binding):**
- `hooks/session-start`: under a broken PATH the `toolkit:` line reads `unavailable (no PATH at session start; check with <PLUGIN_ROOT>/skills/using-superpowers/scripts/kdd-cli --path)`; the other three lines unchanged; `test-session-start.sh`'s empty-PATH case asserts the absolute path in the line; the normal-PATH 0.6.0 parity cases stay green.
- The environment-table row runs that named path; pressure test (c) passes only when the session reports the toolkit **found** (the toolkit is installed in the test).
- Baseline-first pressure tests and the fix loop as in WRK-TASK-FORK-UPSTREAM-005-001's amendments; the amend before the task's complete commit.

## Acceptance Criteria
- [ ] Spec AC1 for using-superpowers; AC5's routing and unavailable pressure tests recorded.

## Test Plan
1. `bash tests/scripts/test-skill-content.sh`; 2. `bash tests/hooks/test-session-start.sh`.
