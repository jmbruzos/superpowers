---
id: WRK-PLAN-FORK-UPSTREAM-003
type: spec
layer: work-plan
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
title: "Upstream sync batch 2 — lean plans — implementation plan"
parent: WRK-SPEC-FORK-UPSTREAM-003
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-UPSTREAM-003
    relation: implements
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-UPSTREAM-003
    resource: specs/work/WRK-SPEC-FORK-UPSTREAM-003-batch-2-lean-plans.md
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T11:53:39+02:00
stale_after: 2027-01-16T11:53:39+02:00
tags: [fork, upstream, writing-plans, plan]
---

# WRK-PLAN-FORK-UPSTREAM-003 — Upstream sync batch 2: lean plans

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** implement WRK-SPEC-FORK-UPSTREAM-003 components 1–9 and meet AC1–AC7.

**Architecture:** prose changes to writing-plans and its templates (task 001), Review Focus carried to reviewers and A2's attack 1 adapted (task 002), the scenario-4 plan metrics in the harness (task 003), then measurement and release (task 004). Each prose change lands with the `test-skill-content.sh` anchors that guard it.

**Tech Stack:** Markdown skills, bash tests, Node ESM (`brief-lib.mjs`), headless `claude -p`.

**Spec:** `specs/work/WRK-SPEC-FORK-UPSTREAM-003-batch-2-lean-plans.md` — the plan argues from the spec, so executors read both. Upstream texts are read with `git show v6.4.2:skills/writing-plans/SKILL.md` and `git show v6.4.1:skills/writing-plans/SKILL.md`.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-UPSTREAM-003-001 | writing-plans and the WRK-PLAN / WRK-TASK templates (components 1–7) | — |
| WRK-TASK-FORK-UPSTREAM-003-002 | Review Focus reaches the reviewers; A2 on lean plans (components 8, 9) | WRK-TASK-FORK-UPSTREAM-003-001 |
| WRK-TASK-FORK-UPSTREAM-003-003 | scenario-4 plan metrics in the harness | WRK-TASK-FORK-UPSTREAM-003-001 |
| WRK-TASK-FORK-UPSTREAM-003-004 | pre-register, measure the candidate, decide, then release 0.8.0 | 001, 002, 003 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "Add rows and sections; do not rewrite tuned prose. An adapted rewrite is pressure-tested with writing-skills, and its commit states the targeted and the observed behaviour." | DOC-FORK-UPSTREAM-001 §3.1 | task 001 keeps every KDD sentence; its commit records the pressure test (spec AC6) |
| "An execution mode keeps every gate SDD gives a task, before the task is marked complete." | DOC-FORK-UPSTREAM-001 §3.4 | task 001: no per-plan recommendation of today's executing-plans |
| "`test-skill-content.sh` changes in the same commit as the prose it anchors" | DOC-FORK-UPSTREAM-001 §3.7 | tasks 001, 002 |
| "A batch is worse when a deciding metric crosses its pre-registered threshold against the before arm, or a behaviour check passes before and fails after. … A worse batch is reworked or reverted with a human ruling" | DOC-FORK-UPSTREAM-001 §4 Worse | task 004 |
| "A2 \| the WRK-PLAN and its tasks \| letter-vs-rule, interface, order and coverage defects are cheaper in the plan than in code" | DOC-FORK-GATES-001, The gates | task 002 adds one sentence to attack 1; trigger and other attacks unchanged |
| "**Before side:** a `git worktree` at the pre-change commit, with the current `test-kdd-flow.sh` copied in" / "One run per side is not a before/after" | DOC-FORK-TOKENS-001, How to measure | task 004 (harness = script, toolkit-env.sh and fixtures, decision log U-9) |

## Review Focus

- A plan written before this batch (no `## Review Focus`), or a spec with no plan, given to `review-brief`: the brief must still build and say so — task 002 cases (a) and (c).
- A WRK-TASK whose implementation step legitimately carries an algorithm body, indented under its `- [ ]` item, in a task whose test step also has a fence: the metric must count the implementation fence only — task 003's fork-shaped temp case; the step rules must still allow the body — task 001's "a code block only for an algorithm they do not determine" anchor.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| A prose edit drops a KDD sentence | medium | P10 breach | spec AC2 `git diff` check in task 001; existing anchors stay green |
| Headless agents read "review the plan" as a stop in non-interactive runs | medium | scenario 4 regresses | scenario 4's prompt (both arms) approves the saved plan in advance; new activation and commit checks see a stop (task 003) |
| Level-2 cost | — | ≈ $70–80 | protocol-approved; recorded in the decision log |

