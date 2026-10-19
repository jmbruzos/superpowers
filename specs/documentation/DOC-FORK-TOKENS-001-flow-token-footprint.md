---
id: DOC-FORK-TOKENS-001
type: spec
layer: documentation
scope: persistent
status: draft
confidence: low
version: 0.4.0
created: 2026-09-19
updated: 2026-10-19
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
  - id: FRAG-FORK-TOKENS-003
    resource: specs/_capture/FRAG-FORK-TOKENS-003-gates-hold-findings-cost/
    title: Scenario 7 before and after WRK-SPEC-FORK-GATES-002 (2026-09-29), two runs per side
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
    title: Cost of a real design + plan, superpowers 6.3.0 vs kdd-superpowers 0.3.0
  - id: FRAG-FORK-GATES-004
    resource: specs/_capture/FRAG-FORK-GATES-004-gates-hold-findings-quality/
    title: Cost of the same design + plan with kdd-superpowers 0.4.0
  - id: FRAG-FORK-UPSTREAM-001
    resource: specs/_capture/FRAG-FORK-UPSTREAM-001-batch-0-baseline/
    title: Batch-0 baseline, fork 0.6.0 on toolkit 1.13.0 and Opus 5.5, scenarios 1–7 × 2 — supersedes FRAG-FORK-TOKENS-003 as the latest fixture baseline
  - id: FRAG-FORK-UPSTREAM-002
    resource: specs/_capture/FRAG-FORK-UPSTREAM-002-batch-1-fixes-measurement/
    title: Batch 1, 0.6.1 vs 0.7.1/0.7.2, scenarios 1–7 × 2
  - id: FRAG-FORK-UPSTREAM-003
    resource: specs/_capture/FRAG-FORK-UPSTREAM-003-batch-2-lean-plans-measurement/
    title: Batch 2 (lean plans), levels 1 and 2, before vs candidate vs reworked candidate
  - id: FRAG-FORK-UPSTREAM-004
    resource: specs/_capture/FRAG-FORK-UPSTREAM-004-batch-3-native-measurement/
    title: Batch 3, Native vs SDD vs the old inline stub on scenario 8; scenarios 4–5
  - id: FRAG-FORK-UPSTREAM-005
    resource: specs/_capture/FRAG-FORK-UPSTREAM-005-batch-4-brainstorming-measurement/
    title: Batch 4 (brainstorming ideas and routing), levels 1 and 2
dependencies:
  - id: FRAG-FORK-TOKENS-001
    relation: distilled-from
  - id: FRAG-FORK-TOKENS-002
    relation: distilled-from
  - id: FRAG-FORK-TOKENS-003
    relation: distilled-from
  - id: FRAG-FORK-UPSTREAM-001
    relation: distilled-from
  - id: FRAG-FORK-UPSTREAM-003
    relation: distilled-from
  - id: FRAG-FORK-UPSTREAM-004
    relation: distilled-from
  - id: FRAG-FORK-UPSTREAM-005
    relation: distilled-from
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-19T01:30:56Z
stale_after: 2027-03-27T12:00:00Z
tags: [kdd, fork, tokens, cost, measurement, testing]
---

# DOC-FORK-TOKENS-001 — Token footprint of the kdd-superpowers flow

## Purpose

Say where the tokens of a kdd-superpowers session go, so that a change to a
skill is judged against a measurement instead of a file size, and so that
the levers that matter are not confused with the ones that do not. Figures
come from FRAG-FORK-TOKENS-001 (two headless runs, one sample per scenario),
FRAG-FORK-TOKENS-002 (three runs per side for writing-plans) and, since the
upstream sync, FRAG-FORK-UPSTREAM-001 … -005 (one to two runs per side per
batch) — indicative, not statistical.

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
| brainstorming, architectural path, 0.3.0, up to the committed WRK-SPEC (scenario 7) | 44-49 | $1.65-1.72 | FRAG-FORK-TOKENS-003 (2 runs) |
| same, 0.4.0 (design file, unlisted-claim check, synchronous gates) | 42-44 | $1.78-1.86 | FRAG-FORK-TOKENS-003 (2 runs) |

### Latest fixture baseline (FRAG-FORK-UPSTREAM-001)

