---
id: WRK-TASK-FORK-GATES-002-001
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-29
updated: 2026-09-29
owner: jmbruzos
title: "Implement WRK-SPEC-FORK-GATES-002"
parent: WRK-PLAN-FORK-GATES-002
activates:
  - DOC-FORK-GATES-001@0.2.0
  - DOC-FORK-TOKENS-001@0.2.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-GATES-002
    relation: implements
sources:
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-29T12:00:00Z }
stale_after: 2026-12-28T12:00:00Z
tags: [fork, gates, task]
---

# WRK-TASK-FORK-GATES-002-001 — Implement WRK-SPEC-FORK-GATES-002

## Objective

Deliver §1–§4 of the spec and meet AC1–AC10 in one pass.

## Implementation Notes

**Files:**
- Modify: `skills/brainstorming/premise-verifier-prompt.md`, `skills/brainstorming/SKILL.md`, `skills/writing-plans/SKILL.md`, `skills/subagent-driven-development/SKILL.md`, `skills/kdd-conventions/references/adversarial-gates.md`, `skills/kdd-conventions/references/artifact-templates.md`, `skills/kdd-conventions/SKILL.md`
- Test: `tests/scripts/test-skill-content.sh`, `tests/claude-code/test-kdd-flow.sh`
- Create: `specs/_capture/FRAG-FORK-TOKENS-003-*`, `specs/_capture/FRAG-FORK-GATES-004-*`
- Release: version files and `RELEASE-NOTES.md`

**Interfaces:**
- Consumes: the spec's exact wording for the contract sentences (§2, §3).
- Produces: the verifier table `| Premise | Listed | Verified by | Result |`, the Ruling format `rejected → <ID> § <section> "<literal>"`, and the gap prefixes `Knowledge gap: contested rule —` and `Knowledge gap: conflict —`.

**Premises:** the WRK-SPEC's Code Premises. Nothing beyond them.

- [ ] **Step 1: Baseline** — record `run.sh`, session-start, sdd-workspace and brainstorm-server results to `.kdd/baseline-*.txt`.
- [ ] **Step 2: Anchors first** — add every anchor in spec §4 to `test-skill-content.sh` and update the two three-column anchors. Run it and see them fail.
- [ ] **Step 3: Prose** — edit the seven files per spec §1–§3. Run `test-skill-content.sh` (green) and `run.sh` diffed against the baseline (no new failures).
- [ ] **Step 4: Scenario 7** — add the three assertions; `bash -n`.
- [ ] **Step 5: Commit** — `feat(WRK-TASK-FORK-GATES-002-001): …`.
- [ ] **Step 6: Behaviour check** — writing-skills pressure test of the three rules (AC7); state target and observation in a commit.
- [ ] **Step 7: Cost** — scenario 7, twice at 0.3.0 (worktree at `5ff773e`) and twice at HEAD. Record the runs in FRAG-FORK-TOKENS-003 (supersedes 002). This also covers AC6's live run.
- [ ] **Step 8: Quality** — K arm with 0.4.0, twice, with the FRAG-FORK-GATES-003 harness and prompt (plus the wait sentence). Evidence judges, neutral summaries, and a blind H1–H10 pass together with FRAG-003's five summaries. Record in FRAG-FORK-GATES-004.
- [ ] **Step 9: Release** — `bump-version.sh 0.4.0` and a RELEASE-NOTES entry.

## Acceptance Criteria

- [ ] AC1–AC10 of WRK-SPEC-FORK-GATES-002.

## Test Plan

Steps 2–4 (deterministic), Step 7 (the live scenario 7 run, AC6), Step 8.
