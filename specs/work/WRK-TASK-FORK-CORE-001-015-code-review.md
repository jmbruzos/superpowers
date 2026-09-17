---
id: WRK-TASK-FORK-CORE-001-015
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "requesting-code-review, code-reviewer.md, receiving-code-review"
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

# WRK-TASK-FORK-CORE-001-015 — `requesting-code-review`, `code-reviewer.md`, `receiving-code-review`

## Objective

Give code review its three modes (KDD work / knowledge base without a
WRK-SPEC / pure brownfield), the knowledge-compliance verdict with gate
A3, the A5 acceptance attack before merge, anchored capture candidates,
and the "feedback vs knowledge" rule for receiving feedback (spec Skill 5;
P5, P11, P12).

## Implementation Notes

**Files:**
- Modify: `skills/requesting-code-review/SKILL.md`, `skills/requesting-code-review/code-reviewer.md`, `skills/receiving-code-review/SKILL.md`, `tests/scripts/test-skill-content.sh`
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: `review-brief` (007); `capturing-from-code.md` and `adversarial-gates.md` (009); toolkit `kdd:spec-context`.
- Produces: `{KNOWLEDGE_BRIEF}` placeholder contract used by SDD's final review (013) and finishing (016).

- [ ] **Step 1: Add the structural assertions (failing)**

```bash
# --- code review (Task 015) ---
must_contain skills/requesting-code-review/SKILL.md "scripts/review-brief" "mode 1 uses review-brief"
must_contain skills/requesting-code-review/SKILL.md "kdd:spec-context" "mode 2 uses spec-context"
must_contain skills/requesting-code-review/SKILL.md "Pure brownfield" "mode 3 exists"
must_contain skills/requesting-code-review/SKILL.md "{KNOWLEDGE_BRIEF}" "knowledge brief placeholder"
must_contain skills/requesting-code-review/code-reviewer.md "### Knowledge Compliance" "reviewer outputs knowledge verdict"
must_contain skills/requesting-code-review/code-reviewer.md "### Capture Candidates" "reviewer outputs capture candidates"
must_contain skills/requesting-code-review/code-reviewer.md "Gate A5" "A5 before merge"
must_contain skills/requesting-code-review/code-reviewer.md "test that guards it" "A3 contract"
must_contain skills/receiving-code-review/SKILL.md "## When Feedback Conflicts With Knowledge" "receiving: knowledge rule"
```

- [ ] **Step 2: Edit `skills/requesting-code-review/SKILL.md`**

(a) Replace the `## How to Request` section (from its heading up to `## Example`) with:

```markdown
## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main, or the task's recorded BASE
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Build the knowledge brief — pick the mode that matches what exists:**

| Mode | When | The third layer of authority |
|---|---|---|
| **1. KDD work** | a WRK-SPEC (and usually a WRK-PLAN) exists for this change | `scripts/review-brief <WRK-SPEC-or-WRK-PLAN file>` (this skill's directory) writes one file: acceptance criteria, constraints, the plan's Architecture Impact, every activated spec in full with pin check, the cited FRAGs. Pass the printed path. |
| **2. Knowledge base, no WRK-SPEC** | an external PR, a hotfix, legacy code under review in a project with `specs/` | invoke `kdd:spec-context "<one-line description of the change>"`, confirm with your human partner which surfaced specs apply, and write their paths plus the requirements into a scratch brief file under `.kdd/review/`. Remind them once that a change of their own should have a compact WRK-SPEC (kdd-superpowers:brainstorming, bounded path). |
| **3. Pure brownfield** | no `specs/` at all | the brief is the requirements you were given, in a scratch file. Capture is mandatory: the reviewer must list the rules the code embodies and the change touches. |

The reviewer receives a path, never pasted spec text.

**3. Dispatch code reviewer subagent:**

Dispatch a `general-purpose` subagent, filling the template at [code-reviewer.md](code-reviewer.md)

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{KNOWLEDGE_BRIEF}` - path of the brief from step 2 (mode 1: the review-brief file; modes 2–3: the scratch brief)
- `{MODE}` - `kdd-work`, `knowledge-no-spec` or `brownfield`
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{BEFORE_MERGE}` - `yes` when this review gates a merge or PR (enables gate A5), else `no`

**4. Act on feedback:**
- Fix Critical issues immediately — a violated activated rule is always Critical
- Fix Important issues before proceeding
- Note Minor issues for later
- **Capture candidates:** offer your human partner to write them as FRAGs with kdd-superpowers:kdd-conventions `references/capturing-from-code.md` (cite-check included); inside SDD, ledger them as `Capture candidate:` lines instead
- **Knowledge findings:** ledger as `Knowledge gap:` (SDD) or note them for consolidation
- Push back if reviewer is wrong (with reasoning)
```

(b) In `## Example`, replace `PLAN_OR_REQUIREMENTS: Task 2 from specs/work/deployment-plan.md` (the path was renamed by Task 001) with `KNOWLEDGE_BRIEF: .kdd/sdd/WRK-PLAN-DEPLOY-VERIFY-001/review-brief.md` and add the line `MODE: kdd-work` after it.

(c) Add to `## Common Rationalizations`:

