---
id: WRK-SPEC-FORK-UPSTREAM-003
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Upstream sync batch 2 — lean plans: a WRK-TASK records decisions not implementation code, a Review Focus the reviewers check, a proportion check, and a plan your human partner reviews before it runs"
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-18T11:45:03+02:00
activation_pins:
  - source: self@6dafe759027e
    integrity: sha256:312e4ca01e66baa97a8d2a6c910a2f86765123d90f7ccff10b6ce4816e318f25
dependencies:
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
sources:
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
    title: Plan executability metric (pre-registration metric 4) and the real-task method
  - id: FRAG-FORK-TOKENS-002
    resource: specs/_capture/FRAG-FORK-TOKENS-002-gate-tuning-measurements/
    title: writing-plans output tokens per run (totals only)
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T11:45:03+02:00
stale_after: 2027-01-16T11:45:03+02:00
tags: [kdd, fork, upstream, writing-plans, review-focus, measurement]
---

# WRK-SPEC-FORK-UPSTREAM-003 — Upstream sync batch 2: lean plans

## Problem Statement

writing-plans is the costliest step of the KDD flow's design half.
DOC-FORK-TOKENS-001 (§Content, item 4) says writing-plans emits 40–70k
output tokens — "plan, tasks with full code blocks, the A2 attack table";
FRAG-FORK-TOKENS-002 records the per-run totals (44.9k–68.4k) but not their
composition. The fork's WRK-TASK template still asks for the implementation
body in Step 3, and its "No Placeholders" rule requires "code blocks required
for code steps" (`skills/writing-plans/SKILL.md:152-157, 187`). Upstream 6.4.2
found that such plans let a frontier model implement the project while
planning it, and made plans record decisions instead: plans took a quarter of
the time and a third of the tokens, executing 9/9 against planted-defect
probes like full-code plans.

Upstream 6.4.1 also added two things the fork lacks:
- **Review Focus** — up to five inputs the spec implies but no test
  exercises, each pinned by a test in its owning task, so reviewers check
  them on purpose (`grep -rn "Review Focus" skills` is empty today).
- **A reviewed plan** — the human reviews the saved plan before anything
  runs. Today the handoff asks "Which approach?" with no plan review
  (`SKILL.md:215-235`).

The fork's Overview is still 6.3.0's ("zero context for our codebase and
questionable taste", `SKILL.md:10`), the reader upstream replaced with "an
engineer who writes idiomatic code once they know the exact interface and
test".

## Proposed Change

### Architecture

Approach A of three (B: templates only, no Review Focus — loses the reviewer
input upstream added; C: replace the skill and re-add KDD — rewrites KDD
prose, P10). Take 6.4.2/6.4.1 where the fork's text is still 6.3.0's; keep
every KDD addition unchanged: WRK-PLAN and WRK-TASK files, IDs, the
activation subset, Architecture Impact, `**Premises:**`, gate A2's trigger,
the `transition` step, and the fork's rule-citation line.

Files that change:
1. `skills/writing-plans/SKILL.md`.
2. `skills/kdd-conventions/references/artifact-templates.md` (WRK-PLAN and
   WRK-TASK templates).
3. `skills/kdd-conventions/scripts/brief-lib.mjs` `buildReviewBrief`.
4. `skills/writing-plans/plan-adversary-prompt.md` — one sentence on attack 1.
5. `skills/requesting-code-review/code-reviewer.md` and
   `skills/requesting-code-review/SKILL.md:36` — Review Focus as a reviewer
   input.

**Amends WRK-SPEC-FORK-CORE-001's WRK-TASK design** (its *Proposed Change*,
"the `- [ ]` steps with real code: failing test → run → minimal
implementation → run → commit", `:366-367`). That line describes 6.3.0's
step shape, not a KDD principle (P1–P13 say nothing about step bodies). After
this batch: the test step keeps real code with the spec's exact values; the
implementation step gives the exact signature and file and carries a body
only for an algorithm the signature and tests do not determine. P5 holds: a
step still names the rule that binds it.

### Components

1. **Overview.** The two 6.3.0 paragraphs become 6.4.2's paragraph verbatim.
   Upstream re-tuning its own prose; no KDD sentence is touched.
2. **Step granularity.** "## Bite-Sized Task Granularity" / "one action (2-5
   minutes)" → "## Step Granularity" / "**Each step is one action with a
   checkable result:**" (6.4.2).
