---
id: WRK-TASK-FORK-CORE-001-013
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "subagent-driven-development: WRK-TASK briefs, three-layer review, gates A3/A4/A5, state transitions"
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

# WRK-TASK-FORK-CORE-001-013 — `subagent-driven-development`: WRK-TASK briefs, three-layer review, gates A3/A4/A5, state transitions

## Objective

Point SDD at a WRK-PLAN and its WRK-TASK files, feed implementers and
reviewers the deterministic brief (task + Architecture Impact + activated
specs + FRAGs), add the *knowledge compliance* verdict and gate A3 to the
task reviewer, the conditional A4 test adversary, the A5 mandate for the
final review, `Knowledge gap:` rulings, and the `completed` transitions
(spec Skill 4; P3, P5, P7).

## Implementation Notes

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md`, `skills/subagent-driven-development/implementer-prompt.md`, `skills/subagent-driven-development/task-reviewer-prompt.md`, `tests/scripts/test-skill-content.sh`
- Create: `skills/subagent-driven-development/test-adversary-prompt.md`
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: `task-brief TASK_FILE` (006) and its section headings (`## 2. Architecture Impact`, `## 3. Activated knowledge`, `## 4. Evidence`); `sdd-workspace` (005); active WRK-PLAN/WRK-TASK files (012); `adversarial-gates.md` (009).
- Produces: ledger lines `Knowledge gap:` and `Attack: … — Ruling: …` that finishing (016) harvests; WRK-TASK/WRK-PLAN `status: completed` that finishing's integrity check requires; the final reviewer mandate consumed via `code-reviewer.md` (015).

- [ ] **Step 1: Add the structural assertions (failing)**

```bash
# --- subagent-driven-development (Task 013) ---
must_contain skills/subagent-driven-development/SKILL.md "scripts/task-brief TASK_FILE" "task-brief takes a WRK-TASK file"
must_contain skills/subagent-driven-development/SKILL.md ".kdd/sdd/<WRK-PLAN-ID>/" "workspace keyed by plan id"
must_contain skills/subagent-driven-development/SKILL.md "Knowledge gap:" "knowledge-gap rulings"
must_contain skills/subagent-driven-development/SKILL.md "PIN DRIFT" "pin drift handled"
must_contain skills/subagent-driven-development/SKILL.md "status: completed" "task completion transition"
must_contain skills/subagent-driven-development/SKILL.md "test-adversary-prompt.md" "gate A4 wired"
must_contain skills/subagent-driven-development/SKILL.md "Gate A5" "gate A5 in final review"
must_not_contain skills/subagent-driven-development/SKILL.md "Global Constraints" "no Global Constraints left"
must_contain skills/subagent-driven-development/implementer-prompt.md "their rules are requirements" "implementer treats knowledge as requirements"
must_contain skills/subagent-driven-development/implementer-prompt.md "Knowledge notes" "implementer reports knowledge notes"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "## Part 2: Knowledge Compliance" "reviewer has knowledge compliance part"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "### Knowledge Compliance" "reviewer outputs knowledge verdict"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "### Capture Candidates" "reviewer outputs capture candidates"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "test that guards it" "gate A3 contract"
must_not_contain skills/subagent-driven-development/task-reviewer-prompt.md "[GLOBAL_CONSTRAINTS]" "no global-constraints placeholder"
must_contain skills/subagent-driven-development/test-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A4 prompt uses the attack table"
```

Run: `bash tests/scripts/test-skill-content.sh` — Expected: new lines FAIL.

- [ ] **Step 2: Edit `SKILL.md` — frontmatter, overview, setup**

(a) Frontmatter `description` → `Use when executing a WRK-PLAN whose WRK-TASKs are independent, in the current session`. First body line → `Execute a WRK-PLAN by dispatching a fresh implementer subagent per WRK-TASK, a task review (spec + knowledge + quality) after each, and a broad whole-branch review at the end.`

(b) In **Rulings, not stalls**, after `Record every decision in the ledger as … and keep going.` add:

```markdown
A ruling that touches knowledge — a task needs a spec outside the frozen
set, an activated rule contradicts the code, a FRAG proved false, a brief
reports PIN DRIFT, an adversary broke an attack that reveals missing
knowledge — is additionally tagged `Knowledge gap: <what is missing or
wrong>`. The activation stays frozen (P3); the gap is harvested at
finishing by consolidation. Never widen `activates` mid-plan.
```

(c) In **Setup**, replace the bullet `Each plan owns a workspace: … (\`<repo-root>/.kdd/sdd/<plan-basename>/\`) …` so it reads:

