---
id: WRK-SPEC-FORK-UPSTREAM-002
type: spec
layer: work-spec
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Upstream sync batch 1 — fixes: code-review and debugging examples, literal companion content, the project's suite defines green, review-package guards, create-only workspace ignore, reviewer judges by a reasonable person, Windows hook wrapper, a hook that survives a broken PATH, transition --verify-only, invariants for new upstream assets"
activates:
  - DOC-FORK-UPSTREAM-001@0.1.0
  - DOC-FORK-TOKENS-001@0.3.0
  - DOC-FORK-GATES-001@0.4.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-18T15:00:00+02:00
activation_pins:
  - source: self@d99d696eee07
    integrity: sha256:312e4ca01e66baa97a8d2a6c910a2f86765123d90f7ccff10b6ce4816e318f25
dependencies:
  - id: DOC-FORK-UPSTREAM-001
    relation: constrained-by
  - id: DOC-FORK-TOKENS-001
    relation: constrained-by
  - id: DOC-FORK-GATES-001
    relation: constrained-by
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
sources:
  - id: FRAG-FORK-TOKENS-003
    resource: specs/_capture/FRAG-FORK-TOKENS-003-gates-hold-findings-cost/
    title: Latest fixture measurement; the batch-0 baseline supersedes it
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T15:00:00+02:00
stale_after: 2027-01-16T15:00:00+02:00
tags: [kdd, fork, upstream, fixes, hooks, code-review, tdd, sdd]
---

# WRK-SPEC-FORK-UPSTREAM-002 — Upstream sync batch 1: fixes

## Problem Statement

