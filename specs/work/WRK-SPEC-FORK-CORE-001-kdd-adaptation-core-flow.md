---
id: WRK-SPEC-FORK-CORE-001
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "kdd-superpowers — Sub-project 1: core flow adaptation of superpowers to KDD"
activates: []
equips: []
activation_frozen: true
activation_resolved_at: 2026-09-17T00:00:00+02:00
dependencies: []
sources:
  - id: KDD-TAXONOMY
    resource: ../knowledge-driven-development/knowledge-architecture/unified-taxonomy.md@ec3bc83
    title: KDD unified four-axis taxonomy
  - id: KDD-ANATOMY
    resource: ../knowledge-driven-development/knowledge-architecture/spec-anatomy.md@ec3bc83
    title: KDD spec anatomy (frontmatter schema, trust family, actor convention)
  - id: KDD-BROWNFIELD
    resource: ../knowledge-driven-development/docs/patterns/brownfield-adoption.md@ec3bc83
    title: KDD brownfield adoption pattern
  - id: KDD-OKF
    resource: ../knowledge-driven-development/docs/patterns/okf-interop.md@ec3bc83
    title: KDD ↔ OKF v0.2 interoperability pattern
  - id: KDD-MANIFESTS
    resource: ../knowledge-driven-development/knowledge-architecture/activation-manifests.md@ec3bc83
    title: Activation manifests (new-task, frozen activation)
  - id: KDD-TOOLKIT
    resource: ../knowledge-driven-development/kdd-toolkit/@ec3bc83
    title: kdd-toolkit plugin (`kdd`) — spec-graph CLI, /kdd:spec-* skills
  - id: KDD-CLI-IDS
    resource: ../knowledge-driven-development/kdd-toolkit/cli/spec-graph-lib.mjs@ec3bc83
    title: ID_PATTERNS accepted by spec-graph validate
  - id: UPSTREAM
    resource: https://github.com/obra/superpowers/tree/b36e082
    title: superpowers v6.3.0 (fork base)
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-17T00:00:00+02:00
stale_after: 2026-12-16T00:00:00+01:00
tags: [kdd, superpowers, fork, methodology, skills, claude-code]
---

# WRK-SPEC-FORK-CORE-001 — kdd-superpowers: core flow adaptation

## Problem Statement

`superpowers` (v6.3.0) gives coding agents a disciplined development
workflow — brainstorm → spec → plan → subagent-driven execution → review →
finish — but its artifacts are free-form Markdown documents under
`docs/superpowers/`, disconnected from any knowledge base. It has no notion
of *which* domain or architecture knowledge a piece of work depends on, no
way to freeze that dependency for reproducibility, no trust metadata, and
no loop that returns what was learned to a persistent knowledge base.

Knowledge-Driven Development (KDD) provides exactly those missing pieces —
typed, versioned specs on four axes (Knowledge, Agentic, Work, Governance),
contextual activation with `activates`/`equips` pins, a trust family
(`generated`/`verified`/`sources`/`stale_after`), a capture layer (`FRAG-*`)
for brownfield evidence, a consolidation loop, and OKF v0.2
interoperability — packaged as the `kdd` Claude Code plugin (`kdd-toolkit`).
But the toolkit's skills are standalone slash commands; they do not shape
the agent's day-to-day development behaviour the way superpowers does.

This work forks superpowers into **`kdd-superpowers`**: the same
behaviour-shaping discipline, producing and consuming KDD artifacts,
driven by the toolkit, in Claude Code only. It is sub-project 1 of 3
(see *Scope* below).

## Proposed Change

### Scope

Three sub-projects were identified; this spec covers the first only.

| # | Sub-project | Covered here |
|---|---|---|
| 1 | **Core flow** — plugin identity, bootstrap, brainstorming → WRK-SPEC, writing-plans → WRK-PLAN/WRK-TASK, SDD and executing-plans with frozen activation, review against specs, finishing → consolidation, code capture from brownfield code, adversarial gates, trust family, OKF conformance | **yes** |
| 2 | Knowledge capture from debugging (`systematic-debugging` → FRAG) | no |
| 3 | Skills as Agentic artifacts (`writing-skills` → SKILL-*, fork skills registered in the graph, adversarial gates as EVAL-*) | no |

Harness support: **Claude Code only**. All other harness assets are removed.

### Operating principles

These principles bind every skill in the fork. Each skill section below
references them by number.

- **P1. Work artifacts are KDD specs, not documents.** Brainstorming,
  plans and tasks are written as WRK-SPEC / WRK-PLAN / WRK-TASK in
  `specs/work/`, with complete frontmatter, and must pass
  `spec-graph validate` before they count as written. `docs/superpowers/`
  no longer exists.
- **P2. Every piece of work declares the knowledge it activates.** A
  project with no knowledge base yields an explicit `activates: []`, said
  out loud — never a silent absence.