## Dependencies

- Release tag `kdd-superpowers--v0.7.0` (before arm), toolkit 1.13.0, mdm-platform at `aacdae5`.

## Execution Log

### Rulings
- Ruling: task 004 runs after the batch-1 measurement (b7fvvep5) finishes — level-1 runs must not overlap (DOC-FORK-TOKENS-001 "Run measurements one after another") — cost if wrong: none.
- WRK-TASK-FORK-UPSTREAM-003-001: Ruling: Step 5's two pressure-test subagents are dispatched by the controller after the implementer's commit (implementers never dispatch subagents); the implementer then amends its commit message with the recorded targets and observations — cost if wrong: one extra resume
- WRK-TASK-FORK-UPSTREAM-003-004: Ruling: the controller executes task 004 itself (long headless measurement runs, judges dispatched as subagents, which an implementer may not do); its record is the FRAG and this ledger — cost if wrong: none (no product code)

### Knowledge gaps
- none

### Attacks broken and adjudicated
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 1 · AC5 lets a worse batch ship with a ruling; omits the behaviour-check condition — spec-rule — DOC-FORK-UPSTREAM-001 §4 Worse — accepted: AC5 now states both conditions and "reworked or reverted … not released as is"
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 1 · the handoff would recommend today's executing-plans, which has no gate — spec-rule — §3.4; `executing-plans/SKILL.md:14,34` — accepted: the per-plan recommendation moves to batch 3; batch 2 adds only the plan review (component 7)
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 1 · CORE-001's WRK-TASK design says "steps with real code" — spec-rule — `WRK-SPEC-FORK-CORE-001:366-367` — accepted: the amendment is stated under *Architecture* and in *Constraints*; the line is 6.3.0's step shape, not a principle; the test step keeps real code
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 2 · "code-fence lines ≤ 25 %" has three readings — ambiguity — fixture: 7 % / 20 % / 34 % — accepted: metric defined (implementation fences over body lines), decided relative to the before arm, no fixed 25 %
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 2 · prompts that pre-approve the plan read two ways — ambiguity — `test-kdd-flow.sh:109`; `ab/prompts/k-task.txt` — accepted: an advance approval naming the plan counts and is quoted; prompts unchanged across arms
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 3 · AC4 met by today's full-code plans — ambiguity — fixture task at 20 % — accepted: AC4 is relative to the before arm
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 3 · "none" satisfies the Review Focus check trivially — ambiguity — component 6 — accepted: "none" needs one line per input class checked and its covering test
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 3 · level-2 deciding metrics improve by construction; upstream's evidence is execution — ambiguity — v6.4.2 release notes "9/9 against planted-defect probes" — accepted as a limit: stated under *Testing*; batch 3's level 2b executes a batch-2 plan and can reopen this batch
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 4 · A2 attack 1 against a signature-only step — knowledge-gap — `plan-adversary-prompt.md:27` — accepted: component 9; DOC-FORK-GATES-001 gap
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 4 · what a reviewer does with Review Focus — knowledge-gap — `code-reviewer.md:23-28` — accepted: component 8 (code-reviewer line, SKILL.md:36); DOC-FORK-GATES-001 gap
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 5 · FRAG-FORK-TOKENS-002 cited for the output composition — internal — FRAG report.md:77-82 — accepted: composition cited to DOC-FORK-TOKENS-001 item 4; the FRAG for totals only
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 5 · 6.4.2's cross-task reference assumes the implementer reads the other task — code-reality — `brief-lib.mjs:108-112` — accepted: component 4 points at the task's own *Consumes* line
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: 6 · the fork's rule-citation line was reworded — internal — `SKILL.md:189` — accepted: kept verbatim; AC2 protects it
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: + 2 · proportion counted on whole files — ambiguity — fixture 57 vs 149 lines — accepted: bodies only, frontmatter excluded
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: + 2 · "few" vs "up to five" — ambiguity — v6.4.1 `:81,:163` — accepted: "up to five"
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: + 4 · no criterion for recommending a mode on Claude Code — knowledge-gap — `executing-plans/SKILL.md:14` — accepted: batch 3
- WRK-SPEC-FORK-UPSTREAM-003 A-gate: + 6 · requesting-code-review lists the brief's contents — internal — `requesting-code-review/SKILL.md:36` — accepted: component 8 updates it
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 1 · handoff could copy "For this plan I recommend" or drop "(recommended)" with the suite green — spec-rule — task 001 anchors; v6.4.1 `:182` — accepted: must_not "For this plan I recommend", must "**1. Subagent-Driven (recommended)**"; Step 3 says not to copy it
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 1 · "a code block only for an algorithm …" unpinned — spec-rule — plan Review Focus 2 — accepted: anchor added
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 1 · a +20 % cost rise closes the batch unaccepted — spec-rule — DOC-FORK-UPSTREAM-001 §4 — accepted: task 004 Step 5 holds the release
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 2 · per-class "none" form vs the metric's classifier — internal — tasks 001, 003 — accepted: fixed wording `none — every input class the spec implies is tested:`; classes `none-per-class:<n>` / `none-bare`; tested
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 3 · AC7 needs all four suites — internal — spec AC7; DOC §3.7 — accepted: task 004 Step 6 runs the four
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 3 · AC6 needs the handoff pressure-tested — internal — spec AC6 — accepted: task 001 Step 5 (b), two prompts, pass/fail stated
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 5 · pressure test had no plan and no pass/fail — ambiguity — task 001 Step 5 — accepted: (a) writes plan + tasks; pass conditions stated
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 5 · "Step 3" does not identify the implementation step — ambiguity — FRAG-FORK-GATES-004 K5 bundle `:1993, :2891` — accepted: title contains "implement" and not "test"
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 6 · release tagged before the decision — ambiguity — task 004; spec AC5 vs *Testing* — accepted: measure the candidate sha; release only after "not worse"; AC5 governs the spec's "after this batch's release"
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 7 · `.json` beside the usage JSONs breaks the table — code-reality — `usage-summary.py:20-32` — accepted: `scenario-4.plan-metrics.txt`
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 7 · scenario 4's prompt approves a mode, not the plan — code-reality — `test-kdd-flow.sh:109` — accepted: both arms' prompt approves the saved plan; activation and commit checks added
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: 7 · no fixture has an algorithm body — code-reality — rounding fixture Step 3 — accepted: Review Focus 2 reworded; task 003 builds the case in a temp copy
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: + 1 · "The five" vs "up to five" — ambiguity — v6.4.1 `:81` — accepted: "Up to five", a recorded deviation from verbatim
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: + 1 · KDD sentence and none form unanchored — ambiguity — task 001 — accepted: anchors added
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: + 2 · the two templates' Step 3 diverged — internal — task 001 Steps 3–4 — accepted: same wording in both, anchored
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: + 2 · review brief with no plan — knowledge-gap — `brief-lib.mjs:127` — accepted: task 002 case (c)
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: + 5 · only column-0 fences tested — ambiguity — fixtures — accepted: indented case in task 003
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: + 7 · hard-coded plan id — code-reality — `test-kdd-flow.sh:111` — accepted: the script takes the plan file; scenario 4 globs it
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: + 6 · code-reviewer.md changes but only scenario 4 runs — knowledge-gap — task 002; task 004 — accepted: level 1 runs scenarios 4–6
- WRK-PLAN-FORK-UPSTREAM-003 A-gate: + 1 · report omits the pre-registration sha/time and start times — spec-rule — DOC §4 — accepted: task 004 Step 4

