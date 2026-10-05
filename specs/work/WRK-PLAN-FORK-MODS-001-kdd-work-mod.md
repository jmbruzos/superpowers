---
id: WRK-PLAN-FORK-MODS-001
type: spec
layer: work-plan
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
title: "kdd-work mod — implementation plan"
parent: WRK-SPEC-FORK-MODS-001
activates: []
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-FORK-MODS-001
    relation: implements
sources:
  - id: WRK-SPEC-FORK-MODS-001
    resource: specs/work/WRK-SPEC-FORK-MODS-001-kdd-work-mod.md
  - id: FRAG-FORK-LEDGER-001
    resource: specs/_capture/FRAG-FORK-LEDGER-001-sdd-ledger-line-forms/
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-05T13:30:00+02:00
stale_after: 2027-01-03T13:30:00+01:00
tags: [fork, mods, plan]
---

# WRK-PLAN-FORK-MODS-001 — kdd-work mod

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file under `specs/work/`; steps use checkbox (`- [ ]`) syntax for tracking.

## Approach

**Goal:** an optional Claude Code mod, `kdd-work`, that shows open KDD work live (pane, status line) and keeps pending consolidation visible (band), fed by a deterministic `kdd-status` script.

**Architecture:** `skills/kdd-conventions/scripts/kdd-status` (+ a pure `kdd-status-lib.mjs`) computes the state of open work as JSON through `kdd-cli`, reading only the SDD ledgers itself. `mods/kdd-work/` is a separate plugin of function hooks that locates the main plugin, runs `kdd-status` on relevant events, keeps the result in `$.state` and draws it. Formatting lives in pure functions so it is testable apart from the engine.

**Tech Stack:** Node ESM (no dependencies) and bash tests for the script; TypeScript/TSX function hooks for Claude Code build 2.1.289 (`claude-code` and `claude-code/testing` modules), `claude plugin validate|test`, `tsc`.

**Spec:** `specs/work/WRK-SPEC-FORK-MODS-001-kdd-work-mod.md` — the plan argues from the spec, so executors read both.

**Mod API authority:** the engine's declaration file. Before the mod has loaded: `/private/tmp/claude-501/bundled-skills/2.1.289/b0610be21fa2b284bc6b23b836f226b9/plugin-authoring/types/claude-code.d.ts` (re-written each time the `plugin-authoring` skill loads; after a restart, load that skill to get the current path). After the engine has loaded the mod: `mods/kdd-work/.claude-plugin/types/claude-code/index.d.ts`. The code in tasks 002–003 is written against build 2.1.289; where `tsc` or `claude plugin validate` disagrees with a name in this plan, the declaration file wins — keep the behaviour and the assertion, change the spelling, and ledger the deviation.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-FORK-MODS-001-001 | `kdd-status` + `kdd-status-lib.mjs` + `tests/scripts/test-kdd-status.sh` | — |
| WRK-TASK-FORK-MODS-001-002 | Mod core: manifest, contract, root location, refresh, status line, skill recording, tests | 001 |
| WRK-TASK-FORK-MODS-001-003 | Mod UI: `/kdd-work` pane, consolidation band, `/kdd-work dismiss`, tests | 002 |
| WRK-TASK-FORK-MODS-001-004 | Packaging: marketplace entry, invariants, `.gitignore`, release notes, README, manual check | 003 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| "Deterministic → CLI; judgment → toolkit skill." | WRK-SPEC-FORK-CORE-001 P4 | All state computation is in task 001's script; the mod (002–003) formats and draws only |
| "No path contains `superpowers`." | WRK-SPEC-FORK-CORE-001 P13 | New paths: `skills/kdd-conventions/scripts/kdd-status`, `kdd-status-lib.mjs`, `mods/kdd-work/`; the mod writes nothing into projects |
| "The only place in kdd-superpowers that knows where spec-graph.mjs lives" | `skills/using-superpowers/scripts/kdd-cli` header | `kdd-status` calls `kdd-cli`; it never names `spec-graph` nor parses spec frontmatter |
| `# SDD ledger — plan: <WRK-PLAN-ID> (<plan file path>)` | FRAG-FORK-LEDGER-001, `subagent-driven-development/SKILL.md:155-155@85acb22` | ledger used only when line 1 starts with `# SDD ledger — plan: <plan id> ` |
| `Task <WRK-TASK-ID>: complete (commits <base7>..<head7>, review clean)` and `[Ledger: Task 1: complete (commits a1b2c3d..d4e5f6a, review clean)]` | FRAG-FORK-LEDGER-001, `SKILL.md:475-475`, `SKILL.md:592-592` | completion by prefix, by id or by position |
| "TTT = position in the plan's Task Breakdown" | kdd-conventions/SKILL.md:24 | `Task <n>` maps to the task whose id ends in `-<n zero-padded to 3>` |
| `collect every ledger line containing` `Ruling:` | FRAG-FORK-LEDGER-001, `SKILL.md:535-535` | ledger tail by containment of `Ruling:` / `Knowledge gap:` |
| finishing requires an `active` WRK-SPEC; a closed-without-archiving one stays pending "until `kdd:spec-consolidate` runs" | `finishing-a-development-branch/SKILL.md:47, 146-148` | band text `run kdd:spec-consolidate <id>` |
| `bump-version.sh` writes `plugins.0.version` only | `.version-bump.json` | `kdd-work` is `plugins[1]`; its versions are bumped by hand; invariant asserts they match |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Mod API names in this plan differ from the build that runs the tests (early access) | medium | task 002/003 stalls on type errors | declaration file is the authority (see Approach); `claude plugin validate` and `tsc` run in each task before tests |
| `claude plugin test` cannot raise `session.start`/`turn.complete` directly | medium | refresh tested only through `tool.call` | tests drive refresh via `$.tool.call` (documented path); the other triggers are covered by the manual check in 004 |
| A real ledger writes lines with a list bullet (`- Task …`) | low | completion missed | lib strips a leading `- ` / `* ` before matching; test covers it |
| `kdd-cli filter` output is large (bodies) | low | slow refresh on big graphs | three `--layer` calls; refresh only on events, debounced |

