---
name: writing-plans
description: Use when you have an approved WRK-SPEC for a multi-step task, before touching code — produces the WRK-PLAN and one WRK-TASK per task
---

# Writing Plans

## Overview

Write implementation plans for an engineer who has not seen this codebase or this spec. Assume they write idiomatic code in the project's language once they know the exact interface and the exact test, and that they will make a reasonable choice wherever the plan leaves one open. What they cannot know is what you decided: which files, which names and signatures, which values from the spec, which tests prove each task. Document those. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `kdd-superpowers:using-git-worktrees` skill at execution time.

**Input:** a WRK-SPEC in `status: active` (approved in brainstorming). If there is none, or it is still `draft`, stop and go back to kdd-superpowers:brainstorming — there is no planning from free text or from an unapproved spec.

**Output:** one WRK-PLAN plus **one WRK-TASK file per task**, all under `specs/work/`, written per kdd-superpowers:kdd-conventions (REQUIRED SUB-SKILL). Separate task files are what let a subagent read only its task, and what let each task carry its own activations.

## Read Before You Plan

1. The WRK-SPEC — the authority. Its *Constraints* and *Acceptance Criteria* are what the plan must cover.
2. **Every activated spec, in full** (`activates` in the WRK-SPEC frontmatter; find the files with `<kdd-cli> --specs specs filter --format json`). Constraints are copied from these files verbatim, never paraphrased from memory.
3. Every FRAG the spec cites in `sources` — the observed behaviour the plan must preserve.
4. The spec's *Code Premises* — what today's code was verified to do. A task that relies on existing behaviour not in that table states it in its *Implementation Notes* as a `**Premises:**` line with how it was verified (`path:lines` + literal, or command + output) — no sha, no cite-check.

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

## Step Granularity

**Each step is one action with a checkable result:**
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

## Review Focus

[Up to five input classes or failure modes the spec implies but no task's
tests exercise that are most likely to bite a person using this software
— one line each, naming the input or condition and the behavior a
reasonable person would expect, most likely first. The spec is a vision
document: it says what the software must do, not everything it will
meet, and its silence on an input is not permission for that input to
break the program. Write the list here, once, with the spec in front of
you. Then, for each line, add the test that pins it to the task that
owns the code, in that task's own step style. An input an activated rule already names is not Review Focus: the rule requires its test, and Architecture Impact carries it. When none is left uncovered, the section reads `none — every input class the spec implies is tested:` followed by one `- <input class> → <task ID>: <test name>` line per class checked; a bare `none` is a skipped check.]

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

**Premises:** [existing behaviour this task relies on that the WRK-SPEC's
Code Premises do not list — each with how it was verified (`path:lines` +
literal, or command + output); "none beyond the spec's" otherwise]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Implement `function(input: InputType) -> ResultType` in `exact/path/to/file.py`**

One line on the approach when the signature and the test leave a choice (which library call, which data structure);
a code block only for an algorithm they do not determine.

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

## What a Step Contains

A step is done when the implementer can write exactly one reasonable thing
from it. That is the whole requirement: unambiguous, not complete. Each kind
of step carries what makes it unambiguous and nothing more:

- **A test step:** the test's name and its assertions, as code, with the
  spec's exact values in them.
- **A code step:** the exact signature (name, parameters, return type), the
  file it lives in, and the specific values the spec pins. The implementer
  writes the body. A body appears only for an algorithm the signature and
  tests do not determine, or for exact copy the spec fixes.
- **A verification step:** the command to run and the output that means it
  passed.
- **A reference to another task:** this task's own *Consumes* line repeats the exact signature it uses — the implementer sees only this task's brief.

A plan is the set of decisions the implementer cannot make alone. A plan
longer than the code it describes has written the code instead. Lines that
decide nothing are the opposite failure, and the self-review catches both:
- "TBD", "handle edge cases", "add appropriate validation", "write tests for the above", a type or function no task defines
- "Follow DOM-X" without the rule's text (copy the rule; the implementer's brief carries the spec, but the step must say which line binds it)

## Validate

`<kdd-cli> --specs specs validate` after writing the plan and every task: 0 errors, and no warning naming your files. An artifact that does not validate is not written.

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Step scan:** Every step must let the implementer write exactly one reasonable thing, and no step may carry more than that: a line that decides nothing is a gap, a function body the signature and tests already determine is a transcript. Fix both.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Activation coverage:** Does every row of *Architecture Impact* cite a spec or a FRAG? Does every task's `activates` stay inside the spec's set? Does every activated spec bind at least one task (otherwise why activate it)?

**5. Roll-up:** Do the tasks' acceptance criteria, taken together, cover every acceptance criterion of the WRK-SPEC?

**6. Review Focus:** For each input class or failure mode the spec implies, is there a task whose tests exercise it? The uncovered ones most likely to bite a person go in the Review Focus section (up to five input classes), and each line there gets its test added to the owning task. A section with nothing uncovered uses the per-class `none` form, which shows you checked, not that you skipped the check.

**7. Proportion:** Compare the bodies (frontmatter excluded) of the WRK-PLAN and its WRK-TASKs to the WRK-SPEC's body. A plan several times longer than the spec it implements is a transcript of the program, not a plan. If code blocks are most of the document, replace bodies with signatures, test names and assertions, and check that each step is still unambiguous.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Gate A2 — plan red-team (conditional)

Dispatch [plan-adversary-prompt.md](plan-adversary-prompt.md) when **any** of these holds: more than 4 tasks; the spec activates a spec with `confidence: low` or no `verified`; the work touches security, money or regulatory logic. Otherwise skip it and say so. Wait for its table before any next step — no commit, no execution hand-off and no final message while it is pending. The adversary returns an attack table (kdd-superpowers:kdd-conventions `references/adversarial-gates.md`, *Design gates*); adjudicate every `BROKEN` finding — full rows and one-liners (a `spec-rule` finding is rejected only with a permitting quote, per the same reference) — fix the plan or the tasks, re-validate, and record the adversary's closing line and every `BROKEN` finding with its ruling in the WRK-PLAN under `## Adversarial Review` as `| Attack | Cause | Evidence | Ruling |`.

## Execution Handoff

After saving and self-reviewing the plan (and after Gate A2, when it ran), link it for your human partner to read and ask them to review it before anything runs: no choice is acted on, and nothing is activated, until they have reviewed the plan or approved it in advance as below. Approving the spec or the scope is not approving a plan your human partner has not seen. An approval given in advance that names the plan itself ("I approve … the plan in advance") counts, and is quoted in the activation commit message; an approval of the design or the scope does not. Then offer the execution choice:

**"Plan complete: `specs/work/<WRK-PLAN file>` with <N> tasks. Please review the plan. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

When your human partner chooses, set `status: active` and `updated` on the plan and every task, re-validate, commit (`plan(<WRK-PLAN-ID>): activate`) — `kdd-conventions/scripts/transition --no-commit <file> active` on the plan and on each task, then that one commit. The SDD workspace for this plan will be `.kdd/sdd/<WRK-PLAN-ID>/`.

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use kdd-superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use kdd-superpowers:executing-plans
- Batch execution with checkpoints for review
