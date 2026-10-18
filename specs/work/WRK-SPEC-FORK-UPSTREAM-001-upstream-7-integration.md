---
id: WRK-SPEC-FORK-UPSTREAM-001
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Upstream superpowers 6.4.1–7.0.0 and kdd toolkit 1.10–1.13: what the fork takes, in which batches, and how each batch is compared with the current fork"
activates:
  - DOC-FORK-TOKENS-001@0.3.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-LEDGER-001@0.1.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-18T10:10:00+02:00
activation_pins:
  - source: self@7dbf122f9bb0
    integrity: sha256:de50749aae1f702dfbb30811daf7223a0f178879ca7233eccca8e327a2439fd3
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-LEDGER-001
    relation: constrained-by
sources:
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
    title: superpowers 6.3.0 vs kdd-superpowers 0.3.0 on RFC-PIPE-039 (method, judges, plan executability metric)
  - id: FRAG-FORK-GATES-004
    resource: specs/_capture/FRAG-FORK-GATES-004-gates-hold-findings-quality/
    title: kdd-superpowers 0.4.0 on RFC-PIPE-039 (judge prompts and K prompt reused verbatim)
  - id: FRAG-FORK-GATES-005
    resource: specs/_capture/FRAG-FORK-GATES-005-bare-claude-vs-superpowers-vs-kdd/
    title: three-arm comparison and its pre-registered reading rule
  - id: FRAG-FORK-TOKENS-003
    resource: specs/_capture/FRAG-FORK-TOKENS-003-gates-hold-findings-cost/
    title: latest fixture cost measurement (scenario 7, n=2 per side)
  - id: FRAG-FORK-LEDGER-001
    resource: specs/_capture/FRAG-FORK-LEDGER-001-sdd-ledger-line-forms/
    title: ledger line forms the skills write and kdd-status parses
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T10:10:00+02:00
stale_after: 2027-01-16T10:10:00+02:00
tags: [kdd, fork, upstream, integration, measurement, ab-test, writing-plans, executing-plans, brainstorming, hooks]
---

# WRK-SPEC-FORK-UPSTREAM-001 — Upstream 6.4.1–7.0.0 integration

## Problem Statement

kdd-superpowers is derived from superpowers 6.3.0 (`b36e082`). Upstream has
since released 6.4.1, 6.4.2 and 7.0.0 (`upstream/main` at `bb92a77`): 106
files, about 7.8k lines added. More than half is support for harnesses the
fork removed. The rest carries real fixes and three behaviour changes with
measured effects upstream:

- **Native execution** (6.4.1). The 6.3.0 `executing-plans` stub "measured
  the same as running with no plugin at all"; upstream rebuilt it as an
  inline mode with ledger, `task-start`/`task-done` and one whole-branch
  review. Our `executing-plans` is that 64-line stub adapted to KDD (68
  lines, ledger and task brief added). It tells the agent to use SDD whenever
  subagents exist, so on Claude Code it is never chosen, and it has no review
  at all.
- **Lean plans** (6.4.2). Plans record decisions, not code; upstream
  reports plans in a quarter of the time and a third of the tokens, and no
  more scratch builds during planning. Our WRK-TASK template still carries a
  full code body in Step 3.
- **Rebuilt brainstorming** (7.0.0). A from-scratch rewrite that drops the
  spike/bounded/architectural router the fork is built on, plus ideas that
  fit it ("how it gets made", chunked playback, open questions first, a
  builder check).

Separately, the kdd toolkit moved from 1.9.0 (paired with fork 0.6.0) to
1.13.0. It now depends on the fork in two places (a parity test against our
`next-id`, and the TUI's copy of our session-start pending-consolidation
criterion) and offers commands the fork does not use yet
(`transition --verify-only`, `/kdd:spec-ask`, `/kdd:spec-tui`).

Taking any of this by merge would overwrite KDD prose (P10) and paths (P13).
Taking it by hand without measurement would repeat what the fork has avoided
so far: changing a behaviour-shaping skill on belief. This umbrella decides
what is taken, in which batches, and how each batch is compared with the
current fork. The comparison reuses the fork's existing scenarios
(`test-kdd-flow.sh` 1–7 and the RFC-PIPE-039 study) and extends them in two
places your human partner approved during design: a scenario 8 for inline
execution and a real-execution level for batch 3.

## Proposed Change

### Architecture

One umbrella WRK-SPEC (this one) and one WRK-SPEC per batch. This spec fixes
the disposition of every upstream and toolkit change, the batch order, the
rules batch 3 must keep, and the comparison protocol every batch follows.
Each batch WRK-SPEC is `constrained-by` this one, goes through its own
brainstorming path (compact for batch 1, full for 2–4), its own gates,
approval, execution and consolidation, and states only its own hypotheses
within the protocol.

