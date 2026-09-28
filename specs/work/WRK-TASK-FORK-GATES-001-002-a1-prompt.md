---
id: WRK-TASK-FORK-GATES-001-002
type: spec
layer: work-task
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "A1 prompt: written spec, Code Premises, Cause column, detail cap"
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

# WRK-TASK-FORK-GATES-001-002 — A1 prompt

## Objective

Rewrite the dispatch template of gate A1 so it attacks the written,
self-reviewed WRK-SPEC instead of a draft, re-verifies the spec's Code
Premises in attack 5, and returns the design-gate table (Cause column,
detail cap with one-line overflow, closing-line breakdown) defined in task
001.

## Implementation Notes

**Files:**
- Modify (full replacement): `skills/brainstorming/spec-adversary-prompt.md`
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes (task 001, exact strings): `| Attack | Scenario | Result | Cause | Evidence |`; `+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>`; `<N> attempted, <M> BROKEN (code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)`; `At most 3 full rows per attack`.
- Produces: placeholder `[WRK_SPEC_PATH]` (task 003's *Gate A1* prose and task 006's scenario rely on the A1 dispatch description `Adversary: A1 spec red-team on <WRK-SPEC-ID>` and on the prompt naming a `specs/work/WRK-SPEC-` path); line `premises re-verified: <N> hold`.

**Premises:** none beyond the WRK-SPEC's Code Premises.

- [ ] **Step 1: Write the failing anchors**

In `tests/scripts/test-skill-content.sh`, replace line

```bash
must_contain skills/brainstorming/spec-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A1 prompt uses the attack table"
```

with

```bash
must_contain skills/brainstorming/spec-adversary-prompt.md "| Attack | Scenario | Result | Cause | Evidence |" "A1 prompt uses the design-gate table"
```

and append before `finish`:

```bash
# --- A1 prompt (WRK-TASK-FORK-GATES-001-002) ---
must_contain skills/brainstorming/spec-adversary-prompt.md "[WRK_SPEC_PATH]" "A1 attacks the written WRK-SPEC"
must_not_contain skills/brainstorming/spec-adversary-prompt.md "DRAFT_PATH" "A1 has no draft input"
must_contain skills/brainstorming/spec-adversary-prompt.md "## Code Premises" "A1 re-verifies Code Premises"
must_contain skills/brainstorming/spec-adversary-prompt.md "premises re-verified: <N> hold" "A1 summarizes premises that hold"
must_contain skills/brainstorming/spec-adversary-prompt.md "At most 3 full rows per attack" "A1 detail cap"
must_contain skills/brainstorming/spec-adversary-prompt.md "+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>" "A1 lists every further BROKEN finding"
must_contain skills/brainstorming/spec-adversary-prompt.md "(code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)" "A1 closing line breakdown"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | grep FAIL`
Expected: 8 FAIL lines naming `spec-adversary-prompt.md` (the replaced header anchor plus the seven appended ones; `A1 has no draft input` fails because `DRAFT_PATH` is still there).

- [ ] **Step 3: Replace `skills/brainstorming/spec-adversary-prompt.md` with exactly:**

`````markdown
# Spec Adversary Prompt (gate A1)

Dispatch after the WRK-SPEC is written, validated and self-reviewed, and
before it is committed and put to your human partner's review. Common
contract, including the design-gate rules (Cause, detail cap, persisted
table): kdd-superpowers:kdd-conventions `references/adversarial-gates.md`.

```
Subagent (general-purpose):
  description: "Adversary: A1 spec red-team on <WRK-SPEC-ID>"
  model: [most capable available — REQUIRED]
  prompt: |
    You are an adversary. Your job is to break a work specification before it is
    committed as the authority for implementation. Produce an attack table.
    Rows without a concrete scenario and evidence do not count.

    ## Artifact under attack
    Read: [WRK_SPEC_PATH] — the written, validated, self-reviewed WRK-SPEC under specs/work/, not yet committed.

    ## What it must hold against
    Read each activated spec: [ACTIVATED_SPEC_PATHS]
    Read each cited fragment: [FRAG_PATHS]
    You have read access to the repository: the code the spec's `## Code Premises` describe is evidence too.

    ## Attacks to attempt (at least one row each)
    1. Rule violation: find a rule in an activated spec that the Proposed Change violates or silently weakens. Quote the rule with its ID and number.
    2. Two readings: find a requirement or acceptance criterion that two competent engineers would implement differently. Give both implementations in one line each.
    3. Trivial satisfaction: find an acceptance criterion that can be met without doing the work (e.g. by returning a constant, by disabling a check). Show how.
    4. Missing knowledge: name a decision the implementation will have to make that no activated spec or fragment settles. Say which spec *should* exist.
    5. Evidence check: for each FRAG-observed behaviour the spec relies on, re-read the anchor and confirm the literal. Re-verify every row of the spec's `## Code Premises` against the code. Find one premise about today's code that the spec relies on but does not list, and check it. Give a row only to what does not hold and to the unlisted premise; put the rest in one line under the table: `premises re-verified: <N> hold`.
    6. Scope leak: find a sentence that commits the work to something outside the stated Problem Statement.

    ## Cause — the first that applies
    - code-reality: assumes something false or unverified about existing code (path, symbol, signature, behaviour, an existing mechanism or integration point).
    - spec-rule: violates or weakens a quoted rule of an activated spec or of a principle the work is constrained by.
    - ambiguity: two readings, a criterion satisfiable without the work, or a step whose expected result cannot tell success from failure.
    - knowledge-gap: a decision no activated spec, fragment or the spec itself settles.
    - internal: inconsistency inside the artifact set: interface mismatch, order trap, uncovered criterion, out-of-set activation, scope leak.

    ## Rules
    - Work read-only. Do not modify files, do not commit, do not dispatch subagents.
    - Every row: Attack · Scenario (concrete) · Result (BROKEN / RESISTED) · Cause (`—` when RESISTED) · Evidence (path:lines, quoted text, command output).
    - At most 3 full rows per attack — the three that would cost most if they reached implementation. List every further BROKEN finding below the table, one line each: `+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>`. Do not list further RESISTED findings.
    - Return only the table, the one-line findings, the premises line, then one line: `<N> attempted, <M> BROKEN (code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)` — M counts full rows and one-liners.

    | Attack | Scenario | Result | Cause | Evidence |
    |---|---|---|---|---|
```
`````

Attacks 1–4 and 6 keep their current wording verbatim (P10); only attack 5 grows.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | tail -3` — Expected: `PASS`.
Run: `bash tests/scripts/run.sh 2>&1 | grep -E '^### |\[FAIL\]' | diff .kdd/baseline-run.txt -` — Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add skills/brainstorming/spec-adversary-prompt.md tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-GATES-001-002): A1 attacks the written spec, re-verifies Code Premises, returns Cause and a detail cap"
```

## Acceptance Criteria

- [ ] The prompt reads `[WRK_SPEC_PATH]`, has no `DRAFT_PATH`, and its header says it runs after write + validate + self-review and before commit (WRK-SPEC AC1, AC3).
- [ ] Attack 5 re-verifies Code Premises, looks for an unlisted one, rows only failing/unlisted premises, summarizes the rest (WRK-SPEC AC3).
- [ ] Five-column table, Cause definitions, detail cap with one-line overflow, closing-line breakdown (WRK-SPEC AC3, AC5).
- [ ] Attacks 1–4 and 6 unchanged word for word (P10, WRK-SPEC AC6).
- [ ] No new test failures against the baseline (WRK-SPEC AC7).

## Test Plan

Steps 1–4. `git diff` of the prompt shows attacks 1–4 and 6 untouched.
