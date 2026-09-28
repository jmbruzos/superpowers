---
id: WRK-TASK-FORK-GATES-001-005
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "writing-plans and A2: Code Premises, Premises line, attack 7, design-gate table"
parent: WRK-PLAN-FORK-GATES-001
activates:
  - DOC-FORK-TOKENS-001@0.1.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-GATES-001
    relation: implements
sources:
  - id: FRAG-FORK-GATES-001
    resource: specs/_capture/FRAG-FORK-GATES-001-adversarial-gate-audit-mdm/
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-28T11:14:33+02:00 }
stale_after: 2026-12-27T11:14:33+01:00
tags: [fork, gates, task]
---

# WRK-TASK-FORK-GATES-001-005 — writing-plans and gate A2

## Objective

Carry code premises into planning and give A2 the design-gate table:
writing-plans reads the spec's Code Premises and asks each task to state
any further premise it relies on; A2 keeps its six attacks and trigger,
gains attack 7 *Code premise*, the Cause column, the detail cap and the
persisted BROKEN table.

## Implementation Notes

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (*Read Before You Plan*; WRK-TASK template *Implementation Notes*; *Gate A2* paragraph)
- Modify (full replacement): `skills/writing-plans/plan-adversary-prompt.md`
- Modify: `skills/kdd-conventions/references/artifact-templates.md` (WRK-TASK body)
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes (task 001, exact strings): `| Attack | Scenario | Result | Cause | Evidence |`; `+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>`; `<N> attempted, <M> BROKEN (code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)`; `At most 3 full rows per attack`; `| Attack | Cause | Evidence | Ruling |`.
- Produces: WRK-TASK line `**Premises:**`.

**Premises:** none beyond the WRK-SPEC's Code Premises.

- [ ] **Step 1: Write the failing anchors**

In `tests/scripts/test-skill-content.sh`, replace line

```bash
must_contain skills/writing-plans/plan-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A2 prompt uses the attack table"
```

with

```bash
must_contain skills/writing-plans/plan-adversary-prompt.md "| Attack | Scenario | Result | Cause | Evidence |" "A2 prompt uses the design-gate table"
```

and append before `finish`:

```bash
# --- writing-plans and A2 (WRK-TASK-FORK-GATES-001-005) ---
must_contain skills/writing-plans/SKILL.md "*Code Premises*" "writing-plans reads the spec's Code Premises"
must_contain skills/writing-plans/SKILL.md "**Premises:**" "WRK-TASK states its own premises"
must_contain skills/writing-plans/SKILL.md "| Attack | Cause | Evidence | Ruling |" "A2 persists the BROKEN table"
must_contain skills/kdd-conventions/references/artifact-templates.md "**Premises:**" "WRK-TASK template has Premises"
must_contain skills/writing-plans/plan-adversary-prompt.md "7. Code premise:" "A2 attack 7"
must_contain skills/writing-plans/plan-adversary-prompt.md "At most 3 full rows per attack" "A2 detail cap"
must_contain skills/writing-plans/plan-adversary-prompt.md "+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>" "A2 lists every further BROKEN finding"
must_contain skills/writing-plans/plan-adversary-prompt.md "(code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)" "A2 closing line breakdown"
must_contain skills/writing-plans/SKILL.md "more than 4 tasks; the spec activates a spec with \`confidence: low\` or no \`verified\`; the work touches security, money or regulatory logic" "A2 trigger unchanged"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | grep FAIL`
Expected: 9 FAIL lines (header plus eight new; `A2 trigger unchanged` passes already).

- [ ] **Step 3: *Read Before You Plan*.** After item `3. Every FRAG the spec cites in `sources` — the observed behaviour the plan must preserve.` add:

```
4. The spec's *Code Premises* — what today's code was verified to do. A task that relies on existing behaviour not in that table states it in its *Implementation Notes* as a `**Premises:**` line with how it was verified (`path:lines` + literal, or command + output) — no sha, no cite-check.
```

- [ ] **Step 4: WRK-TASK template in writing-plans.** Inside the ````` ````markdown ````` WRK-TASK block, immediately after the `**Interfaces:**` bullet list (after the line `  block is how they learn the names and types neighboring tasks use.]`), insert:

```

**Premises:** [existing behaviour this task relies on that the WRK-SPEC's
Code Premises do not list — each with how it was verified (`path:lines` +
literal, or command + output); "none beyond the spec's" otherwise]
```

- [ ] **Step 5: *Gate A2* paragraph.** Replace the sentence

