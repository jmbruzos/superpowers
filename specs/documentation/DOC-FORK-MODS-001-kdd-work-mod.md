---
id: DOC-FORK-MODS-001
type: spec
layer: documentation
scope: persistent
status: draft
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
domain: kdd-superpowers
subdomain: Tooling
title: "The kdd-work mod — how it is built, how it picks what to show, and the Claude Code function-hook constraints it runs under"
sources:
  - id: FRAG-FORK-MODS-001
    resource: specs/_capture/FRAG-FORK-MODS-001-mod-api-constraints/
    title: kdd-work's code at 988dfe7 — engine constraints and focus rule, attacked by gate A6 on 2026-10-05 (with empirical validate runs)
  - id: WRK-SPEC-FORK-MODS-001
    resource: specs/work/WRK-SPEC-FORK-MODS-001-kdd-work-mod.md
    title: The work that built kdd-status and the kdd-work mod
dependencies:
  - id: FRAG-FORK-MODS-001
    relation: distilled-from
  - id: DOC-FORK-LEDGER-001
    relation: relates-to
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-05T18:30:00+02:00
stale_after: 2027-01-03T18:30:00+01:00
tags: [kdd, fork, mods, kdd-work, claude-code]
---

# DOC-FORK-MODS-001 — The kdd-work mod

## Purpose

Record why `kdd-work` is shaped the way it is and the engine rules it
obeys, so the next change to it — or the next mod in this repository —
starts from what was learned instead of from the validate errors. The
Claude Code function-hook API is early access; the engine's
`claude-code.d.ts` for the running build is the authority, and every rule
below is dated to build 2.1.289.

## Audience

Whoever changes `mods/kdd-work/`, `skills/kdd-conventions/scripts/kdd-status*`,
or writes another mod for this plugin.

## Content

### Shape (decided in WRK-SPEC-FORK-MODS-001)

- **Two units.** `kdd-status` (Node ESM, main plugin) computes the state of
  open work as JSON; the mod only locates the main plugin, runs it, keeps
  the result in `$.state` and draws. All formatting is in pure functions
  (`hooks/format.ts`). Reason: P4 — deterministic work is a script, testable
  without Claude.
- **Spec data only through `kdd-cli`** (`filter --layer … --format json`);
  `kdd-status` reads no spec file itself, only ledgers (DOC-FORK-LEDGER-001).
- **A separate plugin**, second marketplace entry, own version (bumped by
  hand; `test-invariants.sh` checks the two version fields match). Reason:
  the mod API is early access; a break there must not touch the main
  plugin's session start.
- **Refresh on events, never on a timer:** `session.start`, `turn.complete`,
  and after (not before) a Write/Edit/Bash whose input mentions `specs/` or
  `.kdd/`; debounced 300 ms; one `kdd-status` run (~360 ms on this
  repository) per burst.

### What it shows

Focus is the open WRK-SPEC (`draft`, `active`, `completed`) whose phase
ranks first in `executing > finishing > planning > spec-review >
consolidation-pending`; ties go to the lower id (lexicographic,
`kdd-status-lib.mjs:12`). Consequence observed at close: with two specs in
`finishing`, the older id wins — the status line showed
WRK-SPEC-FORK-CORE-001, not the work just finished. Whether ties should
favour recent work is an open decision.

### Engine rules (build 2.1.289; confirmed by `claude plugin validate` on copies of the mod, A6)

1. **State references are scanned statically.** Every `$.state` /
   `read` / `update` reference must be an inline literal
   (`{ plugin, key } as const`) or an `atom` / `derive` / `memberOf` (or a
   literal const) built in the same file. A shared atoms module imported by
   the hooks file fails validate ("…takes a source the scan can read…").
2. **`$` is followed only into same-file top-level functions.** `$` may be
   passed, by name, to a function declaration (or a const bound to one) at
   the top of the same file. A closure inside `register`, a function
   imported from another module, or `$` passed as a value all fail validate.
3. **Hook and test answers.** Hooks on `$` operations answer `{ value }`
   (or `{ deny }`); in `claude plugin test`, the test's `on` stands for the
   engine and answers the same way, and `tool.call` with `{ result }`. The
   kit's `$.command.run` takes the full `CommandRunInput` (with `args`,
   `origin`, `presentation`).
4. **`turn.complete` fires for subagent loops too**, once per run of the
   loop, carrying `agentId` (absent on the main loop) — `claude-code.d.ts`
   :12647-12653. A hook that should react only to the main loop filters on
   it; `kdd-work`'s does not (a refresh per subagent turn).
5. **`agentId` on a hook's `e`** marks a subagent loop (`AgentLoop`).
   Contradicted, so not a rule: the test kit lets a test pass `agentId` into
   `$.tool.call`, but the engine declares it dropped there (:12077-12081) —
   the "main loop only" test of skill recording does not prove production
   behaviour.

## Maintenance

On a Claude Code upgrade, run `claude plugin validate mods/kdd-work` and
`claude plugin test mods/kdd-work` first; re-check rules 1–4 against the
new `claude-code.d.ts` and bump this document. Open items from the work: the
live check of the pane and band (AC6, waived at close), the tie-break rule,
the worktree root (DOC-FORK-LEDGER-001, inconsistency 4). Owner: jmbruzos.

## Status

Draft, `confidence: low`: one build, one mod, rules confirmed by validate on
copies but by no engine documentation beyond the declaration file.