3. **WRK-TASK template** (SKILL.md and artifact-templates.md). Step 1 keeps
   the test as code with the spec's exact values. Step 3 becomes "**Step 3:
   Implement `function(input: InputType) -> ResultType` in
   `exact/path/to/file.py`**" followed by 6.4.2's "One line on the approach
   when the signature and the test leave a choice (which library call, which
   data structure); a code block only for an algorithm they do not
   determine." artifact-templates' Step 3 loses "(code block)".
4. **"## No Placeholders" → "## What a Step Contains"** (6.4.2 text) with
   two KDD adaptations:
   - 6.4.2's "A reference to another task: that task's Interfaces block says
     what to use" becomes "**A reference to another task:** this task's own
     *Consumes* line repeats the exact signature it uses — the implementer
     sees only this task's brief" (`task-brief` carries one task).
   - The fork's line "'Follow DOM-X' without the rule's text (copy the rule;
     the implementer's brief carries the spec, but the step must say which
     line binds it)" is kept **verbatim**, in 6.4.2's list of lines that
     decide nothing.
5. **Self-review**, seven items: 1 Spec coverage (unchanged); 2 Step scan
   (6.4.2, replaces Placeholder scan); 3 Type consistency (unchanged);
   4 Activation coverage (fork, unchanged); 5 Roll-up (fork, unchanged);
   6 Review Focus (6.4.1); 7 Proportion — the bodies (frontmatter excluded)
   of the WRK-PLAN and its WRK-TASKs against the WRK-SPEC's body (6.4.2).
6. **Review Focus.** A new WRK-PLAN section after Architecture Impact,
   6.4.1's text ("up to five"), with one KDD sentence: "An input an activated
   rule already names is not Review Focus: the rule requires its test, and
   Architecture Impact carries it." Each line's pinning test goes into the
   owning WRK-TASK. A plan that finds nothing uncovered writes, instead of a
   bare "none", one line per input class it checked and the task test that
   covers it.
7. **Execution handoff.** After saving and self-reviewing (and A2 when it
   runs), the skill links the plan and asks your human partner to review it
   before anything runs (6.4.1), with the fork's sentence "Approving the
   spec or the scope is not approving a plan your human partner has not
   seen" (after upstream's release note #2258). An approval given in advance
   that names the plan itself ("I approve … the plan in advance") counts, and
   is quoted in the activation commit message; an approval of the design or
   the scope does not. The two modes and their wording stay as today; the
   per-plan recommendation waits for batch 3, when an inline mode keeps
   every SDD gate (DOC-FORK-UPSTREAM-001 §3.4) — until then today's
   "(recommended)" on Subagent-Driven stands. The `transition … active` step
   on the choice is unchanged.
