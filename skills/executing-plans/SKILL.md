---
name: executing-plans
description: Use when you have an active WRK-PLAN to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load the WRK-PLAN, review it critically, execute every WRK-TASK with its knowledge context, keep the ledger, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** If subagents are available (they are on Claude Code), use kdd-superpowers:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Ensure an isolated workspace: use kdd-superpowers:using-git-worktrees to create one or verify the existing one
2. Read the WRK-PLAN (*Approach*, *Task Breakdown*, *Architecture Impact*) and the WRK-SPEC it implements (`parent`). Both must be `status: active`; otherwise stop and say why.
3. Resolve the ledger: `skills/subagent-driven-development/scripts/sdd-workspace PLAN_FILE` prints `.kdd/sdd/<WRK-PLAN-ID>/`; the ledger is `.kdd/sdd/<WRK-PLAN-ID>/progress.md`, first line `# SDD ledger — plan: <WRK-PLAN-ID> (<path>)`. If it exists and names this plan, tasks with a `Task <ID>: complete` line are done — resume after them.
4. Review critically - identify any questions or concerns about the plan, including any task whose `activates` is outside the spec's set or whose Architecture Impact row no longer matches the source spec
5. If concerns: Raise them with your human partner before starting
6. If no concerns: Create todos for the tasks in Task Breakdown order and proceed

### Step 2: Execute Tasks

For each WRK-TASK:
1. Mark as in_progress
2. Run `skills/subagent-driven-development/scripts/task-brief TASK_FILE` and read the brief it prints: the task, the plan's Architecture Impact, the activated specs in full, the cited fragments. Sections 2–4 are requirements. A **PIN DRIFT** header means the spec moved since planning: ledger `Knowledge gap: <spec> pinned <a>, file <b>` and implement what the task says.
3. Follow each step exactly (the task has bite-sized steps); commit subjects start with the task ID
4. Run verifications as specified
5. When a step contradicts an activated rule, or the code you touch contradicts one, do not improvise: ledger `Knowledge gap: …` with the rule ID and continue with the task as written unless it is blocked (see below)
6. Set `status: completed` and `updated` in the WRK-TASK frontmatter, validate (`<kdd-cli> --specs specs validate`), commit (`chore(<WRK-TASK-ID>): complete`), append `Task <ID>: complete (commits <a7>..<b7>)` to the ledger
7. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Set the WRK-PLAN to `status: completed`, validate, commit (`chore(<WRK-PLAN-ID>): complete`)
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use kdd-superpowers:finishing-a-development-branch
- Follow that skill to verify tests and knowledge integrity, consolidate, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly
- A task cannot be completed without violating a rule of an activated spec — that is a spec or plan defect, not a ruling you make alone in an inline session

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- The brief's knowledge sections are requirements, and the ledger is where knowledge gaps go — never `activates`
