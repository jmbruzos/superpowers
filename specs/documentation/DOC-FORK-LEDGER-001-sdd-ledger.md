---
id: DOC-FORK-LEDGER-001
type: spec
layer: documentation
scope: persistent
status: draft
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
domain: kdd-superpowers
subdomain: Execution
title: "The SDD ledger — where it lives, the lines the skills write, and how a reader tells progress from notes"
sources:
  - id: FRAG-FORK-LEDGER-001
    resource: specs/_capture/FRAG-FORK-LEDGER-001-sdd-ledger-line-forms/
    title: SDD ledger line forms as the workflow skills specify them (85acb22), attacked by gate A6 on 2026-10-05
  - id: WRK-SPEC-FORK-MODS-001
    resource: specs/work/WRK-SPEC-FORK-MODS-001-kdd-work-mod.md
    title: The work that added the first code reader of the ledger (kdd-status)
dependencies:
  - id: FRAG-FORK-LEDGER-001
    relation: distilled-from
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-05T18:30:00+02:00
stale_after: 2027-04-03T18:30:00+02:00
tags: [kdd, fork, ledger, sdd, execution]
---

# DOC-FORK-LEDGER-001 — The SDD ledger

## Purpose

Say what the SDD ledger is as a contract: where it lives, which lines the
workflow skills write into it, and how a reader — a controller resuming
after compaction, finishing harvesting the Execution Log, or `kdd-status`
— tells completion from notes. The ledger used to be read only by models
following prose; since WRK-SPEC-FORK-MODS-001 it is also parsed by code, so
its forms are now load-bearing.

## Audience

Whoever edits subagent-driven-development, executing-plans,
finishing-a-development-branch, kdd-conventions, or
`skills/kdd-conventions/scripts/kdd-status*`.

## Content

Everything below resisted gate A6 (2026-10-05, 15 attacks) unless it sits
under *Known inconsistencies*.

### Where it lives

`.kdd/sdd/<WRK-PLAN-ID>/progress.md`, git-ignored. Every skill that names it
agrees: executing-plans:21, finishing-a-development-branch:86,
kdd-conventions/SKILL.md:36, using-superpowers/SKILL.md:46, and
`kdd-status` (`join(root, '.kdd', 'sdd', planId, 'progress.md')`). The
directory name is the plan's frontmatter `id:`; `sdd-workspace` falls back
to the file basename only when the plan has no `id:`.

### Identity line

The first line is written as `# SDD ledger — plan: <WRK-PLAN-ID> (<plan
file path>)` (subagent-driven-development/SKILL.md:155). A ledger whose
first line does not name the plan is another plan's progress.

### Completion

A finished task is a line starting `Task <task>: complete`, always followed
by a parenthesised suffix (`(commits <a7>..<b7>, review clean)`, `…, <K>
parked)`, executing-plans' `(commits <a7>..<b7>)`). Readers match the prefix,
never the whole line. The colon delimits the task: `Task 10: complete` does
not complete task 1. `<task>` is written as the WRK-TASK ID in the templates
and as a number in the worked example (`Task 1`), so readers accept both.

### Notes that are not completion

`Task <ID>: fix round <R>/5 …` (a task mid-loop), `Task <ID>: minor
(deferred): …`, `Task <ID>: parked — … — Ruling: …`, and `Ruling:` lines
never start with `Task <x>: complete`. Rulings have no fixed prefix
(`Ruling:`, `Task <ID>: Ruling:`, `… parked — … — Ruling:`, `Attack: … —
Ruling:` from adversarial-gates.md:28); the skills collect them as "every
ledger line containing `Ruling:`" (SDD:535), and finishing harvests them
verbatim. Every writer tags knowledge problems `Knowledge gap:`
(executing-plans, receiving-code-review, requesting-code-review,
adversarial-gates). `kdd-status` follows both rules by containment and
ignores a leading list bullet.

### Known inconsistencies (open, not rules)

Gate A6 refuted these readings; each is a decision still to make, recorded
in WRK-PLAN-FORK-MODS-001's Execution Log.

1. **Ledger vs task status.** SDD:480-482: "A task whose file still says
   `active` is not complete, whatever the ledger says." SDD writes the
   completion line before the task transition, executing-plans after it;
   `kdd-status` counts a task done on either signal. An SDD run interrupted
   between the two steps reads as done in `kdd-status` and as not done in SDD.
2. **Identity by file or by ID.** SDD:148-153 compares the first line by
   *plan file*; `kdd-status` by *plan ID*. A moved or renamed plan file
   splits them.
3. **`Task <n>`: position or ID suffix.** The worked example cannot tell
   the two apart; kdd-conventions defines TTT as the position in the Task
   Breakdown, `kdd-status` parses the suffix. They diverge only if tasks are
   reordered after IDs are allocated.
4. **Which root.** `sdd-workspace` roots the ledger in the working tree
   that holds the plan file (`git -C <plan dir> rev-parse --show-toplevel`);
   `kdd-status` in the cwd's toplevel. Run from the main checkout, it does
   not see a ledger that lives in a worktree — and the ledger is deleted
   with the worktree at finishing.
5. **Inventory.** The ledger also carries `Capture candidate: <anchor> —
   …` lines (SDD:329), the pre-flight conflict table (SDD:192) and ledger
   notes (SDD:169); no reader parses them today.

## Maintenance

Change a ledger form in the skills and in `kdd-status-lib.mjs` in the same
commit; `tests/scripts/test-kdd-status.sh` holds the parsed forms. Resolving
an inconsistency above is a WRK-SPEC of its own; bump this document when it
closes. Owner: jmbruzos.

## Status

Draft, `confidence: low`: distilled from one code capture of skill prose and
one A6 pass; the only code reader is `kdd-status`.
