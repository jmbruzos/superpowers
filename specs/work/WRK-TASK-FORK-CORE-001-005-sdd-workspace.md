---
id: WRK-TASK-FORK-CORE-001-005
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "sdd-workspace under .kdd/sdd/<WRK-PLAN-ID>/"
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
tags: [kdd, fork, task, tooling]
---

# WRK-TASK-FORK-CORE-001-005 — `sdd-workspace` under `.kdd/sdd/<WRK-PLAN-ID>/`

## Objective

Key the SDD workspace by the plan's KDD identifier instead of its file
basename, so the ledger, briefs and review packages of
`WRK-PLAN-RISK-VAR-ENGINE-001` live in `.kdd/sdd/WRK-PLAN-RISK-VAR-ENGINE-001/`
(spec Skill 4 *Workspace and ledger*, P13). Task 001 already moved the root
from `.superpowers/` to `.kdd/`.

## Implementation Notes

**Files:**
- Modify: `skills/subagent-driven-development/scripts/sdd-workspace`, `skills/subagent-driven-development/scripts/review-package` (header comment only), `tests/claude-code/test-sdd-workspace.sh`
- Test: `tests/claude-code/test-sdd-workspace.sh` (it is bash-only despite its directory; it needs no Claude)

**Interfaces:**
- Consumes: fixture `WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md` (Task 002).
- Produces: `sdd-workspace PLAN_FILE` → `<repo-root>/.kdd/sdd/<id>/` where `<id>` is the frontmatter `id:` of PLAN_FILE, falling back to the file basename when there is no frontmatter id. Tasks 006/007 write briefs there; Task 013's skill text names the path.

- [ ] **Step 1: Extend the existing test (failing)**

In `tests/claude-code/test-sdd-workspace.sh`, after the `plan-b.md` fixture
block, add a KDD plan fixture and two assertions. Insert after the line
`PLAN` that closes `plan-b.md`:

```bash
    mkdir -p "$repo/specs/work"
    cp "$REPO_ROOT/tests/scripts/fixtures/specs/work/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md" "$repo/specs/work/"
```

and, right after the assertion `two plans resolve to two distinct directories`, add:

```bash
    local dir_k
    dir_k="$(cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" specs/work/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md)"
    if [[ "$dir_k" == "$repo/.kdd/sdd/WRK-PLAN-BILL-PRORATA-001" ]]; then
        pass "a WRK-PLAN resolves to .kdd/sdd/<frontmatter id>"
    else
        fail "a WRK-PLAN resolves to .kdd/sdd/<frontmatter id>"
        echo "    got: $dir_k"
    fi
    if [[ "$dir_a" == "$repo/.kdd/sdd/plan-a" ]]; then
        pass "a plan without frontmatter falls back to its basename"
    else
        fail "a plan without frontmatter falls back to its basename"
    fi
```

Also update the existing assertion text `prints <repo-root>/.kdd/sdd/<plan-basename>` to
`prints <repo-root>/.kdd/sdd/<plan-basename> (no frontmatter)` — the `.kdd` part was
already renamed by Task 001.

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/claude-code/test-sdd-workspace.sh`
Expected: `[FAIL] a WRK-PLAN resolves to .kdd/sdd/<frontmatter id>` (got `…/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation`); the rest pass.

- [ ] **Step 3: Change `sdd-workspace` to key by id**

Replace the `slug=…` line and the two lines after it in
`skills/subagent-driven-development/scripts/sdd-workspace` with:

```bash
# Workspace key: the plan's KDD id (frontmatter `id:`), so every artifact of
# WRK-PLAN-X-001 lives under .kdd/sdd/WRK-PLAN-X-001/ regardless of the file's
# slug. Plain plan files without frontmatter fall back to their basename.
slug=$(awk 'NR==1&&$0!="---"{exit} /^---$/{c++; if(c==2) exit; next} c==1&&/^id:[[:space:]]*/{sub(/^id:[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print; exit}' "$plan")
[ -n "$slug" ] || slug=$(basename "$plan" .md)
[ -n "$slug" ] && [ "$slug" != "." ] && [ "$slug" != ".." ] && [[ "$slug" != */* ]] \
  || { echo "cannot derive a workspace name from: $plan" >&2; exit 2; }
```

and update the header comment's `(.kdd/sdd/<plan-basename>/)` to
`(.kdd/sdd/<plan id>/, basename fallback)`. In `review-package`, change the
`Default OUTFILE` comment to `<repo-root>/.kdd/sdd/<plan id>/review-<base7>..<head7>.diff`.

- [ ] **Step 4: Run the test**

Run: `bash tests/claude-code/test-sdd-workspace.sh`
Expected: all `[PASS]`, `PASS`.

- [ ] **Step 5: Run the suites and commit**

Run: `bash tests/scripts/run.sh && bash tests/claude-code/test-sdd-workspace.sh` — Expected: ok.

```bash
git add skills/subagent-driven-development/scripts tests/claude-code/test-sdd-workspace.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-005): SDD workspace keyed by WRK-PLAN id under .kdd/sdd/"
```

## Acceptance Criteria

- [ ] `sdd-workspace specs/work/WRK-PLAN-….md` prints `<root>/.kdd/sdd/<id>` and creates it with the self-ignoring `.gitignore` (spec AC 8).
- [ ] Files without frontmatter still resolve (basename), worktree isolation test still passes.

## Test Plan

1. `tests/claude-code/test-sdd-workspace.sh` (extended).
