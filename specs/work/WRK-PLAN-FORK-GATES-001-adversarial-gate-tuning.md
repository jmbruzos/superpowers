---
id: WRK-PLAN-FORK-GATES-001
type: spec
layer: work-plan
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "Adversarial gates A1/A2 tuning — implementation plan"
parent: WRK-SPEC-FORK-GATES-001
activates:
  - DOC-FORK-TOKENS-001@0.1.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-GATES-001
    relation: implements
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: WRK-SPEC-FORK-GATES-001
    resource: specs/work/WRK-SPEC-FORK-GATES-001-adversarial-gate-tuning.md
  - id: DOC-FORK-TOKENS-001
    resource: specs/documentation/DOC-FORK-TOKENS-001-flow-token-footprint.md
  - id: FRAG-FORK-GATES-001
    resource: specs/_capture/FRAG-FORK-GATES-001-adversarial-gate-audit-mdm/
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-28T11:14:33+02:00
stale_after: 2026-12-27T11:14:33+01:00
tags: [fork, gates, plan]
---

# WRK-PLAN-FORK-GATES-001 — Adversarial gates A1/A2 tuning

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** Make brainstorming and writing-plans check their code premises, run gate A1 on the written and self-reviewed WRK-SPEC, and give A1/A2 a Cause column, a detail cap that drops nothing, and a persisted BROKEN table — then prove it headless and measure its cost.

**Architecture:** The shared contract changes first (`adversarial-gates.md` addendum for design gates, templates), then each consumer in dependency order: the A1 prompt, the brainstorming order, the Code premises step and its verifier prompt, writing-plans and the A2 prompt. A new headless scenario exercises the architectural path end to end; a last task measures before/after and releases 0.3.0. Every prose change is test-first: the `test-skill-content.sh` anchor is added red, then the prose makes it green.

**Tech Stack:** Markdown skills and prompt templates; bash tests (`tests/scripts/lib.sh` `pass`/`fail`, `must_contain`/`must_not_contain`); headless Claude Code (`tests/claude-code/test-kdd-flow.sh`); kdd toolkit 1.6.0 (`spec-graph`).

**Spec:** `specs/work/WRK-SPEC-FORK-GATES-001-adversarial-gate-tuning.md` — the plan argues from the spec, so executors read both.

**Baseline commit:** `f8d369c` (spec approved; no skill changed yet). Task 007 measures "before" from a worktree at this commit.