### Capture candidates (pending)
- none

### Parked / deferred
- WRK-TASK-FORK-UPSTREAM-003-001: minor (deferred): "up to five" anchor passes through self-review item 6 — anchor the template's "Up to five input classes" too
- WRK-TASK-FORK-UPSTREAM-003-001: minor (deferred): artifact-templates lacks an anchor for the per-class "none — every input class" form
- WRK-TASK-FORK-UPSTREAM-003-001: minor (deferred): §3.4 guard is the single literal "For this plan I recommend" — broaden in batch 3
- WRK-TASK-FORK-UPSTREAM-003-002: minor (deferred): test-review-brief no-plan case relies on the repo copy being disposable — add a comment
- WRK-TASK-FORK-UPSTREAM-003-003: minor (deferred): plan-metrics fence tracking is a bare toggle (nested/unterminated fences)
- WRK-TASK-FORK-UPSTREAM-003-003: minor (deferred): proportion has no value assertion in test-plan-metrics.sh
- WRK-TASK-FORK-UPSTREAM-003-003: minor (deferred): Review Focus parsing loose (nested bullets, /^none/, heading inside a fence); no test of a title with both implement and test
- WRK-TASK-FORK-UPSTREAM-003-003: minor (deferred): scenario 4 records plan-metrics usage text when no plan exists
- WRK-TASK-FORK-UPSTREAM-003-004: re-review 40f8730..115e7f1: ready (all resolved); minor (deferred): "red step" vs the template's "Run test to verify it fails" — kept, TDD vocabulary; minor: record the scenario-4 check in U-23 (pending runs)