```markdown
- Each plan owns a workspace: at skill start, run this skill's
  `scripts/sdd-workspace PLAN_FILE` — it prints the plan's git-ignored
  directory (`<repo-root>/.kdd/sdd/<WRK-PLAN-ID>/`), home to every
  artifact for THIS plan: ledger, briefs, reports, review packages.
  Another plan's directory is never yours to read or write.
```

and the ledger-identity bullet to `# SDD ledger — plan: <WRK-PLAN-ID> (<plan file path>)`; the stray-ledger sentence's `old flat path .kdd/sdd/progress.md` stays as is.

(d) Replace the paragraph `Read the plan once, note its context and Global Constraints, and create a todo per task. If the plan names a Spec, read that too: …` with:

```markdown
Read the WRK-PLAN once — *Approach*, *Task Breakdown*, *Architecture
Impact* — and create a todo per row of Task Breakdown, in table order,
keyed by WRK-TASK ID. Read the WRK-SPEC it `implements` (its `parent`):
the spec is the authority the plan argues from, and conflicts inside the
plan resolve against it; the activated specs are the constraints both
must respect. Do not read the task files yourself — `task-brief` hands
each one to its implementer. A plan whose spec is not `active`, or whose
tasks are not `active`, gets a ledger note and a ruling before you start.
```

(e) In the pre-flight scan bullet list (`- tasks that contradict each other or the plan's Global Constraints`), replace `Global Constraints` with `Architecture Impact` and add two bullets:

```markdown
- each task's `activates` against the WRK-SPEC's set — a task activating
  outside it is a plan defect to rule on
- each Architecture Impact row against the current text of its source
  spec (open the file; compare version to the pin) — drift found here is a
  `Knowledge gap:` before any implementer sees it
```

and in the "table, not a verdict" paragraph add one sentence: `One row for every task: its activations against the spec's set, and its constraints against the current spec text.`

- [ ] **Step 3: Edit `SKILL.md` — the task loop**

(a) In **1. Dispatch the implementer**, replace the *Task brief* bullet with:

```markdown
- **Task brief:** before dispatching an implementer, run this skill's
  `scripts/task-brief TASK_FILE` (the WRK-TASK file from Task Breakdown) —
  it writes `<workspace>/<WRK-TASK-ID>-brief.md` and prints the path. The
  brief is deterministic: (1) the full task, (2) the plan's Architecture
  Impact, (3) every activated/equipped spec in full with a **PIN DRIFT**
  header when the pinned version differs from the file, (4) the FRAGs the
  task cites. Compose the dispatch so the brief stays the single source of
  requirements: (a) one line on where this task fits; (b) the brief path,
  introduced as "read this first — it is your requirements, with the exact
  values to use verbatim; sections 2–4 bind you"; (c) interfaces and
  decisions from earlier tasks that the brief cannot know; (d) your
  resolution of any ambiguity you noticed; (e) the report-file path and
  report contract. Never make a subagent read the whole plan or the spec.
  If the brief shows PIN DRIFT, ledger it now as `Knowledge gap:` and tell
  the implementer which text it is actually reading.
```

(b) Rename the report-file convention: `(brief \`…/task-N-brief.md\` → report \`…/task-N-report.md\`)` → `(brief \`…/<WRK-TASK-ID>-brief.md\` → report \`…/<WRK-TASK-ID>-report.md\`)`.

(c) In **2. Handle the report**, after the four statuses add:

```markdown
**Knowledge notes** in any report (rules the code contradicted, behaviour
no spec documents) go to the ledger: contradictions as `Knowledge gap:`,
undocumented behaviour as `Capture candidate: <anchor> — <one line>`.
They never widen the activation and never block the review.
```

(d) In **3. Review the task**, replace the *Reviewer inputs* bullet and the *global-constraints block* bullet (from `- **Reviewer inputs:**` through `…for what THIS project's spec demands.`) with:

```markdown
- **Reviewer inputs:** the task reviewer gets three paths — the same brief
  file (task + Architecture Impact + activated specs + FRAGs), the report
  file, and the review package. The brief's sections 2–4 are the
  reviewer's attention lens: exact values, exact rules, stated
  relationships. Do not paste them again; do not summarize them.
- The reviewer returns **three verdicts**: spec compliance, **knowledge
  compliance** (the diff violates no rule of an activated spec and no
  FRAG-observed behaviour the task cites — a violation is blocking), and
  quality. Its knowledge section applies **gate A3**: for every activated
  rule the diff touches, it names the test that guards it or gives a
  concrete input that would violate it undetected. A named counterexample
  without a test is a Critical finding (missing test), not an opinion.
- **Gate A4 — break the tests (conditional):** when the task activates a
  `CALC-*`, a numeric or business rule, or is security-sensitive, dispatch
  [test-adversary-prompt.md](test-adversary-prompt.md) after a clean A3
  and before completing the task. A `BROKEN` row means the tests admit an
  implementation that violates the task or a rule: it enters the fix loop
  as a Critical finding ("tests insufficient: <scenario>"). Ledger every
  row's ruling (`Attack: … — Ruling: …`).
```