The umbrella's WRK-PLAN has one WRK-TASK per batch. A batch task is complete
when the batch WRK-SPEC is `archived` and, for batches 2–4, its measurement
is captured in a FRAG.

### Components

Dispositions: **adopt** (near-literal), **adapt** (rewritten in KDD terms),
**idea** (new rows or sections only, per P10), **discard**.

| Batch | Content | Disposition | Spec |
|---|---|---|---|
| 1. Fixes | `requesting-code-review`: `awk '{print $1}'` → `cut -d' ' -f1` and multi-commit base `git merge-base origin/main HEAD`; `systematic-debugging` example no longer prints the secret; brainstorm `server.cjs` inserts content literally (function replacer); TDD paragraph "the project's suite defines green" (†); `review-package` range guards (exit 3); `sdd-workspace` writes `.kdd/sdd/.gitignore` only when missing; `code-reviewer.md` "the spec is a vision document" and "Declined to judge" (†); `hooks/run-hook.cmd` Windows fixes; `hooks/session-start` survives a broken `PATH` (see AC6); `kdd-conventions/scripts/transition` exposes `--verify-only`; development paths to the toolkit (`CLAUDE.md`, `docs/testing.md`, `tests/claude-code/README.md`, and `test-kdd-flow.sh`'s `KDD_TOOLKIT_DIR` default); `test-invariants.sh` also rejects `.antigravity-plugin`, `.muse-plugin` and `index.js` | adopt; session-start, transition and test-invariants: adapt | compact |
| 2. Lean plans | writing-plans 6.4.2: the plan records decisions, not code; *What a Step Contains*; proportion self-review; Review Focus (up to five uncovered input classes, each pinned by a test in its owning task); your human partner reviews the saved plan before execution; handoff recommends one execution mode with a reason. Touches `artifact-templates.md` and `test-skill-content.sh` anchors. A2 stays. | adapt | full |
| 3. Native | executing-plans inline mode: `task-start` / `task-done` over WRK-TASK files, `transition`, ledger lines per DOC-FORK-LEDGER-001 as WRK-SPEC-FORK-MODS-002 leaves it, `Knowledge gap:` rulings, final review through `review-brief` with the plan's Review Focus, under the rules in *Batch 3 rules* below; SDD's *when to use* diagram; the plan handoff offers Subagent-driven / Native; the opt-in nested SDD orchestrator from upstream's `references/claude-code-tools.md`, placed at `skills/subagent-driven-development/claude-code-orchestrator.md` | adapt | full |
| 4. Brainstorming and routing | ideas from 7.0 only: "how it gets made" (which platform/language/library choices your human partner owns), playback in 200–300-word chunks with guesses marked, open questions before menus, a builder check before A1, the companion offer without its token-cost warning. The three paths, the HARD-GATE and the compact WRK-SPEC stay. using-superpowers *Skill Priority*: a question about what the knowledge says → `kdd:spec-ask`; browsing the graph → `kdd:spec-tui` (your human partner launches it). | idea | full |
| 5. Diagnosing | `diagnosing-superpowers` adapted: state under `.kdd/`, issues to this repository | adapt, optional | decided when batch 4 closes |
| — | other harnesses (Antigravity, Muse, OpenCode, Hermes, Codex, Cursor, Gemini, Kimi, Devin, Qwen) and their manifests, tests and docs; upstream `docs/superpowers/*`; `AGENTS.md` replacing `CLAUDE.md`; the Code of Conduct; the full brainstorming rewrite; "skip the questions" and "quick task: just do it" (they clash with the HARD-GATE and P3); the toolkit's `new-task` as a second path to a WRK-SPEC; a `skills/using-superpowers/references/` directory (`test-invariants.sh:32` forbids it) | discard | — |

(†) Behaviour-shaping prose kept in the unmeasured batch 1 on purpose: both
are additions that touch no KDD prose, and upstream measured each (TDD:
sessions ran only the named file in 11 of 12 probe runs; code review: every
implementer shipped the same crash on an input the spec implied but never
named). Batch 2's fixture and real-task runs observe them as a side effect.

#### Batch 3 rules (decided at gate A1)

Native removes the per-task implementer and reviewer seats. Gates A3 and A4
ride on those seats in SDD (`adversarial-gates.md:9-10`); today's
executing-plans has neither, nor any review (`grep -n "A3\|A4\|A5\|adversar"
skills/executing-plans/SKILL.md` → empty). The batch keeps every gate that
SDD gives a task touching knowledge:

1. **Knowledge-compliance check on a knowledge ruling.** Native rules and
   continues, like SDD. A `Ruling:` tagged `Knowledge gap:` that concerns an
   activated rule immediately dispatches a knowledge-compliance review of
   that task (mid tier, the task's diff against that rule) before the next
   task starts. A violation it finds is blocking and is fixed in the task.
2. **A4 per task.** When a task meets A4's condition (`CALC-*`, a numeric or
   business rule, or security-sensitive), the test adversary runs after the
   task's `task-done`. A `BROKEN` row is fixed in the same task by TDD (a
   test that fails, then passes) before the next task starts.
