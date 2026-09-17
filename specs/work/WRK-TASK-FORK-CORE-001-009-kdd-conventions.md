---
id: WRK-TASK-FORK-CORE-001-009
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "kdd-conventions skill and shared references"
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

# WRK-TASK-FORK-CORE-001-009 — `kdd-conventions` skill and shared references

## Objective

Create the one skill every workflow skill cites when it writes a KDD
artifact (spec *Shared skill — kdd-conventions*): ID rules, locations,
state transitions, trust family, and the three references — artifact
templates, capturing from code (P11/P12), adversarial gates (A1–A6
common contract). Also start the structural content test that later skill
tasks extend.

## Implementation Notes

**Files:**
- Create: `skills/kdd-conventions/SKILL.md`, `skills/kdd-conventions/references/artifact-templates.md`, `skills/kdd-conventions/references/capturing-from-code.md`, `skills/kdd-conventions/references/adversarial-gates.md`, `tests/scripts/test-skill-content.sh`
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: `next-id` (003), `frag-cite-check` (004).
- Produces: the skill name `kdd-superpowers:kdd-conventions` and the three reference paths, cited verbatim by Tasks 010–017; the anchor format `` - `<path>:<start>-<end>@<sha>`: `<literal>` ``; the attack-table contract (columns *Attack · Scenario · Result · Evidence*, verdict lines `BROKEN`/`RESISTED`); `tests/scripts/test-skill-content.sh` with the helper `must_contain FILE 'text' 'name'` that later tasks call.

- [ ] **Step 1: Write the failing structural test**

`tests/scripts/test-skill-content.sh`:

```bash
#!/usr/bin/env bash
# Structural checks on skill prose: the anchors later skills and prompts rely on exist.
# Later tasks append their own `must_contain` lines below the marker.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
echo "=== Test: skill content ==="
must_contain() { # FILE 'text' 'name'
  if [[ -f "$REPO_ROOT/$1" ]] && grep -qF -- "$2" "$REPO_ROOT/$1"; then pass "$3"; else fail "$3 ($1 lacks: $2)"; fi
}
must_not_contain() {
  if [[ -f "$REPO_ROOT/$1" ]] && grep -qF -- "$2" "$REPO_ROOT/$1"; then fail "$3 ($1 still has: $2)"; else pass "$3"; fi
}

# --- kdd-conventions (Task 009) ---
must_contain skills/kdd-conventions/SKILL.md "name: kdd-conventions" "kdd-conventions skill exists"
must_contain skills/kdd-conventions/SKILL.md "number last" "ID rule: number last"
must_contain skills/kdd-conventions/SKILL.md "scripts/next-id" "SKILL cites next-id"
must_contain skills/kdd-conventions/SKILL.md "human:<id>" "actor convention documented"
must_contain skills/kdd-conventions/SKILL.md "never verifies its own output" "writer ≠ confirmer rule"
must_contain skills/kdd-conventions/SKILL.md ".kdd/" "runtime root .kdd/"
must_contain skills/kdd-conventions/references/artifact-templates.md "activation_frozen: true" "WRK-SPEC template freezes activation"
must_contain skills/kdd-conventions/references/artifact-templates.md "## Compact WRK-SPEC" "compact WRK-SPEC template"
must_contain skills/kdd-conventions/references/artifact-templates.md "## Architecture Impact" "WRK-PLAN template has Architecture Impact"
must_contain skills/kdd-conventions/references/artifact-templates.md "source_type: report" "FRAG template uses source_type report"
must_contain skills/kdd-conventions/references/capturing-from-code.md "No anchor, no claim" "P12 rule 1"
must_contain skills/kdd-conventions/references/capturing-from-code.md "## Observed" "observed section"
must_contain skills/kdd-conventions/references/capturing-from-code.md "## Inferred" "inferred section"
must_contain skills/kdd-conventions/references/capturing-from-code.md "frag-cite-check" "cite-check is mandatory"
must_contain skills/kdd-conventions/references/capturing-from-code.md "characterization test" "characterization tests"
must_contain skills/kdd-conventions/references/adversarial-gates.md "| Attack | Scenario | Result | Evidence |" "attack table contract"
must_contain skills/kdd-conventions/references/adversarial-gates.md "Attack: " "ledger line format"
must_contain skills/kdd-conventions/references/adversarial-gates.md "A6" "gates A1–A6 listed"
# --- later tasks append below this line ---

finish
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/scripts/test-skill-content.sh` — Expected: 18 FAIL.

