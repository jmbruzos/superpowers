---
id: WRK-SPEC-FORK-UPSTREAM-001
type: spec
layer: work-spec
scope: ephemeral
status: completed
confidence: low
version: 0.2.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Upstream sync batch 0 — measurement harness and baseline: pinned toolkit paths, the A/B study under version control, a numeric-rule fixture, fork 0.6.0 measured on toolkit 1.13.0"
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-18T12:30:00+02:00
activation_pins:
  - source: self@7cce64680875
    integrity: sha256:d404b83fc02b2799d1b193366aa8eddaf5168fb3b70fcdde608414e3ea6d2624
dependencies:
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
sources:
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
    title: The study whose run script and prompts batch 0 puts under version control
  - id: FRAG-FORK-GATES-004
    resource: specs/_capture/FRAG-FORK-GATES-004-gates-hold-findings-quality/
    title: Evidence-judge and neutral-summary prompts, wait sentence
  - id: FRAG-FORK-GATES-005
    resource: specs/_capture/FRAG-FORK-GATES-005-bare-claude-vs-superpowers-vs-kdd/
    title: Blind-pass prompts and the reading rule
  - id: FRAG-FORK-TOKENS-003
    resource: specs/_capture/FRAG-FORK-TOKENS-003-gates-hold-findings-cost/
    title: The fixture measurement the baseline supersedes
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T12:30:00+02:00
verified:
  - by: human:jmbruzos
    at: 2026-10-18T11:01:52+02:00
stale_after: 2027-01-16T12:30:00+02:00
tags: [kdd, fork, upstream, measurement, harness, baseline, testing]
---

# WRK-SPEC-FORK-UPSTREAM-001 — Upstream sync batch 0: harness and baseline

## Problem Statement

DOC-FORK-UPSTREAM-001 compares every batch of the superpowers 6.4.1–7.0.0
sync with the current fork. The harness it relies on is not ready:

- `test-kdd-flow.sh` loads the toolkit from
  `../knowledge-driven-development/kdd-toolkit` (`:24`), which does not
  exist — the toolkit checkout is `../spec-driven`, and the version to pin
  is the installed 1.13.0 plugin — so with its defaults it skips. The same
  wrong path is the example in `CLAUDE.md:31`, `docs/testing.md:4` and
  `tests/claude-code/README.md:159`.
- The real-task study (RFC-PIPE-039 on mdm-platform) exists only in the
  git-ignored `.kdd/abtest2/` and `.kdd/abtest3/`: the run script, with
  absolute paths and toolkit 1.6.0 hard-coded, and the K, evidence-judge,
  neutral-summary and blind-pass prompts. The fragments that report the
  study (FRAG-FORK-GATES-003/-004/-005) do not hold them, so "reuse them
  verbatim" has nothing to point at.
- Every execution fixture has `activates: []`, so gate A4 and the
  knowledge-compliance check of DOC-FORK-UPSTREAM-001 §3.4 can never fire
  in a measured run.
- The latest fixture measurement (FRAG-FORK-TOKENS-003) used toolkit 1.6.0,
  so no figure exists for fork 0.6.0 on toolkit 1.13.0 — the before arm of
  batch 1.

## Proposed Change

- **Toolkit paths.** In `tests/claude-code/test-kdd-flow.sh`,
  `KDD_SPEC_GRAPH` defaults to `skills/using-superpowers/scripts/kdd-cli
  --path` and `KDD_TOOLKIT_DIR` to the plugin root above that CLI
  (`<root>/cli/spec-graph.mjs` → `<root>`); both stay overridable from the
  environment, and the header comment says so. The three docs give
  `../spec-driven` as the checkout example and the installed plugin as the
  default.
- **The A/B study under version control.** `tests/claude-code/ab/`:
  - `run-one.sh <label> <plugin-dir>…`, the `.kdd/abtest2/run-one.sh` logic
    with every machine path a variable (`MDM_REPO`, `MDM_BASE` default
    `aacdae5`, `KDD_SPEC_GRAPH`, `MODEL` default `opus`, `AB_OUT` default
    `.kdd/ab/<label>`), the toolkit from `kdd-cli --path`, and the timeout
    portable as in `test-kdd-flow.sh`;
  - `prompts/`: the K task prompt and its wait sentence, the evidence-judge,
    neutral-summary and blind-pass prompts, copied byte for byte from the
    `.kdd/abtest2|3` files the fragments' runs used, each with a header
    line naming the source file and the fragment;
  - `README.md`: how a level-2 run, its judges and the blind pass are run.
- **Numeric-rule fixture.** `tests/claude-code/fixtures/rounding-plan/`: a
  `specs/` tree with one domain spec (a money-rounding rule with an exact
  value), an `active` WRK-SPEC that activates it, and an `active` WRK-PLAN
  with two WRK-TASKs, one of which activates the rule — so A4's condition
  (`adversarial-gates.md:11`) holds for it — plus the minimal code the plan
  changes. It validates with toolkit 1.13.0. No scenario uses it yet;
  batch 3 adds scenario 8 on it.
