---
id: DOC-FORK-TOKENS-001
type: spec
layer: documentation
scope: persistent
status: draft
confidence: low
version: 0.2.0
created: 2026-09-19
updated: 2026-09-28
owner: jmbruzos
domain: kdd-superpowers
subdomain: Cost
title: "Token footprint of the kdd-superpowers flow — where it goes, how to measure it"
sources:
  - id: FRAG-FORK-TOKENS-001
    resource: specs/_capture/FRAG-FORK-TOKENS-001-flow-token-measurements/
    title: Headless measurements, baseline and after WRK-SPEC-FORK-TOKENS-001 (2026-09-19)
  - id: FRAG-FORK-TOKENS-002
    resource: specs/_capture/FRAG-FORK-TOKENS-002-gate-tuning-measurements/
    title: Headless measurements before and after WRK-SPEC-FORK-GATES-001 (2026-09-28), three runs per side
dependencies:
  - id: FRAG-FORK-TOKENS-001
    relation: distilled-from
  - id: FRAG-FORK-TOKENS-002
    relation: distilled-from
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-28T12:00:00Z
stale_after: 2027-03-27T12:00:00Z
tags: [kdd, fork, tokens, cost, measurement, testing]
---

# DOC-FORK-TOKENS-001 — Token footprint of the kdd-superpowers flow

## Purpose

Say where the tokens of a kdd-superpowers session go, so that a change to a
skill is judged against a measurement instead of a file size, and so that
the levers that matter are not confused with the ones that do not. Figures
come from FRAG-FORK-TOKENS-001 (two headless runs, one sample per scenario)
and FRAG-FORK-TOKENS-002 (three runs per side for writing-plans) —
indicative, not statistical.

## Audience

Whoever edits a skill, a prompt template or the session-start hook of this
plugin, or asks "does KDD make this more expensive?".

## Content

### Orders of magnitude (Opus in the main session, trivial two-function task)

| Scenario | Turns | Cost | Source |
|---|---|---|---|
| Same task without any plugin | 8 | $0.48 | FRAG-FORK-TOKENS-001 |
| brainstorming, bounded path, up to the active WRK-SPEC | 13-19 | $0.80-1.23 | FRAG-FORK-TOKENS-001 |
| brainstorming, architectural path, premise verifier + gate A1, up to the committed WRK-SPEC | 36 | $1.55 | FRAG-FORK-TOKENS-002 (one run) |
| writing-plans, 2 tasks + gate A2 | 20-22 | $3.06-3.24 | FRAG-FORK-TOKENS-001 (Opus 5, CC 2.1.278) |
| writing-plans, 2 tasks + gate A2 | 44-52 | $1.53-2.28 | FRAG-FORK-TOKENS-002 (Opus 5.5, CC 2.1.283, 6 runs) |
| subagent-driven-development, 2 tasks, 5-7 seats | 26-38 | $2.93-4.03 | FRAG-FORK-TOKENS-001 |

The two writing-plans rows differ in model and Claude Code version; compare
runs only within one fragment. The full architectural flow on a trivial
task is roughly an order of magnitude above doing the task bare. The
scaffolding is close to fixed, so the ratio falls as the task grows; the
order of magnitude does not.

### Where the context comes from

1. **Fixed per session: ~4k tokens.** Hook (~1.5k), skill listing (~1.2k),
   agent listing. Not worth optimizing.
2. **First `Skill` call: ~8k of harness cost.** Claude Code rewrites the
   system prompt (`prompt_snapshot`, ~52 KB) and adds deferred tools once
   per session on the first skill invocation. No skill edit removes it.
3. **Skill prose: ~3 bytes per token, cached.** writing-plans ≈ 3.5k,
   brainstorming ≈ 6k, subagent-driven-development ≈ 11k per load. Read
   once, then cache hits on every later turn.
4. **Output tokens are the expensive line.** writing-plans emits 40-70k
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
   Three writing-plans runs of the same skills spread $1.53-2.06 and
   44.9k-68.4k output tokens (FRAG-FORK-TOKENS-002).

### What was tried and what it did

- `kdd-conventions/scripts/transition` replaced hand edits of the
  frontmatter at every status move — confirmed in every after-run
  transcript. Its token effect is inside run-to-run variance.
- Splitting `references/artifact-templates.md` (5.3 KB) was measured at
  ~0.8k tokens per load and dropped.
- Sections inherited verbatim from upstream superpowers (~2.7k tokens per
  load across three sections) were kept for mergeability.
- Design-gate tuning (WRK-SPEC-FORK-GATES-001: Cause column, detail cap,
  attack 7 in A2, code premises): on writing-plans for a trivial plan, cost
  and output tokens moved inside the spread; turns rose 3-8 per run (44-47
  before, 50-52 after, non-overlapping) — a possible turn cost of the added
  prompt text, n=3 per side. The saving it targets (fewer `code-reality`
  findings to adjudicate) only shows on work with real code premises; see
  DOC-FORK-GATES-001.

### How to measure

`KDD_FLOW_USAGE=<dir> bash tests/claude-code/test-kdd-flow.sh` — JSON per
scenario, transcripts, and a table (turns, cache write/read, output,
`total_cost_usd`, duration; per-model and per-subagent breakdown).
`KDD_FLOW_SCENARIOS="5 6"` limits the run. One run per side is not a
before/after; repeat until the effect you claim exceeds the spread you see.

- **Before side:** a `git worktree` at the pre-change commit, with the
  current `test-kdd-flow.sh` copied in (so harness fixes do not confound the
  skills under test).
- **Credentials:** the isolated `CLAUDE_CONFIG_DIR` has none of its own. It
  gets `~/.claude/.credentials.json` when that file exists; on macOS the
  login may live only in the Keychain, so set `CLAUDE_CODE_OAUTH_TOKEN`
  (`claude setup-token`, long-lived, not rotated) or `ANTHROPIC_API_KEY`
  instead. A run that answers "Not logged in" costs $0.00 and 0 turns.
- **No `timeout` binary:** the harness falls back to
  `perl -e 'alarm shift; exec @ARGV'`.
- **Discard, do not average:** runs lost to authentication or network
  errors ("Can't reach the API server") are set aside and named in the
  fragment's Method, never counted.
- Run measurements one after another: overlapping runs leave tokens and
  cost intact but inflate durations.

## Maintenance

Re-measure after any change to a workflow skill, a prompt template, the
hook, or a Claude Code major release; append the run to a new FRAG that
`supersedes` the latest one (now FRAG-FORK-TOKENS-002) and bump this
document. Owner: jmbruzos.

## Status

Draft, `confidence: low`: one machine; one to three samples per scenario;
two models and two Claude Code versions across the fragments.
