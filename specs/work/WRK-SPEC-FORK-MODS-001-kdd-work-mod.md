---
id: WRK-SPEC-FORK-MODS-001
type: spec
layer: work-spec
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
title: "kdd-work — a Claude Code mod showing open KDD work: pane, status line and consolidation band"
activates: []
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-05T12:50:00+02:00
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: relates-to
sources:
  - id: FRAG-FORK-LEDGER-001
    resource: specs/_capture/FRAG-FORK-LEDGER-001-sdd-ledger-line-forms/
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-05T12:50:00+02:00
verified:
  - by: human:jmbruzos
    at: 2026-10-05T12:52:30+02:00
  - by: human:jmbruzos
    at: 2026-10-05T17:03:02+02:00
stale_after: 2027-01-03T12:50:00+01:00
tags: [fork, mods, ui, ledger]
---

# WRK-SPEC-FORK-MODS-001 — kdd-work: a Claude Code mod showing open KDD work

## Problem Statement

Where a piece of KDD work stands lives in three places: the frontmatter of the
WRK-SPEC / WRK-PLAN / WRK-TASKs under `specs/work/`, the SDD ledger under
`.kdd/sdd/<WRK-PLAN-ID>/progress.md`, and which workflow skill is running now.
The model sees a one-line summary once, at session start (`<KDD-ENVIRONMENT>`,
`open_work:`); your human partner sees none of it without opening files. Work
left `completed` but never consolidated — the step P7 says no work closes
without — is mentioned once and then forgotten.

Claude Code mods (function-hook plugins) can draw a live pane, a status line
entry and a band above the prompt. This work adds an optional mod, `kdd-work`,
that shows open work live — including the latest rulings and knowledge gaps
the ledger recorded, which today are visible only by opening `.kdd/` — and
keeps pending consolidation visible.

## Proposed Change

### Architecture

Two units with one purpose each:

1. **`skills/kdd-conventions/scripts/kdd-status`** (main plugin, Node ESM, no
   dependencies): computes the state of open work as JSON. Deterministic,
   testable without Claude (P4).
2. **`mods/kdd-work/`** — a separate plugin of function hooks: runs
   `kdd-status`, keeps its last result in `$.state`, and draws it. No KDD logic
   of its own beyond formatting.

The mod is a separate plugin because the mod API is early access and moves
between Claude Code releases; a break there must not touch the main plugin's
session-start. `kdd-work` is the second entry of
`.claude-plugin/marketplace.json` (`source: "./mods/kdd-work"`), after
`kdd-superpowers`, with its own version; `scripts/bump-version.sh` keeps
bumping `plugins[0]` only.

Out of scope: archived history, editing from the pane, any change to
`hooks/session-start` or `<KDD-ENVIRONMENT>`.

### Components

**`kdd-status [--specs DIR] [--json]`** — run with the session's cwd. The
**root** is `git rev-parse --show-toplevel` from the cwd, or the cwd itself
outside a git repository (the same root `sdd-workspace` uses); `specs` defaults
to `<root>/specs`. The JSON carries `root` so the pane can show what it reads.

- Spec data: `skills/using-superpowers/scripts/kdd-cli --specs <DIR> filter
  --layer <work-spec|work-plan|work-task> --format json`, using `id`, `layer`,
  `status`, `title`, `file`, `parent`. No frontmatter parsing of its own;
  `kdd-cli` stays the only place that knows where the toolkit is. `kdd-cli`
  exiting 3 becomes `{"error":"toolkit-not-found","message":<its stderr>}`,
  exit 0.
- No `specs/` directory: `{"open_work":[],"phase":"idle",...}` (all lists empty), exit 0.
- Open work: WRK-SPECs with status `draft`, `active` or `completed`, sorted by
  id. `draft` is included on purpose (it is the `spec-review` phase), unlike
  `<KDD-ENVIRONMENT>` `open_work`, which lists only `active|completed`; their plans (`parent` = spec id); each plan's tasks (`parent` = plan id),
  sorted by id.
