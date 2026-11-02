# Report — agentic workflow practice on top of kdd-superpowers (sanitized)

## Scope and provenance

One private KDD platform project, the plugin author's own, ran from 2026-10-30 to 2026-11-02 with one orchestrating
Claude Code session. That session drove the kdd-superpowers flow through Workflow-tool scripts, each orchestrating many
subagents. A private capture fragment in that project holds the full evidence, anchored to the scripts, the session's
decision log, the work artifacts and the git history.

This public report is a sanitized derivative. It keeps aggregated numbers and patterns rewritten in generic terms. It
leaves out paths, identifiers, commit hashes and the project's own content. Its anchors cannot be checked from this
repository; the private fragment is the authority for every number below.

## Quantitative summary

| Measure | Value |
|---|---|
| Workflow scripts written | 63: 17 spec rounds, 45 item pipelines (2 of them resume scripts), 1 other |
| Items per item pipeline | 1 item: 32 scripts; 2: 10; 3: 2; 4: 1 |
| Workflow runs | 81 runs, 1016 subagents started, 1006 returned |
| Subagent roles | refute 117, plan 66, review 64, fix 64, author 40, revise 38; the rest are one agent per task |
| Spec refute rounds | 36 rounds, 108 refuter results; BROKEN/attacks per lens: spec adversary 396/575, premise verifier 217/625, cross-item 264/559 (877/1759 in total) |
| Second refute rounds | 1 (41–42 BROKEN in round 1, 30 in round 2) |
| Plan gate A2 | waived by the human in 44 of 45 pipelines; run with two lenses and an adjudicator in 1 |
| Merges into main | 81 |
| Activation commits | 92; 74 quote the human's approval verbatim |
| Merges recording a conflict | 7; 4 of them on the same changelog line of the project's delivery plan; another recurring one is a generated types file |
| Resumed runs | 7, plus 2 dedicated resume scripts |
| Flakes ruled | 1 (re-run three times on a fresh stack, green each time) |
| Artifact-id collisions | 1 (two parallel worktrees allocated the same WRK-PLAN id) |

## Observed (sanitized)

**O1 — Spec refutation with fixed lenses.** Every WRK-SPEC written by a workflow went through three refuters in
parallel, one lens each: spec adversary (A1), premise verifier, and cross-item consistency and security. One reviser
then adjudicated every BROKEN row. Only questions the author could not resolve reached the human. On the one spec with
a full record, adjudication rejected 0 of 72 BROKEN rows. A second round ran once, because round 1 had produced so many
fixes; the reviser of round 2 recorded that "the round-1 fixes created new holes". No third round ran, and no stopping
rule was ever written down: the human's review was the stop.

**O2 — The item pipeline.** In practice each item ran plan → activate → one fresh agent per task, in order → one
whole-branch reviewer → one fix pass that also closed the plan. Each task's rulings went forward into the prompts of
later tasks, and a blocked task stopped the item. Task agents were told not to dispatch subagents. As a result the
plans' execution logs call the run "native" while the activation commits call it "subagent-driven", for the same run.
The method has no name for this mode.

**O3 — Concurrency.** Items ran in parallel, each in its own git worktree. Every worktree got its own container-stack
project name and a port offset, the same idea in all 45 pipelines. A project rule (not a method rule) capped active
plans at three, with no two writing the same package; it was broken once, on purpose and recorded. `next-id` sees only
its own worktree: after one collision, the orchestrator handed explicit ids to the planning agents (5 scripts).

**O4 — Traceable authorization.** Activation commits copy the human's approval verbatim (74 of 92). Push happened only
on an explicit OK, each one recorded with the human's words. A subagent once took a user message relayed mid-run as its
own request; from then on the prompts say to ignore relayed messages (15 scripts). `verified` was written only on the
human's explicit confirmation of that specific spec.

**O5 — Unattended sessions.** One append-only, dated decision log spans several sessions. It opens with a "decisions
to review" table and carries inline "held for you" / "critical question" markers. Work goes on with a stated default
whenever a decision is not critical.

**O6 — Integration.** No workflow merged anything. The orchestrating session merged one branch at a time, then ran a
single project verification script on the merged main: typecheck, unit tests, validate, images, and the container
stack with every stack suite. It ran after each merge or small batch. The predictable conflicts are lines that every
item amends: a changelog or version line, and a generated file. A failing test on the merged main was re-run three
times on a fresh stack before it was ruled a flake.

**O7 — Resume.** Tasks are idempotent ("if the task file already says completed, return without redoing it"). Before
resuming, the orchestrator finished or fixed the blocking step by hand, then relaunched under a new run. The resumes
are visible only in the decision log.

**O8 — Gate A4 without a nested adversary.** Since task agents could not dispatch, gate A4 became self-mutation: each
task with rules reports at least two mutations tried against its own tests (24 scripts). In one recorded case a
surviving mutant led to an added assertion.

## Inferred

- The lenses break different shares of their attacks (A1 69%, cross-item 47%, premise 35%). Each lens finds things
  the others miss, so all three are worth keeping.
- What made the workflow mode work is what the method already has: frozen activation, task files as the progress
  signal, rulings, and gates. The workflow adds fan-out, isolation and a deterministic order.
- The parts that belong to the project are the verification script, the concurrency cap and the port scheme. A
  generic skill should take them as parameters, not hard-code them.
- Four practices were not supported by the evidence and are left out of any proposal as observed: a BROKEN-count
  stopping rule, a closing "to-do for the human" list, journal-based diagnosis, and a single end-of-session
  verification.