8. **Review Focus reaches the reviewers.**
   - `buildReviewBrief` emits `## 3b. Review Focus (<WRK-PLAN-ID>)` after
     Architecture Impact — the plan's section verbatim, or `_(the plan has no
     Review Focus section)_`. Numbered sections keep their numbers
     (`test-review-brief.sh` asserts them). `task-brief` is unchanged.
   - `code-reviewer.md` adds Review Focus to the brief's listed contents and,
     under *Knowledge compliance*, one line: "Review Focus (when the brief
     has one): for each line, name the test that pins it or give the input
     that breaks it — a line with neither is Important."
   - `requesting-code-review/SKILL.md:36` lists Review Focus among the
     review brief's contents.
9. **A2 on lean plans.** `plan-adversary-prompt.md` attack 1 gains: "A step
   that gives a signature and no body is not a violation by itself: attack
   whether the task's tests pin the rule — a rule its tests would let an
   implementation break is BROKEN."

### Data flow

WRK-SPEC → writing-plans writes the WRK-PLAN (with Review Focus) and lean
WRK-TASKs (Review Focus tests in their owners) → A2 → your human partner
reviews the saved plan (or an advance approval of the plan is quoted) →
`transition … active` → execution; the SDD final reviewer and
requesting-code-review mode 1 read Review Focus from the review brief and
check each line.

### Error handling

A plan written before this batch has no Review Focus; the review brief says
so and does not fail. A plan whose bodies are several times the spec's body,
or whose WRK-TASKs are mostly code, is a transcript: the proportion check
replaces bodies with signatures and test assertions and re-checks each step
is still unambiguous.

### Testing

- `test-skill-content.sh`:
  - anchors: "## Step Granularity", "## What a Step Contains", "**A
    reference to another task:** this task's own *Consumes* line", "**6.
    Review Focus:**", "**7. Proportion:**", "## Review Focus" in SKILL.md and
    artifact-templates.md, "Please review the plan", "is not approving a plan
    your human partner has not seen", the Review Focus line in
    code-reviewer.md, the attack-1 sentence in plan-adversary-prompt.md;
  - kept verbatim: the "'Follow DOM-X' without the rule's text" line;
  - must_not_contain: "2-5 minutes", "questionable taste", "code blocks
    required for code steps", artifact-templates' "**Step 3: Minimal
    implementation** (code block)";
  - every existing writing-plans anchor stays green.
- `test-review-brief.sh`: Review Focus present → carried verbatim under `##
  3b. Review Focus`; absent → the placeholder line; existing headings
  unchanged.
- `test-kdd-flow.sh` scenario 4 gains reported metrics, measured the same way
  on both arms:
  - **implementation-code share**: per WRK-TASK, lines inside fenced blocks
    (delimiters included) that follow a step whose title starts "Step 3" or
    "Implement", over the body's lines (frontmatter excluded), averaged over
    the tasks;
  - **proportion**: plan plus task bodies over the WRK-SPEC body (lines);
  - **Review Focus**: section present; number of lines; or the per-class
    "none" form.
- **Measurement** (DOC-FORK-UPSTREAM-001 §4), pre-registered in
  FRAG-FORK-UPSTREAM-003 before any after-run:
  - Level 1 — scenario 4, n=2 per side, before `kdd-superpowers--v0.7.0`,
    after this batch's release. Deciding: implementation-code share lower in
    both after runs than in both before runs; the existing scenario-4 checks
    pass in both after runs.
  - Level 2 — RFC-PIPE-039, K before vs K after, 2 runs per side, same
    prompt on both arms. Deciding: plan executability (each task has a
    runnable test step, real files and symbols, a valid order — evidence
    judge) not lower, and false claims about code in the plan not 2 or more
    above per run. Reported: plan length, output tokens, cost, H1–H10.
  - Known limit: neither level executes a plan, which is upstream's evidence
    (planted-defect probes). Batch 3's level 2b executes an after-run plan
    of this batch; a failure there that traces to an underspecified step
    reopens this batch.

## Knowledge Context

| Activated Spec | Role in this work |
|---|---|
| DOC-FORK-UPSTREAM-001@0.1.0 | §2 batch-2 row (scope), §3 rules (P10, gates kept, tests), §4 protocol and "worse" |
| DOC-FORK-GATES-001@0.4.0 | A2 stays as tabulated; Review Focus is a reviewer input beside A3/A5, not in their place |
| DOC-FORK-TOKENS-001@0.3.0 | §Content item 4: where writing-plans' output goes; how to measure |
| FRAG-FORK-GATES-003 | evidence, not activated: plan executability metric |
| FRAG-FORK-TOKENS-002 | evidence, not activated: writing-plans output-token totals |

All three activated documents are `draft`, `confidence: low`, without
`verified`.

**Gaps (capture candidates at consolidation):**
- How A2 reads a decisions-only plan, and what a reviewer does with Review
  Focus, are settled here (components 8, 9) but belong in DOC-FORK-GATES-001.
- Which execution mode the handoff recommends, and why, belongs to batch 3's
  execution-modes knowledge.

## Constraints

- **DOC-FORK-UPSTREAM-001 §3.1 (P10):** "Add rows and sections; do not
  rewrite tuned prose. An adapted rewrite is pressure-tested with
  writing-skills, and its commit states the targeted and the observed
  behaviour." The Overview and Step Granularity are upstream's re-tuning of
  6.3.0 text; every KDD sentence keeps its wording, the rule-citation line
  included.
- **DOC-FORK-UPSTREAM-001 §3.4:** "An execution mode keeps every gate SDD
  gives a task, before the task is marked complete." The handoff does not
  start recommending today's executing-plans, which has no gate.
- **DOC-FORK-UPSTREAM-001 §3.7:** "`test-skill-content.sh` changes in the
  same commit as the prose it anchors".
- **DOC-FORK-UPSTREAM-001 §4, Worse:** "A batch is worse when a deciding
  metric crosses its pre-registered threshold against the before arm, or a
  behaviour check passes before and fails after. … A worse batch is reworked
  or reverted with a human ruling".
- **DOC-FORK-GATES-001, The gates:** "A2 | the WRK-PLAN and its tasks |
  letter-vs-rule, interface, order and coverage defects are cheaper in the
  plan than in code". A2's trigger is unchanged; component 9 tells it how to
  read a signature-only step.
- **DOC-FORK-TOKENS-001, How to measure:** before side as a worktree with the
  current harness copied in; "One run per side is not a before/after".
- **WRK-SPEC-FORK-CORE-001 P5:** the WRK-SPEC is the authority, the plan its
  argument, the activated specs its constraints — a lean step still names
  the rule that binds it. CORE-001's WRK-TASK step design is amended as
  stated under *Architecture*.

## Code Premises

Verified on 2026-10-18 by the premise verifier at `6dafe75`; re-verified by
gate A1 (13 hold).

| Premise | Listed | Verified by | Result |
|---|---|---|---|
| 1. The Overview is 6.3.0's verbatim | yes | `git show b36e082:skills/writing-plans/SKILL.md` lines 10 and 12 identical to the fork's | holds |
| 2. "## Bite-Sized Task Granularity" / "(2-5 minutes)" | yes | `SKILL.md:53,55` | holds |
| 3. Step 3 carries a code body; artifact-templates marks Steps 1 and 3 "(code block)" | yes | `SKILL.md:152-157`; `artifact-templates.md:197,199` ("Minimal implementation") | holds |
| 4. "## No Placeholders" requires code blocks and has the "Follow DOM-X" line | yes | `SKILL.md:180,187,189` | holds |
| 5. Self-review has five items | yes | `SKILL.md:199-207` | holds |
| 6. The handoff offers two fixed options, "Which approach?", no plan review, activation via `transition --no-commit` | yes | `SKILL.md:219-227` | holds |
| 7. `buildReviewBrief` and `buildTaskBrief` emit Architecture Impact only; the task brief carries one task | yes | `brief-lib.mjs:108-112, 127` | holds |
| 8. No "Review Focus" in skills | yes | `grep -rn "Review Focus" skills` → rc=1 | holds |
| 9. SDD's final review passes the review brief | yes | `subagent-driven-development/SKILL.md:504,506` | holds |
| 10. `test-review-brief.sh` asserts numbered headings | yes | `:14` — `## 3. Architecture Impact`, `## 4. Activated knowledge`, `## 5. Evidence …` | holds — Review Focus is `3b` |
| 11. Scenario 4 checks nothing about code blocks, length or Review Focus | yes | `test-kdd-flow.sh:111-119` | holds |
| 12. A2 has no attack requiring a code block | yes | `plan-adversary-prompt.md:27-33` | holds |
| 13. No existing anchor uses the removed text | yes | grep over `tests` → only two prompt files say "Which approach do you want?" | holds |
| U7. 6.4.1's skill says "approving the spec or the scope is not approving the plan" | unlisted | `git show v6.4.1:skills/writing-plans/SKILL.md \| grep -in approv` → line 42 only | false as a quotation — the requirement to wait for the review is in the skill (`:171-173`), the sentence is upstream's release note #2258; component 7 marks it as the fork's own sentence |
| A1-5b. 6.4.2's cross-task reference assumes the implementer reads the other task | unlisted (A1) | `git show v6.4.2:skills/writing-plans/SKILL.md:154-155`; fork `brief-lib.mjs:108-112` carries one task | holds — adapted in component 4 |

