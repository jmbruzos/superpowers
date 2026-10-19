---
id: WRK-PLAN-FORK-UPSTREAM-005
type: spec
layer: work-plan
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
title: "Upstream sync batch 4 — brainstorming ideas and routing — implementation plan"
parent: WRK-SPEC-FORK-UPSTREAM-005
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-UPSTREAM-005
    relation: implements
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-UPSTREAM-005
    resource: specs/work/WRK-SPEC-FORK-UPSTREAM-005-batch-4-brainstorming-routing.md
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T12:48:23+02:00
stale_after: 2027-01-16T13:00:00+02:00
tags: [fork, upstream, brainstorming, using-superpowers, plan]
---

# WRK-PLAN-FORK-UPSTREAM-005 — Upstream sync batch 4: brainstorming ideas and routing

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** implement WRK-SPEC-FORK-UPSTREAM-005 components 1–5 and meet AC1–AC6.

**Architecture:** prose rows in brainstorming (001) and using-superpowers (002), each with its anchors and a controller-run pressure test; scenario 9 (003); measurement and release after batch 3's release (004).

**Tech Stack:** Markdown skills, bash tests, headless `claude -p`.

**Spec:** `specs/work/WRK-SPEC-FORK-UPSTREAM-005-batch-4-brainstorming-routing.md`. Upstream text: `git show upstream/main:skills/brainstorming/SKILL.md` (`:52` Get them describing, `:57` How it gets made, `:120` guesses).

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-UPSTREAM-005-001 | brainstorming: how it gets made, open questions first, guesses marked, companion offer | batch 3 released |
| WRK-TASK-FORK-UPSTREAM-005-002 | using-superpowers: spec-ask and spec-tui routes, the unavailable row | 001 |
| WRK-TASK-FORK-UPSTREAM-005-003 | scenario 9 (opt-in) | 002 |
| WRK-TASK-FORK-UPSTREAM-005-004 | pre-register, measure levels 1 and 2, decide, release | 001–003 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "Add rows and sections; do not rewrite tuned prose. An adapted rewrite is pressure-tested with writing-skills, and its commit states the targeted and the observed behaviour." | DOC-FORK-UPSTREAM-001 §3.1 | tasks 001, 002: added lines only except the two the spec names; pressure tests per spec AC5 |
| "`test-skill-content.sh` changes in the same commit as the prose it anchors" | DOC-FORK-UPSTREAM-001 §3.7 | tasks 001, 002 |
| A1 "the written, self-reviewed WRK-SPEC" | DOC-FORK-GATES-001, The gates | task 001 leaves A1 and its order checks untouched |
| "Re-measure after any change to a workflow skill" | DOC-FORK-TOKENS-001, Maintenance | task 004: scenarios 1, 2, 3, 7, 9 |

## Review Focus

none — every input class the spec implies is tested:
- a request that names no platform → WRK-TASK-FORK-UPSTREAM-005-001: pressure test (a)
- a knowledge question asked outside a workflow → WRK-TASK-FORK-UPSTREAM-005-003: scenario 9
- a session whose probe lines read `unavailable` → WRK-TASK-FORK-UPSTREAM-005-002: pressure test (c)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| "open questions first" lengthens interactive brainstorming | medium | time | not observable headless (every prompt says "I will not answer questions"); accepted, noted in the FRAG |
| Level-2 cost | — | ≈ $70–80 | protocol |

## Dependencies

- Batch 3 released (its tag is this batch's before arm; scenario 9 uses batch 3's opt-in helper).

## Execution Log

### Rulings
- Ruling R1: task 004 follows the human's leaner protocol (decision log H-8): level 1 n=1 per side (scenarios 1, 2, 3, 7, 9); level 2 RFC-PIPE-039 B/A with the evidence judge, 2 runs per side; no neutral summaries, no blind H1–H10 pass — so the spec's "hard points comparable" deciding metric is replaced by false claims and executability defects (amendment-3 counting rule of FRAG-FORK-UPSTREAM-003), knowledge violations reported — cost if wrong: a hard-point regression the evidence judge does not see.
- Ruling: the final whole-branch review runs now over tasks 001–003, before task 004 measures — as in batch 3 — cost if wrong: none (task 004 adds only the FRAG)
- Final: Ruling: both Important are controller artifacts, not code — the controller runs the baseline pressure tests (fresh subagents on the before texts, 3502935 / 6c51ac2) and the re-run of (c) to "found", and adds the dated WRK-SPEC amendment citing H-8 and R1; one scoped re-review follows — cost if wrong: none beyond the runs

