---
id: WRK-TASK-FORK-UPSTREAM-004-001
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "task-start / task-done and the ledger reader"
parent: WRK-PLAN-FORK-UPSTREAM-004
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-LEDGER-001@0.1.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-UPSTREAM-004
    relation: implements
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T12:30:39+02:00 }
stale_after: 2027-01-16T12:30:00+02:00
tags: [fork, upstream, executing-plans, task]
---

# WRK-TASK-FORK-UPSTREAM-004-001 — task-start / task-done and the ledger reader

## Objective
WRK-SPEC components 2, 3 and 8: the two Native bookkeeping scripts over WRK-TASK files, ported from `upstream/main` and adapted, their test, and §3.5's reader side (kdd-status-lib header, test-kdd-status cases) in the same commit.

## Implementation Notes
**Files:** Create `skills/executing-plans/scripts/task-start`, `skills/executing-plans/scripts/task-done`, `tests/claude-code/test-executing-plans-scripts.sh`. Modify `skills/kdd-conventions/scripts/kdd-status-lib.mjs` (header comment only), `tests/scripts/test-kdd-status.sh`.

**Interfaces:** Produces
- `task-start PLAN_FILE TASK_FILE` → stdout `brief: <path>` and `base: <40-hex sha>`; exit 2 on usage, on a task whose `parent:` ≠ the plan's `id:`, or on a ledger whose line 1 does not start `# SDD ledger — plan: <WRK-PLAN-ID> `; creates the ledger with `# SDD ledger — plan: <WRK-PLAN-ID> (<plan path relative to the repo root>)` when absent.
- `task-done PLAN_FILE TASK_FILE BASE -- CMD…` → exit 3 on an empty `BASE..HEAD`; runs CMD into `<workspace>/<WRK-TASK-ID>-tests.log`, prints its last 5 lines; on success: head7 = `git rev-parse --short=7 HEAD`, `bash <repo>/skills/kdd-conventions/scripts/transition <TASK_FILE> completed`, appends `Task <WRK-TASK-ID>: complete (commits <base7>..<head7>, tests: <cmd> → <last non-blank line, or (no output)>)`; re-run on a `completed` task without its line: head7 = parent of the task's `chore(<WRK-TASK-ID>): complete` commit, line appended; with the line: no-op exit 0. Exit = CMD's status.
- Both find the workspace with `bash <repo>/skills/subagent-driven-development/scripts/sdd-workspace PLAN_FILE` and the brief with `node <repo>/skills/subagent-driven-development/scripts/task-brief TASK_FILE`.

**Premises:** `upstream/main:skills/executing-plans/scripts/task-done` handles a silent command with `|| last="(no output)"`; `transition` refuses a task already `completed` (exit 1) — spec premises 2, 5; `kdd-status-lib.mjs:3-6` is the header comment listing the forms.

- [ ] **Step 1: Write the failing tests**
  - `tests/claude-code/test-executing-plans-scripts.sh`, on a temp git repo with a copy of `tests/claude-code/fixtures/rounding-plan` (both scripts called through `bash`): task-start prints `brief:` (file exists) and a 40-hex `base:`, creates the identity line exactly; refuses a task of another plan (exit 2, no ledger); refuses a ledger naming `WRK-PLAN-OTHER-001` (exit 2, ledger unchanged); task-done with `-- true` after one commit → task file `status: completed`, a `chore(WRK-TASK-DEMO-MONEY-001-001): complete` commit, ledger line `Task WRK-TASK-DEMO-MONEY-001-001: complete (commits <b7>..<h7>, tests: true → (no output))` with h7 = the commit before the transition; `-- false` → exit 1, no line, task still `active`; no commit since BASE → exit 3; re-run after deleting the line → line back once with the same range; re-run with the line → exit 0, ledger unchanged; no arguments → exit 2.
  - `tests/scripts/test-kdd-status.sh`: the ledger the real scripts build (task 001 done, `Final: Ruling: x — y — z` appended) → `used`; task 001 `done`; the ledger contains the completion line (grep by content); task 002 not `done`; the `Final: Ruling:` line counts as a ruling, not as completion; run from a second worktree of the temp repo (`git worktree add` outside it) → the plan's ledger `none`.
- [ ] **Step 2: Run them** — `bash tests/claude-code/test-executing-plans-scripts.sh; bash tests/scripts/test-kdd-status.sh` → Expected: the new cases FAIL (scripts missing).
- [ ] **Step 3: Implement `task-start` and `task-done`** in `skills/executing-plans/scripts/` (bash, `set -euo pipefail`, executable), per Interfaces.
- [ ] **Step 4: Update the `kdd-status-lib.mjs` header comment** to name the Native writers and the note forms of WRK-SPEC component 8; no code change.
- [ ] **Step 5: Run** — the two tests, then `bash tests/scripts/run.sh` → Expected: all pass (exit codes).
- [ ] **Step 6: Commit** — `feat(WRK-TASK-FORK-UPSTREAM-004-001): Native task-start / task-done over WRK-TASKs; ledger reader documents the writers`.

**Amendments (gate A2, binding):**
- `task-done` runs `transition --specs <repo root>/specs <TASK_FILE> completed` (repo root from `git rev-parse --show-toplevel`); a test calls both scripts from a subdirectory cwd.
- CMD passes but the transition fails → exit 4, stderr "tests passed, transition failed — nothing recorded", no line; tested by making the graph red (a broken `dependencies` reference added to the task file before `task-done`).
- A task `active` whose completion line is already present (SDD interrupted between line and transition): tests run, the transition happens, no second line is written; tested.
- The "last non-blank line" path is pinned with `-- echo ok` (line ends `→ ok)`), beside `-- true` (`→ (no output)`).
- Step 2 also runs the tests against stub scripts that exit 0 and do nothing: every case must FAIL (spec AC1).
- The root cases: from a second worktree on the same branch the plan's ledger is `none`; from a checkout of `main`, which lacks the plan, `kdd-status` lists no such plan.
- The kdd-status-lib header in this commit names the forms these scripts write (identity, completion); task 002's commit adds the note forms its prose introduces.

## Acceptance Criteria
- [ ] Spec AC1 and AC2.

## Test Plan
1. `bash tests/claude-code/test-executing-plans-scripts.sh`; 2. `bash tests/scripts/test-kdd-status.sh`; 3. `bash tests/scripts/run.sh`.
