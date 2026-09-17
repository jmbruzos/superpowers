---
id: WRK-TASK-FORK-CORE-001-016
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "finishing-a-development-branch: knowledge integrity, Execution Log, consolidation, gate A6, transitions"
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

# WRK-TASK-FORK-CORE-001-016 — `finishing-a-development-branch`: knowledge integrity, Execution Log, consolidation, gate A6, transitions

## Objective

Close work the KDD way (spec Skill 6; P7, P8): refuse the menu unless the
graph validates, tasks and plan are `completed` and `export-okf` runs;
persist the ledger's chronicle into the plan; consolidate through
`kdd:spec-consolidate` with the A6 FRAG adversary; transition the
WRK-SPEC.

## Implementation Notes

**Files:**
- Modify: `skills/finishing-a-development-branch/SKILL.md`, `tests/scripts/test-skill-content.sh`
- Create: `skills/finishing-a-development-branch/frag-adversary-prompt.md`
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: ledger lines (013/014), `kdd-cli` (002), `frag-cite-check` (004), `capturing-from-code.md` and `adversarial-gates.md` (009), toolkit `kdd:spec-consolidate`.
- Produces: WRK-SPEC `completed` → `archived`; `## Execution Log` section in the WRK-PLAN.

- [ ] **Step 1: Add the structural assertions (failing)**

```bash
# --- finishing-a-development-branch (Task 016) ---
must_contain skills/finishing-a-development-branch/SKILL.md "## Step 1b: Verify Knowledge Integrity" "knowledge integrity step"
must_contain skills/finishing-a-development-branch/SKILL.md "export-okf" "OKF export as evidence"
must_contain skills/finishing-a-development-branch/SKILL.md "## Execution Log" "execution log persisted"
must_contain skills/finishing-a-development-branch/SKILL.md "kdd:spec-consolidate" "consolidation wired"
must_contain skills/finishing-a-development-branch/SKILL.md "frag-adversary-prompt.md" "gate A6 wired"
must_contain skills/finishing-a-development-branch/SKILL.md "pending consolidation" "deferred consolidation state"
must_contain skills/finishing-a-development-branch/SKILL.md "archived" "archive transition"
must_contain skills/finishing-a-development-branch/frag-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A6 prompt uses the attack table"
```

- [ ] **Step 2: Edit `skills/finishing-a-development-branch/SKILL.md`**

(a) `**Core principle:**` → `Verify tests → Verify knowledge integrity → Detect environment → Persist the chronicle → Consolidate → Present options → Execute choice → Clean up.`

(b) Insert after `## Step 1: Verify Tests` (i.e., before `## Step 2: Detect Environment`):

```markdown
## Step 1b: Verify Knowledge Integrity

Same standing as the tests — a red result means no menu.

```bash
<kdd-cli> --specs specs validate                       # 0 errors; no warning naming this work's artifacts
<kdd-cli> --specs specs filter --layer work-task --format json   # every task of this plan: status completed
<kdd-cli> --specs specs export-okf --out "$(mktemp -d)/okf"      # exit 0; the bundle is evidence, discard it
```

Check by reading the output: every WRK-TASK whose `parent` is this plan is
`completed`; the WRK-PLAN is `completed`; the WRK-SPEC is `active`.
Anything else is unfinished work — report it and stop:

```
Knowledge integrity failing. Must fix before completing:

- WRK-TASK-…-003 is still `active` (no completion commit)
- validate: 1 error — <message>
```

Find the CLI with `skills/using-superpowers/scripts/kdd-cli --path`.
```

(c) Insert after `## Step 3: Determine Base Branch` (before `## Step 4: Present Options`):

```markdown
## Step 3b: Persist the Chronicle

The ledger (`.kdd/sdd/<WRK-PLAN-ID>/progress.md`) is git-ignored and will
be deleted; its durable part moves into the plan. Append to the WRK-PLAN a
section:

```markdown
## Execution Log

### Rulings
- <every `Ruling:` line, verbatim>

### Knowledge gaps
- <every `Knowledge gap:` line>

### Attacks broken and adjudicated
- <every `Attack: … — Ruling: …` line whose result was BROKEN>

### Capture candidates (pending)
- <every `Capture candidate:` line and every anchored candidate from review reports>