- [ ] **Step 3: Write `skills/kdd-conventions/SKILL.md`**

```markdown
---
name: kdd-conventions
description: Use when writing or updating any KDD artifact (WRK-SPEC, WRK-PLAN, WRK-TASK, FRAG) or transitioning its status — IDs, locations, state transitions, trust family, and the scripts that enforce them
---

# KDD Conventions

Every artifact kdd-superpowers writes is a KDD spec: complete frontmatter,
validated by `spec-graph validate`, living in `specs/`. This skill is the
single place those conventions are written down. Workflow skills cite it;
they do not restate it.

**Announce at start:** "Using kdd-conventions to write <artifact>."

## Identifiers — semantic path, number last

IDs are a readable path of uppercase segments with the number **last**:
`WRK-SPEC-RISK-VAR-ENGINE-001`, `DOM-RISK-VAR-001`, `FRAG-BILL-ROUNDING-001`.
This is the grammar `spec-graph` accepts (`^PREFIX(-[A-Z0-9]+)*-\d{3}$`);
the number disambiguates within a semantic path, it is not a global counter.

- Segments are `[A-Z0-9]+`, joined by `-`; 2–4 semantic segments (area + concept) after the type prefix.
- **Reuse before inventing**: run `<kdd-cli> --specs specs filter --format json` and take an existing area when one fits. Use nested areas only if the project already does.
- Work chain: the WRK-PLAN inherits the WRK-SPEC's path; tasks are `WRK-TASK-<path>-<PPP>-<TTT>` (PPP = plan number, TTT = position in the plan's Task Breakdown). A plan prefers its spec's number (`next-id --prefer`).
- Allocate with this skill's `scripts/next-id [--specs DIR] [--prefer NNN] TYPE-PATH` — never by hand.
- Files: `specs/work/<ID>-<lowercase-slug>.md`; fragments: `specs/_capture/<ID>-<slug>/<ID>.md` plus the raw files. `title` in the frontmatter carries the full name.
- The human confirms the proposed ID together with the activation (brainstorming, *Knowledge activation* section). An ID is immutable once committed.

## Locations

| What | Where | Tracked |
|---|---|---|
| Work artifacts (WRK-SPEC / WRK-PLAN / WRK-TASK) | `specs/work/` | yes |
| Capture fragments (FRAG) | `specs/_capture/<ID>-<slug>/` | yes |
| Knowledge/agentic specs the project owns | wherever the project keeps them under `specs/` | yes |
| SDD ledger, briefs, reports, review packages | `.kdd/sdd/<WRK-PLAN-ID>/` | no (gitignored) |
| Visual companion sessions | `.kdd/brainstorm/<session>/` | no |

No path written by this plugin contains `superpowers`. Runtime state goes
under `.kdd/`; the plugin adds `.kdd/` to the project's `.gitignore` the
first time it creates it (append the line if absent).

## Status transitions — who moves what, when

| Artifact | Born | → | By |
|---|---|---|---|
| WRK-SPEC | `draft` (brainstorming writes it) | `active` when your human partner approves the written spec | brainstorming |
| WRK-SPEC | `active` | `completed` at finishing, before the integration menu | finishing-a-development-branch |
| WRK-SPEC | `completed` | `archived` once consolidation is applied | finishing-a-development-branch |
| WRK-PLAN / WRK-TASK | `draft` (writing-plans) | `active` when an execution mode is chosen | writing-plans |
| WRK-TASK | `active` | `completed` when its task review is clean (in the task's closing commit) | SDD / executing-plans |
| WRK-PLAN | `active` | `completed` when the final review is clean | SDD / executing-plans |
| FRAG | `ingested` | `distilled` when a spec cites it in `sources` after consolidation | consolidation (`kdd:spec-consolidate`) |

Every transition also updates `updated:`. Never skip a state.

## Trust family — on everything you write

```yaml
generated:
  by: claude-code/<model-id>        # actor convention: <producer>/<version>
  at: <ISO 8601 with offset>
sources:                            # what the content rests on: activated specs, FRAGs, external docs
  - id: <SPEC-or-FRAG-ID>
    resource: <path or URL>
