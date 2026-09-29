# Adversarial gates

A gate dispatches a subagent whose job is to *break* an artifact, not to
review it. The gates and where they sit:

| Gate | Attacks | Where | When | Seat |
|---|---|---|---|---|
| A1 spec red-team | the written WRK-SPEC, after its self-review | brainstorming, before the human review gate | always (architectural path) | +1 |
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
- **Dispatched gates are synchronous.** A1, A2, A4, A6 and the premise
  verifier run as dispatched subagents. Do not take the next step until the
  gate's table is in: no commit or hand-off of the artifact under attack,
  and no final message. In a non-interactive run, ending the turn ends the run:
  dispatch the gate in the foreground, or wait for its result before your
  turn ends. A3 and A5 run inside reviewers and are not dispatched.
- **Where rulings persist:** A1 rows and rulings go into a `## Adversarial
  Review` section of the WRK-SPEC; A2 rows into a `## Adversarial Review`
  section of the WRK-PLAN — both in the table form of *Design gates* below;
  A3–A6 into the SDD ledger (harvested into the
  Execution Log at finishing). A BROKEN row that reveals missing knowledge
  is also written as `Knowledge gap:` in the same place.
- Model: the most capable available for A1, A2 and A6 (a wrong spec or a wrong DOM is the most expensive failure); mid tier for A4.

## Design gates (A1, A2): cause, detail cap, persisted table

A1 and A2 attack designs and plans, where what an adversary finds is also
the measure of how well the author worked. They extend the common contract
with the rules below. A3–A6 and the generic dispatch template are
unchanged.

- **Cause column.** The table is
  `| Attack | Scenario | Result | Cause | Evidence |`; RESISTED rows carry
  `—`. Cause is the first of these that applies:
  - `code-reality` — the artifact assumes something false or unverified
    about existing code: a path, symbol, signature, behaviour, an existing
    mechanism or integration point.
  - `spec-rule` — violates or weakens a quoted rule of an activated spec or
    of a principle the work is constrained by.
  - `ambiguity` — two readings, an acceptance criterion satisfiable without
    the work, or a step whose expected result cannot tell success from
    failure.
  - `knowledge-gap` — a decision no activated spec, fragment or the artifact
    settles.
  - `internal` — inconsistency inside the artifact set: interface mismatch,
    order trap, uncovered criterion, out-of-set activation, scope leak.

  A rejected finding is not a cause; rejection lives in the ruling.
- **Detail cap, nothing dropped.** At least one row per attack.
  At most 3 full rows per attack — the three that would cost most if they
  reached implementation. Every further BROKEN finding of that attack goes
  below the table, one line each:
  `+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>`.
  RESISTED findings beyond the cap are not listed. Every BROKEN finding,
  full row or one-liner, is adjudicated.
- **Closing line.**
  `<N> attempted, <M> BROKEN (code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)`
  — M counts full rows and one-liners.
- **Persisted form.** `## Adversarial Review` holds the closing line and
  one row per BROKEN finding, full rows and one-liners alike. RESISTED rows
  are not persisted.

```
<N> attempted, <M> BROKEN (code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| <attack # — what broke, one line> | <cause> | <path:lines, command output> | <accepted → fix | rejected → why> |
```

### Rejecting a `spec-rule` finding (A1, A2)

- A BROKEN finding whose Cause is `spec-rule` may be rejected only by
  quoting the literal text of a rule that **permits** the design, from an
  activated spec or from a principle the work is `constrained-by`: ID,
  section and literal.
- Not a permitting quote: the WRK-SPEC or WRK-PLAN itself; a narrower reading of the violated rule; the violated rule quoted back.
- Without a permitting quote the finding is **accepted**: the artifact
  changes to satisfy the rule, and
  `Knowledge gap: contested rule — <ID> § <section>: <the disagreement>`
  records it. Consolidation reads that line as a candidate clarification of
  the rule, not as missing knowledge.
- A rejection with a quote is persisted as `rejected → <ID> § <section> "<literal>"`.
- When the permitting quote comes from another activated rule that
  contradicts the violated one, the finding stands and
  `Knowledge gap: conflict — <ID §> vs <ID §>` is recorded; resolving it
  means changing one of the specs, which is the human partner's call.
- In A1 the human partner adjudicates under the same rule: disagreeing with
  an activated rule means changing that spec, not rejecting the finding.

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