3. **A3 and A5 in the final review.** The whole-branch review covers every
   activated rule the branch touches (A3) and every WRK-SPEC acceptance
   criterion (A5), as SDD's final review does.

### Data flow

- **Order:** 1 → 2 → WRK-SPEC-FORK-MODS-002 → 3 → 4 → (5).
  - Batch 3 depends on batch 2: the plan handoff offers Native, and Native's
    final review uses Review Focus.
  - Batch 3 depends on WRK-SPEC-FORK-MODS-002 (your human partner's draft,
    its own flow, not absorbed here): it settles DOC-FORK-LEDGER-001's
    inconsistencies 1, 2 and 4 (completion line vs task status, ledger
    identity, root), which Native's `task-done` writes into.
  - Batch 4 is independent and goes last because it is the most
    prose-sensitive.
- **Releases:** one minor release per batch, 0.7.0 to 0.10.0, each with its
  `RELEASE-NOTES.md` entry (`scripts/bump-version.sh`) and a tag
  `kdd-superpowers--v<version>` on the release commit (as for 0.6.0;
  `bump-version.sh` does not tag). The tag is the next batch's before arm.
- **At umbrella close:** `CLAUDE.md` and `README.md` say "derived from
  superpowers 6.3.0, with selected changes through 7.0.0", and the
  disposition table above stays as the record of what was taken.

### Error handling

- **Decision rule.** A batch is **worse** on quality when, in one judging
  pass, its mean hard points are more than 1 point below the before arm's;
  or its mean false claims about code per run are 2 or more above; or a
  behaviour check passes on the before side and fails on the after side. A
  worse batch is not released as is: it is reworked or reverted, with a
  human ruling recorded in the batch WRK-PLAN's Execution Log (batch 1: in
  its WRK-SPEC). A cost rise above 20 % with non-overlapping ranges needs
  your human partner's explicit acceptance, recorded the same way.
- **Discarded runs.** Runs lost to authentication or network errors are set
  aside and named in the FRAG's Method, never averaged.
- **A batch that grows** beyond its row in *Components* goes back to this
  spec: a substantive change here re-runs gate A1 and needs a new approval.

### Testing — the comparison protocol

Every batch WRK-SPEC cites this section and adds only its hypotheses.

- **Arms.**
  - **Before:** the fork at the release tag preceding the batch, as a `git
    worktree` (batch 2: the batch-1 tag), with the current
    `tests/claude-code/test-kdd-flow.sh` copied in.
  - **After:** the batch's merge commit.
  - **Fixed across arms:** kdd toolkit 1.13.0 for both the CLI and the
    `kdd:*` skills — `KDD_SPEC_GRAPH=~/.claude/plugins/cache/kdd/kdd/1.13.0/cli/spec-graph.mjs`
    and `KDD_TOOLKIT_DIR=~/.claude/plugins/cache/kdd/kdd/1.13.0` (the
    harness loads it with `--plugin-dir`); the same Claude Code version
    (2.1.302 at the time of writing); `--model opus`; runs in sequence. Each
    FRAG records the three.
  - FRAG-FORK-GATES-003, -004 and -005 ran with toolkit 1.6.0. Their numbers
    are reference only, never a before side.
- **Pre-registration.** `raw/preregistration.md` in the batch FRAG:
  hypotheses, metrics, reading rule, committed before the first after-run.
  The FRAG's report records that commit's sha and time, and every run's
  `result.json` start time, which must be later.
- **Level 1 — fixture** (batches 2–4; batch 1 runs its deterministic tests
  and one smoke run of `test-kdd-flow.sh`, not counted as a measurement).
  - `KDD_FLOW_USAGE`: turns, output tokens, `total_cost_usd`, wall time.
    n=2 per side, more when ranges overlap and an effect is claimed.
  - Behaviour checks on the transcripts, pass/fail on both sides:
    - Batch 2: plan-to-spec length ratio, share of code blocks in the
      WRK-TASKs, Review Focus present, A2 still dispatched.
    - Batch 3: `kdd-status` reads the Native completion lines, no per-task
      implementer or reviewer dispatch, A4 dispatched for a task that meets
      its condition, the final review dispatched on the most capable model,
      the final message carries "Rulings I made".
    - Batch 4: path classification announced, HARD-GATE held, A1 and the
      premise verifier still dispatched, the "how it gets made" question
      asked, and a question about what the knowledge says routed to
      `kdd:spec-ask`, not to brainstorming.
  - **New scenario 8:** inline execution of scenario 5's plan. Three arms on
    the same plan: today's executing-plans (its prompt says to execute
    inline with no subagents, since the skill otherwise defers to SDD),
    Native, and SDD (scenario 5).
