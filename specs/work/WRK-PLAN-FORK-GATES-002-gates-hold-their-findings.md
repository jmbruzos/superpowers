---
id: WRK-PLAN-FORK-GATES-002
type: spec
layer: work-plan
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-09-29
updated: 2026-09-29
owner: jmbruzos
title: "Gates hold their findings — implementation plan"
parent: WRK-SPEC-FORK-GATES-002
activates:
  - DOC-FORK-GATES-001@0.2.0
  - DOC-FORK-TOKENS-001@0.2.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-GATES-002
    relation: implements
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-GATES-002
    resource: specs/work/WRK-SPEC-FORK-GATES-002-gates-hold-their-findings.md
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-29T12:00:00Z
stale_after: 2026-12-28T12:00:00Z
tags: [fork, gates, plan]
---

# WRK-PLAN-FORK-GATES-002 — Gates hold their findings

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** implement WRK-SPEC-FORK-GATES-002 §1–§4 and meet AC1–AC10.

**Architecture:** prose changes to the skills and to the gate contract, the
test anchors that guard them, three scenario-7 assertions, then the two
measurements and the release. The plan has one task, by the human partner's
instruction ("a plan that doesn't need decomposing — be executive"). Gate A2
is skipped by the same instruction: with a single task, the plan-level
attacks (interfaces, order, out-of-set activation) have nothing to find.
Execution is inline, on branch `feat/fork-gates-002`, followed by one final
whole-branch review.

**Tech Stack:** Markdown skills, bash tests, headless Claude Code, kdd
toolkit 1.6.0.

**Spec:** `specs/work/WRK-SPEC-FORK-GATES-002-gates-hold-their-findings.md`
— the plan argues from the spec, so executors read both.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-GATES-002-001 | Everything in WRK-SPEC-FORK-GATES-002 §1–§4 | — |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "it relaxes no existing discipline" | WRK-SPEC-FORK-CORE-001 P10 | Only add sentences and rows. "a broken attack on an activated rule changes the design" stays. |
| "No path contains `superpowers`." | WRK-SPEC-FORK-CORE-001 P13 | The new file lives at `.kdd/brainstorm/<topic>-design.md`. |
| "Re-measure after any change to a workflow skill, a prompt template … append the run to a new FRAG that `supersedes` the latest one" | DOC-FORK-TOKENS-001 §Maintenance | FRAG-FORK-TOKENS-003, from scenario 7 run twice per side. |
| "To compare plugin versions, repeat the FRAG-FORK-GATES-002 method" | DOC-FORK-GATES-001 §Maintenance | K arm with 0.4.0, recorded in FRAG-FORK-GATES-004. |
| "Every BROKEN finding, full row or one-liner, is adjudicated." | adversarial-gates.md | Unchanged; the permitting-quote rule narrows how a rejection is made. |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Measurement noise (n=2) | High | Medium | Report the spread and the direction; do not claim more than the spread allows. |
| Headless runs lost to auth or network | Medium | Low | `CLAUDE_CODE_OAUTH_TOKEN` in `~/.zshenv`; set aside lost runs and re-run them. |

## Dependencies

- kdd toolkit 1.6.0. Headless credentials via `CLAUDE_CODE_OAUTH_TOKEN`.
- The FRAG-FORK-GATES-003 harness in `.kdd/abtest2/` (gitignored).

---

## Execution Log

Inline execution (executing-plans), single task, A2 skipped by human instruction. Written from the ledger `.kdd/sdd/WRK-PLAN-FORK-GATES-002/progress.md`.

### Rulings
- A2 skipped on this plan by the human partner's instruction ("primemos ser ejecutivos").
- Behaviour check (AC7): the first micro-test batch was discarded, because its contexts carried the plan diff; the clean batch showed 0.3.0 3/3 and 0.4.0 3/3 accepting and waiting, with only 0.4.0 recording the contested-rule gap. AC9 is the discriminating test.
- AC6: scenario 7 passes headless against kdd 1.6.0 (the ac6-s7 run). After the final review, the Listed check was corrected to read only subagent replies, and it was re-checked on the saved runs: 0.4.0 passes and 0.3.0 fails.
- AC9: FRAG-FORK-GATES-004. K4 8/10 and K5 9/10; H1 was correct in 2/2 runs against 0/5 before; no `spec-rule` finding was rejected.
- Final review, 11 findings: all fixed in eb4cb0b. The permitting quote must now scope the violated rule; contradicting text is a conflict, ruled `accepted → fix`.
- Baseline failures unchanged and not this work's: test-invariants (untracked `docs/superpowers/`) and test-transition (9 assertions with kdd 1.6.0).

