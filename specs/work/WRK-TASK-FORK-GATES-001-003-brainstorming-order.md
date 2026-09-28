---
id: WRK-TASK-FORK-GATES-001-003
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "brainstorming order: WRK-SPEC → self-review → A1 → commit"
parent: WRK-PLAN-FORK-GATES-001
activates: []
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

# WRK-TASK-FORK-GATES-001-003 — brainstorming order

## Objective

Move gate A1 after the WRK-SPEC is written and self-reviewed, and the
commit after A1 is adjudicated, in every place of `brainstorming/SKILL.md`
that states the order; add the A1 re-run rule; remove the draft file. Only
order and references change — all other prose stays.

## Implementation Notes

**Files:**
- Modify: `skills/brainstorming/SKILL.md` (architectural path bullet ~line 53-55; checklist ~111-115; `dot` flow ~130-162; *Writing the WRK-SPEC* commit bullet ~248; *Gate A1* subsection ~226-237)
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: task 002's `[WRK_SPEC_PATH]` placeholder and the A1 prompt header.
- Produces: checklist bold labels `**Write the WRK-SPEC**`, `**Spec self-review**`, `**Gate A1 — spec red-team**` in that order (task 004 edits step 7 of the same checklist; task 006 relies on the order).

**Premises:** the line numbers above are from `skills/brainstorming/SKILL.md` at `f8d369c` (293 lines); locate each block by its literal text, not by number.

- [ ] **Step 1: Write the failing anchors**

Append before `finish`:

```bash
# --- brainstorming order (WRK-TASK-FORK-GATES-001-003) ---
if grep -rqF -- "-draft.md" "$REPO_ROOT/skills/brainstorming"; then fail "brainstorming has no A1 draft file"; else pass "brainstorming has no A1 draft file"; fi
sr_line=$(grep -nF '**Spec self-review**' "$REPO_ROOT/skills/brainstorming/SKILL.md" | head -1 | cut -d: -f1)
a1_line=$(grep -nF '**Gate A1 — spec red-team**' "$REPO_ROOT/skills/brainstorming/SKILL.md" | head -1 | cut -d: -f1)
if [[ -n "$sr_line" && -n "$a1_line" && "$sr_line" -lt "$a1_line" ]]; then pass "self-review precedes gate A1"; else fail "self-review precedes gate A1 (self-review:$sr_line A1:$a1_line)"; fi
must_contain skills/brainstorming/SKILL.md "gate A1 on the written spec" "path bullet states the new order"
must_contain skills/brainstorming/SKILL.md "run gate A1 again" "A1 re-run rule"
must_contain skills/brainstorming/SKILL.md "only after gate A1 is adjudicated" "architectural commit waits for A1"
must_contain skills/brainstorming/SKILL.md "Adjudicate every \`BROKEN\` finding — full rows and one-liners" "A1 one-liners are adjudicated too"
must_contain skills/brainstorming/SKILL.md "\"Gate A1 on the written spec; adjudicate; commit\"" "dot flow has the new A1 node"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | grep FAIL`
Expected: 7 FAIL lines (draft file, order, and the five `must_contain`).

- [ ] **Step 3: Path bullet.** Replace

```
  Follow the full process: knowledge discovery, questions, approaches,
  sectioned design ending in *Knowledge activation*, gate A1, the WRK-SPEC,
  then the writing-plans skill.
```

with

```
  Follow the full process: knowledge discovery, questions, approaches,
  sectioned design ending in *Knowledge activation*, the WRK-SPEC and its
  self-review, gate A1 on the written spec, then the writing-plans skill.
```

- [ ] **Step 4: Checklist.** Replace

```
8. **Gate A1 — spec red-team** — dispatch `spec-adversary-prompt.md` against the draft; adjudicate every BROKEN row, fix the draft
9. **Write the WRK-SPEC** — `specs/work/<ID>-<slug>.md` per kdd-superpowers:kdd-conventions; `spec-graph validate` with 0 errors; commit
10. **Spec self-review** — placeholders, contradictions, ambiguity, scope, *and* every Constraint cites an activated spec or a FRAG
```

with

```
8. **Write the WRK-SPEC** — `specs/work/<ID>-<slug>.md` per kdd-superpowers:kdd-conventions; `spec-graph validate` with 0 errors; do not commit yet
9. **Spec self-review** — placeholders, contradictions, ambiguity, scope, *and* every Constraint cites an activated spec or a FRAG
10. **Gate A1 — spec red-team** — dispatch `spec-adversary-prompt.md` against the written WRK-SPEC; adjudicate every BROKEN finding, fix the spec, record `## Adversarial Review`, re-validate, commit
```

Steps 11 and 12 stay as they are.

- [ ] **Step 5: `dot` flow.** Make exactly these replacements inside the ```` ```dot ```` block:

Node declarations — replace

```
    "Gate A1: spec red-team; adjudicate" [shape=box];
    "Write WRK-SPEC; validate; commit" [shape=box];
```

