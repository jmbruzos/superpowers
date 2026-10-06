---
id: WRK-SPEC-FORK-TRANSITION-002
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-10-06
updated: 2026-10-06
owner: jmbruzos
title: "transition and its test without GNU-only sed — green on macOS and Linux"
activates: []
equips: []
activation_frozen: true
activation_resolved_at: 2026-10-06T10:00:00+02:00
dependencies:
  - id: WRK-SPEC-FORK-TRANSITION-001
    relation: relates-to
sources: []
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-06T10:00:00+02:00
stale_after: 2027-01-04T10:00:00+01:00
tags: [fork, transition, portability, tests]
---

# WRK-SPEC-FORK-TRANSITION-002 — transition and its test without GNU-only sed

## Problem Statement

`tests/scripts/test-transition.sh` fails 9 assertions on macOS: lines 43,
54 and 77 call `sed -i '<script>' <file>`, which BSD sed reads as "suffix
`<script>`", so the edit never happens. The script itself carries a latent
GNU dependency: in its built-in mode (toolkit without `spec-graph
transition`, < 1.4.0), `skills/kdd-conventions/scripts/transition:92` inserts
a missing `updated:` with `sed -i "0,/^status: …$/s//…/"` — `0,/re/` and
`-i` without a suffix are GNU-only, so on macOS that move breaks for any
artifact without `updated:`. The built-in mode is untested on a machine
whose toolkit has `transition`.

## Proposed Change

1. `transition`: drop the `sed` at line 92. The `awk` that already rewrites
   the frontmatter prints `updated: <today>` right after the `status:` line
   when the frontmatter has no `updated:` (passed in as a flag computed from
   the frontmatter it already reads). One pass, POSIX awk only.
2. `tests/scripts/test-transition.sh`: lines 43, 54, 77 become
   `sed -i.bak '<script>' <file> && rm -f <file>.bak` — the form
   `tests/hooks/test-session-start.sh:288` already uses.
3. New case in `test-transition.sh`: force the built-in mode with a stub
   toolkit (`KDD_SPEC_GRAPH` = a script that forwards every call to the real
   `spec-graph.mjs` but drops the `transition` line from `--help`), run a
   move on an artifact whose frontmatter has no `updated:`, and assert: mode
   is `builtin`, exit 0, exactly one `updated: <today>` line, placed
   immediately after `status: <target>`, and the graph validates.

Out of scope: any other script, the CLI mode.

## Knowledge Context

| Activated Spec | Role in this work |
|---|---|
| — | No knowledge spec covers `transition`'s implementation (`activates: []`). |
| WRK-SPEC-FORK-TRANSITION-001 | Related work (archived): introduced the delegation to `spec-graph transition` and kept the built-in move as fallback. |

## Acceptance Criteria

- [ ] `bash tests/scripts/test-transition.sh` passes on macOS (BSD sed) with `KDD_SPEC_GRAPH` set to the kdd 1.6.0 toolkit — 0 failures (today 9).
- [ ] The new built-in-mode case fails before change 1 (on macOS the `sed` errors, or `updated:` is missing or misplaced) and passes after it.
- [ ] `grep -nE "sed -i[[:space:]]+['\"]|sed -i[[:space:]]+\"0,|0,/" skills/kdd-conventions/scripts/transition tests/scripts/test-transition.sh` finds nothing.
- [ ] `bash tests/scripts/run.sh` shows no new failure (in the main checkout `test-invariants.sh` still fails only because of the untracked `docs/superpowers/`).