DOC-FORK-UPSTREAM-001 §2 lists the upstream 6.4.1–7.0.0 fixes the fork takes
as batch 1. Each is a defect the fork has today (verified at `d99d696` by the
umbrella's premise verifier, rows 1–10, and re-checked for this spec):

1. `requesting-code-review/SKILL.md:69` uses `awk '{print $1}'`; Claude Code
   replaces `$1` in a skill body with an argument word, breaking the example.
   Line 28 offers bare `origin/main`, which shows phantom deletions once main
   moves past the branch point.
2. `systematic-debugging/SKILL.md:91,95` print the secret they check for.
3. `brainstorming/scripts/server.cjs:238` inserts screen content with a string
   replacement, so `$&`, `$'` and similar sequences in a screen are expanded.
4. TDD lets a session call a change green after running only the file its task
   named (upstream: 11 of 12 probe runs).
5. `review-package` accepts an empty range or a HEAD that does not descend
   from BASE, producing a "clean" review of nothing.
6. `sdd-workspace:44` overwrites `.kdd/sdd/.gitignore` on every run, reverting
   a repository's own version.
7. `code-reviewer.md` lets a reviewer grade behaviour the spec is silent on as
   Minor, and gives no record of what the reviewer set aside.
8. `hooks/run-hook.cmd` (unchanged since 6.3.0) misses per-user Git for
   Windows, can run WSL's `bash.exe`, runs a `bash.cmd` or `where.bat`
   planted in the current directory, and reports success for a failed hook;
   its Unix half calls `dirname` and `bash` from `PATH`.
9. `hooks/session-start` run with an empty `PATH` exits 1 and prints nothing:
   the session gets neither using-superpowers nor `<KDD-ENVIRONMENT>`.
10. `kdd-conventions/scripts/transition` cannot record a human `verified`
    entry without a status move, though toolkit 1.13 can
    (`spec-graph transition --verify-only`).
11. `test-invariants.sh` does not reject the upstream assets 7.0 added
    (`.antigravity-plugin`, `.muse-plugin`, `index.js`).

## Proposed Change

Adopted from upstream as written unless the item says how it is adapted.

1. **requesting-code-review.** `:69` → `cut -d' ' -f1`; `:28` → `# or: git
   merge-base origin/main HEAD, or the task's recorded BASE`.
2. **systematic-debugging.** `:91` → `echo "IDENTITY: $([ -n "${IDENTITY:-}" ]
   && echo SET || echo UNSET)"`; `:95` → `printenv IDENTITY >/dev/null 2>&1 &&
   echo "IDENTITY in environment" || echo "IDENTITY not in environment"`.
3. **server.cjs.** `.replace('<!-- CONTENT -->', () => content)`; upstream's
   `server.test.js` case "preserves literal replacement tokens in content
   fragments" is ported.
4. **TDD.** Upstream's paragraph "**'Other tests' means the project's suite,
   not just your file.** …" is inserted after `**Other tests fail?** Fix now.`
   (`:183`), verbatim.
5. **review-package.** Upstream's two guards (exit 3) after the BASE/HEAD
   checks; the call to `sdd-workspace` goes through `"${BASH:-bash}"`.
   Upstream's range-guard cases are ported into `test-sdd-workspace.sh`.
6. **sdd-workspace.** `[ -e "$base/.gitignore" ] || printf '*\n' > …`; a test
   case keeps a repository's own `.kdd/sdd/.gitignore` byte for byte.
7. **code-reviewer.md** (adapted). Upstream's two sections go before *Read-Only
   Review*, with one KDD sentence each:
   - *The spec is a vision document* adds: "An activated spec's rules still
     bind exactly as written; a reasonable person's expectation fills only
     the spec's silence and never overrides a rule." (KDD over upstream: P5.)
   - *Declined to judge* names who rules: "the session that dispatched you"
     (SDD's controller, or whoever requested the review).
   `test-skill-content.sh` anchors both headings.
8. **run-hook.cmd.** Upstream's file verbatim; upstream's
   `tests/hooks/test-run-hook-cmd-windows.sh` ported verbatim (it skips
   outside Git Bash on Windows).
9. **session-start** (adapted). No `dirname` (split `$0` on its last `/` or
   `\`), using-superpowers read with `$(<file)`, output through upstream's
   `emit_json` (pipes through `cat` only when `cat` exists). The KDD probe
   runs only when every command it uses is found (`command -v` for `find`,
   `awk`, `mktemp`, `wc`, `tr`, `sort`, `rm`, `node`); otherwise each of its
   four lines reads `unavailable (no PATH at session start)` and `kdd-cli` is
   not called. `toolkit: NOT FOUND` is printed only when `kdd-cli` ran and
   failed. The `open_work` and pending-consolidation criterion is untouched
   (DOC-FORK-UPSTREAM-001 §5). Telling the agent what to do with
   `unavailable` is batch 4's using-superpowers row (§2), not this batch.
10. **transition** (adapted). `--verify-only` with `--verified human:<id>`
    and no STATUS: delegates to `spec-graph transition --verify-only
    --verified <id> FILE`, commits the file as `spec(<ID>): verified by
    <human:id>`; refused (exit 2) without `--verified`, with a STATUS, or
    when the toolkit lacks `--verify-only` (no built-in fallback — simpler,
    and the toolkit owns the move, P4).
11. **test-invariants.sh.** `.antigravity-plugin`, `.muse-plugin` and
    `index.js` join the removed-assets list.

**Measurement** (DOC-FORK-UPSTREAM-001 §2, batch 1 row; DOC-FORK-TOKENS-001
*Maintenance*: the hook and a prompt template change). Level 1 only:
`test-kdd-flow.sh` scenarios 1–7, n=2, before = `kdd-superpowers--v0.6.1`
(the batch-0 baseline, scenario 4 re-run on the corrected fixture), after =
this batch's release. Deciding metric, pre-registered in the FRAG: every
scenario check that passes before also passes after; cost is reported, not
decisive (a fix batch). Release 0.7.0 with tag `kdd-superpowers--v0.7.0`.

## Knowledge Context

| Activated Spec | Role in this work |
|---|---|
| DOC-FORK-UPSTREAM-001@0.1.0 | §2 batch 1 row (scope), §3 rules (P10, P13, toolkit contracts, tests), §4 protocol |
| DOC-FORK-TOKENS-001@0.3.0 | re-measure after a hook or prompt-template change; how to measure |
| DOC-FORK-GATES-001@0.4.0 | `code-reviewer.md` hosts A3 and A5; the added sections must not displace them |
| FRAG-FORK-TOKENS-003 | evidence, not activated |

## Acceptance Criteria

- [ ] AC1. Items 1, 2 and 4 are in their skills with the literals above;
  `grep -n "awk '{print \$1}'" skills/requesting-code-review/SKILL.md` and
  `grep -n 'IDENTITY:+SET\|env | grep IDENTITY' skills/systematic-debugging/SKILL.md`
  return nothing.
- [ ] AC2. `(cd tests/brainstorm-server && npm test)` passes with the ported
  literal-tokens case, which fails against today's `server.cjs`.
- [ ] AC3. `test-sdd-workspace.sh` passes with cases that fail today: a
  divergent HEAD and an empty range each exit 3; an existing
  `.kdd/sdd/.gitignore` with custom content is unchanged after `sdd-workspace`.
- [ ] AC4. `code-reviewer.md` has both sections with their KDD sentences;
  A3 (*knowledge compliance*) and A5 text are unchanged (`git diff` touches
  only added lines there); `test-skill-content.sh` anchors them.
- [ ] AC5. `hooks/run-hook.cmd` equals `upstream/main`'s byte for byte;
  `tests/hooks/test-run-hook-cmd-windows.sh` exists and skips on macOS.
- [ ] AC6. `test-session-start.sh` has a case running `env -i PATH=
  CLAUDE_PLUGIN_ROOT=<repo> /bin/bash hooks/run-hook.cmd session-start` from a
  directory with `specs/`: exit 0, JSON containing using-superpowers'
  content, four `unavailable (no PATH at session start)` lines, no `NOT
  FOUND`. With a normal PATH, the existing cases pass unchanged.
- [ ] AC7. The `<KDD-ENVIRONMENT>` block is byte-identical to the 0.6.0 hook's
  in `tests/scripts/fixtures` and in a copy whose WRK-SPEC is `completed`.
- [ ] AC8. `test-transition.sh` has cases: `--verify-only --verified
  human:t FILE` adds one verified entry, leaves `status:`, commits
  `spec(<ID>): verified by human:t`; without `--verified`, with a STATUS, or
  with a toolkit lacking `--verify-only` → exit 2, file untouched.
- [ ] AC9. `test-invariants.sh` rejects the three new paths; it passes on the
  tree.
- [ ] AC10. `FRAG-FORK-UPSTREAM-002` holds the level-1 after runs with its
  pre-registration committed first; every check that passes at 0.6.1 passes
  at 0.7.0, or a ruling records why not. `bash tests/scripts/run.sh`,
  `test-session-start.sh`, `test-sdd-workspace.sh` and brainstorm-server pass;
  0.7.0 has its release notes and local tag.