unlisted claims verified: 13 hold

## Acceptance Criteria

- [ ] AC1. `test-skill-content.sh` passes with the anchors, verbatim line and
  must-not lines of *Testing*, and every anchor it had at `6dafe75` still
  passes.
- [ ] AC2. `skills/writing-plans/SKILL.md` keeps, byte for byte, *Read Before
  You Plan*, *Scope Check*, *File Structure*, *Task Right-Sizing*,
  *Identifiers*, *Validate*, *Gate A2*, the WRK-PLAN template's KDD sections,
  the WRK-TASK frontmatter rules and the "'Follow DOM-X' without the rule's
  text" line (`git diff` shows no `-` line inside them).
- [ ] AC3. `test-review-brief.sh` passes with the Review Focus present and
  absent cases; the present case fails today.
- [ ] AC4. In scenario 4, both after-arm WRK-PLANs have a `## Review Focus`
  section with at least one line or the per-class form, and the
  implementation-code share is lower in both after runs than in both before
  runs (values reported for all four).
- [ ] AC5. `FRAG-FORK-UPSTREAM-003` holds levels 1 and 2 with the
  pre-registration committed before the first after-run, and states for each
  deciding metric and each behaviour check whether the batch is worse
  (DOC-FORK-UPSTREAM-001 §4). A worse batch is reworked or reverted with a
  human ruling; it is not released as is.
