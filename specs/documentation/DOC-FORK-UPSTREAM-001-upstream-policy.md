---
id: DOC-FORK-UPSTREAM-001
type: spec
layer: documentation
scope: persistent
status: draft
confidence: low
version: 0.2.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
domain: kdd-superpowers
subdomain: Upstream
title: "The fork and its upstreams — what kdd-superpowers takes from superpowers and the kdd toolkit, in which batches, and how each batch is compared with the current fork"
sources:
  - id: WRK-SPEC-FORK-UPSTREAM-001
    resource: specs/work/WRK-SPEC-FORK-UPSTREAM-001-upstream-7-integration.md
    title: Where this policy was designed and red-teamed (two gate A1 passes, rulings with the human)
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
    title: Real-task method, hard points, plan executability metric
  - id: FRAG-FORK-GATES-004
    resource: specs/_capture/FRAG-FORK-GATES-004-gates-hold-findings-quality/
    title: Evidence judge and neutral summary, wait-for-subagents sentence
  - id: FRAG-FORK-GATES-005
    resource: specs/_capture/FRAG-FORK-GATES-005-bare-claude-vs-superpowers-vs-kdd/
    title: Pre-registered reading rule
  - id: FRAG-FORK-TOKENS-003
    resource: specs/_capture/FRAG-FORK-TOKENS-003-gates-hold-findings-cost/
    title: Latest fixture cost measurement, superseded by the batch-0 baseline
  - id: FRAG-FORK-UPSTREAM-001
    resource: specs/_capture/FRAG-FORK-UPSTREAM-001-batch-0-baseline/
    title: Batch-0 baseline; the harness defects it found; the model pin
  - id: FRAG-FORK-UPSTREAM-002
    resource: specs/_capture/FRAG-FORK-UPSTREAM-002-batch-1-fixes-measurement/
    title: Batch 1 — not worse after two 0.7.0 regressions found and fixed (hook in POSIX mode, classifier cut of the reviewer)
  - id: FRAG-FORK-UPSTREAM-003
    resource: specs/_capture/FRAG-FORK-UPSTREAM-003-batch-2-lean-plans-measurement/
    title: Batch 2 — worse on executability as first measured, not worse after the rework; the executability counting rule (amendment 3)
  - id: FRAG-FORK-UPSTREAM-004
    resource: specs/_capture/FRAG-FORK-UPSTREAM-004-batch-3-native-measurement/
    title: Batch 3 — Native not worse at level 1; level 2b dropped by human ruling H-8
  - id: FRAG-FORK-UPSTREAM-005
    resource: specs/_capture/FRAG-FORK-UPSTREAM-005-batch-4-brainstorming-measurement/
    title: Batch 4 — not worse at levels 1 and 2 under the narrowed protocol; pressure tests with baselines
  - id: WRK-SPEC-FORK-UPSTREAM-004
    resource: specs/work/WRK-SPEC-FORK-UPSTREAM-004-batch-3-native.md
    title: Where §3.4 and §3.5 were first applied (Native's gates; the ledger questions settled)
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: relates-to
  - id: DOC-FORK-GATES-001
    relation: relates-to
  - id: DOC-FORK-LEDGER-001
    relation: relates-to
  - id: FRAG-FORK-UPSTREAM-002
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
stale_after: 2027-04-16T12:00:00+02:00
tags: [kdd, fork, upstream, superpowers, toolkit, measurement, ab-test, policy]
---

# DOC-FORK-UPSTREAM-001 — The fork and its upstreams

## Purpose

Say how kdd-superpowers takes changes from its two upstreams — superpowers,
which it was derived from, and the kdd toolkit, which it depends on — so
that a sync is a sequence of ordinary, measured KDD work instead of a merge
or a rewrite on belief. Record what the current sync (superpowers 6.4.1–7.0.0,
toolkit 1.10–1.13) takes and in which batch, the rules every batch keeps,
the comparison every batch runs against the current fork, and what the
toolkit expects of the fork.

## Audience

Whoever brainstorms, plans, executes or reviews a batch of an upstream sync;
whoever edits a skill, the hook or a script the toolkit depends on.

## Content

### 1. Dispositions

Every upstream change gets exactly one:

- **adopt** — taken near-literally (a bug fix, a missing guard).
- **adapt** — rewritten in KDD terms: WRK artifacts, `.kdd/` paths, the
  activation, the gates.
- **idea** — only the idea is taken, as new rows or sections; tuned prose
  is not rewritten (P10).
- **discard** — not taken, with the reason recorded here.

Nothing is taken by `git merge`: the fork's skills, paths and tests have
diverged on purpose, and a merge would overwrite KDD prose (P10) and paths
(P13).

### 2. The 6.4.1–7.0.0 sync

Base: superpowers 6.3.0 (`b36e082`); target `upstream/main` at `bb92a77`
(v7.0.0). Toolkit: from 1.9.0 (paired with fork 0.6.0) to 1.13.0.

| Batch | Content | Disposition | Work | Outcome |
|---|---|---|---|---|
| 0. Harness and baseline | the measurement harness every later batch uses: toolkit paths and `KDD_TOOLKIT_DIR` pinned in `test-kdd-flow.sh` and the docs; the A/B run script, K prompt, evidence-judge, neutral-summary and blind-pass prompts (today only in the git-ignored `.kdd/abtest2/`, `.kdd/abtest3/`) committed into the repository; a fixture plan whose tasks activate a numeric rule, for execution scenarios; one baseline of fork 0.6.0 on toolkit 1.13.0 at level 1 | adapt | compact WRK-SPEC, measured | | **0.6.1** (WRK-SPEC-FORK-UPSTREAM-001). Baseline in FRAG-FORK-UPSTREAM-001, 47/47 checks ×2 on Opus. It found three harness defects, fixed before the Opus passes: the scenario-4 fixture contradiction (H-6), piped `grep -q` under `pipefail` (U-7), the unpinned model (U-11). |
| 1. Fixes | `requesting-code-review` base-SHA example without `$1` (`cut -d' ' -f1`) and `git merge-base origin/main HEAD`; `systematic-debugging` example that no longer prints the secret; brainstorm `server.cjs` inserting content literally; TDD "the project's suite defines green" (†); `review-package` range guards (exit 3); `sdd-workspace` writing `.kdd/sdd/.gitignore` only when missing; `code-reviewer.md` "the spec is a vision document" and "Declined to judge" (†); `hooks/run-hook.cmd` Windows fixes; `hooks/session-start` surviving a broken `PATH`; `kdd-conventions/scripts/transition --verify-only`; `test-invariants.sh` rejecting `.antigravity-plugin`, `.muse-plugin`, `index.js` | adopt; hook, transition, invariants: adapt | compact WRK-SPEC, level 1 re-measure (the hook and a prompt template change) | | **0.7.0 → 0.7.1, 0.7.2** (WRK-SPEC-FORK-UPSTREAM-002). Not worse (FRAG-FORK-UPSTREAM-002) after two regressions the level-1 runs found and no deterministic suite could: 0.7.0's `run-hook.cmd` ran `session-start` in POSIX mode under Claude Code, injecting nothing — fixed in 0.7.1 (U-18; the wrapper deviates from upstream's file); the reviewer's "Declined to judge" section made the safety classifier cut its report — **dropped** in 0.7.2 (U-20), "the spec is a vision document" kept. The dev-path item was already done in batch 0 (U-6). 0.7.0 was never published. |
| 2. Lean plans | writing-plans 6.4.2: decisions not code, *What a Step Contains*, proportion self-review, Review Focus, your human partner reviews the saved plan, handoff recommends a mode with a reason; `artifact-templates.md`; A2 stays | adapt | full WRK-SPEC, levels 1 and 2 | | **0.8.0** (WRK-SPEC-FORK-UPSTREAM-003), after a rework: the first candidate was worse on plan executability at level 2 (defects 1.0 → 2.0 per plan, test code naming things that do not exist); two writing-plans sentences fixed it (test code compiles where it lands; self-review checks names against the code), re-measured not worse and cheaper (U-22, U-23; FRAG-FORK-UPSTREAM-003). The handoff's per-plan mode recommendation **moved to batch 3** (U-12: there was no gated mode to recommend). Review Focus says "up to five" (U-13). **Rework vs revert awaits the human's ruling** (spec AC5); WRK-SPEC-FORK-UPSTREAM-003 stays `active` until then. |
| 3. Native | executing-plans inline mode over WRK-TASKs (`task-start`, `task-done`, `transition`, ledger, `Knowledge gap:`, final review through `review-brief` with Review Focus) under §3.4; SDD's *when to use*; handoff offers Subagent-driven / Native; the opt-in nested SDD orchestrator at `skills/subagent-driven-development/claude-code-orchestrator.md` | adapt | full WRK-SPEC, levels 1 and 2b | | **0.9.0** (WRK-SPEC-FORK-UPSTREAM-004). Native passes every scenario-8 check ×2; scenarios 4–5 do not regress; about 20 % cheaper than SDD on the fixture (FRAG-FORK-UPSTREAM-004). §3.5's four questions settled, none left out (U-14; DOC-FORK-LEDGER-001 0.2.0). Upstream's "Declined to judge" handling not ported (U-20). **Level 2b dropped** by the human (H-8): Native has not executed a plan from a real task. |
| 4. Brainstorming and routing | from 7.0, ideas only: "how it gets made", playback in 200–300-word chunks with guesses marked, open questions before menus, a builder check before A1, the companion offer without its cost warning; three paths, HARD-GATE and compact WRK-SPEC kept. using-superpowers: a knowledge question → `kdd:spec-ask`, browsing → `kdd:spec-tui`; a `toolkit: unavailable` row for a hook that could not probe | idea | full WRK-SPEC, levels 1 and 2 | | **0.10.0** (WRK-SPEC-FORK-UPSTREAM-005). Not worse at levels 1 and 2, cost +14 % (FRAG-FORK-UPSTREAM-005). **Builder check not taken** (U-16: gate A1's attacks already ask it, and it would stop headless runs); alternating playback not taken as a form, only "mark your guesses" (U-16); `kdd:spec-ask` routed only outside a workflow (U-16); the `unavailable` row names the absolute `kdd-cli` path (U-17). |
| 5. Diagnosing | `diagnosing-superpowers` with state under `.kdd/` and issues to this repository | adapt, optional | go / no-go when batch 4 closes | | **go / no-go pending the human.** |
| — | other harnesses (Antigravity, Muse, OpenCode, Hermes, Codex, Cursor, Gemini, Kimi, Devin, Qwen); upstream `docs/superpowers/*`; `AGENTS.md` replacing `CLAUDE.md`; the Code of Conduct; the full brainstorming rewrite; "skip the questions" and "quick task: just do it" (they clash with the HARD-GATE and P3); a `skills/using-superpowers/references/` directory (`test-invariants.sh` forbids it); the toolkit's `new-task` as a second path to a WRK-SPEC | discard | — | — |

(†) Behaviour-shaping prose in batch 1 on purpose: additions that touch no
KDD prose, each measured upstream (TDD: only the named file was run in 11 of
12 probes; code review: a crash on an input the spec implied but never named
shipped in every eval). The code-review half shipped only in part: "Declined
to judge" was dropped (U-20).

The decision IDs (H-*, by the human; U-*, taken unattended and waiting for
review) are those of `docs/upstream-sync/decision-log.md`.

**Order:** 0 → 1 → 2 → 3 → 4 → (5). Batch 3 needs batch 2 (handoff, Review
Focus); every batch needs batch 0. Each batch is one minor release with a
`RELEASE-NOTES.md` entry and a tag `kdd-superpowers--v<version>` on the
release commit (`scripts/bump-version.sh` does not tag); the tag is the next
batch's before arm. A fix to a release that a measurement finds broken is a
patch release cut on a `release/<version>` branch from the broken tag (0.7.1,
0.7.2), so the tag holds no commit of a later batch; the next batch's before
arm moves to it. A batch is tagged only after its measurement says it is not
worse (U-13). When the last batch closes, `CLAUDE.md` and `README.md`
say "derived from superpowers 6.3.0, with selected changes through 7.0.0". Done after batch 4 (`6046936`).

This table is updated at each batch's consolidation: a row's item that was
dropped carries the batch's ruling, a released one the version. Batches 0–4
were consolidated together after batch 4 (U-19: bumping the activated
documents mid-sync would have put newer text under the pins of batches still
running).

### 3. Rules every batch keeps

1. **P10.** Add rows and sections; do not rewrite tuned prose. An adapted
   rewrite is pressure-tested with writing-skills, and its commit states the
   targeted and the observed behaviour.
2. **P13.** Upstream `.superpowers/…` becomes `.kdd/…`; `test-invariants.sh`
   stays green.
3. **P3.** Nothing taken opens a path to implementation without an active
   WRK-SPEC or reopens `activates` downstream.
4. **An execution mode keeps every gate SDD gives a task, before the task is
   marked complete.** For Native: the task's final test run, A4 when its
   condition holds, and — after a `Knowledge gap:` ruling on an activated
   rule — a knowledge-compliance review of that task, all run before the
   task's `transition … completed` and its ledger completion line; A3 and A5
   run in the whole-branch review. Native rules and continues like SDD, but
   no knowledge ruling goes unchecked into the next task. Applied in 0.9.0;
   the mapping per gate is in DOC-FORK-GATES-001 (*Execution modes and the
   gates*).
5. **Ledger forms change by DOC-FORK-LEDGER-001's maintenance rule**: a new
   form or writer changes `kdd-status-lib.mjs` and `test-kdd-status.sh` in
   the same commit, and DOC-FORK-LEDGER-001 is bumped at consolidation. The
   batch that adds a writer settles, and tests with the writer's real
   output: the identity line's spelling and how readers compare it, which
   signal a resume trusts (ledger line or frontmatter), the ledger's root as
   `kdd-status` sees it from the main checkout, and the commit range in the
   completion line — or records a human ruling that leaves one out. Batch 3
   settled all four (DOC-FORK-LEDGER-001 0.2.0).
6. **Toolkit contracts** (§5) hold after every batch.
7. **Tests.** `test-skill-content.sh` changes in the same commit as the prose
   it anchors; `tests/scripts/run.sh` (which also runs
   `tests/claude-code/test-executing-plans-scripts.sh` through its
   `tests/scripts/` shim), `test-session-start.sh`, `test-sdd-workspace.sh`
   and the brainstorm-server suite are green; upstream test cases are ported
   by hand.
8. **Claude Code only.**
9. **Pressure tests have a baseline.** A writing-skills pressure test of a
   changed skill runs first on the before text, with a fresh subagent, and
   then on the after text; a target is credited only where the behaviour
   differs (batch 4's A2 and final review: two of five targets changed
   behaviour against the before text, three did not).

### 4. The comparison protocol

- **Arms.** *Before*: the fork at the release tag preceding the batch, as a
  detached `git worktree`. *After*: the batch's candidate commit (the
  release is tagged only if it is not worse). *The harness* copied into
  both arms from the measuring commit is `tests/claude-code/test-kdd-flow.sh`,
  `toolkit-env.sh`, the helpers they source **and the fixtures the
  scenarios read** (`tests/scripts/fixtures`, `tests/claude-code/fixtures`) —
  a scenario reads its fixture from the arm's own tree (U-9). *Fixed across
  arms*: toolkit 1.13.0 for the CLI and the `kdd:*` skills
  (`KDD_SPEC_GRAPH=~/.claude/plugins/cache/kdd/kdd/1.13.0/cli/spec-graph.mjs`,
  `KDD_TOOLKIT_DIR=~/.claude/plugins/cache/kdd/kdd/1.13.0`), the same Claude
  Code version, the model pinned with `--model opus` (`KDD_FLOW_MODEL`,
  default `opus`: the account default once moved to Sonnet and silently
  changed the baseline, U-11), runs in sequence; each FRAG records the
  three. Figures from fragments measured with toolkit 1.6.0 are reference
  only.