- **P3. Activation is decided once, with a human, and frozen.**
  Brainstorming is the only place activation is chosen; the design
  approval gate includes the activation. The WRK-SPEC carries
  `ID@version` pins and `activation_frozen: true`. Downstream (plan,
  tasks, subagents, reviewers) nobody reopens it: a task needing knowledge
  outside the frozen set records a *ruling* in the ledger tagged
  `Knowledge gap:` and continues.
- **P4. Deterministic → CLI; judgment → toolkit skill.** Fork skills never
  reimplement what `spec-graph` does (filter, context, validate, export)
  nor what `kdd:spec-context`, `kdd:spec-activate`, `kdd:spec-consolidate`
  do. The `kdd` plugin is a hard dependency; if missing, the bootstrap
  says so and workflow skills stop.
- **P5. Three layers of authority in execution.** The WRK-SPEC is the
  authority; the WRK-PLAN is its argument; the activated specs are its
  constraints. Implementers and reviewers receive all three and verify
  against all three. A change that satisfies the plan but violates a rule
  of an activated spec is a blocking finding.
- **P6. Everything written carries the trust family.** `generated: {by, at}`
  with the agent actor; `sources` citing the activated specs and FRAGs the
  content rests on; `stale_after` on ephemeral artifacts. `verified` is
  only ever recorded on behalf of a human who explicitly confirmed (writer
  ≠ confirmer); a skill never verifies its own output.
- **P7. No work closes without returning knowledge.**
  `finishing-a-development-branch` runs consolidation before offering
  merge/PR. Work artifacts transition `active → completed` at close and
  `archived` once consolidation is applied.
- **P8. OKF by construction, not by extra steps.** No "OKF steps" in the
  daily flow; conformance follows from valid artifacts and a deterministic
  `export-okf`, which is run as evidence at close. External OKF bundles
  (directories with `index.md` declaring `okf_version`) enter via
  `import-okf` before anything in them can be activated.
- **P9. Same methodology with or without `specs/`.** Without a specs
  directory the fork creates `specs/work/` and proceeds. There is no
  "vanilla mode".
- **P10. KDD changes the *what* and the *with which context*; superpowers
  keeps the *how*.** The voice ("your human partner"), red-flag tables,
  approval gates, TDD, subagent discipline and ledger stay intact. KDD
  replaces artifacts and adds activated context; it relaxes no existing
  discipline. Skill language: English.
- **P11. In brownfield, code is the source of knowledge — captured, not
  ignored.** When activation is empty or insufficient and code exists,
  skills explore the code and record what they find as capture-layer
  fragments (`FRAG-*` under `specs/_capture/`). FRAGs are evidence, never
  activated (the toolkit already forbids it); the WRK-SPEC cites them in
  `sources` and in *Knowledge Context*. Distillation FRAG → DOM/ARCH happens
  at consolidation, and only for what the work touched ("start where it
  hurts").
- **P12. A FRAG extracted from code contains only what can be pointed at.**
  (1) No anchor, no claim: every behavioural statement cites
  `path:lines@sha` with the verbatim snippet copied from tool output.
  (2) *Observed* and *Inferred* are separate body sections; every inference
  lists the observations it rests on. (3) Absences are anchored too: "no
  validation of X" is recorded with the search commands run. (4) Mechanical
  cite-check before writing: every anchor is re-read and the literal
  confirmed (`grep -F`); one failure blocks the FRAG. (5) Honest trust: born
  `confidence: low`, `generated` by the agent, no `verified`; only a human
  adds `verified`, and an unverified FRAG is distilled at most into a
  `confidence: low` spec with mandatory review. (6) For computable rules,
  evidence is a characterization test written and run against the current
  code; the observed result is what enters the FRAG. (7) Promotion needs an
  adversary: before a FRAG becomes DOM/ARCH, a reviewer subagent with only
  the FRAG and repo access tries to refute each claim (gate A6).
- **P13. No path contains `superpowers`.** Artifacts live in `specs/`;
  runtime state lives in `.kdd/` (gitignored): `.kdd/sdd/<WRK-PLAN-ID>/`
  for SDD ledgers, briefs, reports and review packages;
  `.kdd/brainstorm/<session>/` for the visual companion. Example strings
  and brand assets referencing the upstream name are replaced or removed.
  The rule governs paths the plugin writes into projects; the plugin's own
  name (`kdd-superpowers`) and skill directory names (`using-superpowers`)
  are identifiers, not project paths.

### Identifiers

IDs carry a **semantic path, number last**, exactly as `spec-graph`
already accepts (`^PREFIX(-[A-Z0-9]+)*-\d{3}$`) and as real KDD projects
already do (`CAP-GR-CDC-ADAPTER-001`).

| Artifact | ID | File |
|---|---|---|
| Work spec | `WRK-SPEC-RISK-VAR-ENGINE-001` | `specs/work/WRK-SPEC-RISK-VAR-ENGINE-001-<slug>.md` |
| Work plan | `WRK-PLAN-RISK-VAR-ENGINE-001` | `specs/work/WRK-PLAN-RISK-VAR-ENGINE-001-<slug>.md` |
| Work task | `WRK-TASK-RISK-VAR-ENGINE-001-003` | `specs/work/WRK-TASK-RISK-VAR-ENGINE-001-003-<slug>.md` |
| Fragment | `FRAG-RISK-VAR-ROUNDING-001` | `specs/_capture/FRAG-RISK-VAR-ROUNDING-001-<slug>/` |

Rules:

- Segments are `[A-Z0-9]+`, 2–4 semantic segments (area + concept).
  Brainstorming proposes the path and the human confirms it with the
  activation. With a knowledge base, the area is the dominant area of the
  activated specs; in brownfield it is the module/domain touched. The fork
  never invents an area when the graph already has a fitting one
  (`spec-graph filter --format json` is consulted first), and uses nested
  areas only if the project already does.
- Plan and tasks inherit the spec's semantic path. A task ID is
  `WRK-TASK-<path>-<PPP>-<TTT>`: PPP is the parent plan's number, TTT the
  task's sequence in the plan's *Task Breakdown* table — so plan and
  position are readable without opening the file, and appear verbatim in
  ledgers and commit messages (`feat(WRK-TASK-RISK-VAR-ENGINE-001-003): …`).
- A plan takes its spec's number when free (the usual one-plan-per-spec
  case reads top to bottom); a second plan for the same spec takes the next
  free number within the path, related by `parent`.
