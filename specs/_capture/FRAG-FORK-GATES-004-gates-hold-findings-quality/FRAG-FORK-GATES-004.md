---
id: FRAG-FORK-GATES-004
type: fragment
layer: capture
scope: persistent
status: distilled
confidence: low
version: 1.0.0
created: 2026-09-29
updated: 2026-09-29
owner: jmbruzos
title: "kdd-superpowers 0.4.0 (WRK-SPEC-FORK-GATES-002) on the RFC-PIPE-039 design + plan: hard points against 0.3.0 and superpowers 6.3.0, H1/H3 handling, cost"
captured_at: 2026-09-29T21:00:00Z
source_type: report
files:
  - raw/K4-bundle.txt
  - raw/K4-neutral-summary.md
  - raw/K4-result.json
  - raw/K5-bundle.txt
  - raw/K5-neutral-summary.md
  - raw/K5-result.json
  - report.md
integrity: "sha256:493d5c73ce2a6f9ef06884c2c8befffe9bbec05f38cba2c6eaa07f8f6a3a6e1d"
origin: mdm-platform
routed_to: []
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-29T21:00:00Z
tags: [capture, fork, gates, adversarial, measurement, ab-test]
---

# FRAG-FORK-GATES-004 — gates hold their findings: quality on a real design + plan

Immutable capture, acceptance criterion 9 of WRK-SPEC-FORK-GATES-002.
report.md holds two headless 0.4.0 runs (K4, K5) of the FRAG-FORK-GATES-003
task, their evidence judges, a blind hard-point pass over all seven designs
of both studies, and how the runs ruled on the H1/H3 findings. raw/ holds
each run's JSON result, its spec+plan+tasks bundle (as .txt so the graph
does not parse it) and its neutral summary. The pre-registration is
FRAG-FORK-GATES-003's. Not code-derived for this repository: no anchors, no
`frag-cite-check`.