- **Level 2 — real task** (batches 2 and 4). RFC-PIPE-039 on mdm-platform at
  `aacdae5`, K before vs K after, 2 runs per side.
  - Pre-flight, recorded in the pre-registration: `spec-graph validate` with
    toolkit 1.13.0 over mdm-platform's specs at `aacdae5`.
  - Prompt: FRAG-FORK-GATES-004's K prompt verbatim, wait-for-subagents
    sentence included.
  - Evidence judge and neutral summary with the FRAG-FORK-GATES-004 prompts
    verbatim; one blind H1–H10 pass over the four new summaries under
    shuffled codes, the key kept outside the judge's reach.
  - Reading rule, from FRAG-FORK-GATES-005's pre-registration: precision is
    "comparable" when the means are within 1 point in the same pass, with H1
    reported separately; a difference below 2 false claims per run is not a
    difference; cost is reported with each arm's range. "Worse" is defined
    under *Error handling*.
  - Batch 2 decides on plan quality, not design: plan executability
    (FRAG-FORK-GATES-003's metric 4: each task has a runnable test step and
    an unambiguous interface), the evidence judge over the plan and its
    tasks, plan length and output tokens. H1–H10 is reported, not decisive.
  - Batch 4 decides on H1–H10, false claims and cost.
- **Level 2b — real execution** (batch 3). The WRK-PLAN committed by batch
  2's after-run, executed once with Native and once with SDD; indicative,
  n=1 per arm. Cost, wall time, green suite, acceptance criteria met (an A5
  judge with the WRK-SPEC), final-review findings, rulings. Expected around
  $30–60 per arm; launched only after your human partner confirms.
- **Record.** One `FRAG-FORK-UPSTREAM-<NNN>` per measured batch with `raw/`
  as in the earlier fragments. DOC-FORK-TOKENS-001 and DOC-FORK-GATES-001
  are bumped at consolidation. The umbrella closes with a before/after table
  per batch in its WRK-PLAN's Execution Log.

## Knowledge Context

| Activated Spec | Role in this work |
|---|---|
| DOC-FORK-TOKENS-001@0.3.0 | level-1 measurement method and the before side |
| DOC-FORK-GATES-001@0.4.0 | level-2 A/B method; gates A1–A6 the batches must keep |
| DOC-FORK-LEDGER-001@0.1.0 | ledger forms the Native mode must write; its open inconsistencies order batch 3 after WRK-SPEC-FORK-MODS-002 |
| FRAG-FORK-GATES-003, -004, -005 | evidence, not activated: protocol, judge prompts, K prompt, reading rule, plan executability metric, reference figures |
| FRAG-FORK-TOKENS-003 | evidence, not activated: latest fixture cost per side |
| FRAG-FORK-LEDGER-001 | evidence, not activated: ledger line forms as written today |

All three activated documents are `draft`, `confidence: low`, without
`verified`; earlier WRK-SPECs activated them in the same state.

**Gaps (capture candidates at consolidation):**
- No spec records the fork's policy towards upstream (what is taken, how,
  with which measurement). Candidate: DOC-FORK-UPSTREAM-001.
- The toolkit's dependencies on the fork (the `next-id` parity test, the
  pending-consolidation criterion) are recorded only in toolkit specs.
  Candidate: a section in DOC-FORK-LEDGER-001 or a new document.
- No spec says which gates each execution mode carries. The *Batch 3 rules*
  above settle it for Native; DOC-FORK-GATES-001 should record it at
  consolidation.

## Constraints

