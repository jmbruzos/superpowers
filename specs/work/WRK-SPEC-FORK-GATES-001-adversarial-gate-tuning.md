---
id: WRK-SPEC-FORK-GATES-001
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "Adversarial gates A1/A2: authors verify code premises, A1 attacks the written spec after self-review, attack tables carry a Cause and a detail cap, BROKEN rows persist with evidence"
activates:
  - DOC-FORK-TOKENS-001@0.1.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-09-28T10:56:10+02:00
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
sources:
  - id: FRAG-FORK-GATES-001
    resource: specs/_capture/FRAG-FORK-GATES-001-adversarial-gate-audit-mdm/
    title: Adversarial gate outcomes in three executed mdm-platform plans (2026-09-26/27), BROKEN rows by inferred root cause
  - id: DOC-FORK-TOKENS-001
    resource: specs/documentation/DOC-FORK-TOKENS-001-flow-token-footprint.md
    title: Token footprint of the kdd-superpowers flow — where it goes, how to measure it
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-28T10:56:10+02:00
stale_after: 2026-12-27T10:56:10+01:00
tags: [kdd, fork, gates, adversarial, brainstorming, writing-plans, cost]
---

# WRK-SPEC-FORK-GATES-001 — Tuning adversarial gates A1 and A2

## Problem Statement

