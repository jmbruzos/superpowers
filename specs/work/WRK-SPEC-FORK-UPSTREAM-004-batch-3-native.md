---
id: WRK-SPEC-FORK-UPSTREAM-004
type: spec
layer: work-spec
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Upstream sync batch 3 — Native execution: executing-plans as a real inline mode over WRK-TASKs that keeps every SDD gate before a task completes, with task-start / task-done, a handoff that recommends a mode per plan, SDD's when-to-use and the opt-in nested orchestrator"
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-LEDGER-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-18T12:18:42+02:00
activation_pins:
  - source: self@7e206c9f29f1
    integrity: sha256:296f244d610cf2d40a53425388ef5d9045c94bc87920ff40d765c35c2ddd86d4
dependencies:
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-LEDGER-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
  - id: WRK-SPEC-FORK-UPSTREAM-003
    relation: depends-on
sources:
  - id: FRAG-FORK-LEDGER-001
    resource: specs/_capture/FRAG-FORK-LEDGER-001-sdd-ledger-line-forms/
    title: Ledger line forms the skills write and kdd-status parses
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T12:18:42+02:00
stale_after: 2027-01-16T12:18:42+02:00
tags: [kdd, fork, upstream, executing-plans, native, sdd, ledger, measurement]
---

# WRK-SPEC-FORK-UPSTREAM-004 — Upstream sync batch 3: Native execution

## Problem Statement

The fork has one execution mode that keeps its gates — subagent-driven
development — and one that keeps none. Today's `executing-plans` is the
6.3.0 stub adapted to KDD: it has no final review and no A3/A4/A5
(`grep -nEi "A3|A4|A5|final review" skills/executing-plans/SKILL.md` →
nothing), and it tells the agent to use SDD whenever subagents exist
(`:14`), so on Claude Code it is never chosen. Upstream 6.4.1 reports that
stub "measured the same as running with no plugin at all" and rebuilt it as
Native execution: the session implements every task itself under SDD's
workspace and ledger, `task-start` / `task-done` keep the ledger honest, and
one fresh whole-branch review runs at the end — "the cheapest way to run a
plan" (v6.4.1 release notes, #2318). Upstream changed SDD's when-to-use to
match and added an opt-in nested orchestrator for SDD on Claude Code.

DOC-FORK-UPSTREAM-001 §2 lists all three under batch 3 ("executing-plans
inline mode …; SDD's *when to use*; handoff offers Subagent-driven / Native;
the opt-in nested SDD orchestrator") and §3.4 sets the bar: "An execution
mode keeps every gate SDD gives a task, before the task is marked complete."
Batch 2 held back the handoff's per-plan recommendation until such a mode
exists (WRK-SPEC-FORK-UPSTREAM-003 component 7).

## Proposed Change

### Architecture

Approach A of three (B: keep the stub and add a final review only — leaves a
mode without A4 or knowledge checks; C: drop executing-plans and keep SDD
only — loses the cheapest mode §2 lists). Rebuild `skills/executing-plans`
from upstream's Native skill (`git show v6.4.1:skills/executing-plans/SKILL.md`;
its scripts from `upstream/main`, which fixed `task-done` for silent
commands), adapted to WRK-TASK files and to §3.4/§3.5; add the scripts and
one prompt beside it; update SDD's when-to-use, its ledger identity rule and
its handling of `review-package` exit 3; update writing-plans' handoff; add
the opt-in nested orchestrator. Claude Code only (§3.8): no path without a
subagent tool.

### Components