Source: the SDD ledger `.kdd/sdd/WRK-PLAN-FORK-UPSTREAM-003/progress.md`, harvested by the controller; the decision log (`docs/upstream-sync/decision-log.md`) holds the cross-batch rulings.

## Adversarial Review

Gate A2, 2026-10-18 (most capable model): `22 attempted, 20 BROKEN (code-reality 4 · spec-rule 4 · ambiguity 6 · knowledge-gap 2 · internal 4)`. Adjudicated unattended (decision log U-13); all accepted.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 · handoff could copy "For this plan I recommend" or drop "(recommended)" with the suite green | spec-rule | task 001 anchors; v6.4.1 `:182` | accepted: must_not "For this plan I recommend", must "**1. Subagent-Driven (recommended)**"; Step 3 says not to copy it |
| 1 · "a code block only for an algorithm …" unpinned | spec-rule | plan Review Focus 2 | accepted: anchor added |
| 1 · a +20 % cost rise closes the batch unaccepted | spec-rule | DOC-FORK-UPSTREAM-001 §4 | accepted: task 004 Step 5 holds the release |
| 2 · per-class "none" form vs the metric's classifier | internal | tasks 001, 003 | accepted: fixed wording `none — every input class the spec implies is tested:`; classes `none-per-class:<n>` / `none-bare`; tested |
| 3 · AC7 needs all four suites | internal | spec AC7; DOC §3.7 | accepted: task 004 Step 6 runs the four |
| 3 · AC6 needs the handoff pressure-tested | internal | spec AC6 | accepted: task 001 Step 5 (b), two prompts, pass/fail stated |
| 5 · pressure test had no plan and no pass/fail | ambiguity | task 001 Step 5 | accepted: (a) writes plan + tasks; pass conditions stated |
| 5 · "Step 3" does not identify the implementation step | ambiguity | FRAG-FORK-GATES-004 K5 bundle `:1993, :2891` | accepted: title contains "implement" and not "test" |
| 6 · release tagged before the decision | ambiguity | task 004; spec AC5 vs *Testing* | accepted: measure the candidate sha; release only after "not worse"; AC5 governs the spec's "after this batch's release" |
| 7 · `.json` beside the usage JSONs breaks the table | code-reality | `usage-summary.py:20-32` | accepted: `scenario-4.plan-metrics.txt` |
| 7 · scenario 4's prompt approves a mode, not the plan | code-reality | `test-kdd-flow.sh:109` | accepted: both arms' prompt approves the saved plan; activation and commit checks added |
| 7 · no fixture has an algorithm body | code-reality | rounding fixture Step 3 | accepted: Review Focus 2 reworded; task 003 builds the case in a temp copy |
| + 1 · "The five" vs "up to five" | ambiguity | v6.4.1 `:81` | accepted: "Up to five", a recorded deviation from verbatim |
| + 1 · KDD sentence and none form unanchored | ambiguity | task 001 | accepted: anchors added |
| + 2 · the two templates' Step 3 diverged | internal | task 001 Steps 3–4 | accepted: same wording in both, anchored |
| + 2 · review brief with no plan | knowledge-gap | `brief-lib.mjs:127` | accepted: task 002 case (c) |
| + 5 · only column-0 fences tested | ambiguity | fixtures | accepted: indented case in task 003 |
| + 7 · hard-coded plan id | code-reality | `test-kdd-flow.sh:111` | accepted: the script takes the plan file; scenario 4 globs it |
| + 6 · code-reviewer.md changes but only scenario 4 runs | knowledge-gap | task 002; task 004 | accepted: level 1 runs scenarios 4–6 |
| + 1 · report omits the pre-registration sha/time and start times | spec-rule | DOC §4 | accepted: task 004 Step 4 |