- Numbers are allocated per semantic path by scanning `specs/`
  (`scripts/next-id`).
- File slugs stay lowercase-descriptive; `title` carries the full name.
- Knowledge specs the fork proposes (e.g. distilled from a FRAG) follow the
  same rule (`DOM-RISK-VAR-001`, not `DOM-RISK-001`); existing project IDs
  are respected as they are.

### Plugin identity

- `.claude-plugin/plugin.json`: `name: kdd-superpowers`, version `0.1.0`,
  author NFQ; README notes derivation from superpowers 6.3.0 (MIT, LICENSE
  kept with derivation note).
- `.claude-plugin/marketplace.json`: marketplace `kdd-superpowers`, single
  plugin. Install: `/plugin marketplace add <owner>/superpowers` +
  `/plugin install kdd-superpowers`. Upstream `superpowers` must be
  uninstalled first (both inject a session bootstrap).
- Every `superpowers:<skill>` reference in skills becomes
  `kdd-superpowers:<skill>`. Toolkit skills are referenced as
  `kdd:spec-<name>`.

### Skill 1 — `using-superpowers` + session-start hook

**Hook** (`hooks/session-start`, bash only, runs on startup/clear/compact):
still injects `using-superpowers/SKILL.md`, and appends a
`<KDD-ENVIRONMENT>` block computed with bash/find/grep only:

```
toolkit: <path to spec-graph.mjs> | NOT FOUND
specs_dir: ./specs (knowledge: N · work: M) | NONE
open_work: WRK-SPEC-… (active|completed, pending consolidation) → WRK-PLAN-… → k/n tasks done | none
okf_bundles: <dir> (okf_version X, not imported) | none
```

CLI search order (shared script `scripts/kdd-cli`): `$KDD_SPEC_GRAPH` →
`./node_modules/.bin/spec-graph` → `./.kdd-toolkit/cli/spec-graph.mjs` →
`~/.claude/plugins/**/kdd*/cli/spec-graph.mjs`. `open_work` comes from
grepping `status:` in `specs/work/`; `okf_bundles` from `index.md` files
containing `okf_version:` outside `specs/`.

**Skill text**: everything upstream stays (the rule, red flags, skill
priority, platform adaptation references). Added:

1. Section *Your KDD environment* — how to read the block and act:
   `toolkit: NOT FOUND` → before any workflow skill (brainstorming,
   writing-plans, SDD, executing-plans, finishing) tell the human partner
   to install the `kdd` plugin and stop; non-dependent skills keep
   working. `specs_dir: NONE` → announce once that `specs/work/` will be
   created with the first WRK-SPEC and knowledge will be captured from
   code (P9, P11). Unimported `okf_bundles` → mention once, offer
   `kdd:spec-graph import-okf --dry-run`, activate nothing from them until
   imported (P8). `open_work` → if the request fits open work, offer to
   resume it (read WRK-SPEC/PLAN and ledger) before starting new work.
2. Skill-priority row disambiguating the toolkit: "I want a domain /
   architecture spec" → `kdd:spec-create` or the `kdd-spec-assistant`
   agent (Knowledge axis); "I want to build / change something" →
   `brainstorming` (Work axis). `kdd:*` skills are not invoked directly for
   workflow steps except where a fork skill says so.
3. New red flag: "I already know which specs apply, no need to activate" →
   *Activation is an auditable record, not your memory. Consult it.*

### Skill 2 — `brainstorming`

Unchanged: the three paths (spike / bounded / architectural), the
HARD-GATE, red flags, one question at a time, 2–3 approaches, sectioned
design with per-section approval, visual companion (now under
`.kdd/brainstorm/`). `spec-document-reviewer-prompt.md` (orphan) is
removed.