(e) In the sentence `The loop triggers when the review reports spec ❌, any Critical or Important finding, or a ⚠️ item you confirmed as a real gap.` → `The loop triggers when the review reports spec ❌ or knowledge ❌, any Critical or Important finding, a BROKEN A4 attack, or a ⚠️ item you confirmed as a real gap.`

(f) In **5. Complete the task**, before `Then mark the todo complete and move on.` add:

```markdown
Then transition the WRK-TASK: set `status: completed` and `updated:
<today>` in its frontmatter, run `<kdd-cli> --specs specs validate`, and
commit it (`chore(<WRK-TASK-ID>): complete`). A task whose file still says
`active` is not complete, whatever the ledger says.
```

(g) In **Final Review**, after `Point it at the ledger's deferred-minor and parked lines …` add:

```markdown
The final review also gets the review brief: run
`../requesting-code-review/scripts/review-brief PLAN_FILE` and pass the
printed path. Its mandate includes **Gate A5 — acceptance attack**: for
every acceptance criterion of the WRK-SPEC, a scenario that would fail it,
executed where possible, reported as an attack table. Adjudicate BROKEN
rows like task findings (one fix wave, one scoped re-review).

When the final review is clean, transition the WRK-PLAN to
`status: completed` (+ `updated`), validate, commit
(`chore(<WRK-PLAN-ID>): complete`), delete this plan's workspace, and hand
over to kdd-superpowers:finishing-a-development-branch. The WRK-SPEC stays
`active` — finishing closes it.
```

(h) In the example transcript (the block starting `You: I'm using Subagent-Driven Development to execute this plan.`), replace `docs/…/feature-plan.md` occurrences with `specs/work/WRK-PLAN-AUTH-HOOKS-001-hook-installation.md`, `Task 1: Hook installation script` with `WRK-TASK-AUTH-HOOKS-001-001: Hook installation script`, `[Run task-brief for Task 1; …]` with `[Run task-brief specs/work/WRK-TASK-AUTH-HOOKS-001-001-hook-installation-script.md; dispatch implementer with brief + report paths + context]`, and the answer `User level (~/.config/superpowers/hooks/)` with `User level (~/.config/<app>/hooks/)`.

- [ ] **Step 4: Edit `implementer-prompt.md`**

(a) Under `## Task Description`, replace `It contains the full task text from the plan.` with:

```markdown
    It contains the full WRK-TASK, the plan's Architecture Impact, the
    knowledge specs this task activates (in full) and the fragments it
    cites. The specs in sections 2–4 bind you: their rules are requirements,
    not optional context. If a spec block says PIN DRIFT, you are reading a
    newer text than the task was planned against — implement what the task
    says, and note the drift in your report.
```

(b) In `## Your Job`, item 4 `Commit your work` → `Commit your work — every commit subject starts with the task ID: \`<type>(<WRK-TASK-ID>): <summary>\``.

(c) In `## Report Format`, after `- Any issues or concerns` add:

```markdown
    - **Knowledge notes:** activated rules the existing code contradicted
      (rule ID + where), and behaviour you observed that no activated spec
      documents (with `path:lines@sha` and the literal — you report capture
      candidates, you do not write fragments)
```

- [ ] **Step 5: Edit `task-reviewer-prompt.md`**

(a) First body sentence `You are reviewing one task's implementation: first whether it matches its requirements, then whether it is well-built.` → `You are reviewing one task's implementation: whether it matches its requirements, whether it respects the knowledge that binds it, and whether it is well-built.`

(b) Under `## What Was Requested`, replace the two lines `Global constraints from the spec/design that bind this task:` / `[GLOBAL_CONSTRAINTS]` with:

```markdown
    The brief's section 2 (Architecture Impact), section 3 (activated
    specs) and section 4 (cited fragments) are the constraints that bind
    this task. They are your attention lens: exact values, exact rules,
    stated relationships.
```

(c) Insert a new part between `## Part 1: Spec Compliance` and `## Part 2: Code Quality`, and renumber the latter to `## Part 3: Code Quality`:

