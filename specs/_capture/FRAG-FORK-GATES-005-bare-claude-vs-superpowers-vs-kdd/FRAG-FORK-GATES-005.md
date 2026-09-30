---
id: FRAG-FORK-GATES-005
type: fragment
layer: capture
scope: persistent
status: distilled
confidence: low
version: 1.0.0
created: 2026-09-30
updated: 2026-09-30
owner: jmbruzos
title: "Bare Claude with a spec-workflow CLAUDE.md vs superpowers 6.3.0 vs kdd-superpowers 0.4.0 on the RFC-PIPE-039 design + plan: hard points, false claims about code, cost"
captured_at: 2026-09-30T09:00:00Z
source_type: report
files:
  - raw/C-prompt.txt
  - raw/C1-bundle.txt
  - raw/C1-neutral-summary.md
  - raw/C1-result.json
  - raw/C2-bundle.txt
  - raw/C2-neutral-summary.md
  - raw/C2-result.json
  - raw/blind-judge-nine-designs.txt
  - raw/claude-md-addendum.txt
  - raw/evidence-judges-C.txt
  - raw/preregistration.md
  - report.md
integrity: "sha256:225ed1967d5812f128fdec6c183cabe877d621cff2d3d59b2dea1c7a2ebac87f"
origin: mdm-platform
routed_to: []
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-30T09:00:00Z
tags: [capture, fork, gates, measurement, ab-test, upstream-comparison, baseline]
---

# FRAG-FORK-GATES-005 — bare Claude + CLAUDE.md vs superpowers vs kdd-superpowers

Immutable capture. report.md holds the pre-registered third arm (Claude Code
with no plugin, mdm-platform's CLAUDE.md plus a generic spec-workflow
addendum), two headless runs of it on the FRAG-FORK-GATES-003 task, their
evidence judges, and one blind hard-point pass over all nine designs of the
three studies. raw/ holds each run's JSON result, its spec+plan+tasks bundle
(as .txt so the graph does not parse it), its neutral summary, the prompt,
the CLAUDE.md addendum, the pre-registration and the judges' summary lines.
U and K runs are kept in FRAG-FORK-GATES-003 and -004. Not code-derived for
this repository: no anchors, no `frag-cite-check`.