- Ledger per plan: `<root>/.kdd/sdd/<plan id>/progress.md`. Used only if
  its first line starts with `# SDD ledger — plan: <plan id> `; otherwise the
  plan gets `ledger: "mismatch"` and is computed from frontmatter alone. Absent
  → `ledger: "none"`.
- A task is **done** if its status is `completed|archived`, or the ledger has a
  line starting with `Task <task id>: complete` or `Task <n>: complete`, where
  `<n>` is the task's position, i.e. the `TTT` suffix of its id without leading
  zeros (kdd-conventions: "TTT = position in the plan's Task Breakdown").
- **Current task** of a plan: the first not-done task, only if the plan's
  ledger is used and the plan is `active`; it is `in-progress`, every other
  not-done task `pending`.
- **Ledger tail**: the last 5 lines of a used ledger containing `Ruling:` or
  `Knowledge gap:`.
- **Phase** per open WRK-SPEC, first rule that applies: `completed` →
  `consolidation-pending`; `draft` → `spec-review`; `active` and some plan is
  `active` with a not-done task → `executing`; `active` and some plan is
  `draft` → `planning`; `active`, at least one plan, and every plan is
  `completed|archived` or has at least one task with all its tasks done →
  `finishing`; any other `active` spec (no plan, a plan with no tasks) →
  `planning`.
- **Focus**: the open WRK-SPEC whose phase ranks first in `executing >
  finishing > planning > spec-review > consolidation-pending`, ties by id; no
  open work → phase `idle`.
- Output (stable keys): `open_work[]` ({id, title, status, phase, plans[]
  ({id, status, ledger, done, total, tasks[] ({id, title, state}), ledger_tail[]})}),
  `focus` ({spec, plan, task, done, total} or null), `phase`,
  `pending_consolidation[]` (ids of `completed` WRK-SPECs).

**`mods/kdd-work/`** — `.claude-plugin/plugin.json`, `hooks/hooks.json`
(`{"modules":["./register.tsx"]}`), `hooks/register.tsx`, `types/index.d.ts`
(the `$.state` contract), `hooks/*.test.ts`.

- Files also: `tsconfig.json` extending `./.claude-plugin/types/tsconfig.json`
  (laid by the engine when it loads the mod); `.claude-plugin/types/` is
  gitignored (machine-specific, generated).
- Version: `mods/kdd-work/.claude-plugin/plugin.json` `version` and
  `marketplace.json` `plugins[1].version` are bumped by hand and must match;
  `test-invariants.sh` asserts it.
- Locates the main plugin root, first hit wins: `$.env.get("KDD_SUPERPOWERS_ROOT")`;
  `$.plugin.root/../..` when it holds `skills/kdd-conventions/scripts/kdd-status`
  (working copy); the newest version (semver order) under
  `~/.claude/plugins/cache/kdd-superpowers/kdd-superpowers/`.
- `$.state`: `status` (last good `kdd-status` JSON), `stale` (reason or none),
  `skill` (last `kdd-superpowers:*` skill invoked this session on the main
  loop), `bandDismissed`.
- **Status line** (`$.ui.status`): with a focus task
  `<task id> · <done>/<total>`, else `<spec id> · <phase>`; then
  ` · <skill without the kdd-superpowers: prefix>` when one is recorded. With
  no open work: the skill alone, or cleared.
- **Pane** (`/kdd-work`, `$.ui.open`): per open WRK-SPEC its phase, per plan
  its tasks marked ✓ done / ▶ in-progress / · pending, `ledger mismatch` when
  flagged, then the ledger tail; a header line with the `root` being read; a
  `stale: <reason>` line when the last refresh failed.
- **Band** (`AbovePrompt`): while `pending_consolidation` is non-empty and
  `bandDismissed` is false: `Consolidation pending: <id> — run
  kdd:spec-consolidate <id>` (one id per completed WRK-SPEC, comma-joined). `/kdd-work dismiss` sets
  `bandDismissed` for the session.

### Data flow

