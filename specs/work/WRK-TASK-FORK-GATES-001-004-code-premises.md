---
id: WRK-TASK-FORK-GATES-001-004
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "Code premises in brainstorming: verifier prompt, design section, Red Flags row"
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

# WRK-TASK-FORK-GATES-001-004 — Code premises in brainstorming

## Objective

Make the brainstorming author check what the design assumes about today's
code before gate A1 sees it: a new mid-tier, read-only verifier template;
a *Code premises* design section presented right before *Knowledge
activation*; a Red Flags row; and `Code Premises` in the WRK-SPEC body
order. This is the change aimed at the 46 % `code-reality` share of A1
findings (FRAG-FORK-GATES-001).

## Implementation Notes

**Files:**
- Create: `skills/brainstorming/premise-verifier-prompt.md`
- Modify: `skills/brainstorming/SKILL.md` (Red Flags table; checklist step 7; *Presenting the design* bullets; *Writing the WRK-SPEC* body bullet)
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: task 001's `## Code Premises` template section and `| Premise | Verified by | Result |` header; task 003's checklist.
- Produces: dispatch description `Premise verifier: <WRK-SPEC-ID or topic>` (task 006 greps the transcript for `Premise verifier`); results `holds` / `false` / `unverifiable`.

**Premises:** none beyond the WRK-SPEC's Code Premises.

- [ ] **Step 1: Write the failing anchors**

Append before `finish`:

```bash
# --- code premises (WRK-TASK-FORK-GATES-001-004) ---
must_contain skills/brainstorming/premise-verifier-prompt.md "Premise verifier: " "verifier dispatch description"
must_contain skills/brainstorming/premise-verifier-prompt.md "model: [mid tier — REQUIRED]" "verifier is mid tier"
must_contain skills/brainstorming/premise-verifier-prompt.md "Work read-only. Do not modify files, do not commit, do not dispatch subagents." "verifier is read-only"
must_contain skills/brainstorming/premise-verifier-prompt.md "| Premise | Verified by | Result |" "verifier returns the premises table"
must_contain skills/brainstorming/premise-verifier-prompt.md "\`unverifiable\`" "verifier can say unverifiable"
must_contain skills/brainstorming/SKILL.md "premise-verifier-prompt.md" "brainstorming dispatches the verifier"
must_contain skills/brainstorming/SKILL.md "**Code premises**" "design has a Code premises section"
must_contain skills/brainstorming/SKILL.md "none — no existing code" "greenfield wording"
must_contain skills/brainstorming/SKILL.md "\"The specs cover it, I don't need to read the code\"" "premises red flag"
must_contain skills/brainstorming/SKILL.md "→ Code Premises" "WRK-SPEC body order includes Code Premises"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | grep FAIL`
Expected: 10 FAIL lines.

- [ ] **Step 3: Create `skills/brainstorming/premise-verifier-prompt.md` with exactly:**

`````markdown
# Premise Verifier Prompt

Dispatch during brainstorming (architectural path), once the design's
*Code premises* section is listed and before you present it for approval.
Skip it in greenfield: the section reads "none — no existing code". The
verifier checks facts; it does not judge the design.

```
Subagent (general-purpose):
  description: "Premise verifier: <WRK-SPEC-ID or topic>"
  model: [mid tier — REQUIRED]
  prompt: |
    You verify statements about how existing code behaves today. For each
    premise below, find the code — or run the command — that settles it, and
    report what you found. You do not judge the design and you do not
    suggest changes.

    ## Premises
    [PREMISES — one per line, numbered]

    ## Repository
    [REPO_ROOT], at HEAD.

    ## Rules
    - Work read-only. Do not modify files, do not commit, do not dispatch subagents.
    - Evidence is `path:lines` with the literal copied from tool output, or a command with its output. Memory is not evidence.
    - `holds` — the evidence shows the statement is true.
    - `false` — the evidence contradicts it; quote what the code does instead.
    - `unverifiable` — the repository cannot settle it; say what you searched and what would settle it.
    - An absence ("X never does Y") needs the search command and its empty result.
    - Return only the table, one row per premise, in the order given.

    | Premise | Verified by | Result |
    |---|---|---|
