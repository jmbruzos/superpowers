---
id: DOC-FORK-LEDGER-001
type: spec
layer: documentation
scope: persistent
status: draft
confidence: low
version: 0.2.0
created: 2026-10-05
updated: 2026-10-19
owner: jmbruzos
domain: kdd-superpowers
subdomain: Execution
title: "The SDD ledger — where it lives, who writes which lines, and how a reader tells progress from notes"
sources:
  - id: FRAG-FORK-LEDGER-001
    resource: specs/_capture/FRAG-FORK-LEDGER-001-sdd-ledger-line-forms/
    title: SDD ledger line forms as the workflow skills specify them (85acb22), attacked by gate A6 on 2026-10-05
  - id: WRK-SPEC-FORK-MODS-001
    resource: specs/work/WRK-SPEC-FORK-MODS-001-kdd-work-mod.md
    title: The work that added the first code reader of the ledger (kdd-status)
  - id: WRK-SPEC-FORK-UPSTREAM-004
    resource: specs/work/WRK-SPEC-FORK-UPSTREAM-004-batch-3-native.md
    title: The work that added Native as a ledger writer and settled identity, resume signal, root and range (DOC-FORK-UPSTREAM-001 §3.5)
  - id: FRAG-FORK-UPSTREAM-004
    resource: specs/_capture/FRAG-FORK-UPSTREAM-004-batch-3-native-measurement/
    title: Batch-3 level 1 — Native's real ledger read by kdd-status in scenario 8 (both completion lines, ledger used)
dependencies:
  - id: FRAG-FORK-LEDGER-001
    relation: distilled-from
  - id: FRAG-FORK-UPSTREAM-004
    relation: distilled-from
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-19T01:30:56Z
stale_after: 2027-04-03T18:30:00+02:00
tags: [kdd, fork, ledger, sdd, native, execution]
---

# DOC-FORK-LEDGER-001 — The SDD ledger

## Purpose