- **Pre-registration.** `raw/preregistration.md` in the batch FRAG —
  hypotheses, the deciding metrics, the threshold for each — committed
  before the first after-run; the report gives that commit's sha and time
  and every run's `result.json` start time, all later.
- **Level 1 — fixture.** `KDD_FLOW_USAGE` over `test-kdd-flow.sh`: turns,
  output tokens, `total_cost_usd`, wall time; n=2 per side, more when ranges
  overlap and an effect is claimed — narrowed by the human (H-8): n=1 per
  side unless a cost or metric gain is claimed, and only the scenarios the
  batch touches. Behaviour checks are read from the run's
  transcripts and from the workspace **before** finishing deletes it; a check
  the fixture cannot trigger (A4 on a plan with `activates: []`) is run on
  batch 0's numeric-rule fixture instead. A new scenario that drives an
  execution mode carries every arm that mode is compared with, each prompted
  so that it really runs that mode.
- **Classifier cuts.** A run whose reviewer transcript holds `stop_reason:
  refusal` was cut by the safety classifier: it is set aside by name, like a
  network loss, and repeated on the same arm until each arm has its uncut
  runs (FRAG-FORK-UPSTREAM-003 amendment 2). A cut that one arm shows and
  the other does not is itself a finding (batch 1, U-20).