- [ ] AC6. The writing-skills pressure test of the new step rules and the
  plan-review handoff is recorded in the commit that changes them: the
  targeted behaviour and the observed one.
- [ ] AC7. `bash tests/scripts/run.sh` and the other deterministic suites
  pass; the release has its notes and local tag.

## Open Questions

1. Level 2 does not execute plans (see *Testing*, known limit); batch 3's
   level 2b is the first execution of a lean plan from a real task.

## Adversarial Review

Gate A1, 2026-10-18 (most capable model): `18 attempted, 17 BROKEN
(code-reality 1 · spec-rule 3 · ambiguity 7 · knowledge-gap 3 · internal 3)`.
Adjudicated unattended (decision log U-12); every finding accepted.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 · AC5 lets a worse batch ship with a ruling; omits the behaviour-check condition | spec-rule | DOC-FORK-UPSTREAM-001 §4 Worse | accepted: AC5 now states both conditions and "reworked or reverted … not released as is" |
| 1 · the handoff would recommend today's executing-plans, which has no gate | spec-rule | §3.4; `executing-plans/SKILL.md:14,34` | accepted: the per-plan recommendation moves to batch 3; batch 2 adds only the plan review (component 7) |
| 1 · CORE-001's WRK-TASK design says "steps with real code" | spec-rule | `WRK-SPEC-FORK-CORE-001:366-367` | accepted: the amendment is stated under *Architecture* and in *Constraints*; the line is 6.3.0's step shape, not a principle; the test step keeps real code |
| 2 · "code-fence lines ≤ 25 %" has three readings | ambiguity | fixture: 7 % / 20 % / 34 % | accepted: metric defined (implementation fences over body lines), decided relative to the before arm, no fixed 25 % |
| 2 · prompts that pre-approve the plan read two ways | ambiguity | `test-kdd-flow.sh:109`; `ab/prompts/k-task.txt` | accepted: an advance approval naming the plan counts and is quoted; prompts unchanged across arms |
| 3 · AC4 met by today's full-code plans | ambiguity | fixture task at 20 % | accepted: AC4 is relative to the before arm |
| 3 · "none" satisfies the Review Focus check trivially | ambiguity | component 6 | accepted: "none" needs one line per input class checked and its covering test |
| 3 · level-2 deciding metrics improve by construction; upstream's evidence is execution | ambiguity | v6.4.2 release notes "9/9 against planted-defect probes" | accepted as a limit: stated under *Testing*; batch 3's level 2b executes a batch-2 plan and can reopen this batch |
| 4 · A2 attack 1 against a signature-only step | knowledge-gap | `plan-adversary-prompt.md:27` | accepted: component 9; DOC-FORK-GATES-001 gap |
| 4 · what a reviewer does with Review Focus | knowledge-gap | `code-reviewer.md:23-28` | accepted: component 8 (code-reviewer line, SKILL.md:36); DOC-FORK-GATES-001 gap |
| 5 · FRAG-FORK-TOKENS-002 cited for the output composition | internal | FRAG report.md:77-82 | accepted: composition cited to DOC-FORK-TOKENS-001 item 4; the FRAG for totals only |
| 5 · 6.4.2's cross-task reference assumes the implementer reads the other task | code-reality | `brief-lib.mjs:108-112` | accepted: component 4 points at the task's own *Consumes* line |
| 6 · the fork's rule-citation line was reworded | internal | `SKILL.md:189` | accepted: kept verbatim; AC2 protects it |
| + 2 · proportion counted on whole files | ambiguity | fixture 57 vs 149 lines | accepted: bodies only, frontmatter excluded |
| + 2 · "few" vs "up to five" | ambiguity | v6.4.1 `:81,:163` | accepted: "up to five" |
| + 4 · no criterion for recommending a mode on Claude Code | knowledge-gap | `executing-plans/SKILL.md:14` | accepted: batch 3 |
| + 6 · requesting-code-review lists the brief's contents | internal | `requesting-code-review/SKILL.md:36` | accepted: component 8 updates it |
