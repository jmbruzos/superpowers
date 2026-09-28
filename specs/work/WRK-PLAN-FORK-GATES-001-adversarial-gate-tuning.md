---
id: WRK-PLAN-FORK-GATES-001
type: spec
layer: work-plan
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "Adversarial gates A1/A2 tuning — implementation plan"
parent: WRK-SPEC-FORK-GATES-001
activates:
  - DOC-FORK-TOKENS-001@0.1.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-GATES-001
    relation: implements
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-GATES-001
    resource: specs/work/WRK-SPEC-FORK-GATES-001-adversarial-gate-tuning.md
  - id: DOC-FORK-TOKENS-001
    resource: specs/documentation/DOC-FORK-TOKENS-001-flow-token-footprint.md
  - id: FRAG-FORK-GATES-001
    resource: specs/_capture/FRAG-FORK-GATES-001-adversarial-gate-audit-mdm/
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-28T11:14:33+02:00
stale_after: 2026-12-27T11:14:33+01:00
tags: [fork, gates, plan]
---

# WRK-PLAN-FORK-GATES-001 — Adversarial gates A1/A2 tuning

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** Make brainstorming and writing-plans check their code premises, run gate A1 on the written and self-reviewed WRK-SPEC, and give A1/A2 a Cause column, a detail cap that drops nothing, and a persisted BROKEN table — then prove it headless and measure its cost.

**Architecture:** The shared contract changes first (`adversarial-gates.md` addendum for design gates, templates), then each consumer in dependency order: the A1 prompt, the brainstorming order, the Code premises step and its verifier prompt, writing-plans and the A2 prompt. A new headless scenario exercises the architectural path end to end; a last task measures before/after and releases 0.3.0. Every prose change is test-first: the `test-skill-content.sh` anchor is added red, then the prose makes it green.

**Tech Stack:** Markdown skills and prompt templates; bash tests (`tests/scripts/lib.sh` `pass`/`fail`, `must_contain`/`must_not_contain`); headless Claude Code (`tests/claude-code/test-kdd-flow.sh`); kdd toolkit 1.6.0 (`spec-graph`).

**Spec:** `specs/work/WRK-SPEC-FORK-GATES-001-adversarial-gate-tuning.md` — the plan argues from the spec, so executors read both.

**Baseline commit:** `f8d369c` (spec approved; no skill changed yet). Task 007 measures "before" from a worktree at this commit.

