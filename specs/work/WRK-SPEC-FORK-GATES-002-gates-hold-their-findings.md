---
id: WRK-SPEC-FORK-GATES-002
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-29
updated: 2026-09-29
owner: jmbruzos
title: "Gates hold their findings: the verifier checks unlisted claims, gates are waited for, and a spec-rule finding is rejected only with a quoted rule"
activates:
  - DOC-FORK-GATES-001@0.2.0
  - DOC-FORK-TOKENS-001@0.2.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-09-29T12:00:00Z
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: FRAG-FORK-GATES-002
    resource: specs/_capture/FRAG-FORK-GATES-002-ab-mdm-member-departure/
    title: A/B of 0.2.1 vs 0.3.0 on a real mdm-platform design (the unlisted-claim error)
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
    title: superpowers 6.3.0 vs kdd-superpowers 0.3.0 (lost A2, rejected spec-rule findings)
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-29T12:00:00Z
stale_after: 2026-12-28T12:00:00Z
tags: [kdd, fork, gates, adversarial, brainstorming, writing-plans, subagent-driven-development]
---

# WRK-SPEC-FORK-GATES-002 — Gates hold their findings

## Problem Statement

Two studies on a real mdm-platform design (FRAG-FORK-GATES-002,
FRAG-FORK-GATES-003) show that the design gates of 0.3.0 find the right
problems but lose them on the way to the final artifact, in three ways:

1. **Unlisted claims go unverified.** The premise verifier checks only what
   the author lists under *Code premises*. The one design-changing false
   claim in 0.3.0's specs sat in *Components*, never listed, so never
   verified (FRAG-FORK-GATES-002, run B1).
2. **A gate dispatched in the background can be lost.** Run K2 dispatched
   gate A2, then ended its turn with "Gate A2 is running … I'll rule on its
   findings when it reports, then commit". In a non-interactive session
   that ended the run: the plan was never adjudicated or committed. K3, told
   to wait, finished cleanly (FRAG-FORK-GATES-003). Neither brainstorming
   nor writing-plans tells the agent to wait for a gate. SDD tells the
   controller how to wait, but not that it must not end the turn with live
   children.
3. **`spec-rule` findings are rejected by reinterpretation.** Gate A1
   flagged the manual-merge survivor recompute as a `spec-rule` BROKEN
   finding in K1 and K2, and emptying the orphaned record in K2. The author
   rejected or "kept" each one by reading the rule's scope its own way. A
   blind judge scored all three decisions wrong against the same rules.
   All five designs in that study got H1 wrong (FRAG-FORK-GATES-003). The
   contract already says "A broken attack on a rule of an activated spec is
   blocking", but nothing makes that operational. Nothing stops the
   adjudicator from ruling the rule away.

## Proposed Change

### 1. The verifier also checks what the author did not list

- **Input.** Before dispatching the premise verifier, brainstorming does two
  things:
  - it makes sure `.kdd/` is in the project's `.gitignore` (adding it if
    absent);
  - it saves every design section approved so far to
    `.kdd/brainstorm/<topic>-design.md` (not `-draft.md`).

  The verifier receives that file along with the premise list.
- **Checks.** It verifies the listed premises as today. It then extracts
  every other statement in those sections about how existing code behaves
  today and verifies it too. It does not judge proposals for change.
- **Output.** The verifier returns
  `| Premise | Listed | Verified by | Result |`, with `yes` or `unlisted`.
- **Consequence.**
  - An `unlisted` claim that is `false` or `unverifiable` is treated like a
    false premise: it changes the design before gate A1.
  - When a false claim changes the design, the verifier is dispatched again
    on the changed statements only.
- **In the WRK-SPEC.** `## Code Premises` carries every listed premise and
  every `unlisted` claim that came back `false` or `unverifiable`, with the
  `Listed` column. The `unlisted` claims that hold are summarised in one
  line: `unlisted claims verified: <N> hold`.
- **Unchanged.** A1 attack 5 stays as it is.
- **Also updated:** brainstorming's inline mention of the verifier table,
  and kdd-conventions' locations table (the new `.kdd/brainstorm/<topic>-design.md`).

### 2. No next step with a gate pending

- **Common contract** (`adversarial-gates.md`), for the gates that are
  dispatched as subagents (A1, A2, A4, A6) and the premise verifier:

  "A dispatched gate is synchronous with the flow. Do not take the next
  step until its table is in: no commit or hand-off of the artifact under
  attack, and no final message. In a non-interactive run, ending the turn
  ends the run. Dispatch the gate in the foreground, or wait for its result
  before your turn ends."

  A3 and A5 run inside reviewers and are not dispatched, so they are
  unaffected.