`session.start`, `turn.complete`, and a `tool.call` of Write/Edit/Bash whose
input mentions `specs/` or `.kdd/` — scheduled after `await next(e)` resolves,
so the tool's effect is on disk — → refresh, debounced 300 ms with
`$.clock.after` → `$.process.run(["node", "<root>/skills/kdd-conventions/scripts/kdd-status",
"--json"], { cwd: $.session.cwd(), timeoutMs: 5000 })` → parse → `$.state`
(pane and band redraw) → `$.ui.status(...)`. The skill is recorded from a
`tool.call` of `Skill` without `agentId` (main loop only; subagents' calls are
ignored) and from `skill.prompt` (a skill your human partner types), when its
name starts with `kdd-superpowers:`; recording redraws the status line and
runs no process.

### Error handling

| Case | Result |
|---|---|
| Main plugin root not found | status `kdd-work: kdd-superpowers not found`; pane explains `KDD_SUPERPOWERS_ROOT`; no band |
| `error: toolkit-not-found` | pane shows the message; status line and band empty |
| No `specs/` | nothing shown; pane says `no specs/ in this project` |
| Process fails, times out, or prints invalid JSON | last good state kept; `stale: <reason>` in the pane; no retry until the next event |
| Ledger first line missing or naming another plan | that plan from frontmatter only; pane shows `ledger mismatch` |
| Session cwd is not where the work is (manual worktree fallback entered with `cd`) | not detected: the mod shows the workspace at `root`, which the pane header names (Knowledge gap, see *Knowledge Context*) |

### Testing

- `tests/scripts/test-kdd-status.sh` (picked up by `run.sh`), over temporary
  copies of `tests/scripts/fixtures/specs/` (BILL-PRORATA: spec, plan and two
  tasks, all `active`), not a git repository (root = cwd), with
  `KDD_SPEC_GRAPH` set: no ledger → `executing`,
  0/2, no current task; ledger completing `WRK-TASK-BILL-PRORATA-001-001` →
  1/2, current 002; ledger with `Task 1: complete` → same; ledger naming
  another plan → `mismatch`, 0/2; spec set to `draft` → `spec-review`; plan
  removed → `planning`; plan with no tasks → `planning`; a second, `draft`
  plan beside the active one → still `executing`; both tasks `completed` →
  `finishing`; spec `completed` → in `pending_consolidation`, phase
  `consolidation-pending`; ledger tail keeps the last 5 `Ruling:` /
  `Knowledge gap:` lines; no `specs/` → empty, exit 0; toolkit unresolvable
  (`KDD_SPEC_GRAPH` unset and `HOME` a temporary empty directory) → error JSON,
  exit 0; a fake toolkit (`KDD_SPEC_GRAPH` = a stub printing prepared JSON for a
  spec absent from the fixture files) → that spec appears in `open_work`,
  proving the data comes through `kdd-cli`.
- Mod: `claude plugin validate mods/kdd-work`, `tsc -p mods/kdd-work`, and
  `claude plugin test mods/kdd-work` with `$.process.run` mocked: status-line
  text with and without focus task, skill recording (only `kdd-superpowers:*`,
  main loop only, from `Skill` and from `skill.prompt`), refresh only after the
  tool resolved,
  band shown/dismissed, failure keeps last state and marks stale, debounce
  coalesces bursts.
- `tests/scripts/test-invariants.sh` grows: its namespace and path greps also
  scan `mods/` and `*.ts`/`*.tsx`; a new assertion checks `plugins[1]` is
  `kdd-work` with the version in `mods/kdd-work/.claude-plugin/plugin.json`. It
  and `test-skill-content.sh` show no failure that is not already there before
  this work (today: the two caused by the untracked `docs/superpowers/`).
- Manual: load the mod with hot reload in a session on this repository, open
  `/kdd-work`; check the band on a temporary project with a `completed` WRK-SPEC.
  While this work runs, the focus in this repository is this WRK-SPEC itself.

## Knowledge Context

