---
id: WRK-SPEC-FORK-TRANSITION-001
type: spec
layer: work-spec
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-19
updated: 2026-09-19
owner: jmbruzos
title: "kdd-conventions/scripts/transition delegates the status move to spec-graph transition (kdd ≥ 1.4.0), keeping the bash path as fallback"
activates: []
equips: []
activation_frozen: true
activation_resolved_at: 2026-09-19T19:45:16+02:00
dependencies:
  - id: WRK-SPEC-FORK-CORE-001
    relation: constrained-by
sources:
  - id: TOOLKIT-TRANSITION
    resource: ../knowledge-driven-development/specs/work/WRK-SPEC-TOOLKIT-TRANSITION-001-status-transition-command.md
    title: spec-graph transition (kdd 1.4.0, CLI 0.8.0) — the command this script now calls; lists this plugin under Consumers
  - id: PLUGIN-TRANSITION
    resource: skills/kdd-conventions/scripts/transition
    title: current bash implementation (0.2.0) and its 33 assertions in tests/scripts/test-transition.sh
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-19T19:45:16+02:00
verified:
  - by: human:jmbruzos
    at: 2026-09-19T19:45:16+02:00
stale_after: 2026-12-18T18:45:16+01:00
tags: [kdd, fork, kdd-conventions, transition, toolkit]
---

# WRK-SPEC-FORK-TRANSITION-001 — `transition` delegates to the toolkit

## Problem Statement

`kdd-conventions/scripts/transition` (0.2.0) reimplements in bash a status
move the toolkit now owns: `spec-graph transition` (kdd 1.4.0) knows every
lifecycle, rewrites the frontmatter byte-for-byte, appends the human
`verified` entry, validates and restores on red. P4 of
WRK-SPEC-FORK-CORE-001: the fork never reimplements what `spec-graph` does.
What stays the plugin's is the commit convention. Installed toolkits older
than 1.4.0 lack the command, and the plugin must not break them.

## Proposed Change

- The script probes the resolved CLI once (`<kdd-cli> transition --help`,
  exit 0 ⇒ available). When available: it validates its own usage (exit 2
  cases unchanged), calls `<kdd-cli> --specs DIR transition FILE STATUS
  [--verified ACTOR]`, maps the CLI's exit 1 (refused move, red validate —
  the CLI already restored the file) to exit 1 with the CLI's stderr, then
  commits with the same messages as today unless `--no-commit`. The
  FRAG refusal stays in the script (the CLI accepts fragment moves; this
  plugin keeps them for `kdd:spec-consolidate`).
- When unavailable: the existing bash path runs unchanged, with one line on
  stderr: `transition: kdd toolkit < 1.4.0 — using the built-in move (update
  with /plugin update kdd)`.
- Same interface, same outputs, same exit codes.

## Knowledge Context

| Ref | Role |
|---|---|
| (none activated) | Activation `[]`. |
| WRK-SPEC-FORK-CORE-001 P4, P13 | deterministic → CLI; no `superpowers` in paths. |
| TOOLKIT-TRANSITION §1 (evidence) | the command's contract: exit 1 on refused/red with file restored, exit 2 on usage, `--verified` needs `human:`. |

## Acceptance Criteria

1. `tests/scripts/test-transition.sh` passes unchanged with `KDD_SPEC_GRAPH` pointing at a CLI **with** the command (kdd ≥ 1.4.0 / `apps/spec-graph` at 0.8.0) and at one **without** it (kdd 1.3.1).
2. With the command available, the transcript of a run shows `spec-graph … transition` being called and no `awk`/`sed` rewrite of the frontmatter; with it unavailable, the fallback notice appears on stderr exactly once.
3. `tests/scripts/test-transition.sh` gains a case per mode asserting AC2 (a `TRANSITION_TRACE=1` env var makes the script print `mode: cli|builtin` on stderr).
4. `tests/scripts/run.sh`, `test-invariants.sh` and `test-skill-content.sh` stay green; RELEASE-NOTES gets a 0.2.1 entry.
