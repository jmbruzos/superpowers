# Knowledge Check Prompt Template (Native gate (b))

Use this template when a Native task ledgered a `Ruling:` tagged
`Knowledge gap:` about an activated rule. Dispatch it after the task's
steps and before `task-done`, once per such ruling, and wait for its
result. It is not a task review — the whole-branch review runs at the end.

**Purpose:** Verify that the task's change, under the ruling the executor
made, violates no rule of an activated spec — and that the rule the ruling
names is guarded by a test.

```
Subagent (general-purpose):
  description: "Knowledge check <WRK-TASK-ID>"
  model: [MODEL — REQUIRED: mid tier; an omitted model silently inherits
         the session's]
  prompt: |
    You are checking one task's change against the knowledge it is bound
    by. The executor made a ruling that touches an activated rule; your
    job is to say whether the change violates any activated rule, and
    whether the rule the ruling names is guarded — nothing else.

    ## The Task and Its Rules

    Read the task brief: [BRIEF_FILE] — section 1 is the task, section 2
    the plan's Architecture Impact, section 3 the activated specs in full,
    section 4 the fragments the task cites. Sections 2–4 are the rules.

    ## The Ruling Under Check

    [RULING_LINE]

    ## The Change

    **Diff file:** [DIFF_FILE]

    Read the diff file once — it contains the task's commits, a stat
    summary, and the diff with surrounding context. Do not re-run git
    commands to re-derive it.

    Your check is read-only on this checkout. Do not mutate the working
    tree, the index, HEAD, or branch state in any way.

    ## You Do Not Dispatch Subagents

    Do all of this check yourself. Never spawn a subagent, and never
    spawn another reviewer for a second opinion. A reviewer you spawn
    duplicates a seat this process already provides, and its verdict
    counts for nothing.

    ## Scope

    Knowledge compliance only: every rule in sections 2–4 the diff
    touches, and the rule the ruling names. Code quality, style and
    requirements are out of scope — the final review covers them. A
    ruling that narrows, reinterprets or sets aside a rule is not
    permission: a change that satisfies the plan but violates a rule of an
    activated spec is a violation. Only a quote from an activated spec
    that explicitly scopes the rule (an exception to it, or a stated
    precedence over it) makes the change compliant.

    Run a test only to settle a specific doubt about whether a test guards
    the rule — a focused test, never a package-wide suite.

    ## Output Format

    Your final message is the report itself: begin directly with the
    heading. Every line is a verdict with file:line evidence — no
    preamble, no process narration.

    ### Knowledge compliance

    One line per activated rule the diff touches:
    - ✅ <rule ID + number> — complies, <file:line>
    - ❌ <rule ID + number> — <how the change violates it>, <file:line> — blocking

    For the rule the ruling names, one more line:
    - **Guard:** <test name, file:line> that fails if the rule is broken
      — or **Counterexample:** <a concrete input the tests never exercise
      on which the rule is violated undetected> — blocking

    ### Verdict

    **Knowledge check:** [Compliant | Violations: <rule IDs>]
```

**Placeholders:**
- `[MODEL]` — REQUIRED: mid tier
- `[BRIEF_FILE]` — the task's brief, the path `scripts/task-start` printed
- `[RULING_LINE]` — the ledger line of the ruling under check, verbatim
- `[DIFF_FILE]` — the path `../subagent-driven-development/scripts/review-package PLAN_FILE BASE HEAD` printed for the task's range

**The check returns:** one ✅ / ❌ line per activated rule the diff touches,
the guarding test or a counterexample for the rule the ruling names, and a
verdict. Every ❌ and every counterexample is blocking: fix it in the task,
by TDD, before `task-done`.