| Activated Spec | Role in this work |
|---|---|
| — | No Knowledge or Agentic spec covers the ledger, the plugin's UI or the mod API (`activates: []`, `equips: []`). |
| FRAG-FORK-LEDGER-001 | Evidence, not activated: the ledger line forms `kdd-status` parses. |
| WRK-SPEC-FORK-CORE-001 | Related work (not activatable): P4, P10, P13 and `kdd-cli` as the single toolkit locator. |

Gaps: (1) the ledger format is a contract between skills, and now with code,
but exists only as prose — candidate for a knowledge spec distilled from
FRAG-FORK-LEDGER-001 at consolidation; (2) the mod API is early access, its
authority is the engine's `claude-code.d.ts`, not versioned here; (3)
`Knowledge gap:` no spec settles the workspace layout across git worktrees ×
`.kdd/` runtime state — with the manual worktree fallback (`cd .worktrees/…`)
the session cwd stays at the main checkout and the mod reads the wrong
workspace. A knowledge spec on workspace and runtime-state layout should exist.

## Constraints

- WRK-SPEC-FORK-CORE-001 P4: "Deterministic → CLI; judgment → toolkit skill." — the state computation is a script, not mod logic.
- WRK-SPEC-FORK-CORE-001 P13: "No path contains `superpowers`." — new paths are `mods/kdd-work/` and `skills/kdd-conventions/scripts/kdd-status`; the mod writes nothing to the project.
- `kdd-cli` is "The only place in kdd-superpowers that knows where spec-graph.mjs lives" (`skills/using-superpowers/scripts/kdd-cli` header) — `kdd-status` calls it.
- Ledger identity line, observed in FRAG-FORK-LEDGER-001: `skills/subagent-driven-development/SKILL.md:155`: `# SDD ledger — plan: <WRK-PLAN-ID> (<plan file path>)`.
- Task completion has a suffix and two task spellings, observed in FRAG-FORK-LEDGER-001: `SKILL.md:475` `Task <WRK-TASK-ID>: complete (commits <base7>..<head7>, review clean)`; `SKILL.md:592` `[Ledger: Task 1: complete (commits a1b2c3d..d4e5f6a, review clean)]`.
- Rulings are collected by containment, observed in FRAG-FORK-LEDGER-001: `SKILL.md:535` `collect every ledger line containing` `Ruling:`.
- `finishing-a-development-branch/SKILL.md:47`: the WRK-SPEC "is `active`" as a precondition, and `:146-148`: a closed-without-archiving WRK-SPEC is listed "as *pending consolidation* until `kdd:spec-consolidate` runs" — so the band for a `completed` WRK-SPEC points to `kdd:spec-consolidate`, the path finishing itself documents, not back to finishing.

## Code Premises