stale_after: <ISO 8601, +90 days for ephemeral work artifacts>
```

- `verified` is written **only on behalf of a human who explicitly confirmed**, as `- by: human:<id>` with `at:` — writer ≠ confirmer. A skill never verifies its own output. Ask for the id once (`git config user.email` local-part is a fine default to propose); never invent one.
- `confidence` is capped by trust: unverified ⇒ `low`. New artifacts are born `confidence: low`; the human's `verified` lifts them (`validate` warns otherwise — treat the warning as an error).
- `activates` holds Knowledge-axis refs only, `equips` Agentic-axis refs only, both pinned `ID@version`. `FRAG-*` and deliverable projections are never activated; cite them in `sources`.

## Validate before you call it written

```bash
<kdd-cli> --specs specs validate
```

0 errors is the bar; warnings about your own artifact are yours to fix. Use
`skills/using-superpowers/scripts/kdd-cli` to find the CLI — never hard-code
its path.

## References

- `references/artifact-templates.md` — frontmatter and body for WRK-SPEC (full and compact), WRK-PLAN, WRK-TASK, FRAG.
- `references/capturing-from-code.md` — how to turn code into evidence without hallucinating (P11/P12).
- `references/adversarial-gates.md` — the common contract for gates A1–A6.

## Red Flags

| Thought | Reality |
|---------|---------|
| "I'll number it 001, it's the first one" | Run `next-id`. The path may already have specs elsewhere in the tree. |
| "The spec is basically right, I'll set confidence medium" | Confidence is capped by trust. Unverified is `low`. Let the human lift it. |
| "I'll mark it verified — the human said 'looks good'" | Record `verified` only after an explicit approval of *this* artifact, with their id. |
| "Validate warns, but not about my file" | Read the warning. If it names your artifact, fix it; if not, say so out loud. |
```

- [ ] **Step 4: Write `references/artifact-templates.md`**

```markdown
# Artifact templates

Angle-bracket fields are filled in; everything else is literal. Dates are
`YYYY-MM-DD`; datetimes carry an offset. Body headings are the KDD anatomy
for each layer — keep them, in this order.

## Full WRK-SPEC (architectural path)

```yaml
---
id: <WRK-SPEC-PATH-NNN>
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: <date>
updated: <date>
owner: <team-or-person>
title: "<full name>"
activates:
  - <KNOWLEDGE-ID>@<version>
equips: []
activation_frozen: true
activation_resolved_at: <datetime>
dependencies:
  - id: <KNOWLEDGE-ID>
    relation: constrained-by
sources:
  - id: <FRAG-ID>
    resource: specs/_capture/<FRAG-ID>-<slug>/
generated:
  by: claude-code/<model-id>
  at: <datetime>
stale_after: <datetime +90d>
tags: [<area>, <concept>]
---
```

Body:

```markdown
# <ID> — <title>

## Problem Statement
## Proposed Change
### Architecture
### Components
### Data flow
### Error handling
### Testing
## Knowledge Context
| Activated Spec | Role in this work |
|---|---|
(FRAGs cited as evidence go here too, marked "evidence, not activated")
## Constraints
(verbatim rules from activated specs, each with its source ID and rule number; FRAG-observed behaviour with its anchor)
## Acceptance Criteria
- [ ] (testable)
## Open Questions
```

Add `- id: <FEAT-ID>\n    relation: implements` under `dependencies` when the work materializes a FEAT.

## Compact WRK-SPEC (bounded path)

Same frontmatter. Body only:

```markdown
# <ID> — <title>

## Problem Statement
## Proposed Change
## Knowledge Context
## Acceptance Criteria
```

## WRK-PLAN

```yaml
---
id: <WRK-PLAN-PATH-NNN>
type: spec
layer: work-plan
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: <date>
updated: <date>
owner: <team-or-person>
title: "<spec title> — implementation plan"
parent: <WRK-SPEC-ID>
activates:
  - <subset of the spec's activates, same pins>
equips: []
activation_frozen: true
dependencies:
  - id: <WRK-SPEC-ID>
    relation: implements
  - id: <KNOWLEDGE-ID>
    relation: constrained-by
sources:
  - id: <WRK-SPEC-ID>
    resource: specs/work/<spec file>