- **WRK-SPEC-FORK-CORE-001, P10:** "KDD changes the *what* and the *with
  which context*; superpowers keeps the *how*. The voice ("your human
  partner"), red-flag tables, approval gates, TDD, subagent discipline and
  ledger stay intact. KDD replaces artifacts and adds activated context; it
  relaxes no existing discipline." Adapted rewrites are pressure-tested with
  writing-skills; the commit states the targeted and the observed behaviour.
- **WRK-SPEC-FORK-CORE-001, P5:** "A change that satisfies the plan but
  violates a rule of an activated spec is a blocking finding." *Batch 3
  rules* 1 is how Native keeps it before the next task.
- **WRK-SPEC-FORK-CORE-001, P13:** "No path contains `superpowers`." Upstream
  `.superpowers/…` paths become `.kdd/…`; `tests/scripts/test-invariants.sh`
  stays green.
- **WRK-SPEC-FORK-CORE-001, P3:** "Activation is decided once, with a human,
  and frozen." Nothing taken from upstream opens a path to implementation
  without an active WRK-SPEC or reopens `activates` downstream.
- **DOC-FORK-LEDGER-001, Completion:** "A finished task is a line starting
  `Task <task>: complete`, always followed by a parenthesised suffix …
  Readers match the prefix, never the whole line." Native writes `<task>` as
  the WRK-TASK ID.
- **DOC-FORK-LEDGER-001, Maintenance:** "Change a ledger form in the skills
  and in `kdd-status-lib.mjs` in the same commit;
  `tests/scripts/test-kdd-status.sh` holds the parsed forms." / "Resolving
  an inconsistency above is a WRK-SPEC of its own".
- **DOC-FORK-TOKENS-001, How to measure:** "**Before side:** a `git worktree`
  at the pre-change commit, with the current `test-kdd-flow.sh` copied in (so
  harness fixes do not confound the skills under test)." / "One run per side
  is not a before/after; repeat until the effect you claim exceeds the spread
  you see." / "**Discard, do not average:** runs lost to authentication or
  network errors are set aside and named in the fragment's Method, never
  counted." / "Run measurements one after another".
- **DOC-FORK-GATES-001, Maintenance:** "To judge design quality, not only
  claims about code, repeat the FRAG-FORK-GATES-003 method: pre-registered
  hard points, neutral summaries, and one blind pass over every arm's
  summaries together."
- **DOC-FORK-GATES-001, The gates:** A1–A6 as tabulated there. The builder
  check (batch 4) and Review Focus (batch 2) are added to them, never in
  place of one; an execution mode keeps every gate SDD gives a task that
  touches knowledge (*Batch 3 rules*).
- **Toolkit contracts** (observed in `../spec-driven`, origin/main, Code
  Premises 16–17; no activated spec records them — see *Gaps*):
  `skills/kdd-conventions/scripts/next-id` keeps its grammar and results;
  the session-start open-work and pending-consolidation criterion
  (`work-spec` + `completed`) stays as is.
- **Repository rules (`CLAUDE.md`, not an activated spec):**
  `test-skill-content.sh` is updated in the same commit as the prose it
  anchors; Claude Code is the only harness; English in the repository.

## Code Premises

Verified on 2026-10-18 by the premise verifier at `7dbf122` (branch
`feat/upstream-7-integration`) and re-verified by gate A1.

| Premise | Listed | Verified by | Result |
|---|---|---|---|
| 1. `requesting-code-review/SKILL.md:69` uses `awk '{print $1}'`; line 28 offers "origin/main", not `merge-base` | yes | `:69 BASE_SHA=$(git log --oneline \| grep "Task 1" \| head -1 \| awk '{print $1}')`; `:28 … # or origin/main, or the task's recorded BASE`; `grep -n merge-base` empty | holds |
| 2. `systematic-debugging/SKILL.md` prints the IDENTITY value | yes | `:91 echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"`, `:95 env \| grep IDENTITY \|\| …` | holds |
| 3. `brainstorming/scripts/server.cjs:238` uses a string replacement | yes | `:238 return renderBranding(frameTemplate).replace('<!-- CONTENT -->', content);` | holds |
| 4. TDD has no "the project's suite defines green" paragraph | yes | `grep -n -i "whole\|entire\|full test suite\|test suite"` empty | holds |
| 5. `review-package` has no ancestor or non-empty range guard | yes | `grep -n -i "merge-base\|is-ancestor\|empty"` empty; `:45` only counts commits after writing | holds |
| 6. `sdd-workspace` overwrites `.kdd/sdd/.gitignore` every run | yes | `:44 printf '*\n' > "$base/.gitignore"`, unconditional | holds |
| 7. `code-reviewer.md` has no "vision document" or "Declined to judge" | yes | `grep -n -i -w "vision\|declined"` → empty, rc=1 | holds |
| 8. `hooks/run-hook.cmd` is unchanged since 6.3.0 | yes | `git diff b36e082 HEAD -- hooks/run-hook.cmd \| wc -c` → `0` | holds |
| 9. `session-start` depends on `PATH` lookups and a broken `PATH` loses the injection | yes | `dirname` (:8), `cat` (:12, final `printf … \| cat`), probe uses `mktemp`, `awk`, `wc`, `tr`, `sort`, `rm`, `find`, `sed`; `env -i PATH= CLAUDE_PLUGIN_ROOT=$PWD /bin/bash hooks/session-start` → `rc=1`, 0 bytes on stdout | holds — nothing at all is emitted |
| 10. `transition` delegates to `spec-graph transition` without `--verify-only` | yes | options `--specs`, `--verified`, `--no-commit`, others exit 2; `--verify-only` absent; delegation when the CLI lists `transition`, builtin fallback otherwise | holds |
| 11. using-superpowers mentions neither `kdd:spec-ask` nor `kdd:spec-tui` | yes | `grep -n "spec-ask\|spec-tui"` empty | holds |
| 12. Dev docs and `test-kdd-flow.sh` point at `../knowledge-driven-development`, which does not exist; the toolkit checkout is `../spec-driven` | yes | `CLAUDE.md:31`, `docs/testing.md:4`, `tests/claude-code/README.md:159`, `test-kdd-flow.sh:4,24`; `ls -d ../knowledge-driven-development` → no such file; `git -C ../spec-driven remote -v` → `jmbruzos/knowledge-driven-development` | holds — the harness also loads `--plugin-dir "$KDD_TOOLKIT_DIR"` (`:52`) from that default |
| 13. executing-plans says to use SDD when subagents exist; it has no scripts and no review | yes | `executing-plans/SKILL.md:14`; `ls skills/executing-plans` → `SKILL.md`; `grep -n "A3\|A4\|A5\|adversar"` empty | holds — it uses SDD's `sdd-workspace` and `task-brief` (:21, :30) |
| 14. The WRK-TASK template carries a code body in Step 3, "No Placeholders" requires code blocks, no Review Focus | yes | `writing-plans/SKILL.md:152` Step 3 + fenced body, `:187` "(code blocks required for code steps)"; `artifact-templates.md:197,199` "(code block)"; `grep -rni "review focus" skills` empty | holds |
| 15. `test-kdd-flow.sh` has scenarios 1–7, scenario 5 runs SDD over WRK-PLAN-DEMO-HELLO-001, none runs executing-plans | yes | seven `=== Scenario` lines; `:128`; `grep -c executing-plans` → 0 | holds |
| 16. Toolkit 1.13 has a parity test against the fork's `next-id` | yes | `../spec-driven` `origin/main:apps/spec-graph/tests/tui-next-id.test.mjs:30-35,91`; tag `kdd--v1.13.0` exists | holds on origin/main and the tag — the `../spec-driven` working tree is on a feature branch at 1.11.0 without the file, so AC7 runs it in a worktree at the tag |
| 17. The toolkit TUI uses the session-start pending-consolidation criterion | yes | `origin/main:apps/spec-graph/tui/model/work.mjs:20,39`; `hooks/session-start:70-74` | holds |
| 18. Toolkit 1.13.0 validates `specs/` with 0 issues; no `kdd-repo.yaml` | yes | `Validation passed. No issues found.` (58 specs, 157 edges with the untracked drafts); `ls kdd-repo.yaml` → no such file | holds |
| 19. `kdd-status-lib.mjs` recognises completion by prefix | yes | `:32-33 l.startsWith(\`Task ${taskId}: complete\`)` | holds |
| 20. Tag `kdd-superpowers--v0.6.0` is an ancestor of `main` | yes | resolves to `acca006`; `git merge-base --is-ancestor` → ancestor | holds — `scripts/bump-version.sh` creates no tag; it was made by hand |
| 21. FRAG-FORK-GATES-003/-004/-005 used toolkit 1.6.0 on mdm-platform `aacdae5` | yes | 003 `report.md:13-14`, 004 `:14-16`, 005 `:23-25`; `git -C ../mdm-platform cat-file -t aacdae5` → commit | holds |
| 22. The fork has no `skills/using-superpowers/references/` | yes | `ls skills/using-superpowers` → `SKILL.md scripts`; `test-invariants.sh:32` fails if it exists | holds |

unlisted claims verified: 13 hold (two needed the author's own check:
`review-brief` at `skills/requesting-code-review/scripts/review-brief`, and
`test-invariants.sh:5` forbidding `.superpowers/`); two concern upstream and
the toolkit, settled by the author's diff of `b36e082..upstream/main` and of
toolkit 1.9.0..1.13.0.

## Acceptance Criteria

- [ ] AC1. Batches 1–4 each have a WRK-SPEC with
  `dependencies: [{id: WRK-SPEC-FORK-UPSTREAM-001, relation: constrained-by}]`
  — compact for batch 1, full for batches 2–4 — and each is `archived` when
  this spec closes.
- [ ] AC2. Every row of *Components* is resolved: each adopt / adapt / idea
  item is in the release of the batch its row names, or carries a `Ruling:`
  that drops it, in that batch's WRK-PLAN Execution Log (batch 1: in its
  WRK-SPEC). No discard item is tracked: `git ls-files` lists nothing under
  `.antigravity-plugin/`, `.muse-plugin/`, `.opencode/`, `.hermes-plugin/`,
  `.codex-plugin/`, `.cursor-plugin/`, `.kimi-plugin/`, `.devin-plugin/`,
  `docs/superpowers/`, `skills/using-superpowers/references/`, nor
  `AGENTS.md`, `index.js` or `gemini-extension.json`; `test-invariants.sh`
  green.