Output per path:

| Path | Upstream | kdd-superpowers |
|---|---|---|
| Spike | answer only | same; facts discovered in code may optionally become a FRAG (P11/P12) |
| Bounded | design in chat, no file | **compact WRK-SPEC**: same frontmatter; body limited to Problem, Proposed Change, Knowledge Context, Acceptance Criteria; no WRK-PLAN |
| Architectural | `docs/superpowers/specs/*.md` | **full WRK-SPEC**, then `writing-plans` |

Bounded work produces an artifact because without a WRK-SPEC there is
nowhere to freeze activation (P3) nor anything for consolidation to hang
on (P7). What scales with simplicity is the artifact's *size*, not its
existence.

New steps (architectural; bounded performs 1, 2, 4 and 6 in short form):

1. **Discover knowledge** — after "explore project context", invoke
   `kdd:spec-context "<description>"` as REQUIRED SUB-SKILL (P4). Skipped
   when there is no `specs/`.
2. **Capture from code (brownfield)** — if candidates do not cover what
   the work will touch and code exists, apply
   `kdd-conventions/references/capturing-from-code.md` (P12) and write
   FRAGs **before** the WRK-SPEC so it can cite them. Only what the work
   touches.
3. **Questions and approaches** — as upstream, informed: rules from
   candidate specs feed questions; each approach names the specs that
   constrain it.
4. **Design section "Knowledge activation"** — last section before
   writing: table of `activates` / `equips` with `ID@version` pins, the
   role of each, FRAGs cited as evidence, gaps (knowledge that should exist
   and does not), and the proposed semantic ID path. **Approving this
   section is the freeze (P3).**
5. **Adversarial gate A1 — spec red-team** (`spec-adversary-prompt.md`):
   before the human review gate, a subagent with only the draft WRK-SPEC
   and the activated spec files attacks it: rule of an activated spec it
   violates; requirement readable two ways; acceptance criterion
   satisfiable trivially; knowledge the work will need that is not
   activated. Attack table; controller adjudicates, ledgers rulings, fixes
   the draft.
6. **Write the WRK-SPEC** to `specs/work/` with frontmatter per
   `kdd-conventions` (status `draft`, `version 0.1.0`, pinned
   `activates`/`equips`, `activation_frozen: true`,
   `activation_resolved_at`, `dependencies` with `constrained-by` for
   activated specs and `implements` for a target FEAT, `sources` with
   FRAGs and their resources, `generated`, `stale_after` +90 days, `tags`).
   Body per KDD work-spec anatomy: Problem Statement → Proposed Change
   (with sub-headings Architecture / Components / Data flow / Error
   handling / Testing — the approved design) → Knowledge Context (table)
   → Constraints (**verbatim rules from activated specs, cited**) →
   Acceptance Criteria → Open Questions.
7. **Validate** — `spec-graph validate` must report 0 errors (P1). Then
   the upstream self-review extended with: every Constraint cites an
   activated spec or a FRAG; nothing in Proposed Change contradicts an
   activated rule.
8. **Commit and human gate** — as upstream. On approval the skill
   transitions `status: draft → active` and appends
   `verified: [{by: human:<id>, at}]` (P6). Then `writing-plans`
   (architectural) or implementation (bounded).