Fork 0.6.0 skills on toolkit 1.13.0, Claude Code 2.1.302, Opus 5.5, two
passes; it supersedes FRAG-FORK-TOKENS-003 as the reference for later
measurements. Every scenario check passed in both passes (47/47).

| Scenario | Turns | Output tokens | Cost | Wall |
|---|---|---|---|---|
| 2 brainstorming, bounded, knowledge base | 12-14 | 7.4-9.0k | $0.48-0.56 | 75-118 s |
| 3 brainstorming, no specs/, FRAG | 19-20 | 9.3-9.7k | $0.63-0.64 | 101-120 s |
| 4 writing-plans | 24-31 | 36.0-38.1k | $1.61-1.73 | 330-403 s |
| 5 SDD, hello plan | 32-39 | 33.6-36.1k | $1.75-1.93 | 408-427 s |
| 6 code review | 6 | 9.8-10.7k | $0.48-0.51 | 89-109 s |
| 7 brainstorming, architectural | 26-31 | 44.8-55.4k | $1.89-2.37 | 419-596 s |
| **Pass total (2–7)** | | | **$7.23-7.35** | |

Scenario 7 at $1.89-2.37 against FRAG-FORK-TOKENS-003's $1.78-1.86 is not
attributed: toolkit, Claude Code and model versions all changed between
them. SDD subagents run Haiku 5.5 and Sonnet 5.5; scenario 7's gates run
Sonnet 5.5.

### What each upstream-sync batch cost (FRAG-FORK-UPSTREAM-002 … -005)

Each row compares the batch's candidate with its before arm inside one
fragment (same toolkit, Claude Code 2.1.302, Opus).

| Batch (release) | Level 1 | Level 2 (RFC-PIPE-039, per run) | Reading |
|---|---|---|---|
| 1 fixes (0.7.1/0.7.2) | scenarios 2–7 per pass $7.23-7.35 → $7.34-7.56 | — | +4.5 % / −0.1 %, inside the before spread except scenario 4, whose prompt changed |
| 2 lean plans (0.8.0, reworked) | scenario 4 $1.83-1.85 → $1.65 (×2) | $17.16-17.63 → $13.99-14.42 | **cheaper**: plans of 1202-1290 bundle lines against 2393-2553; `impl_code_share` 0.20 → ~0.02 |
| 3 Native (0.9.0) | scenarios 4+5 per run $3.09-3.10 → $3.20-3.61 | — (level 2b dropped, H-8) | +10 %; scenario 4 alone +17 % with non-overlapping ranges (the handoff now recommends a mode), under the +20 % rule |
| 4 brainstorming and routing (0.10.0) | s2 $0.52 → $0.56; s3 $0.50 → $0.58; s7 $2.11 → $2.61; s9 $0.17 → $0.17 (n=1) | $11.24-12.36 → $12.71-14.26 | **+14 %** at level 2, under the +20 % rule; scenario 7 +24 % at n=1 |

**Execution modes on the fixture (scenario 8, rounding plan, two tasks,
n=2):** Native $2.07-2.59, SDD $2.76-2.89 — Native about 20 % cheaper with
the same gates passing; 0.8.0's inline stub $0.74-0.76, because it runs no
A4 and no fresh final review, which its two failed checks show.

Level-2 runs of batches 2 and 4 are not comparable with each other: batch
2's before arm cost $17.16-17.63 and batch 4's $11.24-12.36 on the same
task and prompt, after batch 2's lean plans and batch 3 had shipped.

### A real design + plan (mdm-platform RFC-PIPE-039, Opus, headless)

| Arm | Turns | Wall | Cost | Source |
|---|---|---|---|---|
| superpowers 6.3.0, no gates | 65-79 | 15-22 min | $6.03-8.17 | FRAG-FORK-GATES-003 |
| kdd-superpowers 0.3.0 | 57-94 | 45-50 min | $18.38-19.70 | FRAG-FORK-GATES-003 |
| kdd-superpowers 0.4.0 | 63-90 | 40-42 min | $16.88-20.47 | FRAG-FORK-GATES-004 |

