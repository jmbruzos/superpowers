---
id: WRK-TASK-FORK-CORE-001-010
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "using-superpowers skill text"
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

# WRK-TASK-FORK-CORE-001-010 — `using-superpowers` skill text

## Objective

Teach the bootstrap skill to read the `<KDD-ENVIRONMENT>` block and act
on it, route knowledge-spec requests to the toolkit and work requests to
brainstorming, and add the activation red flag (spec Skill 1 *Skill
text*). Everything upstream stays except the *Platform Adaptation*
section, whose reference files Task 001 removed.

## Implementation Notes

**Files:**
- Modify: `skills/using-superpowers/SKILL.md`, `tests/scripts/test-skill-content.sh`
- Test: `tests/scripts/test-skill-content.sh`

**Interfaces:**
- Consumes: the four environment lines from the hook (008); `kdd-superpowers:kdd-conventions` (009).
- Produces: the routing rule other skills assume (knowledge specs → `kdd:*`; work → `brainstorming`) and the "toolkit NOT FOUND → stop workflow skills" behaviour.

- [ ] **Step 1: Add the structural assertions (failing)**

Append under the marker line in `tests/scripts/test-skill-content.sh`:

```bash
# --- using-superpowers (Task 010) ---
must_contain skills/using-superpowers/SKILL.md "## Your KDD Environment" "KDD environment section"
must_contain skills/using-superpowers/SKILL.md "toolkit: NOT FOUND" "handles missing toolkit"
must_contain skills/using-superpowers/SKILL.md "kdd:spec-graph import-okf --dry-run" "offers OKF import"
must_contain skills/using-superpowers/SKILL.md "kdd:spec-create" "routes knowledge specs to the toolkit"
must_contain skills/using-superpowers/SKILL.md "Activation is an auditable record" "activation red flag"
must_not_contain skills/using-superpowers/SKILL.md "## Platform Adaptation" "platform adaptation removed"
must_not_contain skills/using-superpowers/SKILL.md "references/codex-tools.md" "no dangling reference links"
```

Run: `bash tests/scripts/test-skill-content.sh` — Expected: the 7 new lines FAIL (except the two `must_not_contain` only if Step 2 not yet done).

- [ ] **Step 2: Edit `skills/using-superpowers/SKILL.md`**

(a) Delete the whole `## Platform Adaptation` section (heading through the last `- Hermes Agent:` bullet).

(b) In `## Skill Priority`, after the two example bullets (`"Let's build X"`, `"Fix this bug"`), add:

```markdown
- "Write a domain / architecture / product spec for X" → the Knowledge axis belongs to the toolkit: `kdd:spec-create` or the `kdd-spec-assistant` agent. Never brainstorming.
- "Build / change / add X" → the Work axis: kdd-superpowers:brainstorming, which produces the WRK-SPEC and freezes its knowledge activation.
- `kdd:*` skills are not invoked directly for steps of the workflow (discovery, activation, consolidation) — the workflow skills invoke them where the flow says so. Two parallel paths to the same artifact is how activations stop being auditable.
```

(c) Insert a new section between `## Skill Priority` and `## Red Flags`:

```markdown
## Your KDD Environment

The session bootstrap ends with a `<KDD-ENVIRONMENT>` block: four lines
computed from the project at session start. Read it before your first
workflow skill and act on it — once, not every turn.

| Line | Value | What you do |
|------|-------|-------------|
| `toolkit:` | `NOT FOUND` | Before brainstorming, writing-plans, subagent-driven-development, executing-plans or finishing-a-development-branch: tell your human partner the `kdd` toolkit plugin is required (`/plugin install kdd` from the KDD marketplace, or `KDD_SPEC_GRAPH=/path/to/spec-graph.mjs`) and stop there. Skills that do not touch the graph (test-driven-development, systematic-debugging, using-git-worktrees, requesting-code-review in brownfield mode) keep working. |
| `specs_dir:` | `NONE` | Say once that `specs/work/` will be created with the first WRK-SPEC and that, with no knowledge base, activation will be `[]` and knowledge will be captured from the code (kdd-superpowers:kdd-conventions, *capturing-from-code*). Do not ask whether to "use KDD" — there is no other mode. |
| `open_work:` | one or more entries | If the request fits an open WRK-SPEC, offer to resume it — read the WRK-SPEC, its WRK-PLAN and the ledger under `.kdd/sdd/<WRK-PLAN-ID>/` — before starting new work. A `completed` entry is work pending consolidation: mention it. |
| `okf_bundles:` | one or more directories | Mention once that OKF bundles must be imported before their concepts can be activated, and offer `kdd:spec-graph import-okf <dir> --dry-run`. Never activate a raw OKF concept. |

When every line is the quiet value (`toolkit:` found, `specs_dir:` present, `open_work: none`, `okf_bundles: none`) say nothing about it.
```

(d) In `## Red Flags`, add the row (last in the table):

```markdown
| "I already know which specs apply, no need to activate" | Activation is an auditable record, not your memory. Consult it — and freeze it in the WRK-SPEC. |
```

(e) Leave `## The Rule`, the announcement sentence, `## User Instructions` and everything else untouched.

- [ ] **Step 3: Run the structural test**

Run: `bash tests/scripts/test-skill-content.sh` — Expected: all `[PASS]`.

- [ ] **Step 4: Check the hook still injects a well-formed skill and commit**

Run: `bash tests/hooks/test-session-start.sh` — Expected: PASS (the skill text changed; the JSON escaping must still hold — the table pipes and backticks are fine).

```bash
git add skills/using-superpowers/SKILL.md tests/scripts/test-skill-content.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-010): using-superpowers reads the KDD environment and routes knowledge vs work"
```

## Acceptance Criteria

- [ ] The skill has the environment table, the routing bullets and the red flag; Platform Adaptation is gone (spec AC 2 behaviour, Skill 1).
- [ ] Structural and hook tests pass.

## Test Plan

1. `tests/scripts/test-skill-content.sh` (+7).
2. `tests/hooks/test-session-start.sh`.
3. Behavioural check in Task 019 (toolkit missing → brainstorming stops with install instruction).
