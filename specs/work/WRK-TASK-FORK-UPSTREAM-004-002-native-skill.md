---
id: WRK-TASK-FORK-UPSTREAM-004-002
type: spec
layer: work-task
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
title: "executing-plans as Native, knowledge-check prompt"
parent: WRK-PLAN-FORK-UPSTREAM-004
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-LEDGER-001@0.1.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-004
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:30:39+02:00 }
stale_after: 2027-01-16T12:30:00+02:00
tags: [fork, upstream, executing-plans, task]
---

# WRK-TASK-FORK-UPSTREAM-004-002 — executing-plans as Native, knowledge-check prompt

## Objective
WRK-SPEC components 1 and 4: `skills/executing-plans/SKILL.md` becomes upstream's Native skill with exactly the listed adaptations, and the gate-(b) prompt exists.

## Implementation Notes
**Files:** Modify `skills/executing-plans/SKILL.md`, `tests/scripts/test-skill-content.sh`. Create `skills/executing-plans/knowledge-check-prompt.md`.

**Interfaces:** Consumes task 001's `task-start PLAN_FILE TASK_FILE` and `task-done PLAN_FILE TASK_FILE BASE -- CMD…` (exact usage lines). Produces the skill's description `Use when executing a WRK-PLAN in the current session as the implementer yourself — your human partner chose Native execution` and the prompt file with placeholders `[BRIEF_FILE]`, `[RULING_LINE]`, `[DIFF_FILE]`, `[MODEL]`.

**Premises:** today's skill text and anchors: `executing-plans/SKILL.md:3,14,52`; `test-skill-content.sh` anchors on executing-plans (find with `grep -n executing-plans tests/scripts/test-skill-content.sh`) — keep or replace each in this commit.

- [ ] **Step 1: Write the failing anchors** in `test-skill-content.sh` (block `# --- Native (WRK-TASK-FORK-UPSTREAM-004-002) ---`): must_contain in SKILL.md "scripts/task-start PLAN_FILE TASK_FILE", "scripts/task-done PLAN_FILE TASK_FILE BASE --", "test-adversary-prompt.md", "knowledge-check-prompt.md", "review-brief", "{BEFORE_MERGE}: yes", "a task is done when its frontmatter says `completed`", "finishing-a-development-branch harvests the ledger and deletes"; must_not_contain "A task cannot be completed without violating a rule of an activated spec", "../using-superpowers/references/", "If subagents are available (they are on Claude Code), use kdd-superpowers:subagent-driven-development instead"; must_contain in the prompt file "[RULING_LINE]" and "Knowledge compliance".
- [ ] **Step 2: Run** — `bash tests/scripts/test-skill-content.sh` → Expected: the new lines FAIL.
- [ ] **Step 3: Rewrite SKILL.md** from `git show v6.4.1:skills/executing-plans/SKILL.md` with the adaptations of WRK-SPEC component 1 only (WRK-PLAN/WRK-TASK and task-brief wording; *When to Use* without the no-subagent bullet and the references pointer; *Setup* frontmatter resume rule; `Knowledge gap:` tagging; gates (a)–(c) in the task loop before `task-done`, A4's BROKEN handling; the stop replaced by (b); *Finish* keeps the workspace). Commands are invoked as `bash scripts/task-start …`.
- [ ] **Step 4: Write `knowledge-check-prompt.md`** — a dispatch template in the style of `../subagent-driven-development/re-review-prompt.md`: read-only, no subagents, inputs per Interfaces, output: `### Knowledge compliance` with ✅ / ❌ (rule ID + number, file:line, blocking) and, for the rule the ruling names, the guarding test or a counterexample input.
- [ ] **Step 5: Run** — `bash tests/scripts/run.sh` → Expected: all `ok`. Check P10: `diff <(git show v6.4.1:skills/executing-plans/SKILL.md) skills/executing-plans/SKILL.md` shows only the listed adaptations (list them in the report).
- [ ] **Step 6: Commit** — `feat(WRK-TASK-FORK-UPSTREAM-004-002): executing-plans is Native — inline over WRK-TASKs, every SDD gate before completion`. The controller then pressure-tests and resumes you to amend the message with the record.

**Amendments (gate A2, binding):**
- Adaptations added to Step 3's list: remove *Final Review*'s "Without a subagent tool" subsection and every no-subagent sentence (§3.8); the process diagram's "Final review clean: delete this plan's workspace" node becomes "Final review clean: transition the WRK-PLAN to completed"; after a clean final review the session runs `transition --specs specs <plan file> completed` (as SDD does); *Setup*'s identity check compares the plan **ID** and the identity line is `# SDD ledger — plan: <WRK-PLAN-ID> (<path>)`; the PIN DRIFT handling of today's skill is kept ("If the brief shows PIN DRIFT, ledger it as `Knowledge gap:`").
- Anchors added: must_contain "run before `task-done`" (the gates' order sentence), "wait for its result before `task-done`" (synchronous gates), "Attack: … — Ruling:" and "dispatch it once more on the fixed tests" (A4 BROKEN handling), "transition the WRK-PLAN to completed", "names your plan's ID"; must_not_contain "Without a subagent tool", "delete this plan's workspace", "names your plan file".
- The note forms this prose introduces (`Final: Ruling:`, `Final: minor (deferred):`, `Final: fixed`, `Pre-flight:`, `Attack: … — Ruling:`) are added to `kdd-status-lib.mjs`'s header comment and a `test-kdd-status.sh` case asserts none counts as completion — in this commit (DOC-FORK-LEDGER-001 Maintenance).
- Step 5's P10 criterion: the report maps every hunk of the diff against v6.4.1 to one named adaptation of Step 3; a hunk with no adaptation is a finding.
- Gate (b) is not reachable by the rounding fixture; the controller's pressure test includes a prompt that produces a knowledge ruling and checks (b) is dispatched before `task-done` (recorded as a known gap of scenario 8).
- Step 5 also runs `bash tests/hooks/test-session-start.sh`, `bash tests/claude-code/test-sdd-workspace.sh`, `(cd tests/brainstorm-server && npm test)`.

## Acceptance Criteria
- [ ] Spec AC3; AC8 for the Native skill.

## Test Plan
1. `bash tests/scripts/test-skill-content.sh`; 2. `bash tests/scripts/run.sh`.
