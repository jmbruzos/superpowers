---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring skill invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## The Rule

**Invoke relevant or requested skills BEFORE any response or action** — including clarifying questions, exploring the codebase, or checking files. If it turns out wrong for the situation, you don't have to use it.

**Before entering plan mode:** if you haven't already brainstormed, invoke the brainstorming skill first.

Then announce "Using [skill] to [purpose]" and follow the skill exactly. If it has a checklist, create a todo per item.

## Skill Priority

When multiple skills apply, process skills come first — they set the approach, then implementation skills (frontend-design, etc.) carry it out. Brainstorming and systematic-debugging are Superpowers' most common process skills, but the rule holds for any of them.

- "Let's build X" → kdd-superpowers:brainstorming first, then implementation skills.
- "Fix this bug" → kdd-superpowers:systematic-debugging first, then domain skills.
- "Write a domain / architecture / product spec for X" → the Knowledge axis belongs to the toolkit: `kdd:spec-create` or the `kdd-spec-assistant` agent. Never brainstorming.
- "Build / change / add X" → the Work axis: kdd-superpowers:brainstorming, which produces the WRK-SPEC and freezes its knowledge activation.
- `kdd:*` skills are not invoked directly for steps of the workflow (discovery, activation, consolidation) — the workflow skills invoke them where the flow says so. Two parallel paths to the same artifact is how activations stop being auditable.

## Your KDD Environment

The session bootstrap ends with a `<KDD-ENVIRONMENT>` block: four lines
computed from the project at session start. Read it before your first
workflow skill and act on it — once, not every turn.

| Line | Value | What you do |
|------|-------|-------------|
| `toolkit:` | `NOT FOUND` | When `toolkit: NOT FOUND`: before brainstorming, writing-plans, subagent-driven-development, executing-plans or finishing-a-development-branch, tell your human partner the `kdd` toolkit plugin is required (`/plugin install kdd` from the KDD marketplace, or `KDD_SPEC_GRAPH=/path/to/spec-graph.mjs`) and stop there. Skills that do not touch the graph (test-driven-development, systematic-debugging, using-git-worktrees, requesting-code-review in brownfield mode) keep working. |
| `specs_dir:` | `NONE` | Say once that `specs/work/` will be created with the first WRK-SPEC and that, with no knowledge base, activation will be `[]` and knowledge will be captured from the code (kdd-superpowers:kdd-conventions, *capturing-from-code*). Do not ask whether to "use KDD" — there is no other mode. |
| `open_work:` | one or more entries | If the request fits an open WRK-SPEC, offer to resume it — read the WRK-SPEC, its WRK-PLAN and the ledger under `.kdd/sdd/<WRK-PLAN-ID>/` — before starting new work. A `completed` entry is work pending consolidation: mention it. |
| `okf_bundles:` | one or more directories | Mention once that OKF bundles must be imported before their concepts can be activated, and offer `kdd:spec-graph import-okf --dry-run` against each directory (e.g. `kdd:spec-graph import-okf <dir> --dry-run`). Never activate a raw OKF concept. |

When every line is the quiet value (`toolkit:` found, `specs_dir:` present, `open_work: none`, `okf_bundles: none`) say nothing about it.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |
| "I already know which specs apply, no need to activate" | Activation is an auditable record, not your memory. Consult it — and freeze it in the WRK-SPEC. |

## User Instructions

User instructions (CLAUDE.md, AGENTS.md, GEMINI.md, etc, direct requests) take precedence over skills, which in turn override default behavior. Only skip skill workflows or instructions when your human partner has explicitly told you to.
