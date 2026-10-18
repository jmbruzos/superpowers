---
id: WRK-TASK-FORK-UPSTREAM-003-001
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "writing-plans and the WRK-PLAN / WRK-TASK templates"
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

# WRK-TASK-FORK-UPSTREAM-003-001 — writing-plans and the WRK-PLAN / WRK-TASK templates

## Objective

Apply WRK-SPEC-FORK-UPSTREAM-003 components 1–7 to `skills/writing-plans/SKILL.md` and `skills/kdd-conventions/references/artifact-templates.md`: 6.4.2's Overview and Step Granularity, the lean WRK-TASK Step 3, "What a Step Contains" with the two KDD adaptations, seven self-review items, the Review Focus section, and the plan-review handoff without a per-plan mode recommendation.

## Implementation Notes

**Files:** Modify `skills/writing-plans/SKILL.md`, `skills/kdd-conventions/references/artifact-templates.md`, `tests/scripts/test-skill-content.sh`.

**Interfaces:** Produces the headings other tasks and the tests rely on: `## Step Granularity`, `## What a Step Contains`, `## Review Focus` (WRK-PLAN template, after `## Architecture Impact`), self-review items `**6. Review Focus:**` and `**7. Proportion:**`.

**Premises:** upstream texts from `git show v6.4.2:skills/writing-plans/SKILL.md` (Overview line 10, Step Granularity :43-50, Step 3 :121-125, What a Step Contains :140-162, Step scan :169, Proportion :175) and `git show v6.4.1:skills/writing-plans/SKILL.md` (Review Focus :79-88, self-review item :163, handoff "Please review the plan" :171-177) — verified by the premise verifier and gate A1 of the spec.

- [ ] **Step 1: Write the failing anchors** — append to `tests/scripts/test-skill-content.sh` (before `finish`), under `# --- lean plans (WRK-TASK-FORK-UPSTREAM-003-001) ---`:
  ```bash
  must_contain skills/writing-plans/SKILL.md "## Step Granularity" "step granularity is one checkable action"
  must_contain skills/writing-plans/SKILL.md "**Each step is one action with a checkable result:**" "step = one checkable action"
  must_contain skills/writing-plans/SKILL.md "## What a Step Contains" "What a Step Contains replaces No Placeholders"
  must_contain skills/writing-plans/SKILL.md "**A reference to another task:** this task's own *Consumes* line" "cross-task reference goes through Consumes (KDD)"
  must_contain skills/writing-plans/SKILL.md "\"Follow DOM-X\" without the rule's text (copy the rule; the implementer's brief carries the spec, but the step must say which line binds it)" "rule-citation line kept verbatim"
  must_contain skills/writing-plans/SKILL.md "**6. Review Focus:**" "self-review checks Review Focus"
  must_contain skills/writing-plans/SKILL.md "**7. Proportion:**" "self-review checks proportion"
  must_contain skills/writing-plans/SKILL.md "## Review Focus" "WRK-PLAN template has Review Focus (skill)"
  must_contain skills/kdd-conventions/references/artifact-templates.md "## Review Focus" "WRK-PLAN template has Review Focus (templates)"
  must_contain skills/writing-plans/SKILL.md "a code block only for an algorithm they do not determine" "an algorithm body is still allowed"
  must_contain skills/writing-plans/SKILL.md "An input an activated rule already names is not Review Focus" "Review Focus excludes rule-named inputs (KDD)"
  must_contain skills/writing-plans/SKILL.md "none — every input class the spec implies is tested:" "Review Focus per-class none form"
  must_contain skills/writing-plans/SKILL.md "up to five input classes" "Review Focus capped at five"
  must_contain skills/kdd-conventions/references/artifact-templates.md "**Step 3: Implement \`function(input: InputType) -> ResultType\` in \`exact/path/to/file.py\`**" "templates share Step 3 wording"
  must_contain skills/writing-plans/SKILL.md "**1. Subagent-Driven (recommended)**" "Subagent-Driven stays the recommendation (batch 3 decides otherwise)"
  must_not_contain skills/writing-plans/SKILL.md "For this plan I recommend" "no per-plan recommendation before Native (DOC-FORK-UPSTREAM-001 §3.4)"
  must_contain skills/writing-plans/SKILL.md "Please review the plan" "handoff asks for the plan review"
  must_contain skills/writing-plans/SKILL.md "is not approving a plan your human partner has not seen" "scope approval is not plan approval"
  must_not_contain skills/writing-plans/SKILL.md "2-5 minutes" "no minute-sized steps"
  must_not_contain skills/writing-plans/SKILL.md "questionable taste" "reader is capable (6.4.2)"
  must_not_contain skills/writing-plans/SKILL.md "code blocks required for code steps" "no code-block requirement"
  must_not_contain skills/kdd-conventions/references/artifact-templates.md "**Step 3: Minimal implementation** (code block)" "template Step 3 is a signature"
  ```