1. **`skills/executing-plans/SKILL.md`** — upstream's Native text (*Rulings,
   not stalls*, *When to Use*, *Setup*, *The Task Loop*, *The completion
   contract*, *Final Review*, *Finish*, *Common Rationalizations*), with
   these adaptations and no other rewording:
   - a plan is a WRK-PLAN, a task a WRK-TASK file; the brief is the fork's
     `task-brief TASK_FILE`; workspace and ledger are SDD's
     (`.kdd/sdd/<WRK-PLAN-ID>/progress.md`);
   - *When to Use* drops upstream's "no subagent tool" bullet and its pointer
     to `../using-superpowers/references/` (Claude Code only; the directory is
     forbidden);
   - *Setup*: a task is done when its frontmatter says `completed` — the
     resume signal both modes and `kdd-status` share; `task-done` appends a
     missing completion line for such a task;
   - a ruling that touches knowledge is also tagged `Knowledge gap:`; the
     activation stays frozen (P3);
   - **gates before completion** (§3.4), after the task's steps and before
     `task-done`:
     - (a) **A4** when the task's `activates` names a `CALC-*` spec or a spec
       with numeric/business rules, or the task is security-sensitive
       (A4's condition, judged on the task's frontmatter and Architecture
       Impact rows): dispatch `../subagent-driven-development/test-adversary-prompt.md`
       (mid tier) with the task's brief, test files and diff; each BROKEN row
       is fixed by TDD (a test that fails, then passes), then A4 is
       dispatched once more on the fixed tests; a row still BROKEN is parked
       with a ruling. Every row is ledgered `Attack: … — Ruling: …`, as in SDD;
     - (b) a `Ruling:` tagged `Knowledge gap:` about an activated rule
       dispatches **`knowledge-check-prompt.md`** (component 4, mid tier) on
       that task's range; a violation it reports is blocking and fixed in the
       task;
     - (c) the final whole-branch review on the most capable model with
       `../requesting-code-review/scripts/review-brief PLAN_FILE`,
       `{MODE}: kdd-work`, `{BEFORE_MERGE}: yes` — A3, A5 and Review Focus;
   - stops: upstream's four; the fork's former stop ("A task cannot be
     completed without violating a rule of an activated spec") is replaced
     by (b) (decision H-2 in `docs/upstream-sync/decision-log.md`; §3.4);
   - *Finish*: collects "Rulings I made" and "Deferred minors" as upstream,
     and **does not delete the workspace** — finishing-a-development-branch
     harvests the ledger and deletes it (as for SDD).
2. **`skills/executing-plans/scripts/task-start PLAN_FILE TASK_FILE`** →
   prints `brief: <path>` and `base: <full sha>`. Refuses (exit 2) a
   TASK_FILE whose frontmatter `parent:` is not PLAN_FILE's `id:`. Runs
   `task-brief TASK_FILE`; creates the ledger, when absent, with `# SDD
   ledger — plan: <WRK-PLAN-ID> (<plan file path relative to the repository
   root>)`; exits 2 when an existing ledger's line 1 names another plan
   **ID**. Usage → 2.
3. **`skills/executing-plans/scripts/task-done PLAN_FILE TASK_FILE BASE --
   CMD…`** → refuses (exit 3) an empty `BASE..HEAD` range; runs CMD, keeps
   its output in the workspace, prints the tail. On success, and only then:
   head7 = HEAD; transitions the WRK-TASK to `completed` with
   `kdd-conventions/scripts/transition` (commit `chore(<WRK-TASK-ID>):
   complete`); appends `Task <WRK-TASK-ID>: complete (commits
   <base7>..<head7>, tests: <command> → <last output line, or "(no output)">)`.
   Re-run on a task already `completed` with no line: head7 = the parent of
   that task's `chore(<WRK-TASK-ID>): complete` commit, line appended once;
   with the line already present: no-op, exit 0. Exit = CMD's status (2 on
   usage). The range ends before the transition commit, as SDD's does.
4. **`skills/executing-plans/knowledge-check-prompt.md`** — a dedicated,
   trimmed reviewer prompt for gate (b): inputs are the task's brief, the
   ruling line and a `review-package` of the task's range; it returns only
   knowledge compliance: rule violated (rule ID + number, blocking) and, for
   the rule the ruling names, the guarding test or a counterexample input.
