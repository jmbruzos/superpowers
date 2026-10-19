---
id: WRK-PLAN-FORK-UPSTREAM-004
type: spec
layer: work-plan
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
title: "Upstream sync batch 3 — Native execution — implementation plan"
parent: WRK-SPEC-FORK-UPSTREAM-004
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-LEDGER-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-UPSTREAM-004
    relation: implements
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-LEDGER-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-UPSTREAM-004
    resource: specs/work/WRK-SPEC-FORK-UPSTREAM-004-batch-3-native.md
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T12:29:33+02:00
stale_after: 2027-01-16T12:30:00+02:00
tags: [fork, upstream, executing-plans, native, plan]
---

# WRK-PLAN-FORK-UPSTREAM-004 — Upstream sync batch 3: Native execution

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** implement WRK-SPEC-FORK-UPSTREAM-004 components 1–8 and meet AC1–AC6, AC8, AC9; AC7 (level 2b) waits for the human.

**Architecture:** the deterministic part first (scripts, ledger reader, their tests — task 001), then the Native skill and its knowledge-check prompt (002), the SDD / A4-prompt / orchestrator / handoff changes (003), scenario 8 (004), and measurement after batch 2's release (005). The controller runs the writing-skills pressure tests after tasks 002 and 003 (implementers never dispatch subagents).

**Tech Stack:** bash scripts, Node ESM (`kdd-status-lib.mjs`), Markdown skills, headless `claude -p`.