generated: { by: claude-code/<model-id>, at: <datetime> }
stale_after: <datetime +90d>
tags: [<area>, plan]
---
```

Body:

```markdown
# <ID> — <title>

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file; steps use checkbox (`- [ ]`) syntax.

## Approach
**Goal:** … **Architecture:** … **Tech Stack:** …
## Task Breakdown
| Task ID | Description | Dependencies |
|---|---|---|
(table order = execution order)
## Architecture Impact
| Constraint | Source | Impact on plan |
|---|---|---|
(rules copied verbatim from activated specs)
## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
## Dependencies
## Execution Log
(appended at finishing: rulings, Knowledge gaps, broken attacks, pending capture candidates)
```

## WRK-TASK

```yaml
---
id: <WRK-TASK-PATH-PPP-TTT>
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: <date>
updated: <date>
owner: <team-or-person>
title: "<component name>"
parent: <WRK-PLAN-ID>
activates:
  - <2–5 specs this task touches, pins inherited>
equips: []
dependencies:
  - id: <WRK-PLAN-ID>
    relation: implements
sources:
  - id: <FRAG-ID>
    resource: specs/_capture/<FRAG-ID>-<slug>/
generated: { by: claude-code/<model-id>, at: <datetime> }
stale_after: <datetime +90d>
tags: [<area>, task]
---
```

Body:

```markdown
# <ID> — <title>

## Objective
## Implementation Notes
**Files:** Create / Modify / Test with exact paths
**Interfaces:** Consumes / Produces with exact signatures
- [ ] **Step 1: Write the failing test** (code block)
- [ ] **Step 2: Run it to verify it fails** (command + expected)
- [ ] **Step 3: Minimal implementation** (code block)
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** (`<type>(<TASK-ID>): …`)
## Acceptance Criteria
- [ ] (each maps to a spec criterion or an activated rule)
## Test Plan
```

## FRAG (captured from code)

Directory `specs/_capture/<FRAG-ID>-<slug>/` with `<FRAG-ID>.md` and the raw files (`report.md`, optional characterization tests).

```yaml
---
id: <FRAG-PATH-NNN>
type: fragment
layer: capture
scope: persistent
status: ingested
confidence: low
version: 1.0.0
created: <date>
updated: <date>
owner: <team-or-person>
domain: <domain if the project has a taxonomy>
title: "<what was observed, where>"
captured_at: <datetime>
source_type: report
files:
  - report.md
integrity: "sha256:<sha256sum of the files, sorted by name — recompute after any edit>"
origin: <repo or service name>
routed_to: []
generated: { by: claude-code/<model-id>, at: <datetime> }
tags: [capture, <area>]
---
# <ID> — <title>

Immutable capture. Anchored observations live in report.md; the reconciled
knowledge, once distilled, cites this fragment in `sources`.
```

`report.md` structure is defined in `capturing-from-code.md`.
```

- [ ] **Step 5: Write `references/capturing-from-code.md`**

```markdown
# Capturing knowledge from code

Use this whenever a skill records what existing code does as a `FRAG-*`
(brainstorming in brownfield, code review capture candidates, later:
debugging). A hallucinated fragment is worse than none: it enters the graph
looking like evidence and consolidation distills it into a DOM. These rules
make that impossible by construction.

## The seven rules

1. **No anchor, no claim.** Every sentence describing behaviour cites where it comes from and quotes the code verbatim, copied from tool output — never from memory. An unanchored statement is a placeholder: anchor it or delete it.
2. **Observed ≠ Inferred, in separate sections.** *Observed* holds only anchored facts. *Inferred* holds interpretation, and every inference names the observations it rests on. Whatever may be wrong lives in *Inferred*, visibly.
3. **Absences are anchored too.** "There is no validation of X" is a claim. Record the exact search commands and their result (`grep -rn … → 0 results`). No command, no absence.
4. **Cite-check before writing.** Run `skills/kdd-conventions/scripts/frag-cite-check <FRAG-DIR>` from the repo root. One failed anchor blocks the FRAG. This is `verification-before-completion` applied to evidence.
5. **Honest trust.** The FRAG is born `confidence: low`, `generated` by you, with no `verified`. Only a human adds `verified`. Consolidation distills an unverified FRAG at most into a `confidence: low` spec with mandatory review. Never raise your own confidence.
6. **For computable rules, the evidence is a test.** A formula, a rounding, an ordering of validations: write a characterization test against the current code, run it, and put the *observed* result in the FRAG (the test file goes in `files[]`). Reserve this for rules worth it; structure and conventions do not need it.
7. **Promotion needs an adversary.** Before a FRAG becomes DOM/ARCH (consolidation), gate A6 dispatches a reviewer with only the FRAG and repo access to refute each claim. Capture does not pay this cost; promotion does.

## Anchor format

Inside any file listed in the FRAG's `files[]`, one list item per claim:

```
- `<path>:<start>-<end>@<sha>`: `<literal>`
```

- `<path>` repo-relative; `<start>-<end>` 1-based inclusive line range (single line: `12-12`); `<sha>` the commit you read it at (`git rev-parse --short=7 HEAD`); `<literal>` one line of code copied verbatim (no backticks inside).
- Prefer the narrowest range that contains the literal. Several claims about one function are several anchors.

## `report.md` structure

```markdown
# Exploration report — <topic> (<repo>, <sha>)