5. **`skills/subagent-driven-development/SKILL.md`**:
   - upstream 6.4.1's when-to-use diagram ("Partner chose inline, or no
     subagent tool?") and its "vs. Executing Plans (inline)" bullets;
   - the ledger identity check compares the plan **ID** on line 1 (today:
     "names your plan file"), as `kdd-status` and `task-start` do — the ID is
     stable when a plan file moves;
   - `review-package` exit 3 (empty range or HEAD not descending from BASE):
     the task has no reviewable change — rule on it and ledger the ruling
     before going on (the item batch 1's review deferred here);
   - one line pointing at component 6.
   `test-adversary-prompt.md`'s opening sentence becomes "Dispatch after a
   clean A3 (SDD) or after the task's steps (Native) when …".
6. **`skills/subagent-driven-development/claude-code-orchestrator.md`** —
   upstream's `references/claude-code-tools.md` nested-orchestrator text
   (opt-in; "Rulings I made" relayed verbatim), here because
   `test-invariants.sh` forbids `skills/using-superpowers/references/`.
   Opt-in only: no default behaviour changes, so it is not measured;
   pressure-tested with component 1 (AC8).
7. **`skills/writing-plans/SKILL.md` handoff** — two modes, Subagent-driven
   and Native, with upstream's cost sentences, and upstream's "**For this
   plan I recommend <one of the two>, because <one sentence from the plan:
   how much the tasks depend on each other's interfaces, how many there are,
   what a shipped mistake would cost>.**" The batch-2 plan-review rule is
   unchanged. In `test-skill-content.sh`, `must_not_contain "For this plan I
   recommend"` becomes a `must_contain`, and "(recommended)" on option 1 is
   no longer anchored.
8. **`skills/kdd-conventions/scripts/kdd-status-lib.mjs`** — §3.5 applies:
   its header comment, which lists the ledger forms, names Native's writers
   (`task-start`, `task-done`) and the note forms Native writes that are not
   completion (`Final: Ruling: …`, `Final: minor (deferred): …`, `Final:
   fixed …`, `Attack: … — Ruling: …`, `Pre-flight: …`). Parsing is
   unchanged: every completion line starts `Task <WRK-TASK-ID>: complete`
   and every note line differs from it. `test-kdd-status.sh` gains the
   Native case (Testing).

### Data flow

writing-plans recommends a mode → (Native) per task: `task-start` → steps
under TDD → (a)/(b) when they apply → `task-done` (tests, transition, line)
→ next task → final review (c) → one fix pass, each fix RED→GREEN → "Rulings
I made", "Deferred minors" → finishing-a-development-branch (harvests the
ledger, deletes the workspace).

### Error handling

- A failing `task-done` records nothing and transitions nothing; an empty
  range is refused before the tests run.
- Interruption between the transition and the line: the frontmatter says
  `completed`, the task is done (*Setup*); re-running `task-done` appends
  the line with the range of the original task.
- `task-start` with a task of another plan, or on another plan's ledger,
  stops (exit 2).
- **The ledger's root, settled** (§3.5): it is the plan's working tree
  (`sdd-workspace` roots it at `git -C <plan dir> rev-parse --show-toplevel`),
  for both modes. `kdd-status` run from that tree reads it; run from another
  checkout of the repository it reports the plan's ledger as `none` — tested
  (`test-kdd-status.sh`), so the behaviour is a decision, not an accident.
  Reading other worktrees' ledgers is not part of this batch.

### Testing

- `tests/claude-code/test-executing-plans-scripts.sh`, ported from
  `upstream/main` and adapted: task-start prints brief and base, writes the
  identity line, refuses another plan's ledger and a task of another plan;
  task-done on a passing command transitions the task and writes the line
  with base7..head7 ending before the transition commit; on a passing
  command that prints nothing writes `→ (no output)` and exits 0; on a
  failing command writes and transitions nothing; refuses an empty range;
  re-run after a completed-without-line state appends the line once with the
  original range; re-run with the line present is a no-op; usage → 2.