```markdown
| "There's no spec for this repo, so the reviewer can only check style" | The code embodies rules. Mode 3 makes the reviewer surface them as anchored capture candidates — that review *creates* the first knowledge. |
| "The DOM says X but the reviewer says Y is better" | The activated rule wins in this review. If the rule is wrong, that is a Knowledge gap for consolidation, not a silent override. |
```

- [ ] **Step 3: Edit `skills/requesting-code-review/code-reviewer.md`**

(a) Replace the `## Requirements / Plan` block (`## Requirements / Plan` + `[PLAN_OR_REQUIREMENTS]`) with:

```markdown
    ## Requirements and Knowledge

    Mode: [MODE]
    Read the brief: [KNOWLEDGE_BRIEF]
    In mode `kdd-work` it holds the WRK-SPEC's acceptance criteria and
    constraints, the plan's Architecture Impact, the activated specs in
    full and the cited fragments — the WRK-SPEC is the authority, the plan
    its argument, the activated specs its constraints; verify against all
    three. In the other modes it holds the requirements and, when present,
    the specs your human partner confirmed apply.
    Before merge: [BEFORE_MERGE]
```

(b) In `## What to Check`, insert after the **Plan alignment** block:

```markdown
    **Knowledge compliance (all modes with specs):**
    - Does any change contradict a rule of an activated/confirmed spec, or a
      FRAG-observed behaviour the brief cites? Quote rule ID and number. Always Critical.
    - Gate A3: for every rule the diff touches, name the test that guards it
      (file, test name, assertion) or give one concrete input that would violate
      it undetected. A counterexample without a guarding test is Critical:
      "missing test for <rule>: <input>".
    - Knowledge findings: rules the surrounding code already contradicted
      before this diff.

    **Capture candidates (all modes; mandatory in `brownfield`):**
    - Behaviour the code embodies that no spec documents and this diff
      touches: invariants, validations, orderings, formulas, conventions.
      Each one anchored — `path:start-end@sha` plus the literal line — so the
      controller can write a fragment without re-exploring. You do not write
      fragments and you do not guess: no anchor, no candidate.

    **Gate A5 — acceptance attack (only when Before merge is `yes` and the
    brief has acceptance criteria):**
    - For each acceptance criterion, one scenario that would make it fail.
      Execute it when a command or test can (paste the command and output);
      otherwise reason from the diff and say so. Report as an attack table:
      `| Attack | Scenario | Result | Evidence |` with BROKEN / RESISTED.
```

(c) In `## Output Format`, insert after `### Strengths`:

```markdown
    ### Knowledge Compliance

    - ✅ No activated rule violated | ❌ Violated: [rule ID + number, file:line] | n/a (no specs in this mode)
    - Rules touched → guard: [rule → test name, or → counterexample input]

    ### Knowledge Findings
    [pre-existing contradictions, or "none"]

    ### Capture Candidates
    [- `path:start-end@sha`: `literal` — what it embodies; or "none"]

    ### Acceptance Attacks (before merge only)
    | Attack | Scenario | Result | Evidence |
    |---|---|---|---|
```

(d) In **Placeholders** (bottom of the file), replace the `[PLAN_OR_REQUIREMENTS]` line with:

```markdown
- `[KNOWLEDGE_BRIEF]` — path of the brief (review-brief output in mode kdd-work; scratch brief otherwise)
- `[MODE]` — `kdd-work` | `knowledge-no-spec` | `brownfield`
- `[BEFORE_MERGE]` — `yes` | `no` (enables the acceptance attack)
```

- [ ] **Step 4: Edit `skills/receiving-code-review/SKILL.md`**

Insert a new section before `## YAGNI Check for "Professional" Features`:

```markdown
## When Feedback Conflicts With Knowledge

Feedback is checked against the codebase — and the codebase includes the
knowledge graph.

- A comment that contradicts a rule of an activated spec does not win by
  default: the rule does. Verify the rule's text (the spec file, its
  version), then respond with it: "DOM-BILL-PRORATA-001 rule 3 requires
  half-up rounding; this change keeps it. If the rule is wrong, that is a
  spec change."
- If the rule *is* wrong — the reviewer shows it, or the code proves it —
  do not follow the comment silently. Record a `Knowledge gap: <rule> — <why
  it is wrong> — <evidence>` (ledger in SDD; a note for consolidation
  otherwise) so consolidation bumps the spec or opens an ADR. Then decide
  the code change with your human partner, on the record.
- A human reviewer who reveals an undocumented rule ("we always do X here
  because the regulator…") is a capture candidate: note it with
  `source_type: chat`, the human actor and the date, for
  kdd-superpowers:kdd-conventions capture at consolidation.
```

- [ ] **Step 5: Run the tests and commit**

Run: `bash tests/scripts/test-skill-content.sh` — Expected: all `[PASS]`.

```bash
git add skills/requesting-code-review skills/receiving-code-review tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-015): code review in three modes with knowledge compliance, A3/A5 and anchored capture candidates"
```

## Acceptance Criteria

- [ ] Three modes documented with their briefs; reviewer template has Knowledge Compliance, Capture Candidates, A3 and A5; receiving skill has the knowledge-conflict rule (spec AC 9, Skill 5).

## Test Plan

1. `tests/scripts/test-skill-content.sh` (+9).
2. Behavioural scenario in Task 019 (diff violating the fixture DOM rule → Critical with knowledge ❌).