- [ ] AC3. Batches 2–4 each have a `FRAG-FORK-UPSTREAM-<NNN>` whose report
  gives the pre-registration commit's sha and time, every run's
  `result.json` start time (all later), and the toolkit version (1.13.0),
  Claude Code version and model of both arms.
- [ ] AC4. Each such FRAG states the reading-rule outcome per metric and
  whether the batch is "worse" as defined in *Error handling*; a worse
  batch, and any cost rise above 20 % with non-overlapping ranges, has a
  recorded human ruling.
- [ ] AC5. `tests/claude-code/test-kdd-flow.sh` has a scenario 8 that runs
  inline execution of scenario 5's plan, and batch 3's FRAG reports it for
  today's executing-plans (prompted to run inline), Native and SDD.
- [ ] AC6. Batch 1: `tests/hooks/test-session-start.sh` has a case that runs
  the hook with `env -i PATH=` and asserts (a) exit 0, (b) JSON carrying the
  using-superpowers content, (c) a `<KDD-ENVIRONMENT>` block that never
  reads `toolkit: NOT FOUND` unless `kdd-cli` actually ran and exited 3 —
  when the probe cannot run, its lines read `unavailable`, and
  using-superpowers' environment table says what to do with that value.
  `bash tests/scripts/run.sh`, `tests/hooks/test-session-start.sh`,
  `tests/claude-code/test-sdd-workspace.sh` and
  `(cd tests/brainstorm-server && npm test)` pass.