| Premise | Listed | Verified by | Result |
|---|---|---|---|
| `kdd-cli … filter --format json` returns `id`, `layer`, `status`, `title`, `file`, `parent` (plan→spec, task→plan) | yes | ran it: `WRK-PLAN-FORK-CORE-001 work-plan completed {"parent":"WRK-SPEC-FORK-CORE-001"}`; output also carries `body` (580 KB on this repo, 0.08 s) | holds |
| Ledger is `.kdd/sdd/<WRK-PLAN-ID>/progress.md`, first line `# SDD ledger — plan: …`, done = `Task <ID>: complete` | yes | `executing-plans/SKILL.md:21`; `subagent-driven-development/SKILL.md:155, 475-476` | holds — completion lines carry a suffix: prefix match |
| Rulings and knowledge gaps have a recognisable form | yes | `SKILL.md:23, 454, 460, 535`; `executing-plans/SKILL.md:33` | holds — no fixed prefix; match by containment |
| `sdd-workspace PLAN_FILE` → `<repo-root>/.kdd/sdd/<plan id>/` | yes | `sdd-workspace:34-35, 41-42` | holds — id from frontmatter, basename fallback; creates the directory |
| session-start open_work uses spec `active\|completed`, task done `completed\|archived` | yes | `hooks/session-start:74, 88` | holds — parses frontmatter with awk itself |
| `tests/scripts/run.sh` runs every `test-*.sh` | yes | `run.sh`: `for t in test-*.sh` | holds |
| Fixture BILL-PRORATA: spec, plan, two tasks, all `active` | yes | frontmatter grep of `tests/scripts/fixtures/specs/work/` | holds |
| `bump-version.sh` touches only `plugins[0]` of marketplace.json | yes | `.version-bump.json`: `"field": "plugins.0.version"` | holds — index-based: `kdd-work` must come after |
| `test-invariants.sh` identity reads only `plugins[0]` | yes | `test-invariants.sh:40` `m.plugins[0].name` | holds |
| Mod API has `$.plugin.root`, `$.process.run` (cwd, timeoutMs), `$.ui.status`, `$.ui.open`, `$.command.register`, `command.run`, `turn.complete`, `session.start`, `tool.call` (Skill input `skill`), `$.state`/atoms, `$.clock.after`, `$.env.get`, `$.session.cwd` | yes | `claude-code.d.ts` (build 2.1.289): `:2236`, `:3413`, `:7667`, `:2375`, `:2398`, `:2989`, `:1710`, `:4310`, `:4183`, `:3847`, `:15816`, `:3282`, `:13951`, `:3324`, `:3486`, `:2673` | holds — `$.env.get` needs a literal name |
| Installed plugin at `~/.claude/plugins/cache/kdd-superpowers/kdd-superpowers/<version>/` | yes | `ls` → `0.2.1 0.4.0` | holds — pick newest by semver |
| FORK-CORE-001: spec `active`, plan `completed`, 19/19 tasks completed | yes | `kdd-cli filter` | holds — FORK-CORE-001 is `finishing`, no band; while this work runs, the focus is this WRK-SPEC |
| finishing requires an `active` WRK-SPEC; consolidation of a `completed` one runs through `kdd:spec-consolidate` | unlisted | `finishing-a-development-branch/SKILL.md:47, 146-148` | holds — found by gate A1; band text changed |
| `test-skill-content.sh` enumerates no script directory | yes | only `must_contain` on named files | holds |
| `kdd-cli` exits 3 with a stderr message when no toolkit is found | unlisted | `kdd-cli`: `exit 3` | holds — `kdd-status` translates it |

unlisted claims verified: 10 hold

## Acceptance Criteria

- [ ] `kdd-status --json` on each fixture variant in *Testing* prints the stated `phase`, `done/total`, current task, `ledger` flag and `pending_consolidation`; `tests/scripts/test-kdd-status.sh` asserts each and passes under `run.sh`.
- [ ] `kdd-status` exits 0 with `{"error":"toolkit-not-found",...}` when `kdd-cli` exits 3, and with empty lists and `phase: idle` without `specs/`.
- [ ] `kdd-status` reads spec data only through `kdd-cli`: with a stub toolkit returning a spec that no fixture file contains, that spec appears in the output; and the script opens no file under `specs/` (`grep -n "readFile\|readdir" skills/kdd-conventions/scripts/kdd-status` shows reads of the ledger only).
- [ ] `claude plugin validate mods/kdd-work` reports nothing refused; after the engine has loaded the mod once, `tsc -p mods/kdd-work` exits 0; `claude plugin test mods/kdd-work` passes the cases in *Testing*.
- [ ] `.claude-plugin/marketplace.json` lists `kdd-superpowers` first and `kdd-work` second; `scripts/bump-version.sh --check` still reports `plugins[0]` only; `tests/scripts/test-invariants.sh` scans `mods/` and `*.ts/*.tsx`, asserts the `kdd-work` version match, and shows no failure beyond the two pre-existing ones.
- [ ] With hot reload on this repository: the status line shows this WRK-SPEC's focus (its current task or phase, plus the skill when one ran); `/kdd-work` opens the pane with its root, WRK-SPEC-FORK-CORE-001 as `finishing` with 19 ✓ tasks, and this WRK-SPEC; on a temporary project with a `completed` WRK-SPEC the band appears and `/kdd-work dismiss` hides it.
- [ ] `RELEASE-NOTES.md` records the mod and `kdd-status`; README says how to install `kdd-work`.