**Toolkit for every test run:** `export KDD_SPEC_GRAPH=$HOME/.claude/plugins/cache/kdd/kdd/1.6.0/cli/spec-graph.mjs` and, for headless runs, `export KDD_TOOLKIT_DIR=$HOME/.claude/plugins/cache/kdd/kdd/1.6.0`.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-GATES-001-001 | Baseline; design-gate addendum in `adversarial-gates.md`; `## Code Premises` and BROKEN-table placeholders in the templates | — |
| WRK-TASK-FORK-GATES-001-002 | A1 prompt: written spec as input, Code Premises in attack 5, Cause column, detail cap, closing line | 001 |
| WRK-TASK-FORK-GATES-001-003 | brainstorming order: WRK-SPEC → self-review → A1 → commit; re-run rule; no draft file | 002 |
| WRK-TASK-FORK-GATES-001-004 | Code premises: `premise-verifier-prompt.md`, design section, Red Flags row, WRK-SPEC body order | 003 |
| WRK-TASK-FORK-GATES-001-005 | writing-plans and A2: Code Premises read, `**Premises:**` line, attack 7, Cause column, detail cap, persisted table | 001 |
| WRK-TASK-FORK-GATES-001-006 | Headless scenario 7: architectural brainstorming with code and specs; transcript and artifact assertions | 002, 003, 004 |
| WRK-TASK-FORK-GATES-001-007 | Before/after measurement → FRAG-FORK-TOKENS-002; release 0.3.0 | 005, 006 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "KDD changes the *what* and the *with which context*; superpowers keeps the *how*. The voice ("your human partner"), red-flag tables, approval gates, TDD, subagent discipline and ledger stay intact. KDD replaces artifacts and adds activated context; it relaxes no existing discipline. Skill language: English." | WRK-SPEC-FORK-CORE-001 P10 | Every edit adds rows, bullets or sentences, or changes order/references; no existing Red Flags row, rationalization row or approval gate is removed or reworded. The detail cap lists every BROKEN finding. Reviewers diff each skill for removed lines. |
| "No path contains `superpowers`. Artifacts live in `specs/`; runtime state lives in `.kdd/` (gitignored)" | WRK-SPEC-FORK-CORE-001 P13 | New files: `skills/brainstorming/premise-verifier-prompt.md`, `specs/_capture/FRAG-FORK-TOKENS-002-*`. Measurement scratch goes to the session scratchpad or `.kdd/`, never a `superpowers` path. |
| "Output tokens are the expensive line. writing-plans emits 40-60k output tokens: plan, tasks with full code blocks, the A2 attack table, and rewrites after adjudication." | DOC-FORK-TOKENS-001 §Content item 4 | Detail cap (3 full rows per attack, the rest as one-liners) in the A1 and A2 prompts. |
| "Subagent seats and their turns. Each seat starts a fresh 15-24k context (cache write)." | DOC-FORK-TOKENS-001 §Content item 5 | One premise-verifier seat per brainstorming, mid tier; none in greenfield. |
| "One run per side is not a before/after; repeat until the effect you claim exceeds the spread you see." | DOC-FORK-TOKENS-001 §How to measure | Task 007: ≥ 2 runs per side for scenario 4, spread reported. |
| "Re-measure after any change to a workflow skill, a prompt template, the hook, or a Claude Code major release; append the run to a new FRAG that `supersedes` FRAG-FORK-TOKENS-001 and bump this document." | DOC-FORK-TOKENS-001 §Maintenance | Task 007 writes FRAG-FORK-TOKENS-002 (`supersedes` FRAG-FORK-TOKENS-001); DOC bump happens at consolidation (finishing), not in this plan. |
| "The controller adjudicates every `BROKEN` row and ledgers it" | adversarial-gates.md (current contract) | Unchanged; the addendum extends it to one-liners. |
| "`tests/scripts/test-skill-content.sh` asserts the anchors prompts and scripts depend on; when you change a skill, keep it green or update it in the same commit." | CLAUDE.md (repository instruction) | Each task adds its anchors and the prose in the same commit. |
| Suite is not green at baseline: `test-invariants.sh` (untracked `docs/superpowers/`) and `test-transition.sh` (9 assertions, kdd 1.6.0) | WRK-SPEC-FORK-GATES-001 Code Premises | Task 001 records the baseline; every task's check is "no new failures", not "all green". Do not touch `docs/superpowers/` or `transition`. |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| No `timeout`/`gtimeout` on this machine: every headless run fails before starting | Certain | High | Task 006 Step 1 adds a portable `TIMEOUT_CMD` (timeout → gtimeout → `perl -e 'alarm shift; exec @ARGV'`, verified: rc=142 after 2 s); task 007 copies that harness into the "before" worktree. |
| Headless scenario 7 exceeds the 900 s default timeout (architectural path, two subagent seats) | High | Medium | Run it with `CLAUDE_PROMPT_TIMEOUT=2700`; the timeout is an env var already. |
| The headless session asks questions or stops before A1 despite the prompt | Medium | Medium | Prompt pre-approves every section and delegates adjudication; if it still stops, record the transcript and rule in the ledger — the assertions stay as specified. |
| `supersedes` on a fragment rejected by `spec-graph validate` | Low | Low | Task 007 validates before committing; if rejected, record the relation in `sources` and prose instead and ledger a `Knowledge gap:`. |
| Measurement cost (≈ $3 per scenario-4 run, 4 runs, plus scenario 7) | Certain | Low | Accepted by the spec (AC9); runs limited to `KDD_FLOW_SCENARIOS`. |
| Rewording tuned prose while moving the A1 step | Medium | Medium | Task 003 gives the exact old and new text; reviewer diffs for removed sentences. |

## Dependencies

- kdd toolkit 1.6.0 installed at `~/.claude/plugins/cache/kdd/kdd/1.6.0` (CLI and plugin root).
- `claude` on PATH, credentials in `~/.claude/.credentials.json` (tasks 006, 007).

---

## Adversarial Review

