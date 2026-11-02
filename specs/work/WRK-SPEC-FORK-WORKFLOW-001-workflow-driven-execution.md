---
id: WRK-SPEC-FORK-WORKFLOW-001
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-11-02
updated: 2026-11-02
owner: jmbruzos
title: "RFC — workflow-driven execution: a third execution mode that runs the kdd-superpowers flow through orchestration scripts"
activates: []
equips: []
activation_frozen: false
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
sources:
  - id: FRAG-FORK-WORKFLOW-001
    resource: specs/_capture/FRAG-FORK-WORKFLOW-001-agentic-workflow-practice/
    title: Agentic workflow practice on a private KDD platform project (sanitized)
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T18:00:00+01:00
stale_after: 2027-01-31T18:00:00+01:00
tags: [kdd, fork, rfc, workflow, orchestration, subagent-driven-development, executing-plans]
---

# WRK-SPEC-FORK-WORKFLOW-001 — RFC: workflow-driven execution

## Problem Statement

One private KDD platform project ran the whole kdd-superpowers flow through Claude Code Workflow scripts for four
days: 63 scripts, 81 runs and about 1000 subagents, with up to four items in parallel (FRAG-FORK-WORKFLOW-001). The
flow held up. Specs, plans, tasks, rulings and gates worked unchanged. But everything that made orchestration safe
lived in hand-written scripts and in one session's memory:

- **There is no name for the mode.** For the same run, a plan's execution log says "native" and its activation
  commit says "subagent-driven" (O2).
- **Parallel items collide.** `next-id` sees only its own worktree, so two worktrees allocated the same id (O3).
  Container stacks need their own project name and ports per worktree (O3).
- **Authorization gets lost on the way down.** A subagent took a relayed user message as its own request (O4).
- **Spec refutation was invented per script.** The skills do not describe the three-lens rounds with one
  adjudicator (O1).
- **Integration of several branches is not in `finishing-a-development-branch`.** That covers sequential merges, one
  verification of the merged main, the predictable conflicts and the flake protocol (O6).

The next team that tries this will re-learn all of it.

## Proposed Change

### 1. A new skill: `orchestrating-workflows`

It becomes the third execution mode at writing-plans' handoff: **Subagent-driven / Native / Workflow**. The contract
has five parts:

1. **Item pipeline.** For each item: plan → (gate A2 when writing-plans requires it) → activate → one fresh agent per
   task, in Task Breakdown order → one whole-branch reviewer → one fix pass → close the plan. Each task's rulings go
   forward into the prompts of later tasks. A task that returns `blocked` stops its item. A task whose file already
   says `completed` is skipped, which makes a resume idempotent (O2, O7). The mode is recorded with the same word,
   `workflow`, in the activation commit and in the Execution Log.
2. **Spec rounds.** For each WRK-SPEC the workflow writes: author → three refuters in parallel (A1 spec adversary,
   premise verifier, cross-item consistency and security) → one reviser that adjudicates every BROKEN row. Only the
   questions the reviser cannot resolve go to the human. If a round accepts many fixes, a second round runs before the
   human sees the spec. The human's review is the stop (O1).
3. **Isolation.** One worktree per item. Each worktree gets an isolation template that the project supplies: a stack
   project name and a port offset. The orchestrator allocates every artifact id and passes it into the prompt; agents
   never call `next-id` under concurrency. The project also sets a concurrency policy, at most N active plans and at
   most one per declared unit (O3).
4. **Authorization.** The human's literal approval is copied into activation commits and into the prompts. Subagents
   ignore user messages relayed mid-run. Merge, push and `verified` stay with the orchestrator and the human, as in
   the other modes (O4).
5. **Gate A4 without nesting.** Task agents do not dispatch. A task whose rules call for A4 reports at least two
   mutations tried against its own tests, as rulings (O8).

**Templates.** The skill ships three schematic script templates: an item pipeline, a spec round, and an unattended-log
section. The project supplies three parameters: a verification command, an isolation template and a concurrency
policy. Nothing project-specific is hard-coded.

**Host fallback.** Without the Workflow tool, the same contract runs one item at a time through
subagent-driven-development. The method never depends on a single host tool.

### 2. Small changes to existing skills

- **`finishing-a-development-branch`:** add a multi-item section.
  - Merge one branch at a time.
  - Run the project's verification command on the merged main after each merge or small batch.
  - Expect the conflicts on lines every item amends (changelog or version lines, generated files): renumber, never
    drop.
  - Flake protocol: re-run the failing suite N times on a fresh stack before ruling it a flake, and log the ruling.
- **`kdd-conventions`:** under concurrency, ids are allocated by the orchestrator, not by `next-id` in a worktree.
- **`brainstorming`:** point to the three-lens spec round as the workflow form of the existing spec gates.
- **Unattended sessions** (a reference of the new skill): one dated, append-only decision log. It opens with a
  "decisions to review" table and carries inline "held for you" markers; work goes on with a stated default.

### 3. An EVAL

A small fixture with two independent items run in parallel. It checks:

- distinct worktrees and distinct ids;
- no cross-worktree writes;
- rulings carried forward between tasks;
- the mode word identical in the commit and in the log;
- a resume that skips completed tasks.

## Alternatives

- **Leave it to each project.** That is what happened here. The 63 scripts are the cost of re-learning it.
- **Fold it into subagent-driven-development.** That would mix two different control loops in one skill: model-driven
  dispatch and a deterministic script. SDD stays the fallback instead.
- **Ship only templates, no skill.** Without the contract, the templates repeat the same gaps: the mode name, ids and
  relayed messages.

## Constraints

- P10: keep superpowers' voice, red flags and approval gates; add sections, do not rewrite tuned prose.
- P13: no path contains `superpowers`; runtime state under `.kdd/`.
- Never re-implement the kdd toolkit.
- The method works without the Workflow tool (host fallback).
- No project configuration is hard-coded in the skill: ports, caps and script names are all parameters.

## Acceptance Criteria

1. writing-plans' handoff offers three modes, and `workflow` is recorded as such in the activation commit and in the
   Execution Log.
2. `skills/orchestrating-workflows/SKILL.md` states the five-part contract and the three project parameters, and
   ships the templates. `tests/scripts/test-skill-content.sh` asserts its anchors.
3. Without the Workflow tool, the skill routes to subagent-driven-development, and a test pins that route.
4. `finishing-a-development-branch` has the multi-item section, and `kdd-conventions` has the id rule under
   concurrency.
5. The EVAL above passes on the fixture.

## Open Questions

1. Should A2 stay mandatory under workflow mode? In the evidence, the human waived it for 44 of 45 pipelines.
2. Is there a stopping rule for spec rounds beyond "the human reviews"? The evidence has only one second round and
   no rule.
3. Should the concurrency policy be a project file, for example under `.kdd/`, or a parameter given at the handoff?
4. Where does the unattended decision log live: `.kdd/review/` (git-ignored) or a tracked artifact?

## Evidence

FRAG-FORK-WORKFLOW-001: sanitized aggregates and patterns O1–O8. The full anchored evidence stays in the source
project's private capture fragment.
