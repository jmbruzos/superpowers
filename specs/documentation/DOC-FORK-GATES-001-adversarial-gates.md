---
id: DOC-FORK-GATES-001
type: spec
layer: documentation
scope: persistent
status: draft
confidence: low
version: 0.3.0
created: 2026-09-28
updated: 2026-09-29
owner: jmbruzos
domain: kdd-superpowers
subdomain: Quality gates
title: "Adversarial gates of the kdd-superpowers flow — what each attacks, how design-gate findings are recorded, what they measured"
sources:
  - id: FRAG-FORK-GATES-001
    resource: specs/_capture/FRAG-FORK-GATES-001-adversarial-gate-audit-mdm/
    title: Adversarial gate outcomes in three executed mdm-platform plans (2026-09-26/27)
  - id: FRAG-FORK-TOKENS-002
    resource: specs/_capture/FRAG-FORK-TOKENS-002-gate-tuning-measurements/
    title: Headless runs before and after WRK-SPEC-FORK-GATES-001 (gate closing lines)
  - id: WRK-SPEC-FORK-GATES-001
    resource: specs/work/WRK-SPEC-FORK-GATES-001-adversarial-gate-tuning.md
    title: The work that introduced code premises, A1-after-self-review, Cause and the detail cap
  - id: FRAG-FORK-GATES-002
    resource: specs/_capture/FRAG-FORK-GATES-002-ab-mdm-member-departure/
    title: A/B of 0.2.1 vs 0.3.0 on a real mdm-platform design (RFC-PIPE-039), 2 runs per side, blind classifier + evidence judge
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
    title: superpowers 6.3.0 vs kdd-superpowers 0.3.0 on the RFC-PIPE-039 design + plan, blind hard points
  - id: FRAG-FORK-GATES-004
    resource: specs/_capture/FRAG-FORK-GATES-004-gates-hold-findings-quality/
    title: kdd-superpowers 0.4.0 on the same design + plan, blind hard points over all seven runs
  - id: WRK-SPEC-FORK-GATES-002
    resource: specs/work/WRK-SPEC-FORK-GATES-002-gates-hold-their-findings.md
    title: The work that made dispatched gates synchronous, required a permitting quote to reject a spec-rule finding, and had the verifier check unlisted claims
dependencies:
  - id: FRAG-FORK-GATES-001
    relation: distilled-from
  - id: FRAG-FORK-GATES-002
    relation: distilled-from
  - id: FRAG-FORK-GATES-003
    relation: distilled-from
  - id: FRAG-FORK-GATES-004
    relation: distilled-from
  - id: DOC-FORK-TOKENS-001
    relation: relates-to
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-29T21:30:00Z
stale_after: 2027-03-27T12:00:00Z
tags: [kdd, fork, gates, adversarial, quality, measurement]
---

# DOC-FORK-GATES-001 — Adversarial gates of the kdd-superpowers flow

## Purpose

Say why the flow has adversarial gates, what each one attacks, how the
design gates (A1, A2) record what they find, and what the findings have
shown so far — so that a change to a gate is argued from its measured
effect, and so that "the adversary breaks almost everything" is read
correctly. The operational contract lives in
`skills/kdd-conventions/references/adversarial-gates.md`; this document is
the knowledge behind it.

## Audience

Whoever edits a gate's prompt, the brainstorming or writing-plans skills,
or asks "why are the adversaries so successful — and is that a problem?".

## Content

### The gates

| Gate | Attacks | Why it exists |
|---|---|---|
| A1 | the written, self-reviewed WRK-SPEC | a wrong spec is the most expensive failure: every task inherits it |
| A2 | the WRK-PLAN and its tasks | letter-vs-rule, interface, order and coverage defects are cheaper in the plan than in code |
| A3 | each activated rule a task touches (inside the task reviewer) | a rule without a guarding test is a rule nobody enforces |
| A4 | a task's tests | tests that admit a cheating implementation prove nothing |
| A5 | each WRK-SPEC acceptance criterion (final review) | the branch must fail no criterion it claims |
| A6 | each claim of a FRAG about to become DOM/ARCH | a hallucinated fragment would become binding knowledge |

### What the design gates find (baseline, before WRK-SPEC-FORK-GATES-001)

Three executed mdm-platform plans (FRAG-FORK-GATES-001):

