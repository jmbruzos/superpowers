---
id: WRK-TASK-FORK-UPSTREAM-003-002
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Review Focus reaches the reviewers; A2 on lean plans"
parent: WRK-PLAN-FORK-UPSTREAM-003
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-003
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T11:53:39+02:00 }
stale_after: 2027-01-16T11:53:39+02:00
tags: [fork, upstream, writing-plans, task]
---

# WRK-TASK-FORK-UPSTREAM-003-002 — Review Focus reaches the reviewers; A2 on lean plans

## Objective

Spec components 8 and 9: the review brief carries the plan's Review Focus, the code reviewer checks each line, requesting-code-review lists it, and A2's attack 1 reads a signature-only step correctly.

## Implementation Notes

**Files:** Modify `skills/kdd-conventions/scripts/brief-lib.mjs` (`buildReviewBrief`), `tests/scripts/test-review-brief.sh`, `skills/requesting-code-review/code-reviewer.md`, `skills/requesting-code-review/SKILL.md`, `skills/writing-plans/plan-adversary-prompt.md`, `tests/scripts/test-skill-content.sh`.

**Interfaces:** Consumes the WRK-PLAN heading `## Review Focus` (task 001). Produces in the review brief the section `## 3b. Review Focus (<WRK-PLAN-ID>)`, right after `## 3. Architecture Impact (…)` — the plan's section verbatim (via the existing `sectionOf(body, 'Review Focus')`), or `_(the plan has no Review Focus section)_`; with no WRK-PLAN at all, `## 3b. Review Focus (no plan)` and `_(no WRK-PLAN for this spec)_`, as section 3 does. Sections 1–5 keep their numbers.

**Premises:** `brief-lib.mjs:127` builds section 3 with `sectionOf(planNode.body || '', 'Architecture Impact')`; `test-review-brief.sh:14` asserts the numbered headings; the fixture plan `tests/scripts/fixtures/specs/work/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md` has no Review Focus — spec premises 7, 10.

- [ ] **Step 1: Write the failing tests**
  - `test-review-brief.sh`: (a) on the fixture as is, the brief contains `## 3b. Review Focus (WRK-PLAN-BILL-PRORATA-001)` and `_(the plan has no Review Focus section)_`; (b) on a copy of the fixture whose plan gains `## Review Focus\n\n- A 31-day month activated on day 31: one day charged.\n` after its Architecture Impact section, the brief contains that bullet verbatim under `## 3b.` and before `## 4. Activated knowledge`; (c) on a copy with the plan removed, the brief contains `## 3b. Review Focus (no plan)` and `_(no WRK-PLAN for this spec)_`.
  - `test-skill-content.sh` anchors: `code-reviewer.md` contains "Review Focus (when the brief has one): for each line, name the test that pins it or give the input that breaks it"; `requesting-code-review/SKILL.md` contains "Review Focus"; `plan-adversary-prompt.md` contains "A step that gives a signature and no body is not a violation by itself".
- [ ] **Step 2: Run them** — `bash tests/scripts/test-review-brief.sh; bash tests/scripts/test-skill-content.sh` → Expected: the new assertions FAIL, older ones PASS.
- [ ] **Step 3: Implement** `buildReviewBrief` section 3b in `brief-lib.mjs` (one `parts.push` after section 3, same placeholder style); add the code-reviewer line under *Knowledge compliance* and "the plan's Review Focus" to its listed brief contents; add Review Focus to the mode-1 row of `requesting-code-review/SKILL.md:36`; append the component-9 sentence to attack 1 of `plan-adversary-prompt.md`.
- [ ] **Step 4: Run** — `bash tests/scripts/run.sh` → Expected: every file `ok`.
- [ ] **Step 5: Commit** — `feat(WRK-TASK-FORK-UPSTREAM-003-002): Review Focus in the review brief and the reviewer; A2 reads signature-only steps`.

## Acceptance Criteria

- [ ] Spec AC3 (present and absent cases; the present case fails before Step 3).
- [ ] Spec AC1 for components 8 and 9.

## Test Plan

1. `bash tests/scripts/test-review-brief.sh`; 2. `bash tests/scripts/run.sh`.