## Open Questions

- None blocking. The untracked `docs/superpowers/` in the working tree already
  fails `test-invariants.sh` (it lists `docs/superpowers` among removed paths);
  it predates this work and is your human partner's to move or delete.

## Adversarial Review

Gate A1 (2026-10-05): `17 attempted, 16 BROKEN (code-reality 2 · spec-rule 0 · ambiguity 7 · knowledge-gap 3 · internal 4)`; premises re-verified: 14 hold.

| Attack | Cause | Evidence | Ruling |
|---|---|---|---|
| 2 · phase rules leave multi-plan specs and task-less plans undefined | ambiguity | MODS-001 Phase rule; `hooks/session-start:82-91` loops over several plans | accepted → explicit first-match precedence; tests for task-less and second draft plan |
| 2 · refresh before or after the tool finishes | ambiguity | reference.md:77 (`tool.call` is a `next` chain) | accepted → refresh scheduled after `await next(e)` |
| 2 · `<repo-root>` = cwd or git toplevel | ambiguity | `sdd-workspace:39-41` | accepted → `git rev-parse --show-toplevel`, cwd outside git; `root` in the JSON |
| 3 · grep criterion met by a script parsing frontmatter itself | ambiguity | AC vs "No frontmatter parsing of its own" | accepted → stub-toolkit test + no reads under `specs/` |
| 3 · `test-invariants.sh` never scans the mod | ambiguity | `test-invariants.sh:17-19, 23` | accepted → scan `mods/`, `*.ts/*.tsx` |
| 4 · manual worktree fallback leaves the session cwd at the main checkout | knowledge-gap | `using-git-worktrees/SKILL.md:59-72`; `sdd-workspace:39` | accepted as `Knowledge gap:` → not solved; pane names the root it reads |
| 4 · engine-generated types and tsconfig not in the file list | code-reality | reference.md:39-49 | accepted → `tsconfig.json` extending the generated one; `.claude-plugin/types/` gitignored; `tsc` after first load |
| 4 · nothing keeps the mod's two version fields in step | knowledge-gap | `.version-bump.json` (`plugins.0.version` only) | accepted → hand-bumped, invariant asserts the match |
| 5 · band sends a `completed` WRK-SPEC back to finishing, which requires `active` | code-reality | `finishing-a-development-branch/SKILL.md:47, 146-148` | accepted → band says `run kdd:spec-consolidate <id>` |
| 5 · manual check expects FORK-CORE-001 as focus, but this WRK-SPEC will be `executing` | internal | focus order; AC | accepted → AC rewritten |
| 6 · ledger tail outside the Problem Statement | internal | Problem Statement vs Components | rejected → your human partner chose the pane with the ledger tail (option A); Problem Statement now names it |
| + 2 · typed skills missed; subagent Skill calls overwrite the main loop's | ambiguity | `claude-code.d.ts:4160, 196-203` | accepted → `skill.prompt` too; calls with `agentId` ignored |
| + 4 · `Task <n>` → TTT mapping not settled | knowledge-gap | FRAG-FORK-LEDGER-001 Inferred | rejected → kdd-conventions/SKILL.md:24 "TTT = position in the plan's Task Breakdown" settles it; quoted in Components |
| + 6 · `draft` specs open in the mod but not in `<KDD-ENVIRONMENT>` | internal | `hooks/session-start:74` | accepted → kept on purpose, documented in Components |
| + 3 · "toolkit unresolvable" test depends on the machine's plugin cache | ambiguity | `kdd-cli:22-23` | accepted → `HOME` set to a temporary empty directory |
| + 6 · "stay green" is false today | internal | `test-invariants.sh` → `FAILED: 2 assertion(s).` | accepted → "no failure beyond the two pre-existing ones" |