- `tests/scripts/test-kdd-status.sh`: a ledger built by the real
  `task-start`/`task-done` on the fixture — its completion lines are present
  (asserted by content, not only through `done`), the ledger is `used`, every
  completed task `done`; a `Final: Ruling:` note does not count as
  completion; run from a second worktree, the plan's ledger is `none`.
- `test-skill-content.sh`: anchors for gates (a)–(c), the replaced stop, the
  frontmatter resume rule, *Finish* not deleting the workspace, the
  knowledge-check prompt, the SDD diagram, ID comparison and exit-3 lines,
  the orchestrator file, the handoff's two modes and recommendation; the
  existing executing-plans anchors are kept or replaced in the same commit.
- **Scenario 8** in `test-kdd-flow.sh`, run only when `KDD_FLOW_SCENARIOS`
  names `8` (explicit opt-in; `want()` runs every scenario when the list is
  empty) and only with `KDD_FLOW_USAGE` set (transcripts are copied only
  then): execute `tests/claude-code/fixtures/rounding-plan` and **stop after
  the final review and its fixes, before finishing-a-development-branch**
  (finishing deletes the workspace before its menu). Checks: suite green;
  both tasks `completed`; `kdd-status` reads the ledger `used` with both
  completion lines; A4 dispatched for task 001 **before** task 001's
  `chore(…-001): complete` commit (dispatch timestamp in the transcript
  against the commit time); no implementer subagent dispatch (Native arm); a
  final review dispatched on the most capable model; "Rulings I made" in the
  final message.