Out of v1: activation manifests (`new-task` / MFST). The skill documents
the hook point ("if a manifest exists for the task type, it replaces steps
1 and 4") without implementing it.

### Skill 3 — `writing-plans`

Unchanged: the philosophy, *File Structure*, *Task Right-Sizing*, 2–5
minute steps, *No Placeholders*, self-review, the two execution options.

- **Input**: a WRK-SPEC in `status: active`. Otherwise redirect to
  brainstorming; no planning from free text.
- **Output**: one WRK-PLAN plus one WRK-TASK **per task**, separate files
  in `specs/work/`. Separate task files fit SDD ("the implementer sees only
  its task") and the graph (each task has its own activations and
  dependencies).

**WRK-PLAN** — `layer: work-plan`, `parent: <WRK-SPEC>`, `dependencies`
`implements` the spec and `constrained-by` activated specs,
`activates`/`equips` **⊆ the spec's frozen set, same pins**,
`activation_frozen: true`, trust family (`sources` = spec + activated
specs + FRAGs). Body per anatomy: **Approach** (the upstream header: goal,
architecture, tech stack, and "REQUIRED SUB-SKILL:
kdd-superpowers:subagent-driven-development or executing-plans") →
**Task Breakdown** (table: task ID · description · dependencies; table
order = execution order) → **Architecture Impact** (replaces *Global
Constraints*: constraint · source spec · impact, rules copied verbatim) →
**Risk Assessment** → **Dependencies**. Scope check: a multi-subsystem
spec yields several WRK-PLANs sharing `parent`.

**WRK-TASK** — `parent: <WRK-PLAN>`, `activates` limited to the **2–5**
specs the task touches (the toolkit's task-level budget), pins inherited;
hard rule: a task activates nothing the spec does not (P3); same for
`equips`. Body per anatomy: **Objective** → **Implementation Notes**
(*Files*, *Interfaces* consumes/produces, and the `- [ ]` steps with real
code: failing test → run → minimal implementation → run → commit) →
**Acceptance Criteria** (each maps to a spec criterion or an activated
rule) → **Test Plan**. Trust family as the plan.

New steps:

1. Read the WRK-SPEC **and** the activated spec files (constraints are
   copied, not paraphrased).
2. Assign per-task activations while doing *File Structure*: which spec
   constrains which file.
3. Write plan and tasks; `spec-graph validate` 0 errors (P1).
4. Self-review extended: spec coverage (each WRK-SPEC acceptance criterion
   → a task), placeholders, type consistency, **activation coverage**
   (every constraint cites spec or FRAG; each task's `activates` ⊆ spec),
   **roll-up** (task criteria cover spec criteria).
5. **Adversarial gate A2 — plan red-team** (`plan-adversary-prompt.md`),
   conditional: more than 4 tasks, or the spec activates
   `confidence: low` / unverified specs, or the work touches security or
   money. Attacks: a task completable to the letter while violating an
   activated rule; neighbouring tasks whose interfaces disagree; a spec
   criterion with no task. Attack table; rulings; fixes.
6. Handoff: plan and tasks transition `draft → active` when the execution
   mode is chosen; the SDD workspace will be `.kdd/sdd/<WRK-PLAN-ID>/`.

### Skill 4 — `subagent-driven-development` and `executing-plans`

Unchanged: fresh subagent per task, two-stage review, 5-round fix loop
with model escalation, rulings over stalls, the four stop reasons, model
selection, batching, bounded waits, no-subagents contract, "do not trust
the report", final whole-branch review.

- **Input**: the WRK-PLAN (ID or path). The controller reads the plan
  (Approach, Task Breakdown, Architecture Impact) and creates one todo per
  WRK-TASK in table order. It never reads all task files.
- **Workspace and ledger**: `scripts/sdd-workspace WRK-PLAN-FILE` →
  `.kdd/sdd/<WRK-PLAN-ID>/`; ledger `progress.md`, first line
  `# SDD ledger — plan: <WRK-PLAN-ID> (<path>)`. Rulings gain a
  **`Knowledge gap:`** tag for anything touching knowledge (task needs a
  spec outside the frozen set, an activated rule contradicts the code, a
  FRAG proved false, a broken adversarial attack revealing missing
  knowledge). Consolidation harvests these (P3, P7).
- **Deterministic brief** (central change): `scripts/task-brief
  WRK-TASK-FILE` is a Node script that only shells out to `spec-graph`
  and writes `.kdd/sdd/<plan>/<WRK-TASK-ID>-brief.md` containing, in
  order: (1) the full WRK-TASK; (2) the plan's *Architecture Impact*;
  (3) each spec in the task's `activates`/`equips`, full content, from
  `spec-graph context <task> --depth 1 --format json`, with a **PIN DRIFT**
  header when file version ≠ pin (the controller ledgers it as a
  `Knowledge gap`); (4) the FRAGs cited in `sources`. One file, one
  `Read`, for implementer and reviewer alike; zero controller context.
  `kdd:spec-activate` is not in the loop (it remains for interactive use).
- **Pre-flight scan**: upstream rows (task pairs sharing a file;
  per-task self-consistency) plus, per task, its constraints against the
  current version of each activated spec (drift detection) and
  `activates` ⊆ the WRK-SPEC set.
- **Implementer prompt**: three additions — (a) "the brief includes the
  knowledge specs that bind you: their rules are requirements, not
  optional context"; (b) commits carry the task ID; (c) report section
  **Knowledge notes**: activated rules the code contradicted, observed
  undocumented behaviour (capture candidates — the implementer reports,
  never writes FRAGs).
- **Task reviewer prompt — three layers (P5)**: receives brief, report,
  diff. Verdicts: *spec compliance*, **knowledge compliance** (new: no
  violation of an activated rule or of FRAG-observed behaviour;
  violation = blocking), *quality*. **Gate A3** inside the same seat: for
  each activated rule the task touches, point to the test that guards it
  or give a concrete input that would violate it undetected. Section
  **Capture candidates** (anchored `path:lines@sha` + literal, read-only
  proposal). Section **Knowledge findings** (rules the code already
  contradicted before the diff → `Knowledge gap`).
- **Gate A4 — break the tests** (`test-adversary-prompt.md`), conditional:
  the task activates `CALC-*` or numeric/business rules, or is
  security-sensitive. A subagent sees only the task's tests and the brief
  and tries to write an implementation that passes them while violating
  the task or an activated rule; success means the tests are
  insufficient. Attack table; controller rules; fix round.
- **Gate A5 — acceptance attack**: the final whole-branch reviewer
  additionally attempts, per WRK-SPEC acceptance criterion, a scenario
  that would fail it, executed where possible. Attack table.
- **State transitions**: task review approved → controller sets the
  WRK-TASK to `status: completed` (+ `updated`) and commits it with the
  task's closing commit. Final review clean → WRK-PLAN `completed`. The
  WRK-SPEC stays `active` until `finishing-a-development-branch`.
- **`executing-plans`**: same input, same `task-brief` used by the
  executing session to load each task's context, same transitions, a
  reduced ledger (completed tasks and `Knowledge gap:` rulings). Stop
  conditions unchanged.

### Skill 5 — `requesting-code-review`, `code-reviewer.md`, `receiving-code-review`

Unchanged: review early and often, precisely crafted context, read-only,
no-subagents, severities, rationalizations, red flags; in
`receiving-code-review`, the response pattern and forbidden responses.

Three modes for `requesting-code-review` (P5, P11):

| Mode | Situation | Third layer of authority |
|---|---|---|
| 1. KDD work | a WRK-SPEC (and plan) exists | `scripts/review-brief WRK-SPEC-or-PLAN` → one file: WRK-SPEC acceptance criteria, plan *Architecture Impact*, activated specs in full (pin check), cited FRAGs |
| 2. No WRK-SPEC, knowledge base exists | external PR, hotfix, legacy review | controller invokes `kdd:spec-context "<change description>"`, human confirms the applicable specs, packaged into a brief; the skill reminds once that own changes should have a compact WRK-SPEC |
| 3. Pure brownfield | neither | as upstream (diff + given requirements + code conventions) **plus mandatory capture**: the reviewer lists the rules the code embodies and the change touches |

The reviewer receives a `{KNOWLEDGE_BRIEF}` path in all modes (mode 3:
requirements only).

`code-reviewer.md` changes: three verdicts (*requirements compliance* ·
**knowledge compliance** · *quality*; violating an activated rule or
FRAG-observed behaviour = Critical); gate A3 applied; gate A5 before
merge; section **Capture candidates** (all modes, mandatory in mode 3),
each anchored per P12.1 so the controller can write FRAGs without
re-exploring; section **Knowledge findings**.

Controller handling: Critical/Important as upstream; capture candidates →
offer to write FRAGs via `capturing-from-code.md` (cite-check included), or
ledger them in SDD; knowledge findings → ledger `Knowledge gap:` or note
for consolidation.

`receiving-code-review` addition — *When feedback conflicts with
knowledge*: if a reviewer comment contradicts an activated rule, the rule
wins unless the rule is wrong, in which case the comment is not followed
silently: a `Knowledge gap` is recorded so consolidation/governance updates
the spec (version bump, ADR). Human feedback revealing an undocumented rule
is a capture candidate with `source_type: chat` and the human actor.

### Skill 6 — `finishing-a-development-branch`

Unchanged: verify tests → detect environment → base branch → the exact
3/2-option menu → execute → cleanup; integration is the human's decision;
typed `discard`; all rationalizations.

New steps between "tests green" and "menu":

- **1b. Verify knowledge integrity** (failure = no menu): `spec-graph
  validate` 0 errors; all WRK-TASKs and the WRK-PLAN in `completed`;
  `spec-graph export-okf --out <scratch>` exits 0 (P8; bundle discarded).
- **3b. Persist the chronicle**: append a `## Execution Log` section to
  the WRK-PLAN with the ledger's rulings, `Knowledge gap:` entries, broken
  attacks and pending capture candidates; commit. `kdd:spec-consolidate`
  finds them where it already looks (plan/task bodies).
- **3c. Consolidate (P7)**: REQUIRED SUB-SKILL `kdd:spec-consolidate
  <WRK-SPEC-ID>`. Around it the fork adds: pending capture candidates are
  first written as FRAGs via `capturing-from-code.md` (cite-check); any
  FRAG → DOM/ARCH promotion passes **gate A6** (`frag-adversary-prompt.md`:
  verify anchors, search for counterexamples; only what resists is
  distilled); everything the human accepts (ADRs, spec bumps, FRAGs
  `distilled`, new specs at `confidence: low`) is **committed on the work
  branch** so knowledge travels with the code. If the human defers
  consolidation, the skill says once that the branch context will be gone
  after merge, respects the decision, leaves the WRK-SPEC `completed` and
  the bootstrap lists it as *pending consolidation*.
- **3d. Transitions**: WRK-SPEC `active → completed` (+ `updated`, and
  `verified` by the human if they confirm the close). After consolidation
  is applied, spec/plan/tasks → `archived`. Own commit:
  `chore(<WRK-SPEC-ID>): close and consolidate`.

New rationalizations: "Consolidation can wait until after merge" /
"Nothing was learned" / "The FRAG is obviously right, skip the adversary"
/ "Validate fails on a minor warning from another spec" — each answered
in the skill.

### Skill 7 — `verification-before-completion`

Structure unchanged. *Common Failures* gains rows: artifact written →
`spec-graph validate` 0 errors read; activated rules honoured → brief
without PIN DRIFT + knowledge-compliance ✓ with test or counterexample
(A3); FRAG faithful → cite-check passed; OKF-conformant → `export-okf`
exit 0; work closed → `status: completed` in spec/plan/tasks and validate
green; nothing to consolidate → Execution Log read, 0 `Knowledge gap:`, 0
capture candidates. New red flag: "I wrote the spec, I know what it
says" → the file with its version is what counts; read it.

### Shared skill — `kdd-conventions` (new)

An invocable skill the others cite as "REQUIRED SUB-SKILL when writing any
KDD artifact":

- `SKILL.md`: ID rules, locations (`specs/work/`, `specs/_capture/`,
  `.kdd/`), state transitions and who performs them, trust family and
  actor convention (`claude-code/<model>`, `human:<id>`), P13.
- `references/artifact-templates.md`: frontmatter + body of WRK-SPEC
  (full and compact), WRK-PLAN, WRK-TASK, FRAG.
- `references/capturing-from-code.md`: P11/P12 in operational form.
- `references/adversarial-gates.md`: the common rule for gates A1–A6
  (adversary gets only the artifact + repo; output is an attack table —
  attack · concrete scenario · result · evidence, never an opinion;
  controller adjudicates and ledgers `Attack: … — Ruling: …`; a broken
  attack on an activated rule is blocking; most capable model for spec/plan
  adversaries, mid tier for task adversaries). Concrete prompt templates
  live in each skill.

Adversarial gate budget in the typical cycle (spec + 5-task plan): A1 +
A2 + A6 = three extra seats; A4 only on tasks that warrant it; A3 and A5
are contracts inside existing seats.

### Scripts

| Script | Type | Function |
|---|---|---|
| `scripts/kdd-cli` (in `using-superpowers`) | bash | locate `spec-graph.mjs` (search order above); used by hook and scripts |
| `sdd-workspace` | bash (modified) | `.kdd/sdd/<WRK-PLAN-ID>/` |
| `task-brief` | node (new) | task brief with PIN DRIFT |
| `review-brief` | node (new) | spec/plan-level brief for code review |
| `review-package` | unchanged | packaged diff |
| `frag-cite-check` | bash (new) | verify every `path:lines@sha` anchor + literal of a FRAG; non-zero exit on failure |
| `next-id` | bash (new) | next free `TYPE-PATH-NNN` by scanning `specs/` |

Dependencies: bash, git, node, the toolkit CLI. Nothing added to
`package.json`.

### Repository cleanup

- Remove `docs/superpowers/`, `docs/plans/` (upstream design history stays
  in git), `spec-document-reviewer-prompt.md`, the brand image URL in the
  visual companion server.
- Remove all non-Claude-Code harness assets: `hooks/hooks-cursor.json`,
  `gemini-extension.json`, `GEMINI.md`, `AGENTS.md`,
  `scripts/package-codex-plugin.sh`, `scripts/sync-to-codex-plugin.sh`,
  `docs/README.kimi.md`, `docs/README.opencode.md`,
  `docs/porting-to-a-new-harness.md`, `docs/windows/`,
  `using-superpowers/references/*-tools.md`, and `tests/{antigravity,
  codex, codex-plugin-sync, devin, hermes, kimi, opencode, pi}`. The
  *Platform Adaptation* section of `using-superpowers` is removed with
  them.
- `CLAUDE.md` rewritten as the fork's contributor guide (principles
  P1–P13, how to test, relation to the KDD repo and the `kdd` plugin).
- `README.md` rewritten for `kdd-superpowers`: what it is, dependency on
  the `kdd` plugin, installation (uninstall upstream first), the flow,
  principles, attribution to superpowers 6.3.0.
- Version `0.1.0`; `scripts/bump-version.sh` kept.

### Testing

- `tests/claude-code/` (real-harness runner) and `tests/hooks/` kept;
  scenarios added per skill: hook emits valid JSON with the environment
  block in all four states; brainstorming with/without `specs/` and
  bounded; writing-plans produces plan + tasks that validate with
  activations ⊆ spec; SDD `task-brief` four sections and PIN DRIFT,
  `sdd-workspace` under `.kdd/`, ledger `Knowledge gap:` on reviewer
  violation, task → `completed`; review brief per mode and Critical on
  rule violation; finishing stops on an `active` task and runs
  consolidation when clean.
- New `tests/scripts/` (bash only, no Claude): `task-brief`,
  `review-brief`, `frag-cite-check`, `next-id`, `kdd-cli` against a
  minimal `specs/` fixture.
- Invariant test: no file contains `superpowers:` without the `kdd-`
  prefix, nor `.superpowers/`, nor `docs/superpowers/`.
- Fixture `specs/` for tests validated with the toolkit CLI; CLI for the
  fork's own development resolved from the sibling KDD repo
  (`../knowledge-driven-development/apps/spec-graph`) when the `kdd`
  plugin is not installed.

## Knowledge Context

This repository has no knowledge base of its own; `activates` is empty
(P2). The work rests on the KDD framework documents cited in `sources`,
which live in the sibling repository and are read as external references,
not activated specs.

| Source | Role in this work |
|---|---|
| KDD-TAXONOMY | four axes; what a work artifact may activate/equip |
| KDD-ANATOMY | frontmatter schema, work-artifact body sections, trust family, actor convention |
| KDD-BROWNFIELD | "start where it hurts"; code-embedded rules become specs only when touched |
| KDD-OKF | export/import mapping; conformance comes from valid frontmatter |
| KDD-MANIFESTS | frozen-activation semantics (`activation_frozen`, pins) reused without manifests |
| KDD-TOOLKIT | the `kdd` plugin the fork depends on: CLI commands and `/kdd:spec-*` skills |
| KDD-CLI-IDS | ID grammar the semantic-path rule relies on |
| UPSTREAM | the base every skill is derived from |

## Constraints

- IDs must match `spec-graph`'s `ID_PATTERNS` (`^PREFIX(-[A-Z0-9]+)*-\d{3}$`)
  — the semantic-path rule places the number last for this reason
  (KDD-CLI-IDS).
- `activates` accepts only Knowledge-axis references, `equips` only
  Agentic-axis references; `FRAG-*` and `lifecycle: deliverable`
  projections are never activated (KDD-MANIFESTS, toolkit
  `spec-activate` Step 3).
- Trust family: `generated.by` / `verified[].by` follow the actor
  convention; `verified` is recorded only after an explicit human
  confirmation (KDD-ANATOMY; toolkit `spec-consolidate` Step 3.2).
- Fragment `source_type` has no `code` value; code-derived FRAGs use
  `report` (the agent's exploration report is `files[]`, with
  `integrity`), and adding `source_type: code` is proposed to the KDD
  repository as an external change (KDD-ANATOMY).
- Fork skills invoke toolkit skills as `kdd:spec-context`,
  `kdd:spec-consolidate`; the CLI is invoked only through `scripts/kdd-cli`
  (KDD-TOOLKIT).
- No path in the plugin or in projects it operates on contains
  `superpowers` (P13).
- Claude Code is the only supported harness in this sub-project.

## Acceptance Criteria

- [ ] Plugin installs as `kdd-superpowers` 0.1.0 from the fork's marketplace; no file references `superpowers:` without the `kdd-` prefix, `.superpowers/`, or `docs/superpowers/` (invariant test passes).
- [ ] Session start injects `using-superpowers` plus a `<KDD-ENVIRONMENT>` block; with the toolkit absent, invoking `brainstorming` stops with an install instruction.
- [ ] In a project with `specs/`, brainstorming (architectural) produces a WRK-SPEC under `specs/work/` with pinned `activates`, `activation_frozen: true`, trust family, semantic-path ID, that passes `spec-graph validate` with 0 errors, and transitions to `active` with a `verified` human entry on approval.
- [ ] In a project without `specs/`, brainstorming creates `specs/work/`, writes `activates: []`, and any FRAG it writes passes `frag-cite-check`.
- [ ] Bounded brainstorming produces a compact WRK-SPEC and no WRK-PLAN.
- [ ] `writing-plans` from an active WRK-SPEC produces a WRK-PLAN and one WRK-TASK file per task with IDs `WRK-TASK-<path>-<PPP>-<TTT>`, every task's `activates` ⊆ the spec's set, *Architecture Impact* citing each activated spec, and 0 validation errors.
- [ ] `task-brief` writes a brief with the four sections and a PIN DRIFT header when a pinned version differs from the file.
- [ ] SDD ledger lives under `.kdd/sdd/<WRK-PLAN-ID>/`; a reviewer-reported rule violation appears as `Knowledge gap:`; an approved task is `status: completed` in its closing commit.
- [ ] Task reviewer and code reviewer templates return a *knowledge compliance* verdict and mark an activated-rule violation as blocking/Critical; capture candidates are anchored.
- [ ] Adversarial gates A1–A6 exist as templates with the common attack-table contract; A2 and A4 trigger only under their stated conditions.
- [ ] `finishing-a-development-branch` refuses the menu when validate fails or a task is not `completed`; when clean, it appends the Execution Log, invokes `kdd:spec-consolidate`, runs `export-okf` successfully, and transitions the WRK-SPEC to `completed`.
- [ ] `tests/scripts/` passes without Claude; `tests/claude-code/` and `tests/hooks/` pass on Claude Code.
- [ ] README and CLAUDE.md describe the fork, its dependency on the `kdd` plugin, and the principles; all non-Claude-Code harness assets are removed.

## Open Questions

- `source_type: code` for fragments — to be proposed in the KDD repository; until then code-derived FRAGs use `report`.
- SDD ledger vs. RFC-KDD-003 flow runs (`events.jsonl` beside the WRK-SPEC): aligning SDD execution with `new-run` / `run-status` is deferred to a later sub-project.
- Activation manifests (`new-task` / MFST) in brainstorming: hook point documented, implementation deferred until the toolkit's task-type registry is data-driven.
- opencode support (toolkit already ships an opencode adapter): deferred; would be its own sub-project.