- **Level 2 — real task**, run only when a batch changes plan- or
  design-shaping prose (H-8). RFC-PIPE-039 on mdm-platform at `aacdae5`,
  with the run script and prompts batch 0 commits; 2 runs per side,
  alternating; pre-flight: `spec-graph validate` with toolkit 1.13.0 over
  mdm-platform's specs at that commit. One evidence judge per run (claims
  about current code, FALSE and design-changing FALSE, knowledge
  violations), its full return also written to a file. **Executability**
  is counted by a separate adjudicator from the plan bundles under neutral
  codes, key kept apart, with this rule (FRAG-FORK-UPSTREAM-003
  amendment 3): a defect is (a) a task without a runnable test step, (b) an
  invalid task order (a task uses what a later task creates), or (c) a step
  that, as written, names a file, type, method, overload, field, variable or
  accessor that does not exist at that point (neither in the code at
  `aacdae5` nor created by an earlier step), or would not compile as
  written; each distinct step counts once; wrong line anchors, wrong
  descriptions of behaviour, design disagreements, knowledge violations and
  an acceptance check that fails because the design is incomplete are not
  counted. **Dropped by H-8:** the neutral summaries and the blind H1–H10
  pass — they never decided a batch and moved by about one point for the
  same summary between passes.
- **Level 2b — real execution** (a committed WRK-PLAN from a real task,
  executed once per mode) was **dropped by H-8**; batch 3 was released
  without it. Reinstating it is a human decision.
