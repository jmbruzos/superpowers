---
id: DOC-FORK-TOKENS-001
type: spec
layer: documentation
scope: persistent
status: draft
confidence: low
version: 0.1.0
created: 2026-09-19
updated: 2026-09-19
owner: jmbruzos
domain: kdd-superpowers
subdomain: Cost
title: "Token footprint of the kdd-superpowers flow — where it goes, how to measure it"
sources:
  - id: FRAG-FORK-TOKENS-001
    resource: specs/_capture/FRAG-FORK-TOKENS-001-flow-token-measurements/
    title: Headless measurements, baseline and after WRK-SPEC-FORK-TOKENS-001 (2026-09-19)
dependencies:
  - id: FRAG-FORK-TOKENS-001
    relation: distilled-from
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-19T17:46:20+02:00
stale_after: 2027-03-18T16:46:20+01:00
tags: [kdd, fork, tokens, cost, measurement, testing]
---

# DOC-FORK-TOKENS-001 — Token footprint of the kdd-superpowers flow

## Purpose

Say where the tokens of a kdd-superpowers session go, so that a change to a
skill is judged against a measurement instead of a file size, and so that
the levers that matter are not confused with the ones that do not. Every
figure comes from FRAG-FORK-TOKENS-001 (two headless runs, one sample per
scenario — indicative, not statistical).

## Audience

Whoever edits a skill, a prompt template or the session-start hook of this
plugin, or asks "does KDD make this more expensive?".

## Content

### Orders of magnitude (Opus 5 in the main session, trivial two-function task)

| Scenario | Turns | Cost |
|---|---|---|
| Same task without any plugin | 8 | /bin/bash.48 |
| brainstorming, bounded path, up to the active WRK-SPEC | 13-19 | /bin/bash.80-1.23 |
| writing-plans, 2 tasks + gate A2 | 20-22 | .06-3.24 |
| subagent-driven-development, 2 tasks, 5-7 seats | 26-38 | .93-4.03 |

The full architectural flow on a trivial task is roughly an order of
magnitude above doing the task bare. The scaffolding is close to fixed, so
the ratio falls as the task grows; the order of magnitude does not.

### Where the context comes from

1. **Fixed per session: ~4k tokens.** Hook (~1.5k), skill listing (~1.2k),
   agent listing. Not worth optimizing.
2. **First `Skill` call: ~8k of harness cost.** Claude Code rewrites the
   system prompt (`prompt_snapshot`, ~52 KB) and adds deferred tools once
   per session on the first skill invocation. No skill edit removes it.
3. **Skill prose: ~3 bytes per token, cached.** writing-plans ≈ 3.5k,
   brainstorming ≈ 6k, subagent-driven-development ≈ 11k per load. Read
   once, then cache hits on every later turn.
4. **Output tokens are the expensive line.** writing-plans emits 40-60k
   output tokens: plan, tasks with full code blocks, the A2 attack table,
   and rewrites after adjudication. This is the artifact-as-source-of-truth
   design paying for itself; it is not prose overhead.
5. **Subagent seats and their turns.** Each seat starts a fresh 15-24k
   context (cache write). Implementers on the cheapest tier took 30-45
   messages for one-function tasks — turn count, not token price, is what
   the seat costs.
6. **Bookkeeping turns are cheap.** A turn at 80k of cached context costs
   little; the run-to-run variance of a flow (a reviewer finding, a FRAG at
   consolidation) moves the bill far more than a status transition does.

### What was tried and what it did

- `kdd-conventions/scripts/transition` replaced hand edits of the
  frontmatter at every status move — confirmed in every after-run
  transcript. Its token effect is inside run-to-run variance.
- Splitting `references/artifact-templates.md` (5.3 KB) was measured at
  ~0.8k tokens per load and dropped.
- Sections inherited verbatim from upstream superpowers (~2.7k tokens per
  load across three sections) were kept for mergeability.

### How to measure

`KDD_FLOW_USAGE=<dir> bash tests/claude-code/test-kdd-flow.sh` — JSON per
scenario, transcripts, and a table (turns, cache write/read, output,
`total_cost_usd`, duration; per-model and per-subagent breakdown).
`KDD_FLOW_SCENARIOS="5 6"` limits the run. One run per side is not a
before/after; repeat until the effect you claim exceeds the spread you see.

## Maintenance

Re-measure after any change to a workflow skill, a prompt template, the
hook, or a Claude Code major release; append the run to a new FRAG that
`supersedes` FRAG-FORK-TOKENS-001 and bump this document. Owner: jmbruzos.

## Status

Draft, `confidence: low`: one sample per scenario, one machine, one day.