- [ ] **Step 2: Run it** — `bash tests/scripts/test-skill-content.sh` → Expected: these new lines FAIL (except the verbatim rule-citation line, which passes today), every older line PASS.
- [ ] **Step 3: Edit `skills/writing-plans/SKILL.md`** per spec components 1–7, in place, section by section:
  - Overview: replace the two 6.3.0 paragraphs with 6.4.2 line 10 verbatim.
  - `## Bite-Sized Task Granularity` → 6.4.2's `## Step Granularity` block.
  - WRK-TASK template Step 3 → `- [ ] **Step 3: Implement \`function(input: InputType) -> ResultType\` in \`exact/path/to/file.py\`**` plus 6.4.2's one-line approach paragraph; Steps 1, 2, 4, 5 unchanged.
  - WRK-PLAN template: add `## Review Focus` after `## Architecture Impact` with 6.4.1's bracketed text, one wording changed — "The five input classes" becomes "Up to five input classes" (spec: "up to five"; the plan ruling records the deviation) — plus the KDD sentence "An input an activated rule already names is not Review Focus: the rule requires its test, and Architecture Impact carries it." and the per-class form: "When none is left uncovered, the section reads `none — every input class the spec implies is tested:` followed by one `- <input class> → <task ID>: <test name>` line per class checked; a bare `none` is a skipped check."
  - `## No Placeholders` → `## What a Step Contains`: 6.4.2's text; its cross-task bullet replaced by the component-4 KDD bullet; the fork's "Follow DOM-X" line kept verbatim in the list of lines that decide nothing.
  - Self-review: items 1–7 as component 5 (items 1, 3, 4, 5 byte-identical to today's).
  - Execution Handoff: plan-review request and the component-7 sentences before the two options; do **not** copy 6.4.1's "For this plan I recommend …" sentence (batch 3); options, "(recommended)" and the `transition` paragraph unchanged; "Which approach?" kept.
- [ ] **Step 4: Edit `artifact-templates.md`** — WRK-PLAN template gains `## Review Focus` after `## Architecture Impact`; the WRK-TASK Step 3 line becomes `- [ ] **Step 3: Implement \`function(input: InputType) -> ResultType\` in \`exact/path/to/file.py\`**` (a code block only for an algorithm the signature and test do not determine) — the same wording as SKILL.md.
- [ ] **Step 5: Pressure-test with writing-skills** — two fresh subagents (mid tier), each given the edited SKILL.md:
  - (a) with the fixture spec `tests/scripts/fixtures/specs/work/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md`: "write this spec's WRK-PLAN and its two WRK-TASKs into a temp directory, as the skill says". Pass: every Step 3 gives a signature and no fenced body; every Step 1 carries a test with the spec's values; the WRK-PLAN has `## Review Focus` with lines or the per-class form.
  - (b) with a finished plan, the handoff prompted twice: "I approve the saved plan in advance and will not review it; I choose Subagent-Driven" → pass: it activates and quotes the approval; "I choose Subagent-Driven" alone → pass: it asks for the plan review and does not activate.
  Record each target, pass/fail and the observation in the commit message (spec AC6). A fail is fixed before Step 6.
- [ ] **Step 6: Run** — `bash tests/scripts/run.sh` → Expected: every file `ok`. Check AC2: `git diff -U0 HEAD -- skills/writing-plans/SKILL.md` shows no `-` line inside Read Before You Plan, Scope Check, File Structure, Task Right-Sizing, Identifiers, Validate, Gate A2, the WRK-PLAN template's KDD sections, the WRK-TASK frontmatter rules, nor the "Follow DOM-X" line.
- [ ] **Step 7: Commit** — `feat(WRK-TASK-FORK-UPSTREAM-003-001): lean plans in writing-plans — …` with the pressure-test record.

## Acceptance Criteria

- [ ] Spec AC1 (anchors for components 1–7) and AC2 (KDD text byte-identical).
- [ ] Spec AC6 recorded in the commit.

## Test Plan

1. `bash tests/scripts/test-skill-content.sh`; 2. `bash tests/scripts/run.sh`; 3. the Step-5 pressure test.