Gate A2 (triggered: 7 tasks; the spec activates DOC-FORK-TOKENS-001, `confidence: low`, unverified), run in the design-gate form this plan introduces. `16 attempted, 11 BROKEN (code-reality 3 · spec-rule 1 · ambiguity 4 · knowledge-gap 0 · internal 3)`.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 Task 003's *Gate A1* prose still says "Adjudicate every `BROKEN` row", so one-liners past the cap could go unadjudicated | spec-rule | WRK-TASK-003 Step 6; WRK-TASK-005 Step 5; spec §3; P10 | accepted → prose says "every `BROKEN` finding — full rows and one-liners"; anchor added |
| 2 Task 007 compares three suites to a baseline task 001 never persisted | internal | WRK-TASK-001 Step 1; WRK-TASK-007 Step 6 | accepted → task 001 writes four `.kdd/baseline-*.txt` files (listed under Produces); task 007 diffs against them |
| 3 Scenario 7 cannot tell the old order from the new: no write-before-A1 check, assertions read the working tree | ambiguity | spec AC8; WRK-TASK-006 Step 2 | accepted → transcript order check (WRK-SPEC write line < A1 dispatch line); assertions read `git show HEAD:`; working tree must equal the commit |
| 5 Task 002 Step 2 expects 7 FAIL lines; 8 fail | ambiguity | WRK-TASK-002 Step 1–2 | accepted → 8 |
| 7 `.kdd/` does not exist; `> .kdd/baseline-run.txt` fails and every later diff breaks | code-reality | `ls -a .kdd` → No such file; WRK-TASK-001 Step 1 | accepted → `mkdir -p .kdd`; premise recorded in task 001 |
| 7 No `timeout`/`gtimeout` on this machine; every headless run fails | code-reality | `test-kdd-flow.sh:47`, `:62`; `command -v timeout gtimeout` → nothing | accepted → task 006 adds a portable `TIMEOUT_CMD` with a perl fallback (verified rc=142 after 2 s); task 007 copies the harness into the "before" worktree; risk row added |
| 2 (one-liner) Task 002's `internal` definition differs from the addendum's | internal | WRK-TASK-002 prompt vs WRK-TASK-001 addendum | accepted → A1 prompt uses the addendum's definition |
| 3 (one-liner) AC literals `[WRK_SPEC_PATH]` and "at most 3 full rows per attack" not matched by the anchors | ambiguity | spec §4, AC3; WRK-TASK-002 | accepted for `[WRK_SPEC_PATH]` (prompt and anchor now carry it literally); rejected for the case of "At most" — the spec quotes the phrase mid-sentence, the prompts start a sentence with it; same rule |
| 5 (one-liner) `dot` routes every "changes requested" through A1 while the re-run rule says only substantive changes | ambiguity | WRK-TASK-003 Step 5 vs Step 6 | accepted → two edges: substantive changes → write → self-review → A1; wording changes → self-review → user review |
| 5 (one-liner) In a fresh worktree `test-invariants.sh` passes (no untracked `docs/superpowers/`), so "Expected" misdescribes the baseline | code-reality | WRK-TASK-001 Step 1; WRK-TASK-004 Step 8 | accepted → Expected is "whatever the baseline recorded"; both locations reworded |
| 7 (one-liner) Task 007 Premises cite "Step 5" for validation; it is Step 4 | internal | WRK-TASK-007 | accepted → Step 4 |

## Execution Log

Harvested from the SDD ledger (.kdd/sdd/WRK-PLAN-FORK-GATES-001/progress.md) at finishing. Branch feat/fork-gates, 4942275..ca7e402.

### Rulings
- Ruling: the baseline is the one task 001 records inside this worktree (the untracked docs/superpowers/ is absent here, so test-invariants may pass) — the plan's A2 ruling already makes "Expected" = recorded baseline — costs nothing if wrong.
- Task WRK-TASK-FORK-GATES-001-003: Ruling: plan-mandated finding 'no standing automated guard for P10 in brainstorming/SKILL.md' — out of this spec's scope (AC6 is checked by removed-lines review per task, done: 19/19 deletions mapped); forwarded to the final review as a candidate follow-up — costs a later accidental deletion going unnoticed if wrong
- Ruling: task 006 Step 4 (real headless run, up to 45 min) is run by the controller in the background after the implementer commits Steps 1-3; a failing assertion goes back to the implementer with the log — why: a subagent's foreground Bash is capped at 10 min — costs one extra round-trip if the run fails
- Task WRK-TASK-FORK-GATES-001-006: Ruling: plan-mandated finding — substring '*"0 error"*' matches '10 errors' — fix in scenario 7 (new code); leave scenarios 2 and 4 (pre-existing, out of scope) and forward to final review — costs a false pass in 2/4 if wrong
- Ruling: task 007's headless runs are started by the controller in the background (same reason as 006 Step 4); scenario 7 run 2 and before-s4 run 1 overlap in time — tokens and cost are unaffected, durations may be inflated; report says so — costs a noisier duration column
- Ruling: final fix wave = Important 1 + Minor 1 (scenarios 2/4 validate check) + Minor 2 (dot wording edge label) + credentials doc (CLAUDE_CODE_OAUTH_TOKEN in test-kdd-flow.sh header and CLAUDE.md Testing); parked: Minor 3 (no-commit-before-A1 assertion), Minor 4 (looser verifier match; order check covers checklist only) — real, deferred, nothing builds on them; standing P10 guard → follow-up; commit hygiene → merge message — costs a weaker scenario 7 until a follow-up if wrong