- **Brainstorming:** the rule is stated at the verifier and A1 dispatch
  points, plus one Red Flags row:
  *"The gate runs in the background — I'll wrap up and rule when it
  reports"* → *"A pending gate is an unreviewed artifact. Wait for its
  table; a turn that ends first can lose it."*
- **writing-plans:** the rule is stated at the A2 dispatch point.
- **SDD:** one sentence is added to *Waiting on dispatched subagents*: never
  end your turn while a child you dispatched is still running; wait for it
  or reconcile it first.

### 3. No rejection of a `spec-rule` finding without a permitting quote

- **The rule.** It goes in the design-gate addendum of
  `adversarial-gates.md` and applies to A1 and A2.
  - A BROKEN finding whose Cause is `spec-rule` may be rejected only by
    quoting the literal text of a rule that **permits** the design. The
    rule must come from an activated spec, or from a principle the work is
    `constrained-by`, with its ID, section and literal.
  - The following do not count as a permitting quote:
    - the WRK-SPEC or WRK-PLAN itself;
    - a narrower reading of the violated rule;
    - the violated rule quoted back.
  - Without a permitting quote, the finding is **accepted**. The artifact
    changes to satisfy the rule, and a
    `Knowledge gap: contested rule — <ID> § <section>: <the disagreement>`
    records it. Consolidation treats that line as a candidate clarification
    of the rule, not as missing knowledge.
- **Recorded Ruling.** A rejection with a quote is persisted as
  `rejected → <ID> § <section> "<literal>"`.
- **Conflicting rules.** Sometimes the permitting quote comes from another
  activated rule that contradicts the violated one. Then:
  - the finding stands;
  - `Knowledge gap: conflict — <ID §> vs <ID §>` is recorded;
  - resolving the conflict means changing one of the specs, which is the
    human partner's call.
- **No human exception.** In A1 the human partner adjudicates with the same
  rule. Disagreeing with an activated rule means changing that spec, not
  rejecting the finding.
- **Where it is referenced:** brainstorming's *Gate A1* and writing-plans'
  *Gate A2* both point to the rule. SDD is not changed; see Open Questions.
- **It does not stall execution,** because the written rule wins by default.

### 4. Tests, behaviour check, measurement, release

- **Baseline:** record the deterministic suite's result before the first
  change.
- **`tests/scripts/test-skill-content.sh`**, with anchors in the same
  commit as each change:
  - **Updated, not only added:** the two existing anchors on the
    three-column literal `| Premise | Verified by | Result |` (verifier
    prompt and brainstorming) move to the four-column header.
  - **New anchors:**
    - the "unlisted" extraction instruction;
    - the `<topic>-design.md` hand-off and the `.gitignore` step;
    - the contract's synchronous-gate sentence;
    - the waiting rule in brainstorming, writing-plans and SDD;
    - the new Red Flags row;
    - the permitting-quote rule, its exclusions, the Ruling format, and the
      `contested rule` and `conflict` gap prefixes;
    - the `Listed` column in the WRK-SPEC template;
    - the locations table entry.
- **`tests/claude-code/test-kdd-flow.sh` scenario 7** gains three
  assertions on the transcript and the committed spec:
  - a Write of `.kdd/brainstorm/*-design.md` happens before the verifier
    dispatch;
  - the verifier's result includes the `Listed` column;
  - the committed Code Premises table has `Listed`.
- **Behaviour check:** pressure-tested with kdd-superpowers:writing-skills.
  The commit states what behaviour was targeted and what was observed.
- **Cost (DOC-FORK-TOKENS-001 §Maintenance):**
  - Run scenario 7 twice before (0.3.0) and twice after (0.4.0).
  - Record the runs in FRAG-FORK-TOKENS-003, which supersedes
    FRAG-FORK-TOKENS-002.
  - DOC-FORK-TOKENS-001 is bumped at consolidation.
- **Quality (DOC-FORK-GATES-001 §Maintenance):**
  - Repeat the FRAG-FORK-GATES-003 method for the K arm with 0.4.0: two
    runs, the same prompt with the wait sentence, the same pre-registered
    H1–H10 and judges.
  - Record the result in FRAG-FORK-GATES-004.