### Knowledge gaps
- none

### Attacks broken and adjudicated
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 5 · A1's attacks 2 and 4 already ask the builder's questions — code-reality — `spec-adversary-prompt.md:27,29` — accepted: **builder check not taken** (simplicity; KDD's gate covers it); this also resolves the rows below marked "moot"
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 2 · the "theirs" pile ends a headless run before A1 — ambiguity — `test-kdd-flow.sh:175`; `k-task.txt` — moot (builder check not taken)
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 2 · checklist renumbering vs AC2 — internal — `SKILL.md:114-117,161` — moot
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 3 · the order check passes on any earlier mention — ambiguity — `test-skill-content.sh:176-178` — moot
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 3 · dispatched but its answers ignored — ambiguity — spec Testing — moot
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 5 · the piles are in the SKILL.md, not the prompt — code-reality — `upstream/main:…/builder-check-prompt.md` — moot; premise 6 annotated
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: + 2 · does the builder re-run after review — ambiguity — `SKILL.md:163` — moot
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: + 2 · builder reads the WRK-SPEC only or the activated specs — ambiguity — — — moot
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 1 · components 1–2 are adapted rewrites without a pressure test — spec-rule — §3.1 — accepted: AC5 pressure-tests every changed behaviour
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 2 · "you never run it" for spec-tui reads two ways — ambiguity — spec-tui SKILL.md:6 — accepted: invoke the skill; the human runs the viewer
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 3 · scenario 9 may pass without the row — ambiguity — spec-ask description — accepted: a regression check, credits nothing to the row (Testing)
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 4 · only `toolkit:` has an `unavailable` row — knowledge-gap — `hooks/session-start:40,47` — accepted: one row for any `unavailable` line (component 5)
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 4 · what the fork relies on from the toolkit is unrecorded — knowledge-gap — DOC-FORK-UPSTREAM-001 §5 — accepted: gap for consolidation
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: 6 · playback chunks cut to "guesses marked" with no ruling — ambiguity — §2 batch-4 row — accepted: the fork's sectioned design with approval per section is the playback; recorded under *Architecture*
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: + 2 · spec-ask vs spec-context mid-workflow — ambiguity — `using-superpowers/SKILL.md:34`; P3 — accepted: spec-ask only outside a workflow
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: + 2 · open questions vs the approaches menu — ambiguity — `SKILL.md:110-111,204` — accepted: the rule governs intent questions only
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: + 2 · kdd-cli non-3 exits — ambiguity — `kdd-cli:15,23,28` — accepted: any non-path result is NOT FOUND
- WRK-SPEC-FORK-UPSTREAM-005 A-gate: + 5 · scenario 8's helper and the before tag are batch 3's — code-reality — `git tag` — accepted: depends on WRK-SPEC-FORK-UPSTREAM-004; before arm = batch 3's release
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: 1 · pressure tests have no baseline — spec-rule — writing-skills SKILL.md:16,39 — accepted: baseline first (tasks 001, 002)
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: 1 · a failed pressure test still completes the task — ambiguity — tasks 001/002 Step 5 — accepted: fix loop to the cap
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: 2 · scenario 9 without `USAGE_SCENARIO` writes to the wrong dir — code-reality — `usage-lib.sh:26-28` — accepted: `USAGE_SCENARIO=9`
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: 3 · the in-workflow boundary (spec-context) untested — internal — spec component 5 — accepted: scenario 2 check
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: 3 · level-2 pre-flight missing — spec-rule — DOC-FORK-UPSTREAM-001 §4 — accepted: task 004
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: 5 · the fixture's open work competes with spec-ask — ambiguity — `using-superpowers/SKILL.md:46` — accepted: `specs/work` removed
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: 6 · amend timing — internal — WRK-PLAN-FORK-UPSTREAM-004 + 6 — accepted: before fix rounds and the complete commit
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: 7 · the `unavailable` row's relative kdd-cli path — code-reality — `hooks/session-start:51` — accepted: the hook names the absolute path; spec amended
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: + 3 · worse batch reworked without a human — spec-rule — §4 — accepted: held for the human
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: + 3 · closing the sync (CLAUDE.md/README, batch 5) — spec-rule — §2 — accepted: task 004, batch 5 pending the human
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: + 1 · spike clause unanchored — ambiguity — spec component 1 — accepted: dropped
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: + 1 · pressure test (c) passes on a false NOT FOUND — code-reality — `kdd-cli:28` — accepted: passes only on "found"
- WRK-PLAN-FORK-UPSTREAM-005 A-gate: + 5 · the interactive-length risk is unobservable headless — internal — prompts — accepted: noted, not measured

### Capture candidates (pending)
- WRK-TASK-FORK-UPSTREAM-005-003: Capture candidate: tests/claude-code/usage-lib.sh per-scenario transcript copy — undocumented

### Parked / deferred
- WRK-TASK-FORK-UPSTREAM-005-001: minor (deferred): plan Step 4's `grep '^-[^-]'` hides a removed `- ` bullet (its diff line starts `--`)
- WRK-TASK-FORK-UPSTREAM-005-002: minor (deferred): test-session-start.sh:383 passes if both sides print NO BLOCK; SKILL.md:50 wording differs slightly from the spec quote; missing-tool hook branch (session-start:48-51) untested
- WRK-TASK-FORK-UPSTREAM-005-003: minor (deferred): with no transcripts, scenario 9's "no brainstorming" and "no specs/work" checks pass vacuously (test-kdd-flow.sh:67-69); harness checks only grep the source; scenario 2 hard-fails if discovery goes through kdd-cli instead of a Skill call
- Final: minor (deferred): new using-superpowers row's columns swapped vs the table (SKILL.md:50); component-2 anchor pins only "Get them describing first"; $tx2 unquoted (test-kdd-flow.sh:92); scenario 9 named without KDD_FLOW_USAGE prints SKIP without a failure; decision-log heading "before unattended mode" vs H-7–H-9

Source: the SDD ledger `.kdd/sdd/WRK-PLAN-FORK-UPSTREAM-005/progress.md`, harvested by the controller; the decision log (`docs/upstream-sync/decision-log.md`) holds the cross-batch rulings.

## Adversarial Review

Gate A2, 2026-10-18 (most capable model): `18 attempted, 13 BROKEN (code-reality 3 · spec-rule 4 · ambiguity 3 · knowledge-gap 0 · internal 3)`. Adjudicated unattended (decision log U-17); all accepted as binding amendments in the tasks, one also amending the spec.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 · pressure tests have no baseline | spec-rule | writing-skills SKILL.md:16,39 | accepted: baseline first (tasks 001, 002) |
| 1 · a failed pressure test still completes the task | ambiguity | tasks 001/002 Step 5 | accepted: fix loop to the cap |
| 2 · scenario 9 without `USAGE_SCENARIO` writes to the wrong dir | code-reality | `usage-lib.sh:26-28` | accepted: `USAGE_SCENARIO=9` |
| 3 · the in-workflow boundary (spec-context) untested | internal | spec component 5 | accepted: scenario 2 check |
| 3 · level-2 pre-flight missing | spec-rule | DOC-FORK-UPSTREAM-001 §4 | accepted: task 004 |
| 5 · the fixture's open work competes with spec-ask | ambiguity | `using-superpowers/SKILL.md:46` | accepted: `specs/work` removed |
| 6 · amend timing | internal | WRK-PLAN-FORK-UPSTREAM-004 + 6 | accepted: before fix rounds and the complete commit |
| 7 · the `unavailable` row's relative kdd-cli path | code-reality | `hooks/session-start:51` | accepted: the hook names the absolute path; spec amended |
| + 3 · worse batch reworked without a human | spec-rule | §4 | accepted: held for the human |
| + 3 · closing the sync (CLAUDE.md/README, batch 5) | spec-rule | §2 | accepted: task 004, batch 5 pending the human |
| + 1 · spike clause unanchored | ambiguity | spec component 1 | accepted: dropped |
| + 1 · pressure test (c) passes on a false NOT FOUND | code-reality | `kdd-cli:28` | accepted: passes only on "found" |
| + 5 · the interactive-length risk is unobservable headless | internal | prompts | accepted: noted, not measured |