Say what the SDD ledger is as a contract: where it lives, which lines the
workflow skills and scripts write into it, and how a reader — a controller
resuming after compaction, finishing harvesting the Execution Log, or
`kdd-status` — tells completion from notes. The ledger used to be read only
by models following prose; since WRK-SPEC-FORK-MODS-001 it is also parsed by
code, and since WRK-SPEC-FORK-UPSTREAM-004 (0.9.0) it is also written by
code (Native's `task-start` and `task-done`), so its forms are load-bearing
in both directions.

## Audience

Whoever edits subagent-driven-development, executing-plans,
finishing-a-development-branch, kdd-conventions,
`skills/executing-plans/scripts/task-*`, or
`skills/kdd-conventions/scripts/kdd-status*`.

## Content

The forms of 0.1.0 resisted gate A6 (2026-10-05, 15 attacks). What 0.2.0
adds was settled in WRK-SPEC-FORK-UPSTREAM-004 (gate A1 25/26 BROKEN, A2
26/31, all accepted) and tested with the writers' real output
(`tests/claude-code/test-executing-plans-scripts.sh`,
`tests/scripts/test-kdd-status.sh`, scenario 8 in FRAG-FORK-UPSTREAM-004);
it has not been through A6. Line citations are at `6046936`.

### Writers

| Mode | Identity line | Completion line | Order |
|---|---|---|---|
| Subagent-driven (SDD) | the controller, by hand (SDD SKILL.md:162-163) | the controller, by hand (SDD:483-484) | line first, then `transition … completed` (SDD:487-489) |
| Native (executing-plans) | `scripts/task-start`, when the ledger is absent (task-start:52) | `scripts/task-done`, after a passing test run (task-done:122) | `transition … completed` first, then the line |

Both modes keep the ledger in the same workspace and write the same
identity form; `kdd-status-lib.mjs`'s header names both writers.

### Where it lives

`.kdd/sdd/<WRK-PLAN-ID>/progress.md`, git-ignored. Every skill that names
it agrees: executing-plans SKILL.md:139, finishing-a-development-branch:86,
and `kdd-status` (`join(root, '.kdd', 'sdd', planId, 'progress.md')`,
kdd-status:47). The directory name is the plan's frontmatter `id:`;
`sdd-workspace` falls back to the file basename only when the plan has no
`id:`. `sdd-workspace` writes `.kdd/sdd/.gitignore` only when none exists
(create-only, sdd-workspace:44-46), so a repository may version its own.

**Root (settled).** The ledger lives in the working tree that holds the
plan file: `sdd-workspace` and `task-start` root at `git -C <plan dir>
rev-parse --show-toplevel`. `kdd-status` roots at the cwd's toplevel; run
from another checkout or worktree of the repository it reports the plan's
ledger as `none`. That outcome is a decision, tested by
`test-kdd-status.sh` ("second worktree on the same commit: ledger none"),
not an accident. Reading other worktrees' ledgers is out of scope. The
workspace is deleted with the worktree at finishing.

### Identity line

The first line is `# SDD ledger — plan: <WRK-PLAN-ID> (<plan file path>)`
(SDD:163; task-start writes the path relative to the repository root).
**Readers compare the plan ID, in both modes:** the line must start
`# SDD ledger — plan: <WRK-PLAN-ID> ` (ID followed by a space). SDD
(SDD:152-153, 160-161), `task-start` (exit 2 on another plan's ledger,
task-start:48-49) and `kdd-status` (kdd-status-lib:28) all do this; the
path in parentheses is informative, so a moved or renamed plan file keeps
its ledger. A ledger whose first line names another plan ID is another
plan's progress. `task-start` also refuses (exit 2) a WRK-TASK whose
`parent:` is not the plan's `id:`.

### Completion

A finished task is a line starting `Task <task>: complete`, always followed
by a parenthesised suffix:

- SDD: `(commits <base7>..<head7>, review clean)` or `(commits
  <base7>..<head7>, <K> parked)` after a tripped breaker (SDD:483-484);
- Native: `(commits <base7>..<head7>, tests: <command> → <last non-blank
  output line, or "(no output)">)` (executing-plans:292; task-done:120-122).

Readers match the prefix, never the whole line. The colon delimits the
task: `Task 10: complete` does not complete task 1. `<task>` is written as
the WRK-TASK ID in the templates and by `task-done`, and as a number in
SDD's worked example (`Task 1`), so readers accept both.

**Range.** `<base7>` is the commit before the task's first commit;
`<head7>` is the task's last work commit — the range ends **before** the
transition commit in both modes. `task-done` refuses (exit 3) an empty
`BASE..HEAD` range before running the tests, and records nothing when the
tests fail.

**Re-run of `task-done`.** On a task already `completed` with its line
present: no-op, exit 0. On a task `completed` without its line (an
interruption between transition and line): it recovers the task's own
range from git — from the parent of the oldest commit whose subject
carries the WRK-TASK ID to the parent of the `chore(<WRK-TASK-ID>):
complete` commit — and appends the line once. That commit subject is the
one `kdd-conventions/scripts/transition` writes (transition:131); changing
it breaks the recovery. A passed BASE that is not the start of that range
is refused (exit 3) with the recovered BASE printed.

### Resume signal (settled)

**A task is done when its WRK-TASK frontmatter says `completed`**, in both
modes and in `kdd-status` (SDD:152-156; executing-plans:141-143). The
ledger line is the record, not the signal. Each mode names the repair for
the state its own order can leave:

- SDD (line before transition): a `Task <ID>: complete` line over a file
  still `active` was interrupted before its transition — run the
  transition, do not re-dispatch (SDD:156-158);
- Native (transition before line): a `completed` task with no line — re-run
  `task-done`, which appends the line with the original range
  (executing-plans:144-146).

A task whose last ledger line is a fix round (SDD) is mid-loop: resume at
the next round.

### Notes that are not completion

None of these starts with `Task <x>: complete`:

- SDD: `Task <ID>: fix round <R>/5 …`, `Task <ID>: minor (deferred): …`,
  `Task <ID>: parked — … — Ruling: …`, `Task <ID>: Ruling: …`, and
  `Capture candidate: <anchor> — …` (SDD:337);
- Native: `Pre-flight: …` (e.g. `Pre-flight: no shared interfaces`,
  executing-plans:178), `Attack: … — Ruling: …` (A4 rows, :254), `Final:
  minor (deferred): …` (:332), `Final: fixed <finding> — <test> RED→GREEN,
  suite <N>/<N>` (:341), `Final: Ruling: …` (:347);
- both: bare `Ruling:` lines.

Rulings have no fixed prefix; the skills collect them as "every ledger line
containing `Ruling:`" (SDD:543; executing-plans *Finish*), and finishing
harvests them verbatim into the plan's Execution Log. Every writer tags
knowledge problems `Knowledge gap:` (executing-plans, receiving-code-review,
requesting-code-review, adversarial-gates). `kdd-status` follows both rules
by containment and ignores a leading list bullet.

### Workspace lifetime

Neither mode deletes the workspace: Native's *Finish* leaves it in place
(executing-plans:363-365), and finishing-a-development-branch harvests the
ledger and deletes it, as for SDD.

### `review-package` exit 3

`review-package PLAN_FILE BASE HEAD` exits 3 when HEAD does not descend
from BASE (wrong branch or worktree) or the range is empty (review-package:
27-28). SDD rules on it — find the task's commits or rule on the task — and
ledgers the ruling before going on (SDD:321).

### Known inconsistencies (open, not rules)

Settled by WRK-SPEC-FORK-UPSTREAM-004 and removed from this list: 0.1.0's
(1) ledger vs task status — the frontmatter is the signal, each mode names
its repair; (2) identity by file or by ID — by ID everywhere; (4) which root
— the plan's working tree, `none` from another checkout, tested.

Still open:

1. **`Task <n>`: position or ID suffix.** SDD's worked example cannot tell
   the two apart; kdd-conventions defines TTT as the position in the Task
   Breakdown, `kdd-status` parses the suffix. They diverge only if tasks are
   reordered after IDs are allocated.
2. **Inventory.** The ledger also carries `Capture candidate:` lines, the
   pre-flight conflict table and ledger notes; no code reader parses them.
3. **`task-done`'s root.** `task-done` takes the repository root from the
   cwd (task-done:43), `task-start` from the plan's directory; run from
   another checkout it fails with a misleading exit 4. Deferred minor of
   WRK-TASK-FORK-UPSTREAM-004-001.
4. **Bulleted lines.** `task-done`'s check for an existing line ignores a
   leading list bullet that `kdd-status` tolerates, so a bulleted SDD line
   gets a second, unbulleted line. Deferred minor of the same task.
5. **Result tail.** The `→ <result>` part is the test output's last
   non-blank line; under `node --test` that is an `ℹ duration_ms …` line,
   not the pass/fail summary (seen in every batch-3 pressure run). Deferred
   minor of WRK-TASK-FORK-UPSTREAM-004-002.
6. **First-commit lookup.** `task-done`'s recovery finds the first commit
   by substring (`…-001` also matches `…-0010`), and a task whose commits
   lack its ID exits 3 on re-run (fails closed). Deferred minor of the
   batch-3 final review.

## Maintenance

Change a ledger form or writer in the skills, the `task-*` scripts and
`kdd-status-lib.mjs` (header comment) in the same commit;
`tests/scripts/test-kdd-status.sh` holds the parsed forms and
`tests/claude-code/test-executing-plans-scripts.sh` the written ones.
Resolving an inconsistency above is a WRK-SPEC of its own; bump this
document when it closes. Owner: jmbruzos.

## Status

Draft, `confidence: low`: the 0.1.0 forms are distilled from one code
capture and one A6 pass; the 0.2.0 additions come from one batch's design
gates and its deterministic tests and two scenario-8 runs, not from an A6
pass. Code readers: `kdd-status`, `task-done` (its own line).