- **Release:** `scripts/bump-version.sh 0.4.0`, plus a `RELEASE-NOTES.md`
  entry.

## Knowledge Context

| Ref | Role |
|---|---|
| DOC-FORK-GATES-001@0.2.0 (activated; draft, low) | The gate contract and its measurements. The premises-only-protect-what-they-list finding; the design-gate recording rules this work extends. |
| DOC-FORK-TOKENS-001@0.2.0 (activated; draft, low) | Cost levers: subagent seats. The verifier stays one seat. |
| WRK-SPEC-FORK-CORE-001 P10, P13 (constrained-by) | Add rows and sentences; do not rewrite tuned prose. No `superpowers` in paths. |
| FRAG-FORK-GATES-002 (evidence, not activated) | The unlisted design-changing claim (B1). |
| FRAG-FORK-GATES-003 (evidence, not activated) | The lost A2 (K2), the clean K3, the rejected spec-rule findings (H1/H3), cost and quality against plain superpowers. |

Gap: DOC-FORK-GATES-001 does not yet carry FRAG-FORK-GATES-003. It is
distilled at this work's consolidation, which bumps the DOC to 0.3.0.

## Constraints

- **WRK-SPEC-FORK-CORE-001 P10:** "KDD changes the *what* and the *with which
  context*; superpowers keeps the *how*. The voice ("your human partner"),
  red-flag tables, approval gates, TDD, subagent discipline and ledger stay
  intact. KDD replaces artifacts and adds activated context; it relaxes no
  existing discipline. Skill language: English."
- **WRK-SPEC-FORK-CORE-001 P13:** "No path contains `superpowers`. Artifacts
  live in `specs/`; runtime state lives in `.kdd/` (gitignored)"
- **DOC-FORK-GATES-001 §A/B on a real design:** "A premises list only
  protects what it lists. 0.3.0's one design-changing error was a claim
  about current code in *Components*, never listed as a premise, so never
  verified."
- **DOC-FORK-TOKENS-001 §Content item 5:** "Subagent seats and their turns.
  Each seat starts a fresh 15-24k context (cache write)."
- **adversarial-gates.md, common contract (current):** "A broken attack on
  a rule of an activated spec is blocking."
- **adversarial-gates.md, design gates (current):** "Every BROKEN finding,
  full row or one-liner, is adjudicated."
- **CLAUDE.md (repository instruction, not an activated spec):**
  "`tests/scripts/test-skill-content.sh` asserts the anchors prompts and
  scripts depend on; when you change a skill, keep it green or update it in
  the same commit."

## Code Premises

Verified by the premise verifier (sonnet) over the premise list and
`.kdd/brainstorm/fork-gates-002-design.md`, 2026-09-29.

| Premise | Listed | Verified by | Result |
|---|---|---|---|
| premise-verifier-prompt.md returns `\| Premise \| Verified by \| Result \|` with holds/false/unverifiable | yes | `skills/brainstorming/premise-verifier-prompt.md:27-29`, `:33` | holds |
| adversarial-gates.md has the "Design gates (A1, A2)" section; the common contract says the controller adjudicates every BROKEN row | yes | `adversarial-gates.md:37`, `:44`, `:61`, `:71`; `:28` | holds |
| Neither brainstorming nor writing-plans tells the agent to wait for a dispatched gate or verifier | yes | `grep -n -i "end the turn\|end your turn\|before continuing\|while.*pending"` → none; brainstorming `:214`, `:230-242`; writing-plans `:211-213` | holds |
| SDD has the "Waiting on dispatched subagents" paragraph but no rule against ending the turn with live children | yes | `subagent-driven-development/SKILL.md:251-260`; grep shows only "reconcile your live children" | holds |
| test-skill-content asserts `skills/brainstorming/` has no `-draft.md`; a `.kdd/brainstorm/<topic>-design.md` does not trip it | yes | `tests/scripts/test-skill-content.sh:175` (scoped to `skills/brainstorming`) | holds |
| Scenario 7 detects the verifier by the description "Premise verifier" or the prompt opening | yes | `tests/claude-code/test-kdd-flow.sh:184` | holds |
| K2's run ended with "Gate A2 is running … then commit." | yes | FRAG-FORK-GATES-003 raw/K2-result.json, field `result` | holds |
| K1 and K2 rejected the manual-merge-survivor spec-rule finding by reinterpreting the rule | yes | FRAG-FORK-GATES-003 raw/K1-bundle.txt and raw/K2-bundle.txt (the committed K2 spec, after the study correction), `## Adversarial Review` | holds |
| SDD lets the controller rule on findings that conflict with plan text without escalating | yes | `subagent-driven-development/SKILL.md:19-25`, `:80-81`, `:401-405` | holds |
| The verifier is one mid-tier seat | unlisted | `premise-verifier-prompt.md:11` `model: [mid tier — REQUIRED]` | holds |
| A1 attack 5 already looks for one unlisted premise in the written spec | unlisted | `spec-adversary-prompt.md:25` | holds |
| The common contract applies to A1–A6 | unlisted | `adversarial-gates.md:6-13`, `:15-35` | holds |
| The verifier's table has no `Listed` column today | unlisted | `premise-verifier-prompt.md:33` | holds |

