---
id: WRK-SPEC-FORK-UPSTREAM-005
type: spec
layer: work-spec
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-19
owner: jmbruzos
title: "Upstream sync batch 4 — brainstorming ideas and routing: who owns how it gets made, open questions first, guesses marked, a plainer companion offer, and using-superpowers routes for spec-ask, spec-tui and an unavailable probe"
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-GATES-001@0.4.0
  - DOC-FORK-TOKENS-001@0.3.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-18T12:39:43+02:00
activation_pins:
  - source: self@ac817843e7a6
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
  - id: WRK-SPEC-FORK-UPSTREAM-004
    relation: depends-on
sources:
  - id: FRAG-FORK-GATES-003
    resource: specs/_capture/FRAG-FORK-GATES-003-superpowers-vs-kdd-superpowers/
    title: Real-task method and hard points H1–H10
  - id: FRAG-FORK-GATES-005
    resource: specs/_capture/FRAG-FORK-GATES-005-bare-claude-vs-superpowers-vs-kdd/
    title: Reading rule
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T12:39:43+02:00
stale_after: 2027-01-16T12:39:43+02:00
tags: [kdd, fork, upstream, brainstorming, using-superpowers, routing, measurement]
---

# WRK-SPEC-FORK-UPSTREAM-005 — Upstream sync batch 4: brainstorming ideas and routing

## Problem Statement

Upstream 7.0 rebuilt brainstorming from scratch and dropped the three paths
the fork is built on; DOC-FORK-UPSTREAM-001 §2 discards that rewrite and
takes five of its ideas as rows and sentences:

- **Who owns how it gets made.** The fork never asks which choices about
  platform, language, libraries or medium the human wants to own
  (`grep -niE "platform|language|librar" skills/brainstorming/SKILL.md` →
  only a scope example). 7.0 added it "after a session designed an iOS app,
  never asked about platform, and built a web app" and asks it "even when
  you skip the questions" (7.0 release notes, #2482, #2483).
- **Open questions first.** The fork still says "Prefer multiple choice
  questions when possible" (`:192`, 6.3.0's text); 7.0 found menus steer and
  asks people to describe first.
- **Guesses marked.** The fork's design sections have a size rule (`:212`)
  but no rule to mark guesses as guesses.
- **A builder check** (7.0 replaced its spec reviewer with one). The fork's
  gate A1 already asks the builder's questions — attack 2 "two competent
  engineers would implement differently", attack 4 "a decision the
  implementation will have to make that no activated spec … settles"
  (`spec-adversary-prompt.md:27,29`) — so it is **not taken** (ruling in
  *Adversarial Review*).
- **A plainer companion offer** without "It's still new and can be
  token-intensive" (`:296`).

using-superpowers has no route for a question about what the knowledge says
(toolkit 1.11's `kdd:spec-ask`) or for browsing it (toolkit 1.13's
`/kdd:spec-tui`, which the human launches), and no row for the
`unavailable (no PATH at session start)` probe lines batch 1's hook prints.

## Proposed Change

### Architecture

Approach A of three (B: port 7.0's rewrite — rewrites KDD prose and drops
the three paths, discarded in §2; C: only the routing rows — leaves the
gaps 7.0 measured). Rows and sentences only; the three paths, the
HARD-GATE, the compact WRK-SPEC, the premise verifier and gate A1 are
unchanged. 7.0's playback "in chunks … alternating with questions" is not
taken as a form: the fork already presents the design in sections of up to
200–300 words with approval after each; only the guess rule is added
(component 3).

### Components

1. **How it gets made** — a bullet under *Understanding the idea*, after
   7.0's paragraph: find out early which choices about medium, platform,
   language and libraries your human partner wants to make, which they hand
   to you, and what they already have; build on what existing work already
   uses; a choice you make goes in the design as your call, said in plain
   words, never as something they agreed to. It applies on the bounded and
   the architectural path.