- **Hit rates are high:** A1 broke 66 of 84 attacks, A2 36 of 70.
- **The largest cause was unchecked code premises:** 27 of 59 recorded A1
  BROKEN one-liners (46 %) were `code-reality` — the design assumed
  something about current behaviour nobody verified ("the test is already
  green on main", "manual merge does not recompute").
- **The rest:** `spec-rule` 27 %, the rest ambiguity, internal
  inconsistency and knowledge gaps.
- **A2's internal attacks paid for themselves:** interface mismatches,
  order traps, out-of-set activations and uncovered criteria were 25 % of
  A2's BROKEN rows, all defects the plan self-review had missed.
- **The gates moved defects earlier:** two of the three plans ran their
  tasks with 0-1 fix rounds.
- **What reached execution was behaviour, not paths:** task paths and
  signatures matched the code; the false premises that reached execution
  were about behaviour ("unmerge already locks").

A high BROKEN rate is therefore not by itself a sign of bad artifacts:
attacks are required to produce at least one row each, and several
(two readings, trivial satisfaction) nearly always find something in
prose. The useful signal is the cause mix.

### How design-gate findings are recorded

Decided in WRK-SPEC-FORK-GATES-001 (rulings in its Adversarial Review):

- **Cause column, A1 and A2 only.** Values, first that applies:
  `code-reality`, `spec-rule`, `ambiguity`, `knowledge-gap`, `internal`.
  - Rejection is a ruling, not a cause.
  - A3–A6 keep the four-column table: their causes are of another kind
    (tests insufficient, FRAG claim refuted).
- **Detail cap, nothing dropped.** At most 3 full rows per attack; every
  further BROKEN finding as a one-liner, and all of them adjudicated.
  - A hard cap was rejected because it relaxes a discipline (P10). In one
    baseline plan it would have left about 18 real findings unadjudicated.
- **Closing line with the breakdown.** The persisted
  `## Adversarial Review` holds that line and one row per BROKEN finding
  with its evidence and ruling.
  - The baseline could not be measured without re-deriving causes from
    condensed prose; this line and table close that gap.
- **The author checks code premises before A1.**
  - A mid-tier verifier seat checks every statement about today's code
    that the design leans on.
  - The WRK-SPEC carries them as `## Code Premises`.
  - Premises are checked facts for this work, not FRAGs.
- **A1 attacks the written spec after its self-review**, not a draft.
- **A2 keeps its six attacks and its trigger**, and gains attack 7,
  *Code premise*.

Added in WRK-SPEC-FORK-GATES-002 (0.4.0), after FRAG-FORK-GATES-002/003
showed where findings leaked:

- **Dispatched gates are synchronous.** A1, A2, A4, A6 and the premise
  verifier are waited for: no commit or hand-off of the artifact under
  attack, and no final message, while one is pending. In a non-interactive
  run, ending the turn ends the run, and a gate still in the background is
  lost (FRAG-FORK-GATES-003, K2 lost A2 this way).
- **A `spec-rule` finding is rejected only with a permitting quote.**
  - The quote must come from an activated spec or a `constrained-by`
    principle, and must explicitly scope the violated rule: an exception to
    it, or a stated precedence over it.
  - These do not count: the WRK-SPEC or WRK-PLAN itself, a narrower reading
    of the violated rule, or the violated rule quoted back. Those were
    exactly how 0.3.0 runs rejected the manual-merge-survivor finding.
  - Without a quote the finding is accepted. A disputed rule becomes
    `Knowledge gap: contested rule — …`, which consolidation reads as a
    candidate clarification of the rule.
  - Two activated rules that contradict each other become
    `Knowledge gap: conflict — …`: the finding is accepted, and a human
    changes one of the specs.
  - The human partner adjudicates under the same rule; there is no human
    exception.
- **The verifier also checks claims it was not given.** The approved design
  sections are saved to `.kdd/brainstorm/<topic>-design.md`. The verifier
  extracts every other statement about today's code from them, and marks
  each row `Listed: yes | unlisted`. The WRK-SPEC keeps the listed premises
  and the unlisted claims that failed, then `unlisted claims verified: <N>
  hold`.

### What changed after (first samples)

- **Scenario 7** (architectural brainstorming on a small billing project
  with code and specs), A1:
  - `13 attempted, 12 BROKEN (code-reality 3 · …)`
  - an earlier run of the same scenario: `17 attempted, 15 BROKEN (code-reality 3 · …)`
  - `code-reality` 20-25 % of BROKEN, against 46 % in the baseline.
- **Scenario 4** (writing-plans, trivial plan), A2: 7-9 BROKEN per run, with
  0-1 `code-reality`; all within the detail cap.
- **Cost:** see DOC-FORK-TOKENS-001. Cost and output tokens moved inside
  the spread; turns rose 3-8 on the trivial plan.

**These are not like-for-like comparisons.** The baseline is real
brownfield work of 4-13 tasks; the after samples are headless fixtures.

### A/B on a real design (FRAG-FORK-GATES-002)

- **Setup:**
  - Same prompt, same mdm-platform commit (`aacdae5`), same model.
  - Architectural brainstorming for RFC-PIPE-039 (recompute the golden
    record that loses a member), up to the committed WRK-SPEC.
  - Two runs each on 0.2.1 and 0.3.0.
  - A blind classifier assigned causes to A1's findings; a judge checked
    every claim about current code in each final spec against the code.
- **False claims about current code that survive into the final WRK-SPEC**
  (the measure that matters):

  | Version | Claims | False | False that would change the design | Mean cost |
  |---|---|---|---|---|
  | 0.2.1 | 70 | 6 (8.6 %) | 4 | $6.37 |
  | 0.3.0 | 71 | 3 (4.2 %) | 1 | $8.35 |

  The best 0.3.0 spec had 37 of 38 claims true, and its premises caught two
  traps that both 0.2.1 specs fell into.
- **A1's `code-reality` count is not comparable across versions.** It did
  not fall (8 vs 5 of 37 vs 32 BROKEN): in 0.2.1, A1 attacks a draft; in
  0.3.0, the full written spec. Compare what survives into the final spec,
  not what the adversary breaks on the way.
- **A premises list only protects what it lists.** 0.3.0's one
  design-changing error was a claim about current code in *Components*,
  never listed as a premise, so never verified. The candidate improvement
  is a verifier that also extracts such claims from the design sections
  itself.
- **The adversary finds the same substantive design issues in both
  versions** (manual-merge survivor, lost `previous`, orphaned lifecycle).
  Premises move errors about current code, not design judgement.
- **n = 2 per side, one task.** The direction is consistent with the goal;
  the size of the effect is not established.

### Against plain superpowers, and after 0.4.0 (FRAG-FORK-GATES-003, -004)

- **Setup:**
  - Design + plan for RFC-PIPE-039 at mdm-platform `aacdae5`, headless.
  - One neutral prompt, with every approval given in advance.
  - Arms: superpowers 6.3.0 (U1, U2), kdd-superpowers 0.3.0 (K1–K3) and
    0.4.0 (K4, K5).
  - Ten hard points were fixed before any run. A blind judge scored neutral
    summaries against the code and specs; evidence judges checked every
    claim about current code.
- **Results:**

  | Arm | Hard points (of 10) | H1 right | False claims about code | Mean cost |
  |---|---|---|---|---|
  | superpowers 6.3.0 | 7, 6 | 0/2 | 10/110 (9.1 %) | $7.10 |
  | kdd-superpowers 0.3.0 | 9, 5, 6 | 0/3 | 9/192 (4.7 %) | $19.18 |
  | kdd-superpowers 0.4.0 | 8, 9 | 2/2 | 3/117 (2.6 %) | $18.68 |

  H1 asks that the manual-merge survivor's data is not overwritten by the
  recompute.
- **0.3.0 did not beat plain superpowers on design quality.** It halved the
  false claims about code, at about 2.7× the cost.
- **The gates found the right problems, but the authors overrode them.**
  In 0.3.0, A1 flagged the manual-merge survivor as `spec-rule`. The
  authors rejected or "kept" the design by narrowing the rule, and all three
  runs lost H1.
- **Under the permitting-quote rule, both 0.4.0 runs accepted the finding
  and changed the design.** Both got H1 right. The floor rose from 5–6 to
  8; the best run did not change (9).
- **Accepting a finding records a disagreement; it does not resolve a
  conflict between specs.**
  - One mdm-platform rule says an orphaned record does not propagate
    downstream (DOM-MDM-SURVIVORSHIP-001 §3.2).
  - Another says cross-pod cache invalidation rides the same event
    (ARCH-MDM-PERFORMANCE-001 §3.3.1).
  - K4 honoured the first and lost the second; K5 did the opposite.
  - Only a human change to a spec settles it.
- **A KDD-organised repository makes plain superpowers produce KDD-shaped
  artifacts.** The difference is activation, verified premises, gates and
  rulings, not format.
- **n = 2–3 per arm, one task, and the judge varies by about ±1 per run.**
  The H1 result is consistent; the size of the overall gain is not
  established.

### Reading an attack table

- **Many `code-reality` rows:** the author did not verify premises. Look at
  the Code Premises section and at the verifier's table. Then look for
  claims about current code outside that section: those were never
  verified.
- **Many `ambiguity` rows:** tighten acceptance criteria, which is the cheap
  fix.
- **`internal` rows in A2:** the plan self-review missed them. Read them
  before removing any A2 attack.
- **A BROKEN count alone says little.** Read the cause mix and the rulings.

## Maintenance

After the next executed plan in a brownfield project, repeat the
FRAG-FORK-GATES-001 audit on its `## Adversarial Review` tables. It is now
a count of the Cause column, not a re-derivation. Capture it as a new FRAG
and bump this document. To compare plugin versions, repeat the
FRAG-FORK-GATES-002 method (same prompt and commit, disposable worktrees,
blind classifier, evidence judge on the final spec). To judge design
quality, not only claims about code, repeat the FRAG-FORK-GATES-003 method:
pre-registered hard points, neutral summaries, and one blind pass over every
arm's summaries together. After a change to how gates are adjudicated, also
count the rulings: rejected `spec-rule` findings, and contested-rule and
conflict gaps. Owner: jmbruzos.

## Status

Draft, `confidence: low`:
- The baseline is one project and three plans, with causes inferred from
  condensed prose.
- The after samples are three headless fixture runs and one A/B on a real
  design, with 2 runs per side.
- The quality comparison is one task with 2–3 runs per arm, scored by one
  blind judge.