- **Measurement** (DOC-FORK-UPSTREAM-001 §2, batch-3 row: levels 1 and 2b),
  pre-registered in FRAG-FORK-UPSTREAM-004 before any after-run; before arm
  `kdd-superpowers--v0.8.0` (batch 2's release — batch 3 measures after it):
  - Level 1: scenario 8 with three arms on the same fixture — 0.8.0's
    executing-plans prompted to run inline without subagents, this batch's
    Native, and SDD — n=2 each; scenarios 4 and 5 on both releases (4 drives
    the changed handoff, 5 is SDD). Deciding: the Native arm passes every
    scenario-8 check in both runs; scenarios 4 and 5 do not regress.
    Reported: cost, turns, wall time per arm.
  - Level 2b: one committed WRK-PLAN from batch 2's level-2 after-runs,
    executed once with Native and once with SDD. It is launched only after
    the human confirms the cost ($30–60 per arm), and **the batch is not
    released before level 2b has run** (§2: levels 1 and 2b).

## Knowledge Context

| Activated Spec | Role in this work |
|---|---|
| DOC-FORK-UPSTREAM-001@0.1.0 | §2 batch-3 row (scope, levels 1 and 2b); §3.4 gates before completion; §3.5 writers, identity, resume, root, range; §3.8 Claude Code only; §4 protocol |
| DOC-FORK-GATES-001@0.4.0 | A3–A5 Native must keep; dispatched gates are synchronous |
| DOC-FORK-LEDGER-001@0.1.0 | identity and completion forms; inconsistencies 1, 2, 4 settled here for Native and SDD's identity check |
| DOC-FORK-TOKENS-001@0.3.0 | how to measure; re-measure after a workflow-skill change |
| FRAG-FORK-LEDGER-001 | evidence, not activated: line forms as written today |

All four activated documents are `draft`, `confidence: low`, without
`verified`.

**Gaps (consolidation):** the modes-and-gates mapping belongs in
DOC-FORK-GATES-001; DOC-FORK-LEDGER-001 gains Native as a writer, the ID
comparison, the frontmatter resume signal and the root decision (closing its
inconsistencies 1, 2 and 4).

## Constraints

- **DOC-FORK-UPSTREAM-001 §3.4:** "An execution mode keeps every gate SDD
  gives a task, before the task is marked complete. For Native: the task's
  final test run, A4 when its condition holds, and — after a `Knowledge
  gap:` ruling on an activated rule — a knowledge-compliance review of that
  task, all run before the task's `transition … completed` and its ledger
  completion line; A3 and A5 run in the whole-branch review."
- **DOC-FORK-UPSTREAM-001 §3.5:** "a new form or writer changes
  `kdd-status-lib.mjs` and `test-kdd-status.sh` in the same commit, and
  DOC-FORK-LEDGER-001 is bumped at consolidation. The batch that adds a
  writer settles, and tests with the writer's real output: the identity
  line's spelling and how readers compare it, which signal a resume trusts
  (ledger line or frontmatter), the ledger's root as `kdd-status` sees it
  from the main checkout, and the commit range in the completion line — or
  records a human ruling that leaves one out." All four are settled above;
  none is left out.
- **DOC-FORK-UPSTREAM-001 §3.8:** "Claude Code only."
- **DOC-FORK-UPSTREAM-001 §3.1 (P10):** the Native text is upstream's; only
  the listed adaptations change it; every adapted rewrite (Native skill,
  SDD's when-to-use, the orchestrator, the handoff) is pressure-tested with
  writing-skills.
- **DOC-FORK-LEDGER-001, Completion:** "A finished task is a line starting
  `Task <task>: complete`, always followed by a parenthesised suffix …
  Readers match the prefix, never the whole line."
- **DOC-FORK-GATES-001, The gates:** A3 "each activated rule a task touches",
  A4 "a task's tests", A5 "each WRK-SPEC acceptance criterion (final
  review)"; "Dispatched gates are synchronous."
- **DOC-FORK-TOKENS-001, Maintenance:** "Re-measure after any change to a
  workflow skill" — scenarios 4, 5 and 8.
- **WRK-SPEC-FORK-CORE-001 P5:** "A change that satisfies the plan but
  violates a rule of an activated spec is a blocking finding." — gate (b).

## Code Premises

Verified on 2026-10-18 by the premise verifier at `7e206c9`; re-verified by
gate A1 (16 hold; premise 2 corrected).

| Premise | Listed | Verified by | Result |
|---|---|---|---|
| 1. executing-plans has no review or A-gates, defers to SDD, stops on a rule violation | yes | `executing-plans/SKILL.md:3,14,52`; grep → rc=1 | holds |
| 2. Upstream Native skill sections and scripts | yes | `v6.4.1:skills/executing-plans/SKILL.md:32-306`; scripts | holds for SKILL.md; `upstream/main`'s `task-done` adds `\|\| last="(no output)"` (v6.4.1 exits 1 after a silent passing command) — the scripts are taken from `upstream/main` |
| 3. task-brief takes a WRK-TASK file, Node, prints `wrote <path>: <N> lines`, workspace from `parent` | yes | `task-brief:1,4,5,36-49,54` | holds |
| 4. SDD's identity line by plan file; completion line before the transition | yes | `subagent-driven-development/SKILL.md:148-155, 475, 479-481` | holds |
| 5. transition active→completed commits `chore(<ID>): complete`, refuses a second run | yes | temp copy of the rounding fixture | holds |
| 6. kdd-status-lib reads the identity prefix and the completion prefix or frontmatter | yes | `kdd-status-lib.mjs:8,21,32,41` | holds |
| 7. A4's condition; the test adversary prompt says "after a clean A3" | yes | `adversarial-gates.md:11`; `test-adversary-prompt.md:3` | holds |
| 8. SDD's when-to-use has "Stay in this session?" | yes | `subagent-driven-development/SKILL.md:46,60-64` | holds |
| 9. Upstream's nested-orchestrator text; `references/` forbidden | yes | `upstream/main:…/claude-code-tools.md`; `test-invariants.sh:32,34` | holds |
| 10. Today's handoff and the batch-2 anchor | yes | `writing-plans/SKILL.md:244,246`; `test-skill-content.sh:281` | holds |
| 11. Upstream's scripts test exists (incl. the silent-command case) | yes | `upstream/main:tests/claude-code/test-executing-plans-scripts.sh:143-150` | holds |
| 12. `want()` runs all scenarios when the list is empty | yes | `test-kdd-flow.sh:58` | holds — scenario 8 gets an explicit opt-in |
| 13. rounding-plan fixture: active plan, task 001 activates the rule, task 002 activates nothing | yes | fixture files | holds |
| 14. finishing harvests `Ruling:` lines and deletes the workspace **before** its menu | yes | `finishing-a-development-branch/SKILL.md:91-94, 162-166` | holds — scenario 8 stops before finishing |
| 15. kdd-conventions' table names "SDD / executing-plans" | yes | `kdd-conventions/SKILL.md:56-57` | holds |
| A1-a. Transcripts are copied only with `KDD_FLOW_USAGE` | unlisted (A1) | `usage-lib.sh:25,36-39`; `test-kdd-flow.sh:39` | holds — scenario 8 requires it |
| U1. "upstream 6.4.1's" Native skill | unlisted | tag `v6.4.1` | holds for the tag; `upstream/main` is 7.0.0 |
| U12. the stub "measured the same as no plugin" | unlisted | no fork measurement | upstream's claim (v6.4.1 release notes, #2318), cited as such |

unlisted claims verified: 12 hold

## Acceptance Criteria

- [ ] AC1. `test-executing-plans-scripts.sh` passes with the cases of
  *Testing*; each fails against a stub that does nothing.
- [ ] AC2. `test-kdd-status.sh` passes with the Native case (lines asserted
  by content), the note case and the second-worktree case; the
  `kdd-status-lib.mjs` diff touches only its header comment.
- [ ] AC3. `executing-plans/SKILL.md` carries gates (a)–(c) before
  `task-done`, the frontmatter resume rule and a *Finish* that keeps the
  workspace, and no longer carries the former stop sentence; anchored.
- [ ] AC4. SDD compares the ledger identity by plan ID, rules on
  `review-package` exit 3, points at the orchestrator; the writing-plans
  handoff offers Subagent-driven and Native with a per-plan recommendation
  and the batch-2 plan-review text unchanged; anchored.
- [ ] AC5. `claude-code-orchestrator.md` exists; `test-invariants.sh` stays
  green.
- [ ] AC6. Scenario 8 exists, runs only when named with `KDD_FLOW_USAGE`, and
  FRAG-FORK-UPSTREAM-004 reports its three arms (n=2) and scenarios 4 and 5
  on both releases, the pre-registration committed first; the Native arm
  passes every scenario-8 check in both runs, and scenarios 4 and 5 do not
  regress. Otherwise the batch is reworked or reverted (§4) and not released.
- [ ] AC7. Level 2b has run (after the human confirmed its cost) and its
  result is in FRAG-FORK-UPSTREAM-004 before the release.
- [ ] AC8. The writing-skills pressure tests of the Native skill, the SDD
  changes, the orchestrator and the handoff are recorded in the commits that
  change them.
- [ ] AC9. The deterministic suites pass; the release has its notes and local
  tag.

## Open Questions

1. Level 2b waits for the human's confirmation of its cost; the release waits
   for level 2b (AC7).

## Adversarial Review

Gate A1, 2026-10-18 (most capable model): `26 attempted, 25 BROKEN
(code-reality 3 · spec-rule 5 · ambiguity 7 · knowledge-gap 4 · internal 6)`.
Adjudicated unattended (decision log U-14); all accepted.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 · "writer" read as "form" to keep the lib unchanged; new note forms unparsed | spec-rule | DOC-FORK-UPSTREAM-001 §3.5 | accepted: component 8 — the lib's header names the writers and note forms; parsing unchanged; tests assert lines by content and notes are not completion |
| 1 · ledger root left "pending a human ruling" | spec-rule | §3.5 | accepted: settled and tested under *Error handling* |
| 1 · release on level 1 with 2b pending | spec-rule | §2 batch-3 row | accepted: AC7 — no release before 2b; 2b waits for the human's cost confirmation |
| 2 · gate (b) reuses a template that needs an implementer report | ambiguity | `task-reviewer-prompt.md:34,231` | accepted: component 4, a dedicated knowledge-check prompt |
| 2 · resume by ledger (kept upstream text) vs frontmatter | internal | v6.4.1 SKILL.md:131-134 | accepted: *Setup* adapted to the frontmatter signal |
| 2 · head7 on a re-run | ambiguity | component 3 | accepted: parent of the task's `chore(…): complete` commit; tested |
| 3 · the kdd-status case passes from frontmatter alone | ambiguity | `kdd-status-lib.mjs:41` | accepted: lines asserted by content |
| 3 · A4 "dispatched" without order | ambiguity | §3.4 | accepted: dispatch time before the task's complete commit |
| 3 · AC6 closable by a ruling | ambiguity | old AC6 | accepted: removed; rework or revert per §4 |
| 4 · `review-package` exit 3 unsettled | knowledge-gap | decision log U-8 | accepted: task-done refuses empty ranges; SDD rules on exit 3 (component 5) |
| 4 · A4 BROKEN handling in Native; prompt says "after a clean A3" | knowledge-gap | SDD:365-371; prompt:3 | accepted: fix by TDD, one re-dispatch, park with ruling, ledgered; prompt sentence adapted |
| 4 · identity compared by ID vs file across modes | knowledge-gap | DOC-FORK-LEDGER-001 inconsistency 2 | accepted: both modes compare the ID (component 5) |
| 5 · finishing deletes the workspace before its menu | code-reality | finishing:162-166 | accepted: scenario 8 stops before finishing |
| 5 · v6.4.1's task-done fails on a silent passing command | code-reality | `git diff v6.4.1 upstream/main` | accepted: scripts from `upstream/main`; case ported |
| 5 · upstream *Finish* deletes the workspace | internal | v6.4.1:300-302 | accepted: *Finish* keeps it for finishing |
| 6 · a no-subagent path in a Claude-Code-only fork | spec-rule | §3.8 | accepted: dropped |
| 6 · orchestrator and SDD diagram outside the Problem Statement; untested | internal | spec | accepted: Problem Statement names them (§2 lists them); both pressure-tested (AC8); the opt-in orchestrator is not measured |
| + 1 · the handoff changes but scenario 4 is not re-run | spec-rule | DOC-FORK-TOKENS-001 Maintenance | accepted: scenarios 4 and 5 in level 1 |
| + 2 · A4's condition on fixture task 002 | ambiguity | fixture | accepted: judged on the task's `activates` and Architecture Impact rows; task 002 activates nothing |
| + 2 · task-start does not check the task's parent | ambiguity | `task-brief:36-44` | accepted: exit 2 |
| + 2 · "no per-task reviewer" vs gate (b) | internal | scenario 8 | accepted: the check is "no implementer dispatch" |
| + 2 · *When to Use* points at the forbidden references | internal | v6.4.1:49-50 | accepted: dropped |
| + 2 · the "status: completed" anchor | internal | `test-skill-content.sh:99` | accepted: anchors kept or replaced in the same commit |
| + 4 · the before tag does not exist yet | knowledge-gap | `git tag -l` | accepted: batch 3 measures after batch 2's release |
| + 5 · transcripts only with `KDD_FLOW_USAGE` | code-reality | `usage-lib.sh:25,36-39` | accepted: scenario 8 requires it |
