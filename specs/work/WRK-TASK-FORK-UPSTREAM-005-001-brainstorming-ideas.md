---
id: WRK-TASK-FORK-UPSTREAM-005-001
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "brainstorming: how it gets made, open questions, guesses, companion offer"
parent: WRK-PLAN-FORK-UPSTREAM-005
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-005
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:48:23+02:00 }
stale_after: 2027-01-16T13:00:00+02:00
tags: [fork, upstream, brainstorming, task]
---

# WRK-TASK-FORK-UPSTREAM-005-001 — brainstorming: how it gets made, open questions, guesses, companion offer

## Objective
WRK-SPEC components 1–4 in `skills/brainstorming/SKILL.md`, anchored.

## Implementation Notes
**Files:** Modify `skills/brainstorming/SKILL.md`, `tests/scripts/test-skill-content.sh`.
**Interfaces:** Produces the sentences the spec quotes for components 1–4.
**Premises:** `SKILL.md:185-195` (*Understanding the idea*), `:192` (the menu bullet), `:209-213` (*Presenting the design*), `:296` (offer) — spec premises 1–3.

- [ ] **Step 1: Write the failing anchors** (block `# --- brainstorming ideas (WRK-TASK-FORK-UPSTREAM-005-001) ---`): must_contain "which choices about medium, platform, language and libraries", "a choice you make goes in the design as your call", "Get them describing first", "Mark anything you're guessing as your guess"; must_not_contain "Prefer multiple choice questions when possible", "token-intensive".
- [ ] **Step 2: Run** — `bash tests/scripts/test-skill-content.sh` → Expected: the new lines FAIL; every older line PASS.
- [ ] **Step 3: Edit** the four places with the spec's component text; nothing else changes.
- [ ] **Step 4: Run** — `bash tests/scripts/run.sh`; `git diff -U0 skills/brainstorming/SKILL.md | grep '^-[^-]'` → Expected: exactly the menu bullet and the offer line (spec AC2).
- [ ] **Step 5: Commit** — `feat(WRK-TASK-FORK-UPSTREAM-005-001): brainstorming asks who owns how it gets made, describes before menus, marks guesses`. The controller pressure-tests — (a) a request naming no platform: the question is asked or the default stated as "my call"; (b) the first clarifying question is open; (c) a design section with a guess carries the mark — and resumes you to amend the message.

**Amendments (gate A2, binding):**
- Before Step 3 the controller runs each pressure test (a)–(c) on today's skill (baseline, writing-skills RED); a test that already passes on today's text is recorded as "no change observable" rather than as a pass for the change.
- A pressure test that fails after Step 3 enters a fix loop (resume the implementer with the observation, re-test), up to the SDD fix-round cap; the task completes only when every pressure test passes or a ruling at the cap parks it.
- The amend happens on the implementer's HEAD commit before any fix round and before the task's `chore(…): complete` commit.

## Acceptance Criteria
- [ ] Spec AC1 and AC2 for brainstorming; AC5's three brainstorming pressure tests recorded.

## Test Plan
1. `bash tests/scripts/test-skill-content.sh`; 2. `bash tests/scripts/run.sh`.
