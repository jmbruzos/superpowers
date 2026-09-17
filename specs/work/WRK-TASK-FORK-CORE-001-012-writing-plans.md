---
id: WRK-TASK-FORK-CORE-001-012
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "writing-plans: WRK-PLAN and WRK-TASK files, gate A2"
parent: WRK-PLAN-FORK-CORE-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-FORK-CORE-001
    relation: implements
sources:
  - id: WRK-SPEC-FORK-CORE-001
    resource: specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-17T00:00:00+02:00
stale_after: 2026-12-16T00:00:00+01:00
tags: [kdd, fork, task, skills]
---

# WRK-TASK-FORK-CORE-001-012 — `writing-plans`: WRK-PLAN and WRK-TASK files, gate A2

## Objective

Make writing-plans take an active WRK-SPEC and produce a WRK-PLAN plus one
WRK-TASK file per task, activations inherited per task, constraints copied
verbatim, validated, with the conditional A2 plan red-team (spec Skill 3;
P1, P3, P5).

## Implementation Notes

**Files:**
- Replace: `skills/writing-plans/SKILL.md` (full text below — upstream sections kept verbatim where unchanged)
- Create: `skills/writing-plans/plan-adversary-prompt.md`
- Modify: `tests/scripts/test-skill-content.sh`
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: active WRK-SPEC (011); `kdd-conventions` templates and `next-id` (009, 003).
- Produces: `specs/work/WRK-PLAN-<path>-<PPP>-<slug>.md` and `specs/work/WRK-TASK-<path>-<PPP>-<TTT>-<slug>.md` files in `status: active` at handoff — the input contract of SDD (013) and executing-plans (014).

- [ ] **Step 1: Add the structural assertions (failing)**

```bash
# --- writing-plans (Task 012) ---
must_contain skills/writing-plans/SKILL.md "status: active" "requires an active WRK-SPEC"
must_contain skills/writing-plans/SKILL.md "one WRK-TASK file per task" "one file per task"
must_contain skills/writing-plans/SKILL.md "WRK-TASK-<path>-<PPP>-<TTT>" "task ID scheme"
must_contain skills/writing-plans/SKILL.md "## Architecture Impact" "Architecture Impact replaces Global Constraints"
must_contain skills/writing-plans/SKILL.md "activates nothing the spec does not" "task activation subset rule"
must_contain skills/writing-plans/SKILL.md "plan-adversary-prompt.md" "gate A2 wired"
must_contain skills/writing-plans/SKILL.md "Activation coverage" "self-review checks activation"
must_contain skills/writing-plans/SKILL.md ".kdd/sdd/" "workspace path named"
must_not_contain skills/writing-plans/SKILL.md "Global Constraints" "no Global Constraints header left"
must_contain skills/writing-plans/plan-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A2 prompt uses the attack table"
```

Run: `bash tests/scripts/test-skill-content.sh` — Expected: new lines FAIL.

- [ ] **Step 2: Replace `skills/writing-plans/SKILL.md`**

```markdown
---
name: writing-plans
description: Use when you have an approved WRK-SPEC for a multi-step task, before touching code — produces the WRK-PLAN and one WRK-TASK per task
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `kdd-superpowers:using-git-worktrees` skill at execution time.

**Input:** a WRK-SPEC in `status: active` (approved in brainstorming). If there is none, or it is still `draft`, stop and go back to kdd-superpowers:brainstorming — there is no planning from free text or from an unapproved spec.

**Output:** one WRK-PLAN plus **one WRK-TASK file per task**, all under `specs/work/`, written per kdd-superpowers:kdd-conventions (REQUIRED SUB-SKILL). Separate task files are what let a subagent read only its task, and what let each task carry its own activations.

## Read Before You Plan

1. The WRK-SPEC — the authority. Its *Constraints* and *Acceptance Criteria* are what the plan must cover.
2. **Every activated spec, in full** (`activates` in the WRK-SPEC frontmatter; find the files with `<kdd-cli> --specs specs filter --format json`). Constraints are copied from these files verbatim, never paraphrased from memory.
3. Every FRAG the spec cites in `sources` — the observed behaviour the plan must preserve.

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, write several WRK-PLANs — one per subsystem, all with the same `parent` — each producing working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in — and where activations get assigned: for each file, which activated spec constrains it.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Identifiers

- Plan: `next-id --prefer <spec number> WRK-PLAN-<spec path>` — a plan takes its spec's number when free.
- Tasks: `WRK-TASK-<path>-<PPP>-<TTT>`, PPP = the plan's number, TTT = the task's position in *Task Breakdown* (001, 002, …). The ID says plan and position without opening the file; use it in commits (`feat(WRK-TASK-…-003): …`).
- Files: `specs/work/<ID>-<lowercase-slug>.md`.

## The WRK-PLAN

Frontmatter per the kdd-conventions template: `layer: work-plan`, `parent: <WRK-SPEC-ID>`, `dependencies` (`implements` the spec, `constrained-by` each activated spec), `activates`/`equips` **⊆ the spec's frozen set with the same pins**, `activation_frozen: true`, `sources` (the spec, the activated specs, the FRAGs), `generated`, `stale_after`, `status: draft`, `confidence: low`.

**Every plan body MUST start with this header:**

```markdown
# <WRK-PLAN-ID> — <title>

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec:** `specs/work/<WRK-SPEC file>` — the plan argues from the spec, so executors read both.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
(table order is execution order)

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
[Every rule from an activated spec that binds this work, **copied verbatim** with its spec ID and rule number; every FRAG-observed behaviour with its anchor. Every task's requirements implicitly include this table — it is what reviewers hold the diff against.]

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|

## Dependencies

---
```

## The WRK-TASK

One file per task. Frontmatter per the template: `layer: work-task`, `parent: <WRK-PLAN-ID>`, `dependencies` (`implements` the plan), **`activates`: the 2–5 specs this task actually touches**, pins inherited — a task **activates nothing the spec does not** (P3); `equips` likewise; `sources` for the FRAGs it relies on; trust family; `status: draft`, `confidence: low`.

````markdown
# <WRK-TASK-ID> — <component name>

## Objective

[What this task delivers and why it exists in the plan — two or three sentences.]

## Implementation Notes

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat(<WRK-TASK-ID>): add specific feature"
```

## Acceptance Criteria

- [ ] [testable; each maps to a WRK-SPEC criterion or to a rule in an activated spec — name it]

## Test Plan

[the tests above, and any integration/regression check]
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task
- "Follow DOM-X" without the rule's text (copy the rule; the implementer's brief carries the spec, but the step must say which line binds it)