Gates A1 (spec red-team) and A2 (plan red-team) break most of what they
attack, and cost time doing it. In three executed mdm-platform plans
(FRAG-FORK-GATES-001) A1 broke 66 of 84 attacks and A2 36 of 70. By
inferred root cause, 27 of the 59 recorded A1 BROKEN one-liners (46 %;
SOURCE-IDENTITY condensed its 36 BROKEN into 28 one-liners) and 10 of 36 A2
ones are **code-reality**: the design or plan assumed something about
current behaviour ("the test is already green on main", "manual merge does
not recompute", "unmerge already locks") that nobody checked. The author
reads the activated specs; nothing in brainstorming or writing-plans makes
it check the premises it takes from the code when specs appear to cover the
work (`brainstorming/SKILL.md` checklist step 3 captures from code only
"when the candidates do not cover what the work will touch";
`writing-plans/SKILL.md` *Read Before You Plan* lists spec, activated specs
and FRAGs only). The most capable model, in a fresh context, does the
author's checking at adversary prices.

Three further costs compound it:

- A1 runs on a draft of the approved design sections *before* the spec
  self-review (`brainstorming/SKILL.md` checklist: step 8 A1, step 10
  self-review), so the expensive gate reports ambiguity and scope issues a
  free checklist would have fixed, and whatever the WRK-SPEC adds when it
  is written afterwards is never attacked.
- Attack tables are unbounded in detail ("at least one row each", no
  maximum): A1 produced 18–42 fully argued rows per run.
- The persisted form (`## Adversarial Review`: "one line per BROKEN attack —
  attack · ruling") drops the Evidence column and has no cause, so gate
  effectiveness cannot be measured without re-deriving causes from prose —
  1 of 59 A1 one-liners cites code.

What works and must stay: every BROKEN row is adjudicated; A2's internal
attacks catch real plan defects the self-review missed (9 of 36 BROKEN,
e.g. out-of-set activation, a reader ordered before its writer); the gates
move defects earlier (MC and MM ran their tasks with 0–1 fix rounds).
`spec-graph validate` does not check that a task's `activates` stays inside
its WRK-SPEC's set, so no A2 attack can be delegated to the CLI.

## Proposed Change

### 1. Code Premises

**brainstorming (architectural path).** The design gains a section
*Code premises*, presented before *Knowledge activation* (which stays
last): every statement about current behaviour the design leans on, each
with how it was verified (`path:lines` and the literal, or a command and
its output) and a result: `holds`, `false` or `unverifiable`.

- Verification is dispatched with a new template,
  `skills/brainstorming/premise-verifier-prompt.md`: one read-only
  subagent, mid tier, that receives the list of premises and repo access,
  writes nothing, dispatches nothing, and returns the table. The session
  model reads the table, not the files.
- A `false` or `unverifiable` premise changes the design before A1 (an
  unverifiable premise is resolved or the design stops relying on it). A
  premise that contradicts an activated spec is also recorded as
  `Knowledge gap:`.
- Greenfield: the section reads "none — no existing code" and nothing is
  dispatched.
- A premise is not a FRAG: it is a checked fact for this work and does not
  enter the graph.
- New Red Flags row: *"The specs cover it, I don't need to read the code"*
  → *"Specs say what should be; code says what is. Every premise the design
  leans on is checked, not assumed."*

**WRK-SPEC (full template).** New body section `## Code Premises` after
*Constraints*: `| Premise | Verified by | Result |`. The compact WRK-SPEC is
unchanged.

**A1.** Attack 5 (*Evidence check*) also re-verifies every Code Premise and
looks for one premise the spec relies on but does not list. It gives a row
only to premises that do not hold and to the unlisted one; the premises
that hold are summarized in one line, `premises re-verified: <N> hold`.

**writing-plans.** *Read Before You Plan* gains item 4, the spec's Code
Premises. A WRK-TASK whose steps rely on existing behaviour not in that
list states it in *Implementation Notes* as a `**Premises:**` line with how
it was verified — no sha, no cite-check.

**A2.** New attack 7, *Code premise*: find a task step that relies on
behaviour of the existing code that does not hold, or that is neither
listed nor verified.

### 2. Brainstorming order (architectural path)

```
7  design approved (incl. Code premises; activation frozen)
8  write the WRK-SPEC (status: draft), validate — no commit
9  spec self-review, fix inline
10 gate A1 against the WRK-SPEC file
11 adjudicate BROKEN rows with your human partner, fix the spec,
   write ## Adversarial Review, re-validate, commit
12 user reviews the written spec → active + verified
```

Every place that states the old order changes its order and references;
all other prose in those places is kept:

- `skills/brainstorming/SKILL.md` — the *Architectural* path bullet (line
  54: "gate A1, the WRK-SPEC"), the architectural checklist, the `dot`
  process flow, and the first sentences of the *Gate A1* subsection (which
  today save the draft and write the WRK-SPEC afterwards).
- `skills/brainstorming/spec-adversary-prompt.md` — the header ("before
  the WRK-SPEC file is written") and `[DRAFT_PATH]` → `[WRK_SPEC_PATH]`.
- `skills/kdd-conventions/references/adversarial-gates.md` — the A1 row of
  the gates table ("the draft WRK-SPEC").

The `.kdd/brainstorm/<WRK-SPEC-ID>-draft.md` step disappears;
`.kdd/brainstorm/` stays for the visual companion.

Changes requested at the user review are fixed, re-validated and
self-reviewed as today. A1 is re-run when the change touches *Proposed
Change*, *Constraints*, *Acceptance Criteria* or *Code Premises* beyond
wording; not otherwise.

### 3. Attack table contract (A1 and A2 only)

All of this section applies to A1 and A2 and is written into their prompt
files and into `adversarial-gates.md` as an A1/A2 addendum. The common
contract and the generic dispatch template stay as they are; A3–A6 are
unchanged.

- **Cause column:** `| Attack | Scenario | Result | Cause | Evidence |`,
  `—` on RESISTED rows. Values, defined as in FRAG-FORK-GATES-001 so the
  post-release comparison is like-for-like:
  - `code-reality` — the artifact assumes something false or unverified
    about existing code (path, symbol, signature, behaviour, an existing
    mechanism or integration point).
  - `spec-rule` — violates or weakens a quoted rule of an activated spec
    or of a principle the work is constrained by.
  - `ambiguity` — two readings, an acceptance criterion satisfiable
    without the work, or a step whose expected result cannot tell success
    from failure.
  - `knowledge-gap` — a decision no activated spec, fragment or the
    artifact settles.
  - `internal` — inconsistency inside the artifact set: interface
    mismatch, order trap, uncovered criterion, out-of-set activation, scope
    leak.
  - Tie-break: the first value in this list that applies.
  - A rejected finding is not a cause; rejection lives in the Ruling.
- **Detail cap, nothing dropped:** "at least one row each" stays. At most
  3 full rows per attack — the three that would cost most if they reached
  implementation. Every further BROKEN finding of that attack is listed
  below the table, one line each: `+ <attack #> · <scenario in one
  sentence> · <Cause> · <evidence path:lines>`. RESISTED findings beyond
  the cap are not listed. Every BROKEN finding, full row or one-liner, is
  adjudicated (P10).
- **Closing line:** `<N> attempted, <M> BROKEN (code-reality a ·
  spec-rule b · ambiguity c · knowledge-gap d · internal e)`, M counting
  full rows and one-liners.
- **Persistence:** `## Adversarial Review` (WRK-SPEC and WRK-PLAN
  templates, brainstorming *Gate A1*, writing-plans *Gate A2*,
  `adversarial-gates.md` *Where rulings persist*) holds the adversary's
  closing line and a table of **every BROKEN finding** (full rows and
  one-liners): `| Attack | Cause | Evidence | Ruling |`. RESISTED rows are
  not persisted. finishing-a-development-branch's harvest of "every BROKEN
  row … from the `## Adversarial Review` sections" reads the table
  unchanged.
- A2 keeps its six attacks and its trigger conditions; it gains attack 7
  (§1), the cap and the Cause column.

### 4. Tests, behaviour check, release

- **Baseline.** Before any change, record the result of `run.sh`,
  `test-session-start.sh`, `test-sdd-workspace.sh` and the brainstorm-server
  tests with kdd 1.6.0. Known red today: `test-invariants.sh` (the
  untracked `docs/superpowers/` directory) and `test-transition.sh` (9
  assertions with kdd 1.6.0). Neither is in this work's scope.
- `tests/scripts/test-skill-content.sh`, updated in the same commit as each
  change: the A1/A2 table-header anchors move to the five-column header;
  new anchors for *Code premises* and `premise-verifier-prompt.md`
  (brainstorming), `## Code Premises` (template), `[WRK_SPEC_PATH]` and
  `premises re-verified` (A1 prompt), "at most 3 full rows per attack"
  (A1 and A2 prompts), the *Code premise* attack (A2 prompt),
  `**Premises:**` (writing-plans), `| Attack | Cause | Evidence | Ruling |`
  (template and `adversarial-gates.md`), the five Cause values
  (`adversarial-gates.md`); a negative anchor: `skills/brainstorming/`
  no longer mentions `-draft.md`; an order check: in the brainstorming
  checklist *Spec self-review* precedes *Gate A1*.
- `tests/claude-code/test-kdd-flow.sh` gains a scenario running
  brainstorming on the architectural path in a fixture with code and
  specs, so A1 is exercised headless (no current scenario does).
- Behaviour is pressure-tested with kdd-superpowers:writing-skills; the
  commit states what behaviour each change targets and what was observed.
- Cost is measured per DOC-FORK-TOKENS-001 and recorded as a new capture
  fragment that `supersedes` FRAG-FORK-TOKENS-001; DOC-FORK-TOKENS-001 is
  bumped from it at consolidation (finishing).
- `scripts/bump-version.sh 0.3.0`; `RELEASE-NOTES.md` entry.

## Knowledge Context

| Ref | Role |
|---|---|
| DOC-FORK-TOKENS-001@0.1.0 (activated; draft, `confidence: low`, unverified) | Where the flow's cost goes and how to measure it: output tokens and subagent turns are the expensive lines. Grounds the detail cap, the mid-tier premise verifier, and the measurement and its persistence. |
| WRK-SPEC-FORK-CORE-001 P10, P13 (constrained-by) | Keep superpowers' *how* and relax no discipline: add rows and sections, adjudicate every BROKEN finding. No path contains `superpowers`. |
| FRAG-FORK-GATES-001 (evidence, not activated) | Audit of gate outcomes in mdm-platform: the counts, causes, cause definitions and examples this spec argues from, and the baseline for measuring it. |

Gaps: the gate contract lives only in `references/adversarial-gates.md` and
in WRK-SPEC-FORK-CORE-001 — no knowledge spec records it or its measured
effectiveness (candidate `DOC-FORK-GATES` at consolidation, distilled from
FRAG-FORK-GATES-001 and the post-release measurement). Premises carried in
SDD fix briefs are not covered (Open Questions).

## Constraints

- WRK-SPEC-FORK-CORE-001 P10: "KDD changes the *what* and the *with which
  context*; superpowers keeps the *how*. The voice ("your human partner"),
  red-flag tables, approval gates, TDD, subagent discipline and ledger stay
  intact. KDD replaces artifacts and adds activated context; it relaxes no
  existing discipline. Skill language: English."
- WRK-SPEC-FORK-CORE-001 P13: "No path contains `superpowers`. Artifacts
  live in `specs/`; runtime state lives in `.kdd/` (gitignored)"
- DOC-FORK-TOKENS-001 §Content, item 4: "Output tokens are the expensive
  line. writing-plans emits 40-60k output tokens: plan, tasks with full
  code blocks, the A2 attack table, and rewrites after adjudication."
- DOC-FORK-TOKENS-001 §Content, item 5: "Subagent seats and their turns.
  Each seat starts a fresh 15-24k context (cache write)."
- DOC-FORK-TOKENS-001 §How to measure: "One run per side is not a
  before/after; repeat until the effect you claim exceeds the spread you
  see."
- DOC-FORK-TOKENS-001 §Maintenance: "Re-measure after any change to a
  workflow skill, a prompt template, the hook, or a Claude Code major
  release; append the run to a new FRAG that `supersedes`
  FRAG-FORK-TOKENS-001 and bump this document."
- adversarial-gates.md (current contract): "The controller adjudicates
  every `BROKEN` row and ledgers it"
- CLAUDE.md (repository instruction, not an activated spec):
  "`tests/scripts/test-skill-content.sh` asserts the anchors prompts and
  scripts depend on; when you change a skill, keep it green or update it in
  the same commit."

## Code Premises

premises re-verified by gate A1: 5 hold, 1 false (removed; see Adversarial
Review), 1 unlisted found false (added below).

| Premise | Verified by | Result |
|---|---|---|
| finishing harvests BROKEN rows from `## Adversarial Review` without depending on the one-liner format | `skills/finishing-a-development-branch/SKILL.md:100-101`: "BROKEN row harvested from the `## Adversarial Review` sections of the" | holds |
| test-skill-content asserts the four-column header for the A1 and A2 prompts | `tests/scripts/test-skill-content.sh:55` and `:71`: `must_contain … "\| Attack \| Scenario \| Result \| Evidence \|"` | holds |
| `.kdd/brainstorm/` is used by the visual companion independently of the A1 draft | `skills/brainstorming/scripts/start-server.sh:112`: `SESSION_DIR="${PROJECT_DIR}/.kdd/brainstorm/${SESSION_ID}"` | holds |
| `spec-graph validate` (kdd 1.6.0) does not check task `activates` ⊆ spec `activates` | `grep -n "activates" spec-graph.mjs`: the only `activates` checks are axis (19223), fragment (19442) and deliverable (19486) | holds |
| No headless scenario runs brainstorming on the architectural path | `grep -n "Scenario" tests/claude-code/test-kdd-flow.sh`: scenarios 2 and 3 are "bounded path"; 4 is writing-plans | holds |
| The deterministic suite is green today | `KDD_SPEC_GRAPH=<kdd 1.6.0> bash tests/scripts/run.sh` → `test-invariants.sh: FAILED` ("no upstream paths", "removed: docs/superpowers" — untracked `docs/superpowers/`), `test-transition.sh: FAILED (9 assertions)` | false — baseline recorded, AC7 measures against it |

## Acceptance Criteria

1. The brainstorming architectural path reads, in the path bullet, the
   checklist, the `dot` flow and the *Gate A1* subsection: design approved →
   write WRK-SPEC and validate → spec self-review → Gate A1 on the WRK-SPEC
   file → adjudicate, write `## Adversarial Review`, re-validate, commit →
   user review; the A1 prompt header and the A1 row of `adversarial-gates.md`
   agree; `skills/brainstorming/` contains no reference to `-draft.md`;
   the A1 re-run rule names Proposed Change, Constraints, Acceptance
   Criteria and Code Premises.
2. `skills/brainstorming/premise-verifier-prompt.md` exists: read-only, mid
   tier, no subagents, input = premise list + repo, output =
   `| Premise | Verified by | Result |` with `holds` / `false` /
   `unverifiable`. brainstorming dispatches it for the *Code premises*
   section (not in greenfield), treats `unverifiable` like `false`, and has
   the new Red Flags row. The full WRK-SPEC template has `## Code Premises`
   after *Constraints*; the compact template is unchanged.
3. `spec-adversary-prompt.md` reads `[WRK_SPEC_PATH]`; its attack 5 covers
   Code Premises (rows only for failing and unlisted premises, plus the
   `premises re-verified` line); it asks for the five-column table, the
   detail cap with one-line overflow, and the Cause breakdown in the
   closing line.
4. `plan-adversary-prompt.md` keeps attacks 1–6, adds attack 7 *Code
   premise*, and asks for the five-column table, the detail cap with
   one-line overflow and the breakdown; `writing-plans/SKILL.md` lists the
   Code Premises under *Read Before You Plan* and the `**Premises:**` line
   in the WRK-TASK template; A2's trigger conditions are unchanged.
5. `adversarial-gates.md` carries an A1/A2 addendum with the Cause column,
   the five definitions and tie-break, the detail cap with one-line
   overflow, the closing-line breakdown and the persisted table
   `| Attack | Cause | Evidence | Ruling |` of every BROKEN finding; the
   common contract and generic dispatch template are unchanged; the WRK-SPEC
   and WRK-PLAN templates' `## Adversarial Review` placeholders match. A3–A6
   prompt files are byte-identical to before.
6. No existing Red Flags row, rationalization row or approval gate is
   removed or reworded, and no BROKEN finding goes unadjudicated (P10);
   no new path contains `superpowers` (P13).
7. `test-skill-content.sh` carries every anchor listed in Proposed Change
   §4, including the negative `-draft.md` anchor and the
   self-review-before-A1 order check. Against the recorded baseline, no
   test that passed before fails after; the two known-red files fail with
   the same assertions and no others.
8. `test-kdd-flow.sh` has an architectural brainstorming scenario, run
   with `KDD_SPEC_GRAPH` pointing at an installed CLI (a SKIP does not
   count). Its assertions check, on the committed result and the
   transcript: a dispatch whose description names the premise verifier;
   a dispatch whose description names gate A1 and that happens after the
   WRK-SPEC file exists; `## Code Premises` in the WRK-SPEC; an
   `## Adversarial Review` whose closing line parses as
   `<N> attempted, <M> BROKEN (...)` with a table of M data rows
   `| Attack | Cause | Evidence | Ruling |`. It passes.
9. Usage is measured per DOC-FORK-TOKENS-001: the writing-plans scenario
   at least twice before and twice after the change; the new architectural
   scenario after only (it cannot run on the old skills — stated). The runs
   are recorded in a new capture fragment that `supersedes`
   FRAG-FORK-TOKENS-001, with the spread per side, and cited from
   RELEASE-NOTES.
10. Version 0.3.0 in `package.json`, `.claude-plugin/plugin.json` and
    `.claude-plugin/marketplace.json`; `RELEASE-NOTES.md` has the entry.

## Open Questions

- Premises in SDD controller fix briefs: the false premise that reached
  execution in mdm-platform ("unmerge already locks", FRAG-FORK-GATES-001)
  was in a final-review fix brief. Out of scope here; revisit if the
  post-release audit shows it again.
- Post-release measurement (not a completion criterion): on the next
  executed plan in mdm-platform or mapfre-gr, compare against
  FRAG-FORK-GATES-001 — expect A1's `code-reality` share to fall.
- `test-transition.sh` fails with kdd 1.6.0 (9 assertions): a regression
  of 0.2.1 against the newer toolkit, outside this work.

## Adversarial Review

Gate A1, run on the written WRK-SPEC after self-review (the order this
spec introduces). `16 attempted, 15 BROKEN (code-reality 2 · spec-rule 3 ·
ambiguity 3 · knowledge-gap 3 · internal 4)`.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
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
