# Adversarial gates

A gate dispatches a subagent whose job is to *break* an artifact, not to
review it. The gates and where they sit:

| Gate | Attacks | Where | When | Seat |
|---|---|---|---|---|
| A1 spec red-team | the draft WRK-SPEC | brainstorming, before the human review gate | always (architectural path) | +1 |
| A2 plan red-team | WRK-PLAN + WRK-TASKs | writing-plans, before handoff | > 4 tasks, or the spec activates `confidence: low`/unverified specs, or the work touches security, money or regulatory logic | +1 |
| A3 rule → test or counterexample | each activated rule a task touches | task reviewer (SDD) and code reviewer | always | 0 (inside the reviewer) |
| A4 break the tests | the task's tests | SDD, after A3 | the task activates `CALC-*` or numeric/business rules, or is security-sensitive | +1 |
| A5 acceptance attack | each WRK-SPEC acceptance criterion | final whole-branch review | always | 0 (inside the final reviewer) |
| A6 FRAG promotion adversary | each claim of a FRAG about to become DOM/ARCH | finishing (consolidation) | whenever a FRAG is promoted | +1 |

## The common contract

- The adversary receives **only the artifact under attack, the material it must be checked against (activated specs, tests, code), and repo access** — never the author's reasoning, the ledger, or the session history.
- Its output is an **attack table**, never an opinion. "I found no problems" without rows is not a report.

```
| Attack | Scenario | Result | Evidence |
|---|---|---|---|
| <what you tried to break> | <concrete input / state / alternative reading> | BROKEN or RESISTED | <path:lines, command output, quoted text> |
```

- Every row is concrete: an input, a state, a reading of a sentence, a rule ID. Abstract worries ("might be ambiguous") are not attacks.
- The adversary does not fix anything and does not dispatch subagents.
- **The controller adjudicates** every `BROKEN` row and ledgers it: `Attack: <row> — Ruling: <accepted → fix | rejected → why>`. A broken attack on a rule of an activated spec is blocking. A broken attack that reveals missing knowledge is also tagged `Knowledge gap:`.
- **Where rulings persist:** A1 rows and rulings go into a `## Adversarial
  Review` section of the WRK-SPEC; A2 rows into a `## Adversarial Review`
  section of the WRK-PLAN; A3–A6 into the SDD ledger (harvested into the
  Execution Log at finishing). A BROKEN row that reveals missing knowledge
  is also written as `Knowledge gap:` in the same place.
- Model: the most capable available for A1, A2 and A6 (a wrong spec or a wrong DOM is the most expensive failure); mid tier for A4.

## Generic dispatch template

```
Subagent (general-purpose):
  description: "Adversary: <gate> on <artifact id>"
  model: [per the table above — REQUIRED]
  prompt: |
    You are an adversary. Your job is to break the artifact below, not to review it.
    Produce an attack table. Rows without a concrete scenario and evidence do not count.

    ## Artifact under attack
    Read: [ARTIFACT_PATH]

    ## What it must hold against
    Read: [MATERIAL_PATHS — activated spec files / brief / tests]

    ## Attacks to attempt (at least one row each)
    [GATE-SPECIFIC LIST — see the gate's prompt file in its skill]

    ## Rules
    - Work read-only. Do not modify files, do not commit, do not dispatch subagents.
    - Every row: Attack · Scenario (concrete) · Result (BROKEN / RESISTED) · Evidence (path:lines, command output, quoted text).
    - If you run something, paste the command and its output as evidence.
    - Return only the table, then one line: `<N> attempted, <M> BROKEN`.
```

Each gate's prompt file (in its skill) is this template with the
gate-specific attack list filled in.