## Acceptance Criteria

1. **Verifier (§1).**
   - `premise-verifier-prompt.md` takes a design-file input, instructs
     extraction of unlisted claims about today's behaviour (not proposals),
     and returns `| Premise | Listed | Verified by | Result |`.
   - Before dispatching it, brainstorming ensures `.kdd/` is gitignored and
     saves the approved sections to `.kdd/brainstorm/<topic>-design.md`.
   - Brainstorming treats a false or unverifiable unlisted claim like a
     false premise, and re-dispatches the verifier on changed statements.
   - The WRK-SPEC template's Code Premises table has `Listed` plus the
     `unlisted claims verified: <N> hold` line.
   - Brainstorming's inline mention of the table and kdd-conventions'
     locations table are updated.
2. **Synchronous gates (§2).**
   - `adversarial-gates.md` states the rule for dispatched gates (A1, A2,
     A4, A6 and the verifier), including the non-interactive clause.
   - Brainstorming states it at both dispatch points and has the new Red
     Flags row.
   - writing-plans states it at the A2 dispatch point.
   - SDD's waiting paragraph forbids ending the turn with a live child.
3. **Permitting-quote rule (§3).**
   - `adversarial-gates.md` states, for A1 and A2:
     - the permitting-quote rule and its source restriction (activated
       specs or constrained-by principles);
     - the three exclusions (the artifact itself, a narrower reading, the
       violated rule quoted back);
     - default acceptance with `Knowledge gap: contested rule — …`;
     - the `conflict` case;
     - the Ruling format.
   - Brainstorming's *Gate A1* and writing-plans' *Gate A2* reference it.
   - There is no human-rejection exception.
4. **P10 and P13.**
   - No existing Red Flags row, rationalization row or approval gate is
     removed or reworded.
   - The existing rule that "a broken attack on an activated rule changes
     the design" is kept.
   - No new path contains `superpowers`.
5. **test-skill-content.** It carries every anchor in §4, with the two
   three-column anchors updated. Against the recorded baseline, no test that
   passed before fails after, other than those two by their stated update.
6. **Scenario 7.** It has the three new assertions of §4. One headless run
   against kdd 1.6.0 passes, with the log kept.
7. **Behaviour check.** A writing-skills pressure test of the three
   changes is run, and its target and observation are stated in the commit.
8. **Cost.** Scenario 7 is measured twice per side (0.3.0 and 0.4.0),
   recorded in FRAG-FORK-TOKENS-003 (supersedes 002) with the spread per
   side.
9. **Quality.** The K arm of the FRAG-FORK-GATES-003 study is repeated with
   0.4.0: two runs, same prompt plus the wait sentence, same H1–H10, same
   judges. It is recorded in FRAG-FORK-GATES-004, which reports H1 and H3
   against FRAG-FORK-GATES-003's K runs.
10. **Release.** Version 0.4.0 in the three version files, plus a
    RELEASE-NOTES entry.

## Open Questions

- **SDD reviewer findings that cite a rule.** Should they get the same
  permitting-quote rule? There is no evidence yet (the studies stop at the
  plan); it was scoped out by the A1 ruling on scope leak.
- **The orphan state on the knowledge side (H3, H10).** The rules say
  different things: DOM-MDM-PIPELINE-001 §10.8.4 says the emptied source
  record is marked `absorbed`, while DOM-MDM-SURVIVORSHIP-001 §3.2 says
  `orphaned`. That is a spec-to-spec conflict in mdm-platform, not in this
  plugin; it is flagged here for that project's owners.

## Adversarial Review

