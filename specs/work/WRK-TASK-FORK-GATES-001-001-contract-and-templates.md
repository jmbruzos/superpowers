---
id: WRK-TASK-FORK-GATES-001-001
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "Baseline, design-gate addendum and template placeholders"
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

# WRK-TASK-FORK-GATES-001-001 — Baseline, design-gate addendum and template placeholders

## Objective

Record the test baseline, then write the contract every later task consumes:
an A1/A2 addendum in `adversarial-gates.md` (Cause column with definitions,
detail cap with one-line overflow, closing-line breakdown, persisted BROKEN
table) and the matching template placeholders (`## Code Premises` in the
full WRK-SPEC; the BROKEN table under `## Adversarial Review` in WRK-SPEC
and WRK-PLAN).

## Implementation Notes

**Files:**
- Modify: `skills/kdd-conventions/references/adversarial-gates.md` (gates table row A1; *Where rulings persist* bullet; new section before `## Generic dispatch template`)
- Modify: `skills/kdd-conventions/references/artifact-templates.md` (full WRK-SPEC body; WRK-PLAN body)
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: baseline files `.kdd/baseline-run.txt`, `.kdd/baseline-session-start.txt`, `.kdd/baseline-sdd-workspace.txt`, `.kdd/baseline-brainstorm-server.txt` (gitignored; every later task diffs against them).
- Produces (later tasks copy these strings exactly):
  - five-column header `| Attack | Scenario | Result | Cause | Evidence |`
  - one-line overflow format `+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>`
  - closing line `<N> attempted, <M> BROKEN (code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)`
  - persisted header `| Attack | Cause | Evidence | Ruling |`
  - cap sentence `At most 3 full rows per attack`
  - section heading `## Design gates (A1, A2): cause, detail cap, persisted table`

**Premises:** `.kdd/` does not exist in the repository yet (`ls -a .kdd` → No such file) — Step 1 creates it; it is gitignored (`.gitignore:4` `.kdd/`).

- [ ] **Step 1: Record the baseline**

```bash
export KDD_SPEC_GRAPH=$HOME/.claude/plugins/cache/kdd/kdd/1.6.0/cli/spec-graph.mjs
mkdir -p .kdd
bash tests/scripts/run.sh 2>&1 | grep -E '^### |\[FAIL\]' > .kdd/baseline-run.txt; cat .kdd/baseline-run.txt
bash tests/hooks/test-session-start.sh 2>&1 | grep -E '\[FAIL\]|^PASS|^FAILED' > .kdd/baseline-session-start.txt
bash tests/claude-code/test-sdd-workspace.sh 2>&1 | grep -E '\[FAIL\]|^PASS|^FAILED' > .kdd/baseline-sdd-workspace.txt
(cd tests/brainstorm-server && npm test 2>&1 | grep -Ei 'fail|pass' ) > .kdd/baseline-brainstorm-server.txt
cat .kdd/baseline-*.txt
```

Expected: in the main checkout, only `test-invariants.sh` (`no upstream paths`, `removed: docs/superpowers`, caused by the untracked `docs/superpowers/`) and `test-transition.sh` (9 assertions) fail; in a fresh worktree `test-invariants.sh` may pass because that untracked directory is absent. Whatever is recorded here is the baseline every later task diffs against. Paste the four files into the task report. If anything other than those two files fails, stop and report BLOCKED.

- [ ] **Step 2: Write the failing anchors**

Append to `tests/scripts/test-skill-content.sh`, immediately before the final `finish` line:

```bash
# --- adversarial gate tuning (WRK-TASK-FORK-GATES-001-001) ---
must_contain skills/kdd-conventions/references/adversarial-gates.md "## Design gates (A1, A2): cause, detail cap, persisted table" "design-gate addendum"
must_contain skills/kdd-conventions/references/adversarial-gates.md "| Attack | Scenario | Result | Cause | Evidence |" "design gates add a Cause column"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`code-reality\`" "cause: code-reality defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`spec-rule\`" "cause: spec-rule defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`ambiguity\`" "cause: ambiguity defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`knowledge-gap\`" "cause: knowledge-gap defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`internal\`" "cause: internal defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "At most 3 full rows per attack" "detail cap"
must_contain skills/kdd-conventions/references/adversarial-gates.md "+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>" "one-line overflow keeps every BROKEN finding"
must_contain skills/kdd-conventions/references/adversarial-gates.md "| Attack | Cause | Evidence | Ruling |" "persisted BROKEN table"
must_contain skills/kdd-conventions/references/adversarial-gates.md "the written WRK-SPEC, after its self-review" "A1 attacks the written spec"
must_contain skills/kdd-conventions/references/artifact-templates.md "## Code Premises" "WRK-SPEC template has Code Premises"
must_contain skills/kdd-conventions/references/artifact-templates.md "| Premise | Verified by | Result |" "Code Premises table"
must_contain skills/kdd-conventions/references/artifact-templates.md "| Attack | Cause | Evidence | Ruling |" "templates persist the BROKEN table"
must_not_contain skills/kdd-conventions/references/artifact-templates.md "one line per BROKEN attack — attack · ruling" "one-liner persistence replaced"
```