**Spec:** `specs/work/WRK-SPEC-FORK-UPSTREAM-004-batch-3-native.md`. Upstream sources: `git show v6.4.1:skills/executing-plans/SKILL.md`, `git show upstream/main:skills/executing-plans/scripts/{task-start,task-done}`, `git show upstream/main:tests/claude-code/test-executing-plans-scripts.sh`, `git show upstream/main:skills/subagent-driven-development/SKILL.md` (when-to-use), `git show upstream/main:skills/using-superpowers/references/claude-code-tools.md`, `git show upstream/main:skills/writing-plans/SKILL.md` (handoff).

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-UPSTREAM-004-001 | task-start / task-done, their test, kdd-status-lib header and test-kdd-status cases | batch 2 released (\`kdd-superpowers--v0.8.0\`) |
| WRK-TASK-FORK-UPSTREAM-004-002 | executing-plans as Native, knowledge-check prompt | 001 |
| WRK-TASK-FORK-UPSTREAM-004-003 | SDD when-to-use / ID identity / exit 3, A4 prompt sentence, orchestrator, writing-plans handoff | 002 |
| WRK-TASK-FORK-UPSTREAM-004-004 | scenario 8 (opt-in) in test-kdd-flow.sh | 001, 002 |
| WRK-TASK-FORK-UPSTREAM-004-005 | pre-register, measure level 1 after 0.8.0, hold for level 2b | 001–004; batch 2 released |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "An execution mode keeps every gate SDD gives a task, before the task is marked complete. For Native: the task's final test run, A4 when its condition holds, and — after a `Knowledge gap:` ruling on an activated rule — a knowledge-compliance review of that task, all run before the task's `transition … completed` and its ledger completion line; A3 and A5 run in the whole-branch review." | DOC-FORK-UPSTREAM-001 §3.4 | task 002 (skill order), task 001 (task-done transitions only on a passing final run), task 004 (A4 before the complete commit) |
| "a new form or writer changes `kdd-status-lib.mjs` and `test-kdd-status.sh` in the same commit" | DOC-FORK-UPSTREAM-001 §3.5 | task 001 |
| "Claude Code only." | DOC-FORK-UPSTREAM-001 §3.8 | task 002 drops the no-subagent paths |
| "A finished task is a line starting `Task <task>: complete`, always followed by a parenthesised suffix … Readers match the prefix, never the whole line." | DOC-FORK-LEDGER-001, Completion | task 001 |
| "Dispatched gates are synchronous." | DOC-FORK-GATES-001 (via adversarial-gates.md) | task 002: A4 and the knowledge check are waited for |
| "Re-measure after any change to a workflow skill" | DOC-FORK-TOKENS-001, Maintenance | task 005: scenarios 4, 5, 8 |

## Review Focus

- `task-done` re-run after an interruption between the transition commit and the ledger append: the line must appear once with the original range — task 001's re-run case.
- `task-start` given a WRK-TASK of another plan, or a ledger whose line 1 names another plan ID: refused, nothing written — task 001.
- A task whose steps produced no commit reaching `task-done`: refused before the tests run — task 001's empty-range case.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Upstream Native prose reworded beyond the listed adaptations | medium | P10 | task 002 AC: `git diff` against `v6.4.1`'s text limited to the listed adaptations |
| Scenario 8 transcript checks brittle (paraphrased dispatch descriptions) | medium | false failures | recognise gates by description or prompt opening line, as scenario 7 does |
| Level-1 cost (three arms × 2 + scenarios 4, 5 × 2 × 2) | — | ≈ $20–35 on Opus | protocol |

## Dependencies

- Batch 2 released as `kdd-superpowers--v0.8.0` **before task 001 starts**: every batch-3 commit lands after that tag, so the tag (task 005's before arm) holds no batch-3 change. Level 2b and the release wait for the human (spec AC7).
- Pressure tests (tasks 002, 003): the controller runs them after the implementer's commit and before the task's transition commit; the implementer then amends its own HEAD commit's message.

## Execution Log

### Rulings
- Ruling R1: task 002 drops upstream Native's "Declined to judge" paragraph sentence (v6.4.1:261-266) — the fork's reviewer has no such list since 0.7.2 (decision log U-20: the section triggered the safety classifier); an adaptation outside component 1's list, carried in task 002's dispatch — cost if wrong: Native loses a ruling form nobody can produce.
- Ruling R2: task 005 runs level 2b without waiting — decision log H-7 records the human's approval of measurement cost ("lifts the level-2b hold"); AC7 is met by running it before the release — cost if wrong: ~$30–60 spent the human would have deferred.
- WRK-TASK-FORK-UPSTREAM-004-002: Ruling: keep the hunk "every commit subject starts with the WRK-TASK ID" outside component 1's adaptation list — the fork convention already in today's skill and SDD, which kdd-status/finishing rely on for traceability (KDD over upstream) — cost if wrong: one line to revert under a strict P10 reading
- WRK-TASK-FORK-UPSTREAM-004-002: Ruling: gate (b) is not re-dispatched after its violation is fixed (TDD verifies the fix; A4 differs because its subject is the tests) — spec silent, simpler — cost if wrong: a fix that still violates the rule reaches the final review, whose A3 checks every touched rule
- WRK-TASK-FORK-UPSTREAM-004-003: Ruling: keep the added resume sentence (a `Task X: complete` line over a file still `active` → run the transition, do not re-dispatch) — it is the SDD side of task-done's "active + line present" case (A2 amendment, task 001) and prevents re-dispatching finished work — cost if wrong: one sentence to drop
- WRK-TASK-FORK-UPSTREAM-004-003: Ruling: keep the adapted "vs. Executing Plans" bullets that list the gates Native keeps — upstream's text says Native has no review until the end, which §3.4 makes false here (KDD over upstream, logged as a P10 exception) — cost if wrong: two bullets reworded
- WRK-TASK-FORK-UPSTREAM-004-003: Ruling: Important 1 (plan text gave the exit-3 sentence verbatim) — adopt the reviewer's two-case wording; spec component 5 itself names both cases ("empty range or HEAD not descending from BASE"), so the verbatim sentence under-states the spec — cost if wrong: one sentence
- WRK-TASK-FORK-UPSTREAM-004-004: Ruling: the reviewer's SDD counterexample (pt-004-003/b task 001 inline) is a misread — that fixture shipped task 001 already implemented (a resume test) — but the finding stands: add `sdd` = every task has an implementer dispatch, `inline-old` = no implementer dispatch (not "no Agent at all": the check is the mode, not incidental tool use) — cost if wrong: an inline-old run that dispatches a non-implementer helper passes
- WRK-TASK-FORK-UPSTREAM-004-004: Ruling: the SDD arm also carries "final review on the most capable model" and "Rulings I made" — both are SDD requirements (SKILL.md Final Review, Finish), so the arms are compared on the same bar; inline-old does not (its 0.8.0 skill has neither) — cost if wrong: SDD-arm failures that are not deciding (only the Native arm decides)
- Ruling: the final whole-branch review runs now, over tasks 001–004 (d59e66e..755887e), before task 005 measures — so the measured candidate is the code that ships; task 005 adds only the FRAG — cost if wrong: none (task 005 changes no skill or script)
- Final: Ruling: both Important enter ONE fix dispatch; every deferred minor stays deferred (reviewer triage: none blocks merge) — cost if wrong: the "ℹ duration_ms" ledger tail (seen in all pressure runs) ships as is
- Ruling: level 2b dropped — human decision H-8 (spec AC7 waived); task 005 ends with level 1 and the release

### Knowledge gaps
- WRK-TASK-FORK-UPSTREAM-004-001: Knowledge gap: DOC-FORK-LEDGER-001 Completion lists executing-plans' suffix as `(commits a..b)`; Native writes `(commits a..b, tests: … → …)` — bump at consolidation
- WRK-TASK-FORK-UPSTREAM-004-002: Knowledge gap: DOC-FORK-LEDGER-001 cites executing-plans:21 for the ledger path (now :139); inconsistency 1 settled for Native in favour of frontmatter — record at consolidation
- WRK-TASK-FORK-UPSTREAM-004-003: Knowledge gap: DOC-FORK-LEDGER-001's SDD line citations (:155, :148-153, :480-482) stale — consolidation
- Final: Knowledge gap: DOC-FORK-UPSTREAM-001 §3.7's suite list does not name test-executing-plans-scripts.sh — consolidation

### Attacks broken and adjudicated
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 1 · "writer" read as "form" to keep the lib unchanged; new note forms unparsed — spec-rule — DOC-FORK-UPSTREAM-001 §3.5 — accepted: component 8 — the lib's header names the writers and note forms; parsing unchanged; tests assert lines by content and notes are not completion
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 1 · ledger root left "pending a human ruling" — spec-rule — §3.5 — accepted: settled and tested under *Error handling*
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 1 · release on level 1 with 2b pending — spec-rule — §2 batch-3 row — accepted: AC7 — no release before 2b; 2b waits for the human's cost confirmation
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 2 · gate (b) reuses a template that needs an implementer report — ambiguity — `task-reviewer-prompt.md:34,231` — accepted: component 4, a dedicated knowledge-check prompt
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 2 · resume by ledger (kept upstream text) vs frontmatter — internal — v6.4.1 SKILL.md:131-134 — accepted: *Setup* adapted to the frontmatter signal
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 2 · head7 on a re-run — ambiguity — component 3 — accepted: parent of the task's `chore(…): complete` commit; tested
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 3 · the kdd-status case passes from frontmatter alone — ambiguity — `kdd-status-lib.mjs:41` — accepted: lines asserted by content
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 3 · A4 "dispatched" without order — ambiguity — §3.4 — accepted: dispatch time before the task's complete commit
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 3 · AC6 closable by a ruling — ambiguity — old AC6 — accepted: removed; rework or revert per §4
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 4 · `review-package` exit 3 unsettled — knowledge-gap — decision log U-8 — accepted: task-done refuses empty ranges; SDD rules on exit 3 (component 5)
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 4 · A4 BROKEN handling in Native; prompt says "after a clean A3" — knowledge-gap — SDD:365-371; prompt:3 — accepted: fix by TDD, one re-dispatch, park with ruling, ledgered; prompt sentence adapted
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 4 · identity compared by ID vs file across modes — knowledge-gap — DOC-FORK-LEDGER-001 inconsistency 2 — accepted: both modes compare the ID (component 5)
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 5 · finishing deletes the workspace before its menu — code-reality — finishing:162-166 — accepted: scenario 8 stops before finishing
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 5 · v6.4.1's task-done fails on a silent passing command — code-reality — `git diff v6.4.1 upstream/main` — accepted: scripts from `upstream/main`; case ported
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 5 · upstream *Finish* deletes the workspace — internal — v6.4.1:300-302 — accepted: *Finish* keeps it for finishing
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 6 · a no-subagent path in a Claude-Code-only fork — spec-rule — §3.8 — accepted: dropped
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: 6 · orchestrator and SDD diagram outside the Problem Statement; untested — internal — spec — accepted: Problem Statement names them (§2 lists them); both pressure-tested (AC8); the opt-in orchestrator is not measured
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: + 1 · the handoff changes but scenario 4 is not re-run — spec-rule — DOC-FORK-TOKENS-001 Maintenance — accepted: scenarios 4 and 5 in level 1
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: + 2 · A4's condition on fixture task 002 — ambiguity — fixture — accepted: judged on the task's `activates` and Architecture Impact rows; task 002 activates nothing
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: + 2 · task-start does not check the task's parent — ambiguity — `task-brief:36-44` — accepted: exit 2
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: + 2 · "no per-task reviewer" vs gate (b) — internal — scenario 8 — accepted: the check is "no implementer dispatch"
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: + 2 · *When to Use* points at the forbidden references — internal — v6.4.1:49-50 — accepted: dropped
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: + 2 · the "status: completed" anchor — internal — `test-skill-content.sh:99` — accepted: anchors kept or replaced in the same commit
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: + 4 · the before tag does not exist yet — knowledge-gap — `git tag -l` — accepted: batch 3 measures after batch 2's release
- WRK-SPEC-FORK-UPSTREAM-004 A-gate: + 5 · transcripts only with `KDD_FLOW_USAGE` — code-reality — `usage-lib.sh:25,36-39` — accepted: scenario 8 requires it
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 1 · upstream's "Without a subagent tool" final review survives — spec-rule — §3.8; v6.4.1:253-258 — accepted: task 002 amendment, must_not anchor
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 1 · gates' order unanchored; gate (b) never triggered — spec-rule — §3.4 — accepted: order and waiting anchors; (b) in the controller's pressure test, a known gap of scenario 8
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 1 · skill prose adds ledger note forms without the lib in the same commit — spec-rule — DOC-FORK-LEDGER-001 Maintenance — accepted: task 002 updates the lib header and test-kdd-status
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 2 · SDD resumes by line, Native by frontmatter; duplicate line — internal — SDD:149 — accepted: SDD's resume rule changes too (task 003); task-done handles "active + line present" (task 001)
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 2 · tests pass, transition fails: exit undefined — ambiguity — transition:21-23 — accepted: exit 4, nothing recorded, tested
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 2 · Native's cost sentence says "no independent review until the end" — internal — upstream handoff:192 — accepted: adapted sentence (task 003)
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 3 · AC9 in no task — internal — plan — accepted: task 005, held with AC7
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 3 · AC1's "fails against a stub" never run — ambiguity — spec AC1 — accepted: stub run in task 001 Step 2
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 4 · task 002 writes ledger rules without DOC-FORK-LEDGER-001 — internal — task 002 — accepted: activation added (inside the spec's set)
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 5 · scenario 8's checks first run in the paid measurement — ambiguity — task 004 — accepted: checks in a script tested deterministically
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 5 · the P10 diff check has no criterion — ambiguity — task 002 Step 5 — accepted: every hunk mapped to a named adaptation
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 6 · 0.8.0 tag would contain batch-3 commits — code-reality — `git tag -l`; plan — accepted: task 001 waits for the 0.8.0 tag
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 7 · Native never completes the WRK-PLAN — code-reality — finishing:46-48 — accepted: transition after a clean final review (task 002)
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: 7 · `task-done` transition without `--specs` from another cwd — code-reality — transition:7,26 — accepted: `--specs <root>/specs`, tested from a subdirectory
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 1 · SDD node "or no subagent tool?" — spec-rule — §3.8 — accepted: "Partner chose Native?"
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 1 · diagram node deletes the workspace — ambiguity — v6.4.1:87 — accepted: replaced, must_not
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 1 · Setup compares by plan file — ambiguity — v6.4.1:131-139 — accepted: by ID, anchored
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 1 · only `-- true` tested — ambiguity — task 001 — accepted: `-- echo ok` case
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 1 · synchronous gates unanchored — spec-rule — plan row — accepted: anchor
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 1 · root tested from a same-branch worktree only — spec-rule — §3.5 — accepted: plus a `main` checkout case
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 1 · A4 BROKEN handling unanchored — ambiguity — spec 1(a) — accepted: anchors
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 3 · other suites not run — internal — §3.7 — accepted: tasks 002, 003, 005
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 4 · task 004 checks GATES rules without activating GATES — internal — task 004 — accepted: activation added
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 6 · pressure-test amend timing — internal — plan — accepted: before the transition commit, on the implementer's HEAD
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 7 · PIN DRIFT handling dropped — code-reality — executing-plans:30 — accepted: kept as an adaptation
- WRK-PLAN-FORK-UPSTREAM-004 A-gate: + 7 · shared CONFIG_DIR leaks transcripts — ambiguity — test-kdd-flow.sh:37 — accepted: per-scenario transcripts dir

### Capture candidates (pending)
- WRK-TASK-FORK-UPSTREAM-004-001: Capture candidate: skills/kdd-conventions/scripts/transition:131 — the `chore(<ID>): complete` subject task-done greps for
- WRK-TASK-FORK-UPSTREAM-004-003: Capture candidate: skills/subagent-driven-development/scripts/review-package:25-28 — exit 3 covers an empty range and a HEAD not descending from BASE

### Parked / deferred
- WRK-TASK-FORK-UPSTREAM-004-001: minor (deferred): task-done takes repo root from cwd, task-start from the plan dir — misleading exit 4 from another checkout
- WRK-TASK-FORK-UPSTREAM-004-001: minor (deferred): has_line ignores a leading list bullet that kdd-status tolerates — a bulleted SDD line gets a second line
- WRK-TASK-FORK-UPSTREAM-004-001: minor (deferred): task-done's extra exit-2 refusals (other plan's ledger/task) untested
- WRK-TASK-FORK-UPSTREAM-004-001: minor (deferred): completed-without-chore-commit path exits 1, indistinguishable from CMD failing with 1
- WRK-TASK-FORK-UPSTREAM-004-001: minor (deferred): ledger line renders the command lossily (quotes, $, *); ANSI codes and \r from the last output line written as-is
- WRK-TASK-FORK-UPSTREAM-004-001: minor (deferred): test-executing-plans-scripts.sh is mode 644, not in CLAUDE.md/README, not in run.sh
- WRK-TASK-FORK-UPSTREAM-004-001: minor (deferred): TDD order (scripts before tests); new test-kdd-status cases never run RED; lib header omits "(no output)"
- WRK-TASK-FORK-UPSTREAM-004-002: minor (deferred): knowledge-check prompt's permitting-quote rule omits GATES-001's "or a `constrained-by` principle" (knowledge-check-prompt.md:56-58)
- WRK-TASK-FORK-UPSTREAM-004-002: minor (deferred): upstream's "start your own, fresh" (SKILL.md:152-153) cannot be followed — task-start exits 2 on another plan's ledger
- WRK-TASK-FORK-UPSTREAM-004-002: minor (deferred): final review's wait and {KNOWLEDGE_BRIEF} unanchored; note-forms test lacks a `Task <ID>:`-prefixed note
- WRK-TASK-FORK-UPSTREAM-004-002: minor (deferred): task-done records the test output's last line ("ℹ duration_ms …" under node --test) instead of the pass/fail summary — seen in both pressure runs (cf. task 001 minor on the ledger line)
- WRK-TASK-FORK-UPSTREAM-004-003: minor (deferred): repair sentence unanchored; resume rule beside "do not read the task files"; pre-supplied-method handoff variant not taken; Native cost sentence omits the final test run; writing-plans:75 header still says SDD "(recommended)"
- WRK-TASK-FORK-UPSTREAM-004-004: minor (deferred): crashed checks script adds 0 to FAILURES (test-kdd-flow.sh:249); `out` captured but never echoed (:243); final-review regex also matches "Fix final-review findings" (scenario8-checks.sh:59); `cd:` stderr in captured output
- WRK-TASK-FORK-UPSTREAM-004-004: minor (deferred): sdd task-001 implementer match could be satisfied by a task-002 prompt head naming task 001 (scenario8-checks.sh:52)
- Final: minor (deferred): AC8 letter — 7e8a006's message says pending; its record is in 9bd06d9 of the same task
- Final: minor (deferred): task-done:127 first-commit lookup is a substring match (…-001 vs …-0010); a task whose commits lack its ID exits 3 on re-run (fails closed)

Source: the SDD ledger `.kdd/sdd/WRK-PLAN-FORK-UPSTREAM-004/progress.md`, harvested by the controller; the decision log (`docs/upstream-sync/decision-log.md`) holds the cross-batch rulings.

## Adversarial Review

Gate A2, 2026-10-18 (most capable model): `31 attempted, 26 BROKEN (code-reality 4 · spec-rule 6 · ambiguity 9 · knowledge-gap 0 · internal 7)`. Adjudicated unattended (decision log U-15); all accepted, recorded as binding amendments in the tasks.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 · upstream's "Without a subagent tool" final review survives | spec-rule | §3.8; v6.4.1:253-258 | accepted: task 002 amendment, must_not anchor |
| 1 · gates' order unanchored; gate (b) never triggered | spec-rule | §3.4 | accepted: order and waiting anchors; (b) in the controller's pressure test, a known gap of scenario 8 |
| 1 · skill prose adds ledger note forms without the lib in the same commit | spec-rule | DOC-FORK-LEDGER-001 Maintenance | accepted: task 002 updates the lib header and test-kdd-status |
| 2 · SDD resumes by line, Native by frontmatter; duplicate line | internal | SDD:149 | accepted: SDD's resume rule changes too (task 003); task-done handles "active + line present" (task 001) |
| 2 · tests pass, transition fails: exit undefined | ambiguity | transition:21-23 | accepted: exit 4, nothing recorded, tested |
| 2 · Native's cost sentence says "no independent review until the end" | internal | upstream handoff:192 | accepted: adapted sentence (task 003) |
| 3 · AC9 in no task | internal | plan | accepted: task 005, held with AC7 |
| 3 · AC1's "fails against a stub" never run | ambiguity | spec AC1 | accepted: stub run in task 001 Step 2 |
| 4 · task 002 writes ledger rules without DOC-FORK-LEDGER-001 | internal | task 002 | accepted: activation added (inside the spec's set) |
| 5 · scenario 8's checks first run in the paid measurement | ambiguity | task 004 | accepted: checks in a script tested deterministically |
| 5 · the P10 diff check has no criterion | ambiguity | task 002 Step 5 | accepted: every hunk mapped to a named adaptation |
| 6 · 0.8.0 tag would contain batch-3 commits | code-reality | `git tag -l`; plan | accepted: task 001 waits for the 0.8.0 tag |
| 7 · Native never completes the WRK-PLAN | code-reality | finishing:46-48 | accepted: transition after a clean final review (task 002) |
| 7 · `task-done` transition without `--specs` from another cwd | code-reality | transition:7,26 | accepted: `--specs <root>/specs`, tested from a subdirectory |
| + 1 · SDD node "or no subagent tool?" | spec-rule | §3.8 | accepted: "Partner chose Native?" |
| + 1 · diagram node deletes the workspace | ambiguity | v6.4.1:87 | accepted: replaced, must_not |
| + 1 · Setup compares by plan file | ambiguity | v6.4.1:131-139 | accepted: by ID, anchored |
| + 1 · only `-- true` tested | ambiguity | task 001 | accepted: `-- echo ok` case |
| + 1 · synchronous gates unanchored | spec-rule | plan row | accepted: anchor |
| + 1 · root tested from a same-branch worktree only | spec-rule | §3.5 | accepted: plus a `main` checkout case |
| + 1 · A4 BROKEN handling unanchored | ambiguity | spec 1(a) | accepted: anchors |
| + 3 · other suites not run | internal | §3.7 | accepted: tasks 002, 003, 005 |
| + 4 · task 004 checks GATES rules without activating GATES | internal | task 004 | accepted: activation added |
| + 6 · pressure-test amend timing | internal | plan | accepted: before the transition commit, on the implementer's HEAD |
| + 7 · PIN DRIFT handling dropped | code-reality | executing-plans:30 | accepted: kept as an adaptation |
| + 7 · shared CONFIG_DIR leaks transcripts | ambiguity | test-kdd-flow.sh:37 | accepted: per-scenario transcripts dir |