with

```
    "Gate A1 on the written spec; adjudicate; commit" [shape=box];
    "Write WRK-SPEC; validate" [shape=box];
```

Edges — replace

```
    "User approves design + activation?" -> "Gate A1: spec red-team; adjudicate" [label="yes — activation frozen"];
    "Gate A1: spec red-team; adjudicate" -> "Write WRK-SPEC; validate; commit";
    "Write WRK-SPEC; validate; commit" -> "Spec self-review\n(fix inline)";
    "Spec self-review\n(fix inline)" -> "User reviews spec?";
    "User reviews spec?" -> "Write WRK-SPEC; validate; commit" [label="changes requested"];
```

with

```
    "User approves design + activation?" -> "Write WRK-SPEC; validate" [label="yes — activation frozen"];
    "Write WRK-SPEC; validate" -> "Spec self-review\n(fix inline)";
    "Spec self-review\n(fix inline)" -> "Gate A1 on the written spec; adjudicate; commit";
    "Gate A1 on the written spec; adjudicate; commit" -> "User reviews spec?";
    "User reviews spec?" -> "Write WRK-SPEC; validate" [label="substantive changes (A1 again)"];
    "User reviews spec?" -> "Spec self-review\n(fix inline)" [label="wording changes"];
    "Spec self-review\n(fix inline)" -> "User reviews spec?" [label="wording-only revision"];
```

- [ ] **Step 6: *Gate A1* subsection.** Replace

```
Before you write the WRK-SPEC file, save the approved design sections to
`.kdd/brainstorm/<WRK-SPEC-ID>-draft.md` and dispatch the adversary in
[spec-adversary-prompt.md](spec-adversary-prompt.md) with that draft path
and the activated spec files. It returns an attack table
(kdd-superpowers:kdd-conventions `references/adversarial-gates.md`).
Adjudicate every `BROKEN` row out loud with your human partner — a broken
attack on an activated rule changes the design; a broken attack that
reveals missing knowledge becomes a gap in *Knowledge activation*. Then
write the WRK-SPEC, and record every `BROKEN` row and its ruling in the
WRK-SPEC under `## Adversarial Review` (after Open Questions).
```

with

```
Once the WRK-SPEC file is written, validated and self-reviewed — and
before you commit it — dispatch the adversary in
[spec-adversary-prompt.md](spec-adversary-prompt.md) with the WRK-SPEC path
and the activated spec files. It returns an attack table
(kdd-superpowers:kdd-conventions `references/adversarial-gates.md`).
Adjudicate every `BROKEN` finding — full rows and one-liners — out loud with your human partner — a broken
attack on an activated rule changes the design; a broken attack that
reveals missing knowledge becomes a gap in *Knowledge activation*. Then
fix the WRK-SPEC, record the adversary's closing line and every `BROKEN`
finding with its ruling under `## Adversarial Review` (after Open
Questions), re-validate and commit.

If your human partner's review changes *Proposed Change*, *Constraints*,
*Acceptance Criteria* or *Code Premises* beyond wording, run gate A1 again
on the revised spec before asking for approval; otherwise do not.
```

- [ ] **Step 7: *Writing the WRK-SPEC* commit bullet.** Replace

```
- Commit the WRK-SPEC (`spec(<ID>): <title>`).
```

with

```
- Commit the WRK-SPEC (`spec(<ID>): <title>`) — on the architectural path, only after gate A1 is adjudicated.
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | tail -3` — Expected: `PASS`.
Run: `bash tests/scripts/run.sh 2>&1 | grep -E '^### |\[FAIL\]' | diff .kdd/baseline-run.txt -` — Expected: no output.
Run: `git diff --stat skills/brainstorming/SKILL.md` and `git diff skills/brainstorming/SKILL.md | grep '^-[^-]'` — every removed line must be one of the replaced blocks above.

- [ ] **Step 9: Commit**

```bash
git add skills/brainstorming/SKILL.md tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-GATES-001-003): brainstorming writes and self-reviews the WRK-SPEC before gate A1; commit after adjudication; A1 re-run rule"
```

## Acceptance Criteria

- [ ] Path bullet, checklist, `dot` flow and *Gate A1* subsection all state: write + validate → self-review → A1 on the written spec → adjudicate, record, re-validate, commit → user review (WRK-SPEC AC1).
- [ ] `skills/brainstorming/` contains no `-draft.md` (WRK-SPEC AC1).
- [ ] The re-run rule names Proposed Change, Constraints, Acceptance Criteria and Code Premises (WRK-SPEC AC1).
- [ ] No Red Flags row, rationalization row or approval gate removed or reworded; removed lines are only the replaced blocks (P10, WRK-SPEC AC6).
- [ ] No new test failures against the baseline (WRK-SPEC AC7).

## Test Plan

Steps 1–2 and 8, including the line-order check and the removed-lines review.
