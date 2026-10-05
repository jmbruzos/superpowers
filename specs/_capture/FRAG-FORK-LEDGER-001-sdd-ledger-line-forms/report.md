# Exploration report — SDD ledger line forms (kdd-superpowers, 85acb22)

## Scope
The line forms the workflow skills tell the orchestrator to write into the SDD ledger
(`.kdd/sdd/<WRK-PLAN-ID>/progress.md`), as far as a reader of the ledger needs them to tell
which plan a ledger belongs to, which tasks are done, and which lines are rulings or knowledge
gaps. Needed by WRK-SPEC-FORK-MODS-001 (`kdd-status` parses the ledger). Nothing else.

## Observed
- `skills/subagent-driven-development/scripts/sdd-workspace:34-34@85acb22`: `slug=$(awk 'NR==1&&$0!="---"{exit} /^---$/{c++; if(c==2) exit; next} c==1&&/^id:[[:space:]]*/{sub(/^id:[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print; exit}' "$plan")`
- `skills/subagent-driven-development/scripts/sdd-workspace:35-35@85acb22`: `[ -n "$slug" ] || slug=$(basename "$plan" .md)`
- `skills/subagent-driven-development/scripts/sdd-workspace:41-41@85acb22`: `base="$root/.kdd/sdd"`
- `skills/subagent-driven-development/scripts/sdd-workspace:42-42@85acb22`: `dir="$base/$slug"`
- `skills/subagent-driven-development/SKILL.md:155-155@85acb22`: `# SDD ledger — plan: <WRK-PLAN-ID> (<plan file path>)`
- `skills/executing-plans/SKILL.md:21-21@85acb22`: `the ledger is`
- `skills/executing-plans/SKILL.md:21-21@85acb22`: `/progress.md`
- `skills/subagent-driven-development/SKILL.md:149-149@85acb22`: `: complete`
- `skills/subagent-driven-development/SKILL.md:149-149@85acb22`: `line are DONE`
- `skills/subagent-driven-development/SKILL.md:475-475@85acb22`: `Task <WRK-TASK-ID>: complete (commits <base7>..<head7>, review clean)`
- `skills/subagent-driven-development/SKILL.md:476-476@85acb22`: `Task <WRK-TASK-ID>: complete (commits <base7>..<head7>, <K> parked)`
- `skills/executing-plans/SKILL.md:34-34@85acb22`: `then append`
- `skills/executing-plans/SKILL.md:34-34@85acb22`: `Task <ID>: complete (commits <a7>..<b7>)`
- `skills/subagent-driven-development/SKILL.md:592-592@85acb22`: `[Ledger: Task 1: complete (commits a1b2c3d..d4e5f6a, review clean)]`
- `skills/subagent-driven-development/SKILL.md:618-618@85acb22`: `[Ledger: Task 2: complete (commits d4e5f6a..b7c8d9e, review clean)]`
- `skills/subagent-driven-development/SKILL.md:23-23@85acb22`: `Ruling: <what you decided> — <why> — <what it costs if wrong>`
- `skills/subagent-driven-development/SKILL.md:454-454@85acb22`: `Task <WRK-TASK-ID>: parked — <finding> — Ruling: <why the code stands>`
- `skills/subagent-driven-development/SKILL.md:460-460@85acb22`: `ledger it as`
- `skills/subagent-driven-development/SKILL.md:460-460@85acb22`: `Task <WRK-TASK-ID>: Ruling: <finding> — <what you decided and why>`
- `skills/subagent-driven-development/SKILL.md:535-535@85acb22`: `collect every ledger line containing`
- `skills/subagent-driven-development/SKILL.md:30-30@85acb22`: `knowledge — is additionally tagged`
- `skills/subagent-driven-development/SKILL.md:30-30@85acb22`: `Knowledge gap: <what is missing or`
- `skills/executing-plans/SKILL.md:33-33@85acb22`: `Knowledge gap: …`
- `skills/subagent-driven-development/SKILL.md:444-444@85acb22`: `Task <WRK-TASK-ID>: fix round <R>/5 (<X> addressed, <Y> open — <finding one-liners>; commits <a7>..<b7>)`
- `skills/subagent-driven-development/SKILL.md:400-400@85acb22`: `Task <WRK-TASK-ID>: minor (deferred): <one-liner>`

## Inferred
- The ledger of a plan is `<repo-root>/.kdd/sdd/<plan frontmatter id>/progress.md`, the directory named by the plan's `id:` and by its file basename only when it has none (rests on: sdd-workspace:34-35, 41-42; executing-plans:21).
- The first line identifies the plan; a ledger whose first line names another plan is not this plan's (rests on: SDD:155; executing-plans:21).
- A task is done when a line starts with `Task <task>: complete`; the line carries a parenthesised suffix, so a reader matches the prefix, not the whole line (rests on: SDD:149, 475-476; executing-plans:34).
- `<task>` is written as the WRK-TASK ID in the templates but as the task's position in the plan (`Task 1`, `Task 2`) in the worked example, so a reader should accept both (rests on: SDD:475-476 vs SDD:592, 618).
- Rulings have no fixed line prefix: `Ruling:` appears at the start or after a `Task <ID>:` / `parked — … —` prefix; the skill's own collection rule is "line containing `Ruling:`" (rests on: SDD:23, 454, 460, 535).
- Knowledge gaps are tagged `Knowledge gap:`, possibly after other text (rests on: SDD:30; executing-plans:33).
- Other line forms (`fix round <R>/5`, `minor (deferred)`) are progress notes, not completion (rests on: SDD:444, 400).

## Absences
- `grep -rn 'progress.md' skills/*/scripts/` → 0 results; no script reads ledger lines today.