- **Baseline.** Scenarios 1–7 of `test-kdd-flow.sh` at tag
  `kdd-superpowers--v0.6.0` (a `git worktree`, the batch-0
  `test-kdd-flow.sh` copied in), toolkit 1.13.0, `--model opus`, n=2, in
  sequence, under `KDD_FLOW_USAGE`. Captured as `FRAG-FORK-UPSTREAM-001`
  (`supersedes` FRAG-FORK-TOKENS-003) with `raw/` as in the earlier
  fragments: per-scenario JSON, the usage table, the Claude Code and
  toolkit versions, discarded runs named.
- **Release.** 0.6.1, `RELEASE-NOTES.md` entry, tag `kdd-superpowers--v0.6.1`
  — the before arm of batch 1 (the skills are unchanged, so it measures as
  0.6.0).

## Knowledge Context

| Activated Spec | Role in this work |
|---|---|
| DOC-FORK-UPSTREAM-001@0.1.0 | §4 is the protocol this harness serves; §2 lists batch 0 |
| DOC-FORK-TOKENS-001@0.3.0 | *How to measure*: worktree before side with the current harness copied in, n per side, discard rule, sequential runs |
| FRAG-FORK-GATES-003, -004, -005 | evidence, not activated: the study whose script and prompts move into the repository |
| FRAG-FORK-TOKENS-003 | evidence, not activated: superseded by the baseline |

## Acceptance Criteria

- [ ] AC1. With no `KDD_*` variables set, `bash tests/claude-code/test-kdd-flow.sh`
  finds the toolkit (no `SKIP: kdd toolkit not found`) and its runs load
  the `kdd:*` skills from the same plugin root as the CLI; with
  `KDD_TOOLKIT_DIR`/`KDD_SPEC_GRAPH` set, those win. `grep -rn
  knowledge-driven-development CLAUDE.md docs tests` returns nothing.
- [ ] AC2. `tests/claude-code/ab/prompts/` holds the K, evidence-judge,
  neutral-summary and blind-pass prompts; for each, `diff` of the body
  against its named `.kdd/abtest2|3` source is empty. `run-one.sh` holds no
  `/Users/` path and no toolkit version; `bash -n` passes and
  `tests/shell-lint` passes on it.
- [ ] AC3. `kdd-cli --specs tests/claude-code/fixtures/rounding-plan/specs
  validate` reports 0 issues; exactly one WRK-TASK there activates the
  rounding spec, and that spec's body states the rule with an exact value.
- [ ] AC4. `FRAG-FORK-UPSTREAM-001` exists, `supersedes` FRAG-FORK-TOKENS-003,
  validates, and its report gives for scenarios 1–7 two kept runs each
  (turns, output tokens, `total_cost_usd`, wall time), the Claude Code and
  toolkit (1.13.0) versions, the model, and any discarded run by name.
- [ ] AC5. `bash tests/scripts/run.sh`, `tests/hooks/test-session-start.sh`,
  `tests/claude-code/test-sdd-workspace.sh` and the brainstorm-server suite
  pass; 0.6.1 has its `RELEASE-NOTES.md` entry and the tag
  `kdd-superpowers--v0.6.1`.

## Adversarial Review

This spec first held the whole-sync umbrella (version 0.1.0, commits
`303f7ec`, `81a3949`). Gate A1 ran twice on it: `23 attempted, 22 BROKEN`
and `20 attempted, 17 BROKEN`. Your human partner and the author adjudicated
the first pass one by one (decisions D1–D3); the second showed the umbrella
was designing batch 3's mechanism from outside it. Your human partner then
ruled to move the policy and protocol into DOC-FORK-UPSTREAM-001 and to
reuse this ID for batch 0. Where the rulings went:

| Rulings about | Now in |
|---|---|
| dispositions, batch contents and order (D3), releases and tags | DOC-FORK-UPSTREAM-001 §2 |
| gates in an execution mode (D1.1, D1.2; second pass: A4 and the final test run after completion) | DOC-FORK-UPSTREAM-001 §3.4 |
| ledger forms, identity, resume signal, root, range (D2 and its revision; second pass) | DOC-FORK-UPSTREAM-001 §3.5, settled in batch 3's WRK-SPEC |
| arms, pinned toolkit, pre-registration timing, "worse", reading rule, checks before finishing, prompts verbatim | DOC-FORK-UPSTREAM-001 §4; the harness parts in this spec |
| toolkit contracts and how to check them | DOC-FORK-UPSTREAM-001 §5 |
| batch 1 re-measure after a hook / prompt-template change (second pass) | DOC-FORK-UPSTREAM-001 §2, batch 1 row |
| the `toolkit: unavailable` row in using-superpowers (second pass, scope) | DOC-FORK-UPSTREAM-001 §2, batch 4 row |

WRK-SPEC-FORK-MODS-002, an uncommitted draft, was discarded by your human
partner and moved out of the graph to `.kdd/discarded/`.