**Toolkit for every test run:** `export KDD_SPEC_GRAPH=$HOME/.claude/plugins/cache/kdd/kdd/1.6.0/cli/spec-graph.mjs` and, for headless runs, `export KDD_TOOLKIT_DIR=$HOME/.claude/plugins/cache/kdd/kdd/1.6.0`.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-GATES-001-001 | Baseline; design-gate addendum in `adversarial-gates.md`; `## Code Premises` and BROKEN-table placeholders in the templates | — |
| WRK-TASK-FORK-GATES-001-002 | A1 prompt: written spec as input, Code Premises in attack 5, Cause column, detail cap, closing line | 001 |
| WRK-TASK-FORK-GATES-001-003 | brainstorming order: WRK-SPEC → self-review → A1 → commit; re-run rule; no draft file | 002 |
| WRK-TASK-FORK-GATES-001-004 | Code premises: `premise-verifier-prompt.md`, design section, Red Flags row, WRK-SPEC body order | 003 |
| WRK-TASK-FORK-GATES-001-005 | writing-plans and A2: Code Premises read, `**Premises:**` line, attack 7, Cause column, detail cap, persisted table | 001 |
| WRK-TASK-FORK-GATES-001-006 | Headless scenario 7: architectural brainstorming with code and specs; transcript and artifact assertions | 002, 003, 004 |
| WRK-TASK-FORK-GATES-001-007 | Before/after measurement → FRAG-FORK-TOKENS-002; release 0.3.0 | 005, 006 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "KDD changes the *what* and the *with which context*; superpowers keeps the *how*. The voice ("your human partner"), red-flag tables, approval gates, TDD, subagent discipline and ledger stay intact. KDD replaces artifacts and adds activated context; it relaxes no existing discipline. Skill language: English." | WRK-SPEC-FORK-CORE-001 P10 | Every edit adds rows, bullets or sentences, or changes order/references; no existing Red Flags row, rationalization row or approval gate is removed or reworded. The detail cap lists every BROKEN finding. Reviewers diff each skill for removed lines. |
| "No path contains `superpowers`. Artifacts live in `specs/`; runtime state lives in `.kdd/` (gitignored)" | WRK-SPEC-FORK-CORE-001 P13 | New files: `skills/brainstorming/premise-verifier-prompt.md`, `specs/_capture/FRAG-FORK-TOKENS-002-*`. Measurement scratch goes to the session scratchpad or `.kdd/`, never a `superpowers` path. |
| "Output tokens are the expensive line. writing-plans emits 40-60k output tokens: plan, tasks with full code blocks, the A2 attack table, and rewrites after adjudication." | DOC-FORK-TOKENS-001 §Content item 4 | Detail cap (3 full rows per attack, the rest as one-liners) in the A1 and A2 prompts. |
| "Subagent seats and their turns. Each seat starts a fresh 15-24k context (cache write)." | DOC-FORK-TOKENS-001 §Content item 5 | One premise-verifier seat per brainstorming, mid tier; none in greenfield. |
| "One run per side is not a before/after; repeat until the effect you claim exceeds the spread you see." | DOC-FORK-TOKENS-001 §How to measure | Task 007: ≥ 2 runs per side for scenario 4, spread reported. |
| "Re-measure after any change to a workflow skill, a prompt template, the hook, or a Claude Code major release; append the run to a new FRAG that `supersedes` FRAG-FORK-TOKENS-001 and bump this document." | DOC-FORK-TOKENS-001 §Maintenance | Task 007 writes FRAG-FORK-TOKENS-002 (`supersedes` FRAG-FORK-TOKENS-001); DOC bump happens at consolidation (finishing), not in this plan. |
| "The controller adjudicates every `BROKEN` row and ledgers it" | adversarial-gates.md (current contract) | Unchanged; the addendum extends it to one-liners. |
| "`tests/scripts/test-skill-content.sh` asserts the anchors prompts and scripts depend on; when you change a skill, keep it green or update it in the same commit." | CLAUDE.md (repository instruction) | Each task adds its anchors and the prose in the same commit. |
| Suite is not green at baseline: `test-invariants.sh` (untracked `docs/superpowers/`) and `test-transition.sh` (9 assertions, kdd 1.6.0) | WRK-SPEC-FORK-GATES-001 Code Premises | Task 001 records the baseline; every task's check is "no new failures", not "all green". Do not touch `docs/superpowers/` or `transition`. |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| No `timeout`/`gtimeout` on this machine: every headless run fails before starting | Certain | High | Task 006 Step 1 adds a portable `TIMEOUT_CMD` (timeout → gtimeout → `perl -e 'alarm shift; exec @ARGV'`, verified: rc=142 after 2 s); task 007 copies that harness into the "before" worktree. |
| Headless scenario 7 exceeds the 900 s default timeout (architectural path, two subagent seats) | High | Medium | Run it with `CLAUDE_PROMPT_TIMEOUT=2700`; the timeout is an env var already. |
| The headless session asks questions or stops before A1 despite the prompt | Medium | Medium | Prompt pre-approves every section and delegates adjudication; if it still stops, record the transcript and rule in the ledger — the assertions stay as specified. |
| `supersedes` on a fragment rejected by `spec-graph validate` | Low | Low | Task 007 validates before committing; if rejected, record the relation in `sources` and prose instead and ledger a `Knowledge gap:`. |
| Measurement cost (≈ $3 per scenario-4 run, 4 runs, plus scenario 7) | Certain | Low | Accepted by the spec (AC9); runs limited to `KDD_FLOW_SCENARIOS`. |
| Rewording tuned prose while moving the A1 step | Medium | Medium | Task 003 gives the exact old and new text; reviewer diffs for removed sentences. |