### Knowledge gaps
- Knowledge gap: contested rule — DOM-MDM-SURVIVORSHIP-001 § 3.2 ("Propaga downstream: No") vs ARCH-MDM-PERFORMANCE-001 § 3.3.1 (cross-pod invalidation via `golden_record.updated`). It is an mdm-platform issue, surfaced by FRAG-FORK-GATES-004, and not this plugin's to resolve.

### Attacks broken and adjudicated
Gate A1 on the WRK-SPEC: `21 attempted, 19 BROKEN (code-reality 2 · spec-rule 3 · ambiguity 5 · knowledge-gap 3 · internal 6)`.
- 1 — No re-measurement for changes to workflow skills and prompt templates; "still one mid-tier seat" asserted without measurement (spec-rule) — Ruling: accepted → §4 Cost; AC8 (FRAG-FORK-TOKENS-003)
- 1 — The `rejected → human:<id>` exception relaxes "a broken attack on an activated rule changes the design" (spec-rule) — Ruling: accepted → exception removed; disagreement means changing the spec (§3, AC3, AC4)
- 2 — "A rule that permits the design" could be the WRK-SPEC itself, so K2's failure would pass (ambiguity) — Ruling: accepted → permitting rules come only from activated specs or constrained-by principles, with three exclusions (§3)
- 2 — "Carries both kinds" could mean dozens of rows (ambiguity) — Ruling: accepted → listed premises plus false or unverifiable unlisted claims; holds summarised in one line (§1)
- 2 — Which sections go in the design file; re-verify after a change? (ambiguity) — Ruling: accepted → all sections approved so far; re-dispatch on changed statements (§1)
- 3 — Scenario 7 passes by merely naming a file and adding a `Listed` header (ambiguity) — Ruling: accepted → assertions on the Write-before-dispatch order and on the verifier's result (§4, AC6)
- 3 — K1's real rejection already fits `rejected → <ID> § "<literal>"` (ambiguity) — Ruling: accepted → a narrower reading and the violated rule quoted back are excluded; adjudication behaviour is measured in AC9
- 3 — AC5 contradicts the two existing three-column anchors (internal) — Ruling: accepted → listed as updated anchors (§4, AC5)
- 4 — How to wait in interactive sessions (knowledge-gap) — Ruling: accepted → the rule is "no next step and no final message"; non-interactive: foreground or wait before the turn ends (§2)
- 4 — Two activated rules conflict (knowledge-gap) — Ruling: accepted → `Knowledge gap: conflict — …`; the finding stands; the human changes a spec (§3)
- 4 — `Knowledge gap:` reused for a disagreement (knowledge-gap) — Ruling: accepted → the `contested rule —` prefix, read by consolidation as a candidate clarification (§3)
- 5 — Premise 8's evidence for K2 does not hold in the study bundle (code-reality) — Ruling: accepted → study defect: the K2 bundle held an early, pre-A1 spec instead of the committed one. FRAG-FORK-GATES-003 is corrected in place (human ruling) and K2 re-judged; premise 8's evidence now cites K2's committed spec
- 5 — `.kdd/` is not yet gitignored when the design file is written (code-reality) — Ruling: accepted → gitignore step before writing (§1, AC1)
- 6 — The SDD quote sentence has no evidence (the studies stop at the plan) (internal) — Ruling: accepted → SDD unchanged for §3; Open Question
- + 1 — The quality A/B that DOC-FORK-GATES-001 describes is not required (spec-rule) — Ruling: accepted (no permitting quote; human ruling) → AC9, FRAG-FORK-GATES-004
- + 3 — The writing-skills pressure test has no acceptance criterion (internal) — Ruling: accepted → AC7
- + 5 — brainstorming/SKILL.md:214 hard-codes the three-column table (internal) — Ruling: accepted → updated (§1, AC1)
- + 5 — The kdd-conventions locations table lacks the design file (internal) — Ruling: accepted → updated (§1, AC1)
- + 6 — Synchronous gates imposed on A3 and A5, which are never dispatched (internal) — Ruling: accepted → scoped to dispatched gates (A1, A2, A4, A6) and the verifier (§2)

### Capture candidates (pending)
- none: the studies are captured as FRAG-FORK-GATES-004 and FRAG-FORK-TOKENS-003.

### Parked / deferred
- SDD reviewer findings that cite a rule: should the permitting-quote rule apply to them? No evidence yet (spec Open Questions).
- test-transition fails with kdd 1.6.0 (pre-existing).
- A guard for P10 (tuned prose reworded) is not automated.