- **Reading rule** (FRAG-FORK-GATES-005's pre-registration): precision is
  comparable when the means are within 1 point in the same pass, H1
  reported separately (only where a blind pass runs); a difference below 2 false claims per run is not a
  difference; cost is reported with each arm's range.
- **Worse.** Each batch's pre-registration names its deciding metrics. A
  batch is worse when a deciding metric crosses its pre-registered
  threshold against the before arm, or a behaviour check passes before and
  fails after. Defaults when a batch names none: executability defects
  higher on average; false claims 2 or more above per run (hard points
  more than 1 below in one pass, where a blind pass runs). A worse batch is
  reworked or reverted with a human ruling — the rework is re-measured
  against the same before runs before anything is released (batch 2,
  U-22) — and is held, not released, while that ruling is pending; a cost
  rise above 20 % with
  non-overlapping ranges needs your human partner's explicit acceptance.
- **Record.** One `FRAG-FORK-UPSTREAM-<NNN>` per measured batch, `raw/` as
  in the earlier fragments, including `raw/preregistration.md` and every
  dated amendment (an amendment says what had and had not been read when it
  was written); batch 0's baseline supersedes FRAG-FORK-TOKENS-003.
  DOC-FORK-TOKENS-001 and DOC-FORK-GATES-001 are bumped at each
  consolidation that adds a FRAG; this document's §2 records the outcome.

### 5. What the toolkit expects of the fork

- `skills/kdd-conventions/scripts/next-id` keeps its grammar and results:
  toolkit 1.13's `apps/spec-graph/tests/tui-next-id.test.mjs` runs a parity
  test against it (found under the kdd-superpowers plugin cache or
  `$KDD_NEXT_ID`). Check it in a `git worktree` of the toolkit at its release
  tag, not in a working checkout that may sit on another branch.
- The session-start `open_work` criterion — a `work-spec` that is `active` or
  `completed`, `completed` labelled "pending consolidation" — is replicated
  by the toolkit TUI (`apps/spec-graph/tui/model/work.mjs`). Check the
  `<KDD-ENVIRONMENT>` block byte for byte on `tests/scripts/fixtures` and on a
  copy holding a `completed` WRK-SPEC.
- `activation_pins` from `kdd-cli pins` on every frozen activation
  (toolkit ≥ 1.9; `activation-unpinned` where a `kdd-repo.yaml` exists).

## Maintenance

Update §2 at each batch's consolidation. At the next upstream release,
diff it against the base this document names, add its rows to a new §2
table, and keep §1, §3 and §4 unless a batch's FRAG shows they failed.
Owner: jmbruzos.

## Status

Draft, `confidence: low`: written before any batch ran and updated after
batches 0–4 (one measured FRAG each). §3.4 and §3.5 come from gate A1
adjudications with the human and were applied once (batch 3), on a fixture;
the §4 changes of 0.2.0 are the human's narrowing (H-8) and unattended
rulings (U-9, U-11, U-20, U-22) that await the human's review.