## Dependencies

- kdd toolkit 1.6.0 installed at `~/.claude/plugins/cache/kdd/kdd/1.6.0` (CLI and plugin root).
- `claude` on PATH, credentials in `~/.claude/.credentials.json` (tasks 006, 007).

---

## Adversarial Review

Gate A2 (triggered: 7 tasks; the spec activates DOC-FORK-TOKENS-001, `confidence: low`, unverified), run in the design-gate form this plan introduces. `16 attempted, 11 BROKEN (code-reality 3 · spec-rule 1 · ambiguity 4 · knowledge-gap 0 · internal 3)`.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 Task 003's *Gate A1* prose still says "Adjudicate every `BROKEN` row", so one-liners past the cap could go unadjudicated | spec-rule | WRK-TASK-003 Step 6; WRK-TASK-005 Step 5; spec §3; P10 | accepted → prose says "every `BROKEN` finding — full rows and one-liners"; anchor added |
| 2 Task 007 compares three suites to a baseline task 001 never persisted | internal | WRK-TASK-001 Step 1; WRK-TASK-007 Step 6 | accepted → task 001 writes four `.kdd/baseline-*.txt` files (listed under Produces); task 007 diffs against them |
| 3 Scenario 7 cannot tell the old order from the new: no write-before-A1 check, assertions read the working tree | ambiguity | spec AC8; WRK-TASK-006 Step 2 | accepted → transcript order check (WRK-SPEC write line < A1 dispatch line); assertions read `git show HEAD:`; working tree must equal the commit |
| 5 Task 002 Step 2 expects 7 FAIL lines; 8 fail | ambiguity | WRK-TASK-002 Step 1–2 | accepted → 8 |
| 7 `.kdd/` does not exist; `> .kdd/baseline-run.txt` fails and every later diff breaks | code-reality | `ls -a .kdd` → No such file; WRK-TASK-001 Step 1 | accepted → `mkdir -p .kdd`; premise recorded in task 001 |
| 7 No `timeout`/`gtimeout` on this machine; every headless run fails | code-reality | `test-kdd-flow.sh:47`, `:62`; `command -v timeout gtimeout` → nothing | accepted → task 006 adds a portable `TIMEOUT_CMD` with a perl fallback (verified rc=142 after 2 s); task 007 copies the harness into the "before" worktree; risk row added |
| 2 (one-liner) Task 002's `internal` definition differs from the addendum's | internal | WRK-TASK-002 prompt vs WRK-TASK-001 addendum | accepted → A1 prompt uses the addendum's definition |
| 3 (one-liner) AC literals `[WRK_SPEC_PATH]` and "at most 3 full rows per attack" not matched by the anchors | ambiguity | spec §4, AC3; WRK-TASK-002 | accepted for `[WRK_SPEC_PATH]` (prompt and anchor now carry it literally); rejected for the case of "At most" — the spec quotes the phrase mid-sentence, the prompts start a sentence with it; same rule |
| 5 (one-liner) `dot` routes every "changes requested" through A1 while the re-run rule says only substantive changes | ambiguity | WRK-TASK-003 Step 5 vs Step 6 | accepted → two edges: substantive changes → write → self-review → A1; wording changes → self-review → user review |
| 5 (one-liner) In a fresh worktree `test-invariants.sh` passes (no untracked `docs/superpowers/`), so "Expected" misdescribes the baseline | code-reality | WRK-TASK-001 Step 1; WRK-TASK-004 Step 8 | accepted → Expected is "whatever the baseline recorded"; both locations reworded |
| 7 (one-liner) Task 007 Premises cite "Step 5" for validation; it is Step 4 | internal | WRK-TASK-007 | accepted → Step 4 |