2. **Open questions first** — the bullet "Prefer multiple choice questions
   when possible, but open-ended is fine too" becomes "Get them describing
   first: open questions come first, a short menu only when they're stuck,
   and when they say 'just guess' or 'what do you think?', propose something
   concrete." (7.0's *Get them describing*). It governs the clarifying
   questions about intent; proposing 2–3 approaches (a deliberate menu) and
   the checklist examples are unchanged. The surrounding bullets ("one
   question per message", "Focus on understanding") are unchanged.
3. **Guesses marked** — under *Presenting the design*, after the size rule:
   "Mark anything you're guessing as your guess; only what they said goes in
   as theirs." (7.0, *Play It Back*).
4. **Companion offer** — the quoted offer loses "It's still new and can be
   token-intensive."
5. **using-superpowers**:
   - *Skill Priority*: "A question about what the knowledge says ('what does
     our spec say about X?', 'which rules apply to Y?') asked outside a
     workflow skill → `kdd:spec-ask`. Never brainstorming. Inside a workflow,
     discovery stays with the skill's own step (`kdd:spec-context`)." and
     "Browsing the knowledge graph → `kdd:spec-tui`: the skill prepares the
     `spec-graph tui` command and your human partner runs it in their own
     terminal; you never run the viewer."
   - *Your KDD Environment* table: one row for any line reading `unavailable
     (no PATH at session start)` → "the probe could not run: before the first
     workflow skill, run the `kdd-cli` path the `toolkit:` line names (the
     hook prints it: `toolkit: unavailable (no PATH at session start; check
     with <absolute plugin path>/skills/using-superpowers/scripts/kdd-cli
     --path)`) and act on its result as on the `toolkit:` line (a path:
     found; any other result: NOT FOUND), check yourself whether `specs/` exists (act as on
     `specs_dir:`), and treat `open_work` and `okf_bundles` as unknown — say
     so once."

### Data flow

Brainstorming's flow is unchanged. Session start: an `unavailable` probe →
one `kdd-cli --path` call and an `ls specs` before the first workflow skill.

### Error handling

- `kdd-cli --path` failing with any status after an `unavailable` line is
  treated exactly as `toolkit: NOT FOUND`.

### Testing

- `test-skill-content.sh`: anchors for components 1–5; must_not_contain
  "Prefer multiple choice questions when possible" and "token-intensive";
  every existing brainstorming and using-superpowers anchor stays green.
- New **scenario 9**, run only when named (batch 3's explicit opt-in helper):
  in a project with `specs/`, the prompt "What do our specs say about
  rounding pro-rata amounts?" → `kdd:spec-ask` invoked, `kdd-superpowers:brainstorming`
  not invoked. It is a regression check: the toolkit's own skill description
  may route correctly without the new row, so a pass on both arms credits
  nothing to the row.
- **Measurement** (DOC-FORK-UPSTREAM-001 §4), pre-registered in
  FRAG-FORK-UPSTREAM-005 before any after-run; before arm = the release
  preceding this batch:
  - Level 1: scenarios 1, 2, 3, 7 and 9, n=2 per side; before arm =
    batch 3's release (this batch depends on it). Deciding: every check
    that passes in both before runs passes in both after runs; scenario 9
    routes to `kdd:spec-ask` in both after runs. Reported: cost, turns,
    output tokens, wall time.
  - Level 2: RFC-PIPE-039, K before vs K after, 2 runs per side, same prompt.
    Deciding: hard points comparable or better (after mean not more than 1
    below before in the same blind pass; H1 reported separately), false
    claims about code not 2 or more above per run. Reported: cost, H1–H10,
    knowledge violations.

## Knowledge Context

| Activated Spec | Role in this work |
|---|---|
| DOC-FORK-UPSTREAM-001@0.1.0 | §2 batch-4 row (ideas only; the rewrite discarded); §3.1 P10; §4 protocol |
| DOC-FORK-GATES-001@0.4.0 | A1 unchanged; its attacks 2 and 4 already cover the builder check, which is not taken |
| DOC-FORK-TOKENS-001@0.3.0 | how to measure; re-measure after a workflow-skill change |
| FRAG-FORK-GATES-003, -005 | evidence, not activated: hard points, reading rule |

All three activated documents are `draft`, `confidence: low`, without
`verified`.

**Gaps (consolidation):** what the fork relies on from the toolkit's skills
(spec-ask's lookup, spec-tui's TTY and write limits) — the counterpart of
DOC-FORK-UPSTREAM-001 §5; and the degraded-probe behaviour of component 5.

## Constraints

- **DOC-FORK-UPSTREAM-001 §2 (batch-4 row):** "from 7.0, ideas only …;
  three paths, HARD-GATE and compact WRK-SPEC kept"; and the discard row:
  "the full brainstorming rewrite; 'skip the questions' and 'quick task:
  just do it' (they clash with the HARD-GATE and P3)".
- **DOC-FORK-UPSTREAM-001 §3.1 (P10):** "Add rows and sections; do not
  rewrite tuned prose. An adapted rewrite is pressure-tested with
  writing-skills, and its commit states the targeted and the observed
  behaviour." Component 2 replaces one 6.3.0 bullet with 7.0's re-tuning of
  the same guidance; every KDD sentence keeps its wording.
- **DOC-FORK-GATES-001, The gates:** A1 "the written, self-reviewed
  WRK-SPEC" — unchanged.
- **WRK-SPEC-FORK-CORE-001 P3:** "Activation is decided once, with a human,
  and frozen." The spec-ask route is for questions outside a workflow; inside
  one, discovery and activation stay with the workflow's own step.

## Code Premises

Verified on 2026-10-18 by the premise verifier at `ac81784`.

| Premise | Listed | Verified by | Result |
|---|---|---|---|
| 1. `:192` is the "Prefer multiple choice" bullet, 6.3.0's text | yes | `sed -n 192p`; `git show b36e082:…:170` | holds |
| 2. `:212` size rule; no guess rule | yes | `sed -n 212p`; `grep -n guess` empty | holds |
| 3. `:296` offer with "token-intensive" | yes | `sed -n 296p` | holds |
| 4. Checklist 9 self-review, 10 A1; the order test | yes | `SKILL.md:114-115`; `test-skill-content.sh:175-178` | holds |
| 5. No ownership question | yes | grep → only `:189`'s scope example | holds |
| 6. 7.0's paragraphs and `builder-check-prompt.md` with three piles | yes | `upstream/main:skills/brainstorming/SKILL.md:52,57,112,120,160-171` | holds for the paragraphs; the piles live in the SKILL.md, not the prompt (A1) — moot, the builder check is not taken |
| 7. No spec-ask / spec-tui route; one `toolkit:` row | yes | `using-superpowers/SKILL.md:26-44` | holds |
| 8. Toolkit 1.13.0 has spec-ask and spec-tui; the human launches spec-tui | yes | toolkit `skills/`; spec-tui SKILL.md:6,36 | holds |
| 9. The hook prints the four `unavailable` lines on a broken PATH | yes | `hooks/session-start:23,38-48` | holds |
| 10. Scenario 7 checks A1 and the verifier; 1–3 exercise brainstorming | yes | `test-kdd-flow.sh:61,77,94,168,196-206` | holds |
| 11. No scenario 9 | yes | grep empty | holds |
| D9. "even when you skip the questions" is 7.0's | unlisted | not in 7.0's skill | in 7.0's release notes (#2482), cited as such |
| D14. the iOS-built-as-web session | unlisted | not in the fork | 7.0's release notes (#2482), cited as such |

unlisted claims verified: 12 hold

## Acceptance Criteria

- [ ] AC1. `test-skill-content.sh` passes with the anchors and must-not lines
  of *Testing*; every brainstorming and using-superpowers anchor it had at
  `ac81784` still passes.
- [ ] AC2. `git diff` of `skills/brainstorming/SKILL.md` removes only the
  "Prefer multiple choice" bullet and the token-cost sentence; every other
  change is an added line.
- [ ] AC3. Scenario 9 exists and runs only when named.
- [ ] AC4. FRAG-FORK-UPSTREAM-005 holds levels 1 and 2 with the
  pre-registration committed first, and states for each deciding metric and
  behaviour check whether the batch is worse; a worse batch is reworked or
  reverted, not released.
- [ ] AC5. The writing-skills pressure tests are recorded in the commits that
  change the skills: how it gets made (a request with no platform named →
  the question, or the default stated as "my call"), open questions (the
  first clarifying question is open, not a menu), guesses marked (a design
  section with a guess carries the mark), the spec-ask and spec-tui routes,
  the `unavailable` row.
- [ ] AC6. The deterministic suites pass; the release has its notes and local
  tag.

## Adversarial Review

Gate A1, 2026-10-18 (most capable model): `24 attempted, 18 BROKEN
(code-reality 3 · spec-rule 1 · ambiguity 11 · knowledge-gap 2 · internal 1)`.
Adjudicated unattended (decision log U-16).

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 5 · A1's attacks 2 and 4 already ask the builder's questions | code-reality | `spec-adversary-prompt.md:27,29` | accepted: **builder check not taken** (simplicity; KDD's gate covers it); this also resolves the rows below marked "moot" |
| 2 · the "theirs" pile ends a headless run before A1 | ambiguity | `test-kdd-flow.sh:175`; `k-task.txt` | moot (builder check not taken) |
| 2 · checklist renumbering vs AC2 | internal | `SKILL.md:114-117,161` | moot |
| 3 · the order check passes on any earlier mention | ambiguity | `test-skill-content.sh:176-178` | moot |
| 3 · dispatched but its answers ignored | ambiguity | spec Testing | moot |
| 5 · the piles are in the SKILL.md, not the prompt | code-reality | `upstream/main:…/builder-check-prompt.md` | moot; premise 6 annotated |
| + 2 · does the builder re-run after review | ambiguity | `SKILL.md:163` | moot |
| + 2 · builder reads the WRK-SPEC only or the activated specs | ambiguity | — | moot |
| 1 · components 1–2 are adapted rewrites without a pressure test | spec-rule | §3.1 | accepted: AC5 pressure-tests every changed behaviour |
| 2 · "you never run it" for spec-tui reads two ways | ambiguity | spec-tui SKILL.md:6 | accepted: invoke the skill; the human runs the viewer |
| 3 · scenario 9 may pass without the row | ambiguity | spec-ask description | accepted: a regression check, credits nothing to the row (Testing) |
| 4 · only `toolkit:` has an `unavailable` row | knowledge-gap | `hooks/session-start:40,47` | accepted: one row for any `unavailable` line (component 5) |
| 4 · what the fork relies on from the toolkit is unrecorded | knowledge-gap | DOC-FORK-UPSTREAM-001 §5 | accepted: gap for consolidation |
| 6 · playback chunks cut to "guesses marked" with no ruling | ambiguity | §2 batch-4 row | accepted: the fork's sectioned design with approval per section is the playback; recorded under *Architecture* |
| + 2 · spec-ask vs spec-context mid-workflow | ambiguity | `using-superpowers/SKILL.md:34`; P3 | accepted: spec-ask only outside a workflow |
| + 2 · open questions vs the approaches menu | ambiguity | `SKILL.md:110-111,204` | accepted: the rule governs intent questions only |
| + 2 · kdd-cli non-3 exits | ambiguity | `kdd-cli:15,23,28` | accepted: any non-path result is NOT FOUND |
| + 5 · scenario 8's helper and the before tag are batch 3's | code-reality | `git tag` | accepted: depends on WRK-SPEC-FORK-UPSTREAM-004; before arm = batch 3's release |

**Amendment (gate A2 of WRK-PLAN-FORK-UPSTREAM-005, 2026-10-18):** component
5's `unavailable` row first told the session to run
`skills/using-superpowers/scripts/kdd-cli --path`, a path relative to the
plugin, which does not exist in a user's project — the row would then report
an installed toolkit as NOT FOUND. The hook's `toolkit:` line under a broken
PATH now names the absolute `kdd-cli` path and the row runs that; the
component-1 spike clause is dropped (no anchor, no checklist step reaches it).
`hooks/session-start` changes only in the `unavailable` `toolkit:` line, so the
normal-PATH `<KDD-ENVIRONMENT>` block stays byte-identical to 0.6.0's
(DOC-FORK-UPSTREAM-001 §5). Recorded as decision log U-17.

**Amendment (measurement protocol, 2026-10-19):** after this spec was
written the human narrowed the protocol for the rest of the sync (decision
log H-8; ledger ruling R1 of WRK-PLAN-FORK-UPSTREAM-005). *Testing →
Measurement* is superseded by FRAG-FORK-UPSTREAM-005's pre-registration
(`dfa6bb6`): level 1 n=1 per side, a failing check re-run once on both arms;
level 2 two runs per side with the evidence judge only — no neutral
summaries, no blind H1–H10 pass — deciding on false claims (after mean not
2 or more above) and executability defects (after mean not higher, counted
under FRAG-FORK-UPSTREAM-003 amendment 3's rule). AC4's "each deciding
metric" means that pre-registered set.