```
`````

- [ ] **Step 4: Red Flags row.** In the `## Red Flags` table of `skills/brainstorming/SKILL.md`, append after the last row (`"They approved the spike, so the follow-up change is approved too"`):

```
| "The specs cover it, I don't need to read the code" | Specs say what should be; code says what is. Every premise the design leans on is checked, not assumed. |
```

- [ ] **Step 5: Checklist step 7.** Replace

```
7. **Present design** — in sections scaled to their complexity, approval after each; the last section is always **Knowledge activation**
```

with

```
7. **Present design** — in sections scaled to their complexity, approval after each; the last section is always **Knowledge activation**, and the one before it is **Code premises**, checked by `premise-verifier-prompt.md`
```

- [ ] **Step 6: *Presenting the design*.** Insert this bullet immediately after the bullet that starts `- Cover: architecture, components, data flow, error handling, testing` (leave that bullet untouched):

```
- **Code premises** comes right before *Knowledge activation*: every statement about how existing code behaves today that the design leans on ("X already locks", "test T is green on main", "manual merge does not recompute"). Dispatch [premise-verifier-prompt.md](premise-verifier-prompt.md) with the list and present its table (`| Premise | Verified by | Result |`). A `false` or `unverifiable` premise changes the design before gate A1 — resolve it or stop relying on it; one that contradicts an activated spec is also a `Knowledge gap:`. Greenfield: the section reads "none — no existing code" and nothing is dispatched. A premise is not a FRAG: it is a checked fact for this work and does not enter the graph.
```

- [ ] **Step 7: WRK-SPEC body order.** In *Writing the WRK-SPEC*, in the bullet starting `- Body per the template:`, replace

```
→ Constraints (**verbatim** rules from activated specs with source ID and rule number; FRAG-observed behaviour with its anchor) → Acceptance Criteria (testable) → Open Questions.
```

with

```
→ Constraints (**verbatim** rules from activated specs with source ID and rule number; FRAG-observed behaviour with its anchor) → Code Premises (the verifier's table, architectural path) → Acceptance Criteria (testable) → Open Questions.
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `bash tests/scripts/test-skill-content.sh 2>&1 | tail -3` — Expected: `PASS`.
Run: `bash tests/scripts/run.sh 2>&1 | grep -E '^### |\[FAIL\]' | diff .kdd/baseline-run.txt -` — Expected: no output.
Run: `bash tests/scripts/test-invariants.sh 2>&1 | grep FAIL` — Expected: exactly the `test-invariants.sh` failures recorded in `.kdd/baseline-run.txt`, if any (the new file's path has no `superpowers`).

- [ ] **Step 9: Commit**

```bash
git add skills/brainstorming/premise-verifier-prompt.md skills/brainstorming/SKILL.md tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-GATES-001-004): brainstorming checks its code premises with a mid-tier verifier before gate A1"
```

## Acceptance Criteria

- [ ] `premise-verifier-prompt.md` exists: read-only, mid tier, no subagents, input = premise list + repo, output = `| Premise | Verified by | Result |` with `holds` / `false` / `unverifiable` (WRK-SPEC AC2).
- [ ] brainstorming dispatches it for *Code premises* (not in greenfield), treats `unverifiable` like `false`, and has the new Red Flags row (WRK-SPEC AC2).
- [ ] The WRK-SPEC body order in *Writing the WRK-SPEC* lists Code Premises between Constraints and Acceptance Criteria, matching the template (WRK-SPEC AC2).
- [ ] Existing Red Flags rows and the *Cover:* bullet untouched (P10, WRK-SPEC AC6); no new path contains `superpowers` (P13).
- [ ] No new test failures against the baseline (WRK-SPEC AC7).

## Test Plan

Steps 1–2 and 8.
