---
id: WRK-TASK-FORK-CORE-001-017
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "verification-before-completion: KDD evidence rows"
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

# WRK-TASK-FORK-CORE-001-017 — `verification-before-completion`: KDD evidence rows

## Objective

Extend the *Common Failures* table with the claims the KDD flow tempts
without evidence, and add the "I wrote the spec" red flag (spec Skill 7).

## Implementation Notes

**Files:**
- Modify: `skills/verification-before-completion/SKILL.md`, `tests/scripts/test-skill-content.sh`
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: `frag-cite-check` (004), `kdd-cli` (002).
- Produces: nothing other skills depend on.

- [ ] **Step 1: Add the structural assertions (failing)**

```bash
# --- verification-before-completion (Task 017) ---
must_contain skills/verification-before-completion/SKILL.md "spec-graph validate" "validate as evidence"
must_contain skills/verification-before-completion/SKILL.md "frag-cite-check" "cite-check as evidence"
must_contain skills/verification-before-completion/SKILL.md "export-okf" "OKF export as evidence"
must_contain skills/verification-before-completion/SKILL.md "the file with its version is what counts" "spec red flag"
```

- [ ] **Step 2: Edit the skill**

(a) Append to the `## Common Failures` table:

```markdown
| WRK-SPEC/PLAN/TASK written | `spec-graph validate` output: 0 errors, read | "It follows the template" |
| Activated rules honoured | Brief without PIN DRIFT + reviewer's Knowledge Compliance ✅ with rule→test or counterexample (A3) | "I wrote it while reading the DOM" |
| FRAG faithful to the code | `frag-cite-check <dir>`: `verified N anchors` | "I just looked at it" |
| OKF-conformant | `export-okf` exit 0 on the current specs dir | "The frontmatter is valid" |
| Work closed | `status: completed` in spec, plan and every task **and** validate green | Tests green |
| Nothing to consolidate | Execution Log read: 0 `Knowledge gap:`, 0 capture candidates | "I don't remember anything relevant" |
```

(b) Append to `## Red Flags - STOP`:

```markdown
- "I wrote the spec, I know what it says" — the file with its version is what counts; read it
```

- [ ] **Step 3: Run the tests and commit**

Run: `bash tests/scripts/test-skill-content.sh` — Expected: all `[PASS]`.

```bash
git add skills/verification-before-completion/SKILL.md tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-017): verification-before-completion lists KDD evidence"
```

## Acceptance Criteria

- [ ] Six new rows and the red flag present (spec Skill 7).

## Test Plan

1. `tests/scripts/test-skill-content.sh` (+4).