## Dependencies

- `kdd` toolkit (`spec-graph`) reachable through `kdd-cli` (tests set `KDD_SPEC_GRAPH`).
- Claude Code build with function hooks (2.1.289 used to write this plan); `claude` and `tsc` on PATH for tasks 002–004 (`npx -y -p typescript tsc` when `tsc` is not installed).

## Execution Log

Persisted from the SDD ledger `.kdd/sdd/WRK-PLAN-FORK-MODS-001/progress.md` (worktree `.claude/worktrees/kdd-work-mod`, branch `feat/kdd-work-mod`, merged fast-forward into main at b4c0de5). Tasks: 001 cc1cfe9 · 002 8fbb2e4..1b156ae (1 fix round) · 003 9c60ae7 · 004 7f92a7f · final-review fix wave b4c0de5.

### Rulings
- Ruling: proceed with test-transition.sh red as a known pre-existing failure, approved by human partner — any change in its failure count is a regression — costs: a real regression in transition could hide behind the known red.
- Ruling: in this worktree "no failure beyond the two pre-existing ones" (spec AC5, task 004 Steps 2/4/6) means test-invariants.sh fully green — the two failures came from the untracked docs/superpowers/ in the main checkout only — costs: none if wrong; stricter bar.
- Ruling: state.ts is dropped from the plan's Produces block — the engine requires atoms to be consts in the file that reads/writes them, so a shared atoms module cannot exist; task 003 declares/uses the atoms inside register.tsx — costs if wrong: task 003 must re-split later.
- Ruling: WRK-TASK-FORK-MODS-001-004 is completed on Steps 1–7; its live checks (Steps 8–9, spec AC6) are run by the human partner before the WRK-PLAN is set to completed — they need an interactive session — costs if wrong: a broken live behaviour (ui.render hooks, session.start/turn.complete triggers) is found after the task closed and reopens the plan.
- Ruling: focus ranking across two open specs unguarded → test in fix wave (Important #3).
- Ruling: fix wave also takes Minor #5 (clear `status` when the main root is not found, spec "no band"), #6 (status line empty on a status error, spec "status line … empty"), plugin.json `author` — one line each — costs: none.
- Ruling: Minor #7 (working-copy test depends on /mods/ path), #8 (refresh cost, turn.complete per subagent loop) stay deferred — costs: brittle test in an unusual checkout; ~360 ms per subagent turn.
- Ruling: `e.args.trim()` deferred minor dropped — CommandRunInput.args is declared `string` ("" when none), claude-code.d.ts:1715-1720.
- Ruling: WRK-PLAN-FORK-MODS-001 set to completed without the live check (spec AC6, task 004 Steps 8–9) — human partner's explicit decision ("pásalo todo a complete") after merge to main — costs if wrong: a ui.render or session.start/turn.complete defect surfaces in use and needs a follow-up WRK-SPEC.

### Knowledge gaps
- Knowledge gap: mod API (early access) constraints not in any spec — static scan rules for `$` and atoms, test-kit op answer shapes; authority is claude-code.d.ts/engine, not versioned here (spec gap (2)).
- Knowledge gap: `turn.complete` fires for every agent loop, carrying `agentId` (claude-code.d.ts:363) — not stated in the spec's Data flow; adds to the mod-API gap.

### Attacks broken and adjudicated
- WRK-SPEC-FORK-MODS-001 gate A1: 17 attempted, 16 BROKEN — 14 accepted, 2 rejected; full table under the WRK-SPEC's `## Adversarial Review`.
- WRK-PLAN gate A2: not triggered (4 tasks, no low-confidence activation, no security/money logic).
- Attack: AC6 status line "shows this WRK-SPEC's focus" — Ruling: accepted as a spec-text defect, not code — with all MODS-001 tasks done both open specs rank `finishing` and the id tie-break picks WRK-SPEC-FORK-CORE-001, which is the spec's own focus rule; the WRK-SPEC (human-verified) is not edited mid-plan; the live check expects `WRK-SPEC-FORK-CORE-001 · finishing` — costs if wrong: the human partner wanted the newest work to win ties; then the tie-break rule changes in a follow-up.
- Attack: AC4 "refresh only after the tool resolved" unguarded (mutation passes) — Ruling: accepted → test in fix wave.
- Attack: AC2 header contract — toolkit JSON that is not an array crashes kdd-status (exit 1) — Ruling: accepted → Array.isArray guard in fix wave.

- Attack (A6, FRAG-FORK-LEDGER-001: 15 attempted, 9 BROKEN): done-by-ledger contradicts SDD:480-482 ("A task whose file still says `active` is not complete, whatever the ledger says"); identity is compared by plan file in SDD:148-153, by plan ID in kdd-status-lib.mjs:21; "Task <n>" = position vs id suffix not settled by SDD:592/618; `<repo-root>` is the worktree holding the plan (sdd-workspace:39), so kdd-status run from the main checkout misses a worktree's ledger; inventory of line forms incomplete (`Capture candidate:`, `Attack: … — Ruling:`, pre-flight table, ledger notes); absence outdated (kdd-status now reads the ledger) — Ruling: FRAG stays `ingested`; DOC-FORK-LEDGER-001 distils only the RESISTED contract and lists the contradictions under *Known inconsistencies* as open work, not as rules.
- Attack (A6, FRAG-FORK-MODS-001: 17 attempted, 7 BROKEN): ui.test.ts:4 anchors split by a backtick lose `$.command.run`; the d.ts line it cites (:14343) is the EngineNoun mapping, CommandRunInput is :1710; `$` rule is narrower than stated — empirically (`claude plugin validate` on copies) `$` may only be passed by name to a function declaration (or const bound to one) at the top of the same file, never across an import, never as a value; state references must be inline literals or atom/derive/memberOf/literal consts of the same file (atoms not required); `turn.complete` per subagent rests on d.ts :12647-12653, not :362-363 (fires once per run of a subagent loop); `agentId` on `$.tool.call` is dropped by the engine (d.ts :12077-12081) though the test kit carries it, so the main-loop-only test does not prove production behaviour; byId defined at kdd-status-lib.mjs:12 — Ruling: FRAG stays `ingested`; DOC-FORK-MODS-001 distils the RESISTED claims in the adversary's empirically confirmed wording and marks the `agentId` claim as contradicted.

### Capture candidates (captured as FRAG-FORK-MODS-001, 2026-10-05)
- `mods/kdd-work/hooks/register.tsx:9-10@51419f7` — engine rule: state atoms must be consts of the file that uses them (final review).
- `mods/kdd-work/hooks/register.test.ts:78@51419f7` — `agentId` is on the hook's `e` (AgentLoop), not in `$.tool.call`'s declared input (final review).
- `mods/kdd-work/hooks/ui.test.ts:3-6@9c60ae7` — test kit `$.command.run` takes the full CommandRunInput (task 003 review).
- `skills/kdd-conventions/scripts/kdd-status-lib.mjs:21@51419f7` — ledger identity contract now in code; input to distil FRAG-FORK-LEDGER-001 (final review).
- `skills/kdd-conventions/scripts/kdd-status-lib.mjs:78@51419f7` — focus tie-break by id within a phase rank (final review).

### Parked / deferred
- Task WRK-TASK-FORK-MODS-001-001: minor (deferred): implementer report misstates line counts / line refs and records no actual RED run ("would have failed") — TDD evidence is narrative only.
- Task WRK-TASK-FORK-MODS-001-001: minor (deferred): test group comments dropped from test-kdd-status.sh (readability).
- Task WRK-TASK-FORK-MODS-001-001: minor (deferred): group 20 read check counts readFileSync/readdirSync only (plan-mandated).
- Task WRK-TASK-FORK-MODS-001-001: minor (deferred): untested branches — archived task/plan as done, draft plan with a ledger (no current task), active plan all-done by ledger; no test pins identity line without path, nor `complete (… <K> parked)` form.
- Task WRK-TASK-FORK-MODS-001-002: minor (deferred): concurrent refresh — a slow earlier run can overwrite a newer result (no in-flight guard), register.tsx:329-335.
- Task WRK-TASK-FORK-MODS-001-002: minor (deferred): `status!.phase` non-null assertion in format.ts; plugin.json has no author (validate warning); `.kdd/` branch of touchesWork untested at hook level.
- Task WRK-TASK-FORK-MODS-001-003: minor (deferred): pane lines.map children without `key` (register.tsx:263-267, plan-mandated code); `e.args.trim()` throws if args undefined (register.tsx:250) — `(e.args ?? '').trim()`; ui.render hooks untested (live check in 004); ui.test world() stubs uncommented, pane-open branch does not assert bandDismissed untouched.
- Task WRK-TASK-FORK-MODS-001-004: minor (deferred): marketplace entry without category/homepage; invariant §5 hides node errors (`got: ` without cause); commit 7f92a7f attribution says Claude Haiku 4.5.

## Adversarial Review