```
The adversary returns an attack table (kdd-superpowers:kdd-conventions `references/adversarial-gates.md`); adjudicate every `BROKEN` row, fix the plan or the tasks, re-validate, and record every `BROKEN` row and its ruling in the WRK-PLAN under `## Adversarial Review`.
```

with

```
The adversary returns an attack table (kdd-superpowers:kdd-conventions `references/adversarial-gates.md`, *Design gates*); adjudicate every `BROKEN` finding — full rows and one-liners — fix the plan or the tasks, re-validate, and record the adversary's closing line and every `BROKEN` finding with its ruling in the WRK-PLAN under `## Adversarial Review` as `| Attack | Cause | Evidence | Ruling |`.
```

The trigger sentence before it stays word for word.

- [ ] **Step 6: WRK-TASK template in `artifact-templates.md`.** In the WRK-TASK body, replace

```
**Interfaces:** Consumes / Produces with exact signatures
```

with

```
**Interfaces:** Consumes / Produces with exact signatures
**Premises:** existing behaviour relied on beyond the WRK-SPEC's Code Premises, each with how it was verified
```

- [ ] **Step 7: Replace `skills/writing-plans/plan-adversary-prompt.md` with exactly:**

`````markdown
# Plan Adversary Prompt (gate A2)

Dispatch before the execution handoff when the plan meets the A2
condition in SKILL.md. Common contract, including the design-gate rules
(Cause, detail cap, persisted table): kdd-superpowers:kdd-conventions
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
    Read the spec: [WRK-SPEC_PATH] — including its `## Code Premises`
    Read each activated spec: [ACTIVATED_SPEC_PATHS]
    You have read access to the repository: the code the tasks modify is evidence too.

    ## Attacks to attempt (at least one row each)
    1. Letter vs rule: find a task that can be completed exactly as written while violating a rule in an activated spec or a row of Architecture Impact. Quote the step and the rule.
    2. Interface mismatch: find two tasks where what one Produces does not match what the other Consumes (name, type, order, error behaviour).
    3. Uncovered criterion: find a WRK-SPEC acceptance criterion that no task's acceptance criteria cover.
    4. Out-of-set activation: find a task whose `activates` names a spec the WRK-SPEC does not activate, or a task that needs a rule from a spec it does not activate.
    5. Untestable step: find a step whose "Expected" cannot distinguish success from failure.
    6. Order trap: find a task that depends on a later task's output.
    7. Code premise: find a task step that relies on behaviour of the existing code that does not hold, or that is neither in the spec's Code Premises nor in the task's `**Premises:**` line with how it was verified. Check it against the code.

    ## Cause — the first that applies
    - code-reality: assumes something false or unverified about existing code (path, symbol, signature, behaviour, an existing mechanism or integration point).
    - spec-rule: violates or weakens a quoted rule of an activated spec or of a principle the work is constrained by.
    - ambiguity: two readings, a criterion satisfiable without the work, or a step whose expected result cannot tell success from failure.
    - knowledge-gap: a decision no activated spec, fragment or the plan settles.
    - internal: inconsistency inside the plan and its tasks: interface mismatch, order trap, uncovered criterion, out-of-set activation, scope leak.

    ## Rules
    - Work read-only. Do not modify files, do not commit, do not dispatch subagents.
    - Every row: Attack · Scenario (concrete) · Result (BROKEN / RESISTED) · Cause (`—` when RESISTED) · Evidence (task ID + step, quoted text, path:lines).
    - At most 3 full rows per attack — the three that would cost most if they reached implementation. List every further BROKEN finding below the table, one line each: `+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>`. Do not list further RESISTED findings.
    - Return only the table, the one-line findings, then one line: `<N> attempted, <M> BROKEN (code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)` — M counts full rows and one-liners.

    | Attack | Scenario | Result | Cause | Evidence |
    |---|---|---|---|---|
```
`````

Attacks 1–6 keep their current wording verbatim (P10).

- [ ] **Step 8: Run the tests to verify they pass**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | tail -3` — Expected: `PASS`.
Run: `bash tests/scripts/run.sh 2>&1 | grep -E '^### |\[FAIL\]' | diff .kdd/baseline-run.txt -` — Expected: no output.

- [ ] **Step 9: Commit**

```bash
git add skills/writing-plans/SKILL.md skills/writing-plans/plan-adversary-prompt.md skills/kdd-conventions/references/artifact-templates.md tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-GATES-001-005): writing-plans carries code premises; A2 gains attack 7, Cause, detail cap and the persisted BROKEN table"
```

## Acceptance Criteria

- [ ] `plan-adversary-prompt.md` keeps attacks 1–6 verbatim, adds attack 7 *Code premise*, and asks for the five-column table, the detail cap with one-line overflow and the breakdown (WRK-SPEC AC4).
- [ ] `writing-plans/SKILL.md` lists Code Premises under *Read Before You Plan* and the `**Premises:**` line in the WRK-TASK template; A2 trigger conditions unchanged (WRK-SPEC AC4).
- [ ] A2 persistence uses `| Attack | Cause | Evidence | Ruling |` (WRK-SPEC AC5).
- [ ] No Red Flags row, rationalization row or approval gate removed (P10, WRK-SPEC AC6).
- [ ] No new test failures against the baseline (WRK-SPEC AC7).

## Test Plan

Steps 1–2 and 8; `git diff` of the prompt shows attacks 1–6 untouched.