### Knowledge gaps
- Task WRK-TASK-FORK-GATES-001-006: Step 4 blocked — headless claude 'Not logged in': ~/.claude/.credentials.json absent (existed at FRAG-FORK-TOKENS-001 time); Keychain read denied by permission classifier; asked human partner to provide credentials (credentials file, CLAUDE_CODE_OAUTH_TOKEN or ANTHROPIC_API_KEY). Knowledge gap: test harness premise 'credentials file exists' was unverified in the plan

### Attacks broken and adjudicated
- Gate A1 (WRK-SPEC-FORK-GATES-001, `## Adversarial Review`): 16 attempted, 15 BROKEN; all accepted (row 2 by human ruling, option A).
  | 1 AC9 records usage in commit/notes, dropping DOC's "new FRAG that supersedes … and bump this document" | spec-rule | DOC-FORK-TOKENS-001:101-103 | accepted → Constraint quoted in full; measurement goes to a superseding FRAG; DOC bumped at consolidation (§4, AC9) |
  | 1 A hard 3-row cap leaves real BROKEN findings unadjudicated (SI: ~18 of 36) — relaxes a discipline | spec-rule | P10; adversarial-gates.md:28; FRAG report SI 42/36 | accepted, human ruling (option A) → detail cap: 3 full rows, every further BROKEN as a one-liner, all adjudicated (§3, AC6) |
  | 2 Row cap's scope unnamed: A1/A2 prompts only, or the generic template (capping A4/A6) | ambiguity | adversarial-gates.md:52, :62-63 | accepted → §3 applies to A1/A2 only, as an addendum; generic template unchanged; A3–A6 byte-identical (AC5) |
  | 2 Attack 5 must re-verify every premise but is capped at 3 rows | internal | spec :103-104 vs :144-145 | accepted → rows only for failing/unlisted premises; holds summarized in one line (§1, AC3) |
  | 2 *Gate A1* prose states the old order; line 54, the prompt header and the gates table also do and were not listed | internal | brainstorming/SKILL.md:54, :228-237; spec-adversary-prompt.md:3-4; adversarial-gates.md:8 | accepted → every location listed in §2; order and references change, other prose kept (AC1) |
  | 3 AC8 passes on SKIP or with an empty header and no A1 dispatch | ambiguity | test-kdd-flow.sh:22, :30 | accepted → run against an installed CLI, SKIP does not count; transcript assertions on both dispatches and a parsed closing line (AC8) |
  | 3 AC2 met by a heading and a sentence | ambiguity | test-skill-content.sh:7-8 (`grep -qF`) | accepted → dedicated prompt file with its contract, anchored, and its dispatch asserted headless (AC2, AC8) |
  | 3 AC9 met by one run per side; the new scenario has no "before" | spec-rule | DOC-FORK-TOKENS-001:96-97 | accepted → ≥ 2 runs per side for writing-plans, spread recorded; architectural scenario after-only, stated (AC9) |
  | 4 Premise verifier has no prompt file, tier, input contract or "cannot verify" outcome | knowledge-gap | spec :86-88, :84; adversarial-gates.md:34 | accepted → `premise-verifier-prompt.md`, mid tier, read-only; `unverifiable` treated as `false` (§1, AC2) |
  | 4 Cause values named but undefined; FRAG baseline had a sixth bucket | knowledge-gap | FRAG report.md:35-40; writing-plans/SKILL.md:112 | accepted → definitions as in the FRAG, tie-break by list order, out-of-set activation is `internal`, rejection lives in Ruling (§3, AC5) |
  | 4 User-review edits to AC/Constraints never re-attacked | knowledge-gap | spec :132-134; spec-adversary-prompt.md:25-26 | accepted → A1 re-runs when Proposed Change, Constraints, AC or Code Premises change beyond wording (§2, AC1) |
  | 5 Premise 6 ("A1 draft already carries Constraints and AC") unsupported: no pre-A1 revision exists | code-reality | FRAG report.md:18-20; brainstorming/SKILL.md:210, :228-229 | accepted → premise removed; FRAG section retitled before its first commit; Problem Statement reworded |
  | 5 "46 % (27 of 59)" treats 59 one-liners as 66 BROKEN rows | internal | FRAG report.md:29-31, :44, :47 | accepted → stated as 27 of 59 recorded one-liners, with the condensation noted (Problem Statement; FRAG table) |
  | 5 Unlisted premise: suite green today — it is not | code-reality | `run.sh` → test-invariants FAILED (untracked `docs/superpowers/`), test-transition FAILED (9) | accepted → listed as a false premise; baseline recorded; AC7 measures "no new failures" |
  | 6 "noted as a capture candidate" adds a channel brainstorming has no ledger for | internal | spec :92-94; finishing SKILL.md:85, :104 | accepted → sentence removed |