- [ ] AC7. Toolkit contracts hold after every batch:
  - the toolkit parity test, run in a `git worktree` of `../spec-driven` at
    tag `kdd--v1.13.0` (`cd <worktree>/apps/spec-graph && KDD_NEXT_ID=<repo>/skills/kdd-conventions/scripts/next-id node --test tests/tui-next-id.test.mjs`),
    passes with no skipped test;
  - the hook's `<KDD-ENVIRONMENT>` block, run with cwd
    `tests/scripts/fixtures` and with cwd at a temporary copy of that
    fixture holding one WRK-SPEC set to `completed`, is byte-identical to
    the 0.6.0 hook's output in the same two directories (the second shows
    `completed, pending consolidation`).
- [ ] AC8. Batch 3 implements *Batch 3 rules* 1–3, and its scenario-8 or
  level-2b transcripts show A4 dispatched for a task that meets its
  condition. WRK-SPEC-FORK-MODS-002 is `completed` or `archived` before
  batch 3's WRK-SPEC is approved.
- [ ] AC9. Releases 0.7.0 onward each have a `RELEASE-NOTES.md` entry and a
  `kdd-superpowers--v<version>` tag; `CLAUDE.md` and `README.md` carry the
  "selected changes through 7.0.0" wording; the umbrella WRK-PLAN's
  Execution Log ends with a before/after table per batch.
- [ ] AC10. Batch 5 has a recorded go / no-go from your human partner.
- [ ] AC11. At consolidation, DOC-FORK-TOKENS-001 and DOC-FORK-GATES-001 are
  bumped with the batch FRAGs as sources, and the three gaps in *Knowledge
  Context* are decided (captured or dropped, with the reason).

## Open Questions

1. **`new-task`.** Toolkit 1.12's `spec-graph new-task` writes a frozen
   WRK-SPEC from a manifest. If projects start using manifests, brainstorming
   and `new-task` become two paths to one artifact, which
   using-superpowers warns against. Out of scope here; revisit if a project
   asks for it.
2. **Batch 5.** Whether `diagnosing-superpowers` is worth adapting is decided
   when batch 4 closes (AC10).
3. **Level 2b's n=1.** One run per arm is indicative only; whether to buy a
   second pair is decided after the first, with its cost in hand.

## Adversarial Review