## Scope
What was explored and why (the work that needed it). Only what the work touches.

## Observed
- `src/billing.js:12-14@abc1234`: `return Math.round(amount * 100) / 100;`
- `src/billing.js:40-40@abc1234`: `if (days <= 0) throw new RangeError('days');`

## Inferred
- Rounding is half-up for positive amounts (rests on: billing.js:12-14).
- Zero or negative day counts are rejected before any calculation (rests on: billing.js:40-40).

## Absences
- `grep -rn "ROUND_HALF_EVEN\|bankers" src/` → 0 results.

## Tests run (if any)
- `tests/characterize-rounding.test.js` — `round2(0.125) === 0.13` observed on <sha>.
```

## Procedure

1. Decide the scope from the work at hand (spec or task). Do not explore beyond it.
2. Read the code with tools; paste literals from tool output into *Observed* with anchors as you go.
3. Write *Inferred* last, each line pointing at its observations.
4. Record every search that came back empty under *Absences*, with the command.
5. Allocate the ID with `next-id FRAG-<AREA>-<CONCEPT>`; create the directory per `artifact-templates.md`; compute `integrity`.
6. Run `frag-cite-check <dir>`; fix or delete anything it rejects; recompute `integrity` if the report changed.
7. Run `<kdd-cli> --specs specs validate`.
8. Cite the FRAG from the artifact that needed it (`sources`, and in prose as "observed in FRAG-…").

## Red Flags

| Thought | Reality |
|---------|---------|
| "I read that function a minute ago, I remember what it does" | Memory is not an anchor. Re-read and paste. |
| "It obviously validates the input somewhere" | Find it or record the search that failed. |
| "The inference is safe, I'll put it under Observed" | Observed is for literals only. Interpretation goes to Inferred. |
| "Cite-check is overkill for two anchors" | Two wrong anchors become a DOM that constrains future work. Run it. |
```

- [ ] **Step 6: Write `references/adversarial-gates.md`**

```markdown
# Adversarial gates

A gate dispatches a subagent whose job is to *break* an artifact, not to
review it. The gates and where they sit:

| Gate | Attacks | Where | When | Seat |
|---|---|---|---|---|
| A1 spec red-team | the draft WRK-SPEC | brainstorming, before the human review gate | always | +1 |
| A2 plan red-team | WRK-PLAN + WRK-TASKs | writing-plans, before handoff | > 4 tasks, or the spec activates `confidence: low`/unverified specs, or the work touches security or money | +1 |
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
```

- [ ] **Step 7: Run the structural test**

Run: `bash tests/scripts/test-skill-content.sh` — Expected: 18 `[PASS]`, `PASS`.

- [ ] **Step 8: Run the suite and commit**

Run: `bash tests/scripts/run.sh` — Expected: all ok.

```bash
git add skills/kdd-conventions tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-009): kdd-conventions skill with artifact templates, code capture rules and adversarial gate contract"
```

## Acceptance Criteria

- [ ] Skill and three references exist with the anchors the structural test checks (spec: *Shared skill*, P12, gates table).
- [ ] Anchor format and attack-table contract are stated once, here, and match the scripts (004) and prompts (011–016).

## Test Plan

1. `tests/scripts/test-skill-content.sh` — 18 structural assertions (grows in later tasks).
