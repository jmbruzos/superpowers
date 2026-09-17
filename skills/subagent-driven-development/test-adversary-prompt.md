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