### Parked / deferred
- <parked findings and deferred minors>
```

Then `updated: <today>`, validate, commit (`chore(<WRK-PLAN-ID>): execution log`).
`kdd:spec-consolidate` reads plan and task bodies for decision language —
this is where it finds what the run learned. With no ledger (a plan
executed without one), write the section from the commit history and say
so.

## Step 3c: Consolidate

No work closes without returning knowledge. **REQUIRED SUB-SKILL:**
`kdd:spec-consolidate <WRK-SPEC-ID>`. It reads the work tree, the
activated specs and the Execution Log, and proposes ADRs, spec deltas with
version bumps, new specs at `confidence: low`, confidence upgrades and
fragment distillation; your human partner decides what to apply.

Around it, this skill adds three things:

1. **Pending capture candidates become FRAGs first.** For each candidate
   in the Execution Log, write the fragment per
   kdd-superpowers:kdd-conventions `references/capturing-from-code.md`
   (anchors, Observed/Inferred, `frag-cite-check`, `confidence: low`) so
   consolidation can cite and distill it. A candidate whose anchor no
   longer verifies is dropped with a note.
2. **Gate A6 before any promotion.** When consolidation proposes turning
   a FRAG into a DOM/ARCH (or updating one from it), dispatch
   [frag-adversary-prompt.md](frag-adversary-prompt.md) first. Only claims
   that RESISTED are distilled; BROKEN rows are ledgered in the Execution
   Log with their ruling and the FRAG stays `ingested`.
3. **Knowledge travels with the code.** Everything your human partner
   accepts (ADRs, spec bumps, `distilled` fragments, new specs) is
   committed on this branch, before the integration menu, so the merge or
   PR carries the knowledge change next to the code change
   (`chore(<WRK-SPEC-ID>): consolidate`).

If your human partner defers consolidation, say once: "After the merge
this branch's context is gone and the knowledge does not come back." Then
respect the decision: the WRK-SPEC is closed as `completed` without
archiving, and the session bootstrap will list it as *pending
consolidation* until `kdd:spec-consolidate` runs.

## Step 3d: Close the Work Artifacts

- WRK-SPEC: `status: active → completed`, `updated: <today>`; if your human
  partner confirmed the close explicitly, append `verified: - by: human:<id>`
  with `at:`.
- After consolidation was applied: WRK-SPEC, WRK-PLAN and every WRK-TASK
  → `status: archived`.
- Validate; commit (`chore(<WRK-SPEC-ID>): close and consolidate`).

Only now present the menu.
```

(d) Add to `## Common Rationalizations`:

```markdown
| "Consolidation can wait until after the merge" | After the merge the branch context is gone and the knowledge never comes back. Now or never. |
| "Nothing was learned in this plan" | The Execution Log says otherwise: every ruling is a candidate. Read it before claiming that. |
| "The FRAG is obviously right, skip the adversary" | That DOM will constrain future work. It earns its adversary. |
| "Validate fails on a warning about someone else's spec" | Read it. If it names this work's artifacts, fix it; if not, say so out loud and rule. A graph that does not validate does not export or activate cleanly. |
```

- [ ] **Step 3: Write `frag-adversary-prompt.md`**

```markdown
# FRAG Adversary Prompt (gate A6)

Dispatch during consolidation before a fragment is distilled into a
DOM/ARCH spec. Common contract: kdd-superpowers:kdd-conventions
`references/adversarial-gates.md`.

```
Subagent (general-purpose):
  description: "Adversary: A6 refute <FRAG-ID> before promotion"
  model: [most capable available — REQUIRED]
  prompt: |
    You are an adversary. A fragment captured from code is about to become a
    knowledge spec that constrains future work. Your job is to refute it.
    Produce an attack table.

    ## Artifact under attack
    Read the fragment directory: [FRAG_DIR] (frontmatter file and report.md)

    ## What it must hold against
    The repository at HEAD, read-only.

    ## Attacks to attempt (at least one row each)
    1. Anchor check: for every anchor, re-read the range at the cited sha and at HEAD; report any literal that is not there or whose meaning changed.
    2. Counterexample: for every Inferred claim, look for code paths, configuration or tests that contradict it (another branch, a feature flag, an override, a caller that bypasses it). Quote them.
    3. Unsupported inference: find an Inferred claim whose listed observations do not actually entail it.
    4. Absence check: re-run every recorded absence command; report any that now returns results.
    5. Scope: find a claim that is true of the cited file but false of the system (other modules doing it differently).

    ## Rules
    - Work read-only. Do not modify files, do not commit, do not dispatch subagents.
    - Every row: Attack · Scenario (claim attacked, concrete evidence sought) · Result (BROKEN / RESISTED) · Evidence (path:lines at sha, command output).
    - Return only the table, then one line: `<N> attempted, <M> BROKEN`.

    | Attack | Scenario | Result | Evidence |
    |---|---|---|---|
```
```

- [ ] **Step 4: Run the tests and commit**

Run: `bash tests/scripts/test-skill-content.sh` — Expected: all `[PASS]`.

```bash
git add skills/finishing-a-development-branch tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-016): finishing verifies knowledge integrity, persists the execution log, consolidates with gate A6"
```

## Acceptance Criteria

- [ ] Steps 1b, 3b, 3c, 3d present with the exact commands, transitions and deferral behaviour (spec AC 11).

## Test Plan

1. `tests/scripts/test-skill-content.sh` (+8).
2. Behavioural scenario in Task 019 (plan with an `active` task → stops at 1b; all completed → Execution Log appended, consolidation invoked).