- [ ] **Step 3: Run it to verify it fails**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | grep FAIL`
Expected: FAIL on the new lines (15). If any new anchor already passes, note which in the report — it means the string exists elsewhere in the file.

- [ ] **Step 4: Edit `adversarial-gates.md`**

4a. In the gates table, replace

```
| A1 spec red-team | the draft WRK-SPEC | brainstorming, before the human review gate | always (architectural path) | +1 |
```

with

```
| A1 spec red-team | the written WRK-SPEC, after its self-review | brainstorming, before the human review gate | always (architectural path) | +1 |
```

4b. In *The common contract*, replace the bullet

```
- **Where rulings persist:** A1 rows and rulings go into a `## Adversarial
  Review` section of the WRK-SPEC; A2 rows into a `## Adversarial Review`
  section of the WRK-PLAN; A3–A6 into the SDD ledger (harvested into the
  Execution Log at finishing). A BROKEN row that reveals missing knowledge
  is also written as `Knowledge gap:` in the same place.
```

with

```
- **Where rulings persist:** A1 rows and rulings go into a `## Adversarial
  Review` section of the WRK-SPEC; A2 rows into a `## Adversarial Review`
  section of the WRK-PLAN — both in the table form of *Design gates* below;
  A3–A6 into the SDD ledger (harvested into the
  Execution Log at finishing). A BROKEN row that reveals missing knowledge
  is also written as `Knowledge gap:` in the same place.
```

4c. Insert this section immediately before `## Generic dispatch template`:

````markdown
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

````

Keep the wrapping shown: each anchor string must sit on one line.

- [ ] **Step 5: Edit `artifact-templates.md`**

5a. In the full WRK-SPEC body, replace

```
## Constraints
(verbatim rules from activated specs, each with its source ID and rule number; FRAG-observed behaviour with its anchor)
## Acceptance Criteria
- [ ] (testable)
## Open Questions
## Adversarial Review
(only when a gate ran: one line per BROKEN attack — attack · ruling)
```

with

```
## Constraints
(verbatim rules from activated specs, each with its source ID and rule number; FRAG-observed behaviour with its anchor)
## Code Premises
| Premise | Verified by | Result |
|---|---|---|
(every statement about how existing code behaves today that the design relies on; `path:lines` + literal, or command + output; holds / false / unverifiable. Greenfield: "none — no existing code")
## Acceptance Criteria
- [ ] (testable)
## Open Questions
## Adversarial Review
(only when a gate ran: the adversary's closing line, then one row per BROKEN finding — adversarial-gates.md, *Design gates*)
| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
```

5b. In the WRK-PLAN body, replace

```
## Adversarial Review
(only when a gate ran: one line per BROKEN attack — attack · ruling)
```

with

```
## Adversarial Review
(only when a gate ran: the adversary's closing line, then one row per BROKEN finding — adversarial-gates.md, *Design gates*)
| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
```

The compact WRK-SPEC template is not touched.

- [ ] **Step 6: Run the tests to verify they pass**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | tail -3` — Expected: `PASS`.
Run: `bash tests/scripts/run.sh 2>&1 | grep -E '^### |\[FAIL\]' | diff .kdd/baseline-run.txt -` — Expected: no output (no new failures).

- [ ] **Step 7: Commit**

```bash
git add skills/kdd-conventions/references/adversarial-gates.md skills/kdd-conventions/references/artifact-templates.md tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-GATES-001-001): design-gate addendum — Cause, detail cap, persisted BROKEN table; Code Premises in the WRK-SPEC template"
```

## Acceptance Criteria

- [ ] `adversarial-gates.md` has the *Design gates* section with the five Cause definitions and tie-break, the detail cap with one-line overflow, the closing line and the persisted table; the common contract and generic dispatch template are otherwise unchanged (WRK-SPEC AC5).
- [ ] The A1 row of the gates table names the written WRK-SPEC after self-review (WRK-SPEC AC1).
- [ ] Full WRK-SPEC template has `## Code Premises` after *Constraints*; compact template unchanged (WRK-SPEC AC2).
- [ ] WRK-SPEC and WRK-PLAN `## Adversarial Review` placeholders carry the BROKEN table (WRK-SPEC AC5).
- [ ] No existing line of either file removed other than the replaced placeholders and the reworded A1 row and persistence bullet (P10, WRK-SPEC AC6).
- [ ] No new test failures against the baseline (WRK-SPEC AC7).

## Test Plan

Steps 2–6: the anchors above, then `run.sh` diffed against the baseline.