On real work the flow costs about 2.7× plain superpowers. Most of the
difference is the premise verifier, the gates, and the output of
adjudicating them. The 0.4.0 changes add a measurable 8 % on the small
fixture, but on this task they are not visible above the run-to-run spread.

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
- Lean plans (WRK-SPEC-FORK-UPSTREAM-003: decisions, not code): the
  largest saving the fork has measured on real work — about 18 % per
  level-2 run and plans half as long — because output tokens are the
  expensive line (item 4 above). The first candidate's plans also had more
  executability defects (test code naming things that do not exist); two
  sentences in writing-plans removed them without losing the saving
  (FRAG-FORK-UPSTREAM-003, decision log U-22).
- Gates-hold-their-findings (WRK-SPEC-FORK-GATES-002: design file, the
  verifier checking unlisted claims, synchronous gates, the permitting
  quote):
  - On scenario 7: +8 % cost, +7 % output tokens and +14 % wall time, with
    non-overlapping ranges (n=2 per side). Turns did not rise; the cost is
    in output and time.
  - On a real design + plan, the difference sits inside the spread.

### How to measure

`KDD_FLOW_USAGE=<dir> bash tests/claude-code/test-kdd-flow.sh` — JSON per
scenario, transcripts, and a table (turns, cache write/read, output,
`total_cost_usd`, duration; per-model and per-subagent breakdown).
`KDD_FLOW_SCENARIOS="5 6"` limits the run; scenarios 8 (execution modes)
and 9 (a knowledge question routed to `kdd:spec-ask`) are opt-in — they run
only when named, and only with `KDD_FLOW_USAGE` set, because their checks
read the run's transcripts. `usage-lib.sh` copies each scenario's
transcripts into `<dir>/scenario-<N>.transcripts/` (those newer than the
previous scenario's); behaviour checks read them before finishing deletes a
workspace. One run per side is not a before/after; repeat until the effect
you claim exceeds the spread you see.

- **Model:** `KDD_FLOW_MODEL` (default `opus`) is passed as `--model`. The
  account default is not a fixed condition: it moved from Opus to Sonnet
  once and silently turned a baseline into a Sonnet run (decision log
  U-11; FRAG-FORK-UPSTREAM-001 keeps those runs as supplementary).

- **Before side:** a `git worktree` at the pre-change commit (a release
  tag), with the current harness copied in — `test-kdd-flow.sh`,
  `toolkit-env.sh`, the helper scripts it sources and **the fixtures the
  scenarios read** (`tests/scripts/fixtures`, `tests/claude-code/fixtures`),
  so harness fixes do not confound the skills under test (decision log U-9:
  a scenario reads its fixture from the arm's own tree).
- **Credentials:** the isolated `CLAUDE_CONFIG_DIR` has none of its own. It
  gets `~/.claude/.credentials.json` when that file exists; on macOS the
  login may live only in the Keychain, so set `CLAUDE_CODE_OAUTH_TOKEN`
  (`claude setup-token`, long-lived, not rotated) or `ANTHROPIC_API_KEY`
  instead. A run that answers "Not logged in" costs $0.00 and 0 turns.
- **No `timeout` binary:** the harness falls back to
  `perl -e 'alarm shift; exec @ARGV'`.
- **Discard, do not average:** runs lost to authentication or network
  errors ("Can't reach the API server") are set aside and named in the
  fragment's Method, never counted. So are runs whose reviewer transcript
  holds `stop_reason: refusal` (the safety classifier cut the report): set
  aside by name and repeated on the same arm (DOC-FORK-UPSTREAM-001 §4).
- **Read `result.json` with care:** one scenario-8 run reported 4 turns and
  90 s for a session whose transcripts show both tasks and the final review
  (FRAG-FORK-UPSTREAM-004); its cost was in line, its turns and wall time
  were not read.
- Run measurements one after another: overlapping runs leave tokens and
  cost intact but inflate durations.

## Maintenance

Re-measure after any change to a workflow skill, a prompt template, the
hook, or a Claude Code major release; record the run in a new FRAG and bump
this document. A new fixture baseline `supersedes` the latest one (now
FRAG-FORK-UPSTREAM-001); a before/after measurement keeps its before arm in
the same or the preceding fragment (`relates-to`). Owner: jmbruzos.

## Status

Draft, `confidence: low`: one machine; one to three samples per scenario
(batch 4's level 1 is n=1); several models and Claude Code versions across
the fragments; the real-task figures are 2-3 runs per arm on one task.
