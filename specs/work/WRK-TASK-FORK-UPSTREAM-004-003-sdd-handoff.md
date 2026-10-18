---
id: WRK-TASK-FORK-UPSTREAM-004-003
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "SDD, A4 prompt, orchestrator, handoff"
parent: WRK-PLAN-FORK-UPSTREAM-004
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-LEDGER-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-004
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:30:39+02:00 }
stale_after: 2027-01-16T12:30:00+02:00
tags: [fork, upstream, executing-plans, task]
---

# WRK-TASK-FORK-UPSTREAM-004-003 — SDD, A4 prompt, orchestrator, handoff

## Objective
WRK-SPEC components 5, 6 and 7: SDD's when-to-use, ID-based ledger identity and exit-3 ruling; the A4 prompt's opening sentence; the opt-in orchestrator file; the writing-plans handoff with Native and a per-plan recommendation.

## Implementation Notes
**Files:** Modify `skills/subagent-driven-development/SKILL.md`, `skills/subagent-driven-development/test-adversary-prompt.md`, `skills/writing-plans/SKILL.md`, `tests/scripts/test-skill-content.sh`. Create `skills/subagent-driven-development/claude-code-orchestrator.md`.

**Interfaces:** Consumes the Native skill's name `kdd-superpowers:executing-plans` (task 002). Produces SDD's identity sentence "If its first line names your plan's ID" and the handoff options "**Subagent-driven**" / "**Native**".

**Premises:** SDD when-to-use at `subagent-driven-development/SKILL.md:44-64`, identity check at `:148-153`; handoff at `writing-plans/SKILL.md:240-260`; batch-2 anchors at `test-skill-content.sh` (`grep -n "For this plan I recommend\|Subagent-Driven (recommended)" tests/scripts/test-skill-content.sh`).

- [ ] **Step 1: Write the failing anchors** (block `# --- SDD and handoff (WRK-TASK-FORK-UPSTREAM-004-003) ---`): SDD contains "Partner chose inline, or no subagent tool?", "vs. Executing Plans (inline)", "names your plan's ID", "review-package` exits 3", "claude-code-orchestrator.md"; the A4 prompt contains "after a clean A3 (SDD) or after the task's steps (Native)"; the orchestrator file contains "Rulings I made"; writing-plans contains "**Native**", "For this plan I recommend"; replace the batch-2 `must_not_contain … "For this plan I recommend"` and `must_contain … "**1. Subagent-Driven (recommended)**"` lines; keep "Please review the plan" and "is not approving a plan your human partner has not seen".
- [ ] **Step 2: Run** — `bash tests/scripts/test-skill-content.sh` → Expected: the new lines FAIL.
- [ ] **Step 3: Edit SDD** — upstream's diagram and bullets (`git show upstream/main:skills/subagent-driven-development/SKILL.md:36-58`); the identity check by ID (line 1 starts `# SDD ledger — plan: <WRK-PLAN-ID> `); one sentence for exit 3 under the review package step ("If `review-package` exits 3, the task has no reviewable change: rule on it and ledger the ruling before going on."); one line pointing at the orchestrator.
- [ ] **Step 4: A4 prompt and orchestrator** — the opening sentence of `test-adversary-prompt.md`; `claude-code-orchestrator.md` from upstream's `references/claude-code-tools.md` (title, the orchestration section; superpowers → kdd-superpowers skill names).
- [ ] **Step 5: Handoff** — `writing-plans/SKILL.md` options become upstream's Subagent-driven / Native with their cost sentences and the "For this plan I recommend …" sentence; the batch-2 plan-review text and the `transition` paragraph unchanged; "If Native chosen: REQUIRED SUB-SKILL kdd-superpowers:executing-plans".
- [ ] **Step 6: Run** — `bash tests/scripts/run.sh` → Expected: all `ok`.
- [ ] **Step 7: Commit** — `feat(WRK-TASK-FORK-UPSTREAM-004-003): SDD when-to-use and ID identity, orchestrator, handoff offers Native with a recommendation`. The controller pressure-tests and resumes you to amend the message.

**Amendments (gate A2, binding):**
- SDD's when-to-use node is "Partner chose Native?" (upstream's "…, or no subagent tool?" dropped, §3.8); anchor that text instead of upstream's.
- SDD's resume rule changes too: "a task whose frontmatter says `completed` is DONE" (the signal both modes share), in the same step as the ID identity check; anchored.
- The Native option's cost sentence is adapted: "I implement every task myself in this session; the gates SDD gives a task run only where a rule or a ruling calls for them (A4, a knowledge check), then one fresh reviewer on the most capable model checks the whole branch." — not upstream's "no independent review until the end".
- Step 6 also runs the three other deterministic suites.

## Acceptance Criteria
- [ ] Spec AC4, AC5; AC8 for SDD, the orchestrator and the handoff.

## Test Plan
1. `bash tests/scripts/test-skill-content.sh`; 2. `bash tests/scripts/run.sh`.