```markdown
    ## Part 2: Knowledge Compliance

    Compare the diff against the activated specs and cited fragments in the
    brief:

    - **Rule violated:** a change that contradicts a rule of an activated
      spec (quote the rule with its ID and number) or a FRAG-observed
      behaviour the task relies on (quote the anchor). Always Critical.
    - **Rule → test or counterexample (gate A3):** for every activated rule
      the diff touches, either name the test in the diff that guards it
      (file, test name, the assertion), or give one concrete input for
      which the code would violate the rule with no test noticing. A
      counterexample without a guarding test is a Critical finding: "missing
      test for <rule>: <input>".
    - **Knowledge findings:** rules the surrounding code already
      contradicted *before* this diff (not the implementer's fault; the
      controller records a Knowledge gap).
    - **Capture candidates:** behaviour you observed in the code that no
      activated spec documents and this task touches. Each one anchored:
      `path:start-end@sha` plus the literal line, so the controller can write
      a fragment without re-exploring. You do not write fragments.
```

(d) In `## Output Format`, after the `### Spec Compliance` block add:

```markdown
    ### Knowledge Compliance

    - ✅ No activated rule violated | ❌ Violated: [rule ID + number, file:line]
    - Rules touched → guard: [rule → test name, or → counterexample input]

    ### Knowledge Findings
    [pre-existing contradictions, or "none"]

    ### Capture Candidates
    [- `path:start-end@sha`: `literal` — what it embodies; or "none"]
```

(e) In **Placeholders**, replace the `[BRIEF_FILE]` line's parenthesis with `(\`scripts/task-brief TASK_FILE\` prints the path; same file the implementer worked from)` and delete the `[GLOBAL_CONSTRAINTS]` entry. Update `**Reviewer returns:**` to `Spec Compliance verdict (✅/❌/⚠️), Knowledge Compliance verdict (✅/❌) with rule→guard lines, Knowledge Findings, Capture Candidates, Strengths, Issues (Critical/Important/Minor), Task quality verdict`.

- [ ] **Step 6: Write `test-adversary-prompt.md`**

```markdown
# Test Adversary Prompt (gate A4)

Dispatch after a clean A3 when the task activates a `CALC-*`, a numeric
or business rule, or is security-sensitive. Common contract:
kdd-superpowers:kdd-conventions `references/adversarial-gates.md`.

```
Subagent (general-purpose):
  description: "Adversary: A4 break the tests of <WRK-TASK-ID>"
  model: [mid tier — REQUIRED]
  prompt: |
    You are an adversary. Your job is to show that this task's tests are
    insufficient: that an implementation can pass all of them while violating the
    task or a rule it is bound by. Produce an attack table.

    ## Artifacts under attack
    The task's test files: [TEST_FILE_PATHS]

    ## What they must hold against
    Read the brief: [BRIEF_FILE] — section 1 is the task, sections 2–3 the rules.

    ## Attacks to attempt (at least one row each)
    1. Constant return: could an implementation that ignores its inputs pass these tests? Name the constant.
    2. Rule bypass: for each rule in sections 2–3 the task touches, name an input the tests never exercise where the rule matters (boundary, rounding, ordering, empty, negative, overflow, locale).
    3. Assertion strength: find a test whose assertion accepts more than one distinct behaviour (loose matcher, truthiness, "does not throw").
    4. Mocked truth: find a test where the thing under test is mocked away.
    5. Actually try it: write the minimal cheating implementation for your best attack in a scratch file, run the tests against it, and paste the result. Do not commit or leave the file behind.

    ## Rules
    - Do not modify tracked files. Scratch work under /tmp only, removed afterwards.
    - Every row: Attack · Scenario (concrete input or cheating implementation) · Result (BROKEN = the tests pass it / RESISTED) · Evidence (test names, command output).
    - Return only the table, then one line: `<N> attempted, <M> BROKEN`.

    | Attack | Scenario | Result | Evidence |
    |---|---|---|---|
```
```

- [ ] **Step 7: Run the tests and commit**

Run: `bash tests/scripts/test-skill-content.sh` — Expected: all `[PASS]`.
Run: `bash tests/claude-code/test-sdd-workspace.sh` — Expected: PASS (scripts unchanged in this task).

```bash
git add skills/subagent-driven-development tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-013): SDD runs WRK-PLANs with deterministic briefs, knowledge compliance, gates A3/A4/A5 and completion transitions"
```

## Acceptance Criteria

- [ ] SKILL.md: WRK-PLAN input, workspace by plan id, task-brief per task, PIN DRIFT and Knowledge gap handling, three-verdict review, A4 conditional, A5 in final review, `completed` transitions (spec AC 8, 9, 10).
- [ ] Prompts: implementer treats sections 2–4 as requirements and reports Knowledge notes; reviewer has Part 2 Knowledge Compliance with A3 and the two new output sections; no `[GLOBAL_CONSTRAINTS]` placeholder.

## Test Plan

1. `tests/scripts/test-skill-content.sh` (+16).
2. Behavioural scenario in Task 019 (2-task fixture plan → ledger under `.kdd/sdd/<id>/`, `Knowledge gap:` on a reported violation, task file `completed`).