- Gate A2 (this plan, `## Adversarial Review`): 16 attempted, 11 BROKEN; 10 accepted, 1 half-rejected (case of "At most").
  | 1 Task 003's *Gate A1* prose still says "Adjudicate every `BROKEN` row", so one-liners past the cap could go unadjudicated | spec-rule | WRK-TASK-003 Step 6; WRK-TASK-005 Step 5; spec §3; P10 | accepted → prose says "every `BROKEN` finding — full rows and one-liners"; anchor added |
  | 2 Task 007 compares three suites to a baseline task 001 never persisted | internal | WRK-TASK-001 Step 1; WRK-TASK-007 Step 6 | accepted → task 001 writes four `.kdd/baseline-*.txt` files (listed under Produces); task 007 diffs against them |
  | 3 Scenario 7 cannot tell the old order from the new: no write-before-A1 check, assertions read the working tree | ambiguity | spec AC8; WRK-TASK-006 Step 2 | accepted → transcript order check (WRK-SPEC write line < A1 dispatch line); assertions read `git show HEAD:`; working tree must equal the commit |
  | 5 Task 002 Step 2 expects 7 FAIL lines; 8 fail | ambiguity | WRK-TASK-002 Step 1–2 | accepted → 8 |
  | 7 `.kdd/` does not exist; `> .kdd/baseline-run.txt` fails and every later diff breaks | code-reality | `ls -a .kdd` → No such file; WRK-TASK-001 Step 1 | accepted → `mkdir -p .kdd`; premise recorded in task 001 |
  | 7 No `timeout`/`gtimeout` on this machine; every headless run fails | code-reality | `test-kdd-flow.sh:47`, `:62`; `command -v timeout gtimeout` → nothing | accepted → task 006 adds a portable `TIMEOUT_CMD` with a perl fallback (verified rc=142 after 2 s); task 007 copies the harness into the "before" worktree; risk row added |
  | 2 (one-liner) Task 002's `internal` definition differs from the addendum's | internal | WRK-TASK-002 prompt vs WRK-TASK-001 addendum | accepted → A1 prompt uses the addendum's definition |
  | 3 (one-liner) AC literals `[WRK_SPEC_PATH]` and "at most 3 full rows per attack" not matched by the anchors | ambiguity | spec §4, AC3; WRK-TASK-002 | accepted for `[WRK_SPEC_PATH]` (prompt and anchor now carry it literally); rejected for the case of "At most" — the spec quotes the phrase mid-sentence, the prompts start a sentence with it; same rule |
  | 5 (one-liner) `dot` routes every "changes requested" through A1 while the re-run rule says only substantive changes | ambiguity | WRK-TASK-003 Step 5 vs Step 6 | accepted → two edges: substantive changes → write → self-review → A1; wording changes → self-review → user review |
  | 5 (one-liner) In a fresh worktree `test-invariants.sh` passes (no untracked `docs/superpowers/`), so "Expected" misdescribes the baseline | code-reality | WRK-TASK-001 Step 1; WRK-TASK-004 Step 8 | accepted → Expected is "whatever the baseline recorded"; both locations reworded |
  | 7 (one-liner) Task 007 Premises cite "Step 5" for validation; it is Step 4 | internal | WRK-TASK-007 | accepted → Step 4 |
- Gate A5 (final review): AC1–AC10 all RESISTED; Important 1 (FRAG-FORK-TOKENS-002 Inferred turn claim contradicted its data) fixed in b062345.

### Capture candidates (pending)
- none (no review reported one)