Gate A1, 2026-10-18 (most capable model): `23 attempted, 22 BROKEN
(code-reality 7 · spec-rule 2 · ambiguity 7 · knowledge-gap 3 · internal 3)`.
Rulings adjudicated with your human partner one by one; D1–D3 are their
decisions.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 · Native drops per-task A3/A4 | spec-rule | `adversarial-gates.md:9-10`; upstream "no reviewer per task" | accepted, reframed: today's executing-plans has no gate at all, so Native relaxes nothing against it, but it would against SDD. D1.2: A4 per task when its condition holds (*Batch 3 rules* 2); A3/A5 in the final review (rule 3) |
| 1 · Native drops the stop on an activated-rule conflict | spec-rule | `executing-plans/SKILL.md:52`; P5 | accepted, reframed: the loss is that the inline agent rules alone and the independent check comes only at the end. D1.1: rule and continue, but a knowledge ruling on an activated rule triggers an immediate per-task knowledge-compliance review (rule 1) |
| 2 · AC6 empty-PATH: two readings | ambiguity | `session-start:20-21`; using-superpowers `:44` | accepted: AC6 (c) — never `NOT FOUND` unless kdd-cli ran; `unavailable` otherwise, with its row in using-superpowers |
| 2 · "worse" undefined | ambiguity | FRAG-005 prereg:56-59 | accepted: defined under *Error handling* |
| 2 · AC7 fixture directory | ambiguity | hook output differs in `tests/scripts` vs `tests/scripts/fixtures` | accepted: cwd `tests/scripts/fixtures` |
| 3 · AC7 does not cover `completed` | ambiguity | fixture has 4 × `status: active` | accepted: second directory with a `completed` WRK-SPEC |
| 3 · AC3 `git log` cannot order runs | ambiguity | runs leave no commit here | accepted: pre-registration sha/time vs `result.json` start times |
| 3 · batch 2 judged on design points | ambiguity | FRAG-003 prereg:52-55 | accepted: batch 2 decides on plan executability and the evidence judge over the plan; H1–H10 reported only |
| 4 · Native ledger order and identity | knowledge-gap | DOC-FORK-LEDGER-001 inconsistencies 1–2; WRK-SPEC-FORK-MODS-002 | accepted: D2 — MODS-002 closes before batch 3 (*Data flow*, AC8) |
| 5 · `references/` forbidden by test-invariants | code-reality | `test-invariants.sh:32,35` | accepted: D3 — the orchestrator moves to batch 3 as `skills/subagent-driven-development/claude-code-orchestrator.md`; `references/` added to the discard row |
| 5 · AC7 toolkit test absent from the checkout | code-reality | `../spec-driven` on a feature branch at 1.11.0 | accepted: run in a worktree at tag `kdd--v1.13.0` |
| 5 · arms do not pin the `kdd:*` skills | code-reality | `test-kdd-flow.sh:24,52` | accepted: `KDD_TOOLKIT_DIR` fixed to the 1.13.0 plugin; batch 1 fixes the default |
| 6 · scenario 8 and level 2b vs "existing scenarios" | internal | Problem Statement | accepted: Problem Statement names both extensions as approved |
| 6 · batch 1 carries unmeasured routing and orchestrator prose | internal | Problem Statement "on belief" | accepted: D3 — orchestrator → batch 3, spec-ask/spec-tui row → batch 4 with a routing check; TDD and code-reviewer additions stay in batch 1 with the (†) justification |
| + 3 · scenario 8's today-arm defers to SDD | ambiguity | `executing-plans/SKILL.md:14` | accepted: that arm is prompted to run inline |
| + 5 · premise 7 evidence matches "revision" | code-reality | `code-reviewer.md:43` | accepted: evidence now `grep -w` (empty); the premise holds |
| + 5 · reading rule incomplete | internal | FRAG-005 prereg:56-57 | accepted: "in the same pass" and H1 separately added |
| + 5 · AC2 `git grep docs/superpowers` fails on committed specs | code-reality | `git grep -l docs/superpowers` | accepted: AC2 checks tracked paths with `git ls-files` |
| + 5 · test-invariants misses new upstream assets | code-reality | `test-invariants.sh:29-33` | accepted: batch 1 adds `.antigravity-plugin`, `.muse-plugin`, `index.js` |
| + 5 · no tag for the before arm | code-reality | `bump-version.sh` creates no tag | accepted: every release tags `kdd-superpowers--v<version>` (*Data flow*, AC9) |
| + 4 · Native completion line: number or WRK-TASK ID | knowledge-gap | DOC-FORK-LEDGER-001 inconsistency 3 | accepted: WRK-TASK ID (*Constraints*, ledger) |
| + 4 · level 2 prompt and mdm validity under 1.13.0 | knowledge-gap | FRAG-004 report:15-19 | accepted: K prompt verbatim with the wait sentence; validate pre-flight in the pre-registration |