## Validate

`<kdd-cli> --specs specs validate` after writing the plan and every task: 0 errors, and no warning naming your files. An artifact that does not validate is not written.

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Activation coverage:** Does every row of *Architecture Impact* cite a spec or a FRAG? Does every task's `activates` stay inside the spec's set? Does every activated spec bind at least one task (otherwise why activate it)?

**5. Roll-up:** Do the tasks' acceptance criteria, taken together, cover every acceptance criterion of the WRK-SPEC?

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Gate A2 — plan red-team (conditional)

Dispatch [plan-adversary-prompt.md](plan-adversary-prompt.md) when **any** of these holds: more than 4 tasks; the spec activates a spec with `confidence: low` or no `verified`; the work touches security, money or regulatory logic. Otherwise skip it and say so. The adversary returns an attack table (kdd-superpowers:kdd-conventions `references/adversarial-gates.md`); adjudicate every `BROKEN` row, fix the plan or the tasks, re-validate.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete: `specs/work/<WRK-PLAN file>` with <N> tasks. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

When your human partner chooses, set `status: active` and `updated` on the plan and every task, re-validate, commit (`plan(<WRK-PLAN-ID>): activate`). The SDD workspace for this plan will be `.kdd/sdd/<WRK-PLAN-ID>/`.

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use kdd-superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use kdd-superpowers:executing-plans
- Batch execution with checkpoints for review
```

- [ ] **Step 3: Write `skills/writing-plans/plan-adversary-prompt.md`**

```markdown
# Plan Adversary Prompt (gate A2)

Dispatch before the execution handoff when the plan meets the A2
condition in SKILL.md. Common contract: kdd-superpowers:kdd-conventions
`references/adversarial-gates.md`.

```
Subagent (general-purpose):
  description: "Adversary: A2 plan red-team on <WRK-PLAN-ID>"
  model: [most capable available — REQUIRED]
  prompt: |
    You are an adversary. Your job is to break an implementation plan before it is
    executed. Produce an attack table. Rows without a concrete scenario and evidence
    do not count.

    ## Artifacts under attack
    Read the plan: [WRK-PLAN_PATH]
    Read every task: [WRK-TASK_PATHS]

    ## What they must hold against
    Read the spec: [WRK-SPEC_PATH]
    Read each activated spec: [ACTIVATED_SPEC_PATHS]

    ## Attacks to attempt (at least one row each)
    1. Letter vs rule: find a task that can be completed exactly as written while violating a rule in an activated spec or a row of Architecture Impact. Quote the step and the rule.
    2. Interface mismatch: find two tasks where what one Produces does not match what the other Consumes (name, type, order, error behaviour).
    3. Uncovered criterion: find a WRK-SPEC acceptance criterion that no task's acceptance criteria cover.
    4. Out-of-set activation: find a task whose `activates` names a spec the WRK-SPEC does not activate, or a task that needs a rule from a spec it does not activate.
    5. Untestable step: find a step whose "Expected" cannot distinguish success from failure.
    6. Order trap: find a task that depends on a later task's output.

    ## Rules
    - Work read-only. Do not modify files, do not commit, do not dispatch subagents.
    - Every row: Attack · Scenario (concrete) · Result (BROKEN / RESISTED) · Evidence (task ID + step, quoted text).
    - Return only the table, then one line: `<N> attempted, <M> BROKEN`.

    | Attack | Scenario | Result | Evidence |
    |---|---|---|---|
```
```

- [ ] **Step 4: Run the tests and commit**

Run: `bash tests/scripts/test-skill-content.sh` — Expected: all `[PASS]`.

```bash
git add skills/writing-plans tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-012): writing-plans produces WRK-PLAN + WRK-TASK files with inherited activation and gate A2"
```

## Acceptance Criteria

- [ ] Skill requires an active WRK-SPEC, writes plan + task files with the ID scheme, verbatim Architecture Impact, per-task activations ⊆ spec, validation, extended self-review, conditional A2, handoff transition (spec AC 6).

## Test Plan

1. `tests/scripts/test-skill-content.sh` (+10).
2. Behavioural scenario in Task 019 (active WRK-SPEC → plan + tasks validate; task activations ⊆ spec).