### Parked / deferred
- Task WRK-TASK-FORK-GATES-001-001: minor (deferred): report's Knowledge notes section is boilerplate
- Task WRK-TASK-FORK-GATES-001-003: minor (deferred): report attributed 37/19 to SKILL.md alone (26/19 + 11/0)
- Task WRK-TASK-FORK-GATES-001-006: minor (deferred): scenario project dirs ($p*) never removed — pre-existing convention across all scenarios
- Task WRK-TASK-FORK-GATES-001-007: minor (deferred): FRAG-FORK-TOKENS-002 report.md Inferred says turn shift '4-8', data gives 3-8 (fix would recompute integrity; fragment not yet merged) — fixed in b062345 as part of final-review Important 1
- Final review Minor 3: scenario 7 has no assertion that no `spec(` commit precedes the A1 dispatch — deferred (follow-up).
- Final review Minor 4: the verifier check also accepts the template prompt text; the test-skill-content order check covers the checklist only, not the dot flow — deferred.
- Final review Minor 5: Co-Authored-By inside the subject of 2ac209a, 17eac82, 02dbd73; skill commits do not state observed behaviour — addressed in the merge/PR message.
- Follow-up: a standing automated P10 guard (Red Flags / rationalization rows / approval gates) in test-skill-content.

### Execution notes
- Task WRK-TASK-FORK-GATES-001-003: fix round 1/5 (1 addressed, 0 open — report claimed run.sh unrunnable; now carries the command and empty diff; no code change, no diff to re-review — controller verified the report section at :139-147)
- Task WRK-TASK-FORK-GATES-001-006: Step 4 blocked — headless claude 'Not logged in': ~/.claude/.credentials.json absent (existed at FRAG-FORK-TOKENS-001 time); Keychain read denied by permission classifier; asked human partner to provide credentials (credentials file, CLAUDE_CODE_OAUTH_TOKEN or ANTHROPIC_API_KEY). Knowledge gap: test harness premise 'credentials file exists' was unverified in the plan
- Task WRK-TASK-FORK-GATES-001-006: fix round 1/5 (1 addressed, 0 open — scenario 7 validate check anchored on 'Validation passed'; commits a1df171..94773a1). Code review clean; completion waits on Step 4 (live run) — blocked on credentials
- Task WRK-TASK-FORK-GATES-001-006: live run 1 (after credentials via CLAUDE_CODE_OAUTH_TOKEN): 11/12 PASS, 839s, $1.87; FAIL 'premise verifier dispatched' is an assertion defect — verifier dispatched with a paraphrased description ('Verify code premises for billing statement module', sonnet, template prompt). A1 closing line: 17 attempted, 15 BROKEN (code-reality 3 · spec-rule 0 · ambiguity 6 · knowledge-gap 3 · internal 3). Fix round 2 sent
- Task WRK-TASK-FORK-GATES-001-006: fix round 2/5 (1 addressed, 0 open — premise-verifier check recognises the template prompt; commits 94773a1..37d36e1); live run 2 in progress
- Runs invalid (not counted): scenario 7 run 2 and before-s4 run 1 — 'API Error: Can't reach the API server (ENOTFOUND)' mid-run (transient DNS); set aside as .kdd/usage/failed-net-*; rerunning sequentially
- Task WRK-TASK-FORK-GATES-001-006: live run 3: 12/12 PASS, 495s, $1.55; A1: 13 attempted, 12 BROKEN (code-reality 3 · spec-rule 1 · ambiguity 2 · knowledge-gap 3 · internal 3); log .kdd/usage/after-s7.log
- Task WRK-TASK-FORK-GATES-001-006: complete (commits 0ef0de9..37d36e1, review clean after 2 fix rounds)
- Task WRK-TASK-FORK-GATES-001-007: s4 runs — before: $2.01/61.1k out, $2.06/68.4k; after: $1.92/55.9k, $2.28/64.8k — difference inside spread → third pair per task Step 2
- Task WRK-TASK-FORK-GATES-001-007: third pair — before $1.53/44.9k, after $2.17/65.3k. A2 closing lines: before 13/10, 10/8, 10/6; after 13/9 (cr1 sr2 amb2 kg3 int1), 12/7 (cr0 sr1 amb3 kg3 int0), 13/7 (cr1 sr1 amb3 kg2 int0). Before-worktree removed (--force: it carried the copied harness)
- Final review: With fixes — Important 1 (FRAG-FORK-TOKENS-002 Inferred contradicts its turn data); Minor 1-6; AC1-AC10 RESISTED
- Final fix wave: 4/4 addressed (commit b062345), scoped re-review clean, no new breakage