Gate A1 ran on the written, self-reviewed spec, adjudicated with the human
partner, 2026-09-29.
`21 attempted, 19 BROKEN (code-reality 2 · spec-rule 3 · ambiguity 5 · knowledge-gap 3 · internal 6)`

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 1 — No re-measurement for changes to workflow skills and prompt templates; "still one mid-tier seat" asserted without measurement | spec-rule | DOC-FORK-TOKENS-001 §Maintenance, §How to measure | accepted → §4 Cost; AC8 (FRAG-FORK-TOKENS-003) |
| 1 — The `rejected → human:<id>` exception relaxes "a broken attack on an activated rule changes the design" | spec-rule | WRK-SPEC-FORK-CORE-001 P10; brainstorming/SKILL.md:237-239 | accepted → exception removed; disagreement means changing the spec (§3, AC3, AC4) |
| 2 — "A rule that permits the design" could be the WRK-SPEC itself, so K2's failure would pass | ambiguity | FRAG-003 K2 spec "No aplica … (spec, Componentes 3)" | accepted → permitting rules come only from activated specs or constrained-by principles, with three exclusions (§3) |
| 2 — "Carries both kinds" could mean dozens of rows | ambiguity | FRAG-003 claim counts 56–74 | accepted → listed premises plus false or unverifiable unlisted claims; holds summarised in one line (§1) |
| 2 — Which sections go in the design file; re-verify after a change? | ambiguity | premise-verifier-prompt.md:3-4; SKILL.md:212-214 | accepted → all sections approved so far; re-dispatch on changed statements (§1) |
| 3 — Scenario 7 passes by merely naming a file and adding a `Listed` header | ambiguity | test-kdd-flow.sh; spec §4 | accepted → assertions on the Write-before-dispatch order and on the verifier's result (§4, AC6) |
| 3 — K1's real rejection already fits `rejected → <ID> § "<literal>"` | ambiguity | FRAG-003 K1 bundle, Adversarial Review | accepted → a narrower reading and the violated rule quoted back are excluded; adjudication behaviour is measured in AC9 |
| 3 — AC5 contradicts the two existing three-column anchors | internal | test-skill-content.sh:161, :189 | accepted → listed as updated anchors (§4, AC5) |
| 4 — How to wait in interactive sessions | knowledge-gap | SDD SKILL.md:251-260; DOC-FORK-TOKENS-001 item 5 | accepted → the rule is "no next step and no final message"; non-interactive: foreground or wait before the turn ends (§2) |
| 4 — Two activated rules conflict | knowledge-gap | spec Open Questions; FRAG-003 | accepted → `Knowledge gap: conflict — …`; the finding stands; the human changes a spec (§3) |
| 4 — `Knowledge gap:` reused for a disagreement | knowledge-gap | adversarial-gates.md:28; finishing SKILL.md:96-97 | accepted → the `contested rule —` prefix, read by consolidation as a candidate clarification (§3) |
| 5 — Premise 8's evidence for K2 does not hold in the study bundle | code-reality | FRAG-003 raw/K2-bundle.txt:97, :118, :335-337 | accepted → study defect: the K2 bundle held an early, pre-A1 spec instead of the committed one. FRAG-FORK-GATES-003 is corrected in place (human ruling) and K2 re-judged; premise 8's evidence now cites K2's committed spec |
| 5 — `.kdd/` is not yet gitignored when the design file is written | code-reality | brainstorming/SKILL.md:214 vs :253; test-kdd-flow.sh:57 | accepted → gitignore step before writing (§1, AC1) |
| 6 — The SDD quote sentence has no evidence (the studies stop at the plan) | internal | spec Problem 3; FRAG-003 Method | accepted → SDD unchanged for §3; Open Question |
| + 1 — The quality A/B that DOC-FORK-GATES-001 describes is not required | spec-rule | DOC-FORK-GATES-001 §Maintenance | accepted (no permitting quote; human ruling) → AC9, FRAG-FORK-GATES-004 |
| + 3 — The writing-skills pressure test has no acceptance criterion | internal | spec §4 | accepted → AC7 |
| + 5 — brainstorming/SKILL.md:214 hard-codes the three-column table | internal | brainstorming/SKILL.md:214 | accepted → updated (§1, AC1) |
| + 5 — The kdd-conventions locations table lacks the design file | internal | kdd-conventions/SKILL.md:37 | accepted → updated (§1, AC1) |
| + 6 — Synchronous gates imposed on A3 and A5, which are never dispatched | internal | adversarial-gates.md:10,12 | accepted → scoped to dispatched gates (A1, A2, A4, A6) and the verifier (§2) |
