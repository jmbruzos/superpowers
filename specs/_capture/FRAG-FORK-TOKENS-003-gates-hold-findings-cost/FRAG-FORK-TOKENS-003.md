---
id: FRAG-FORK-TOKENS-003
type: fragment
layer: capture
scope: persistent
status: ingested
confidence: low
version: 1.0.0
created: 2026-09-29
updated: 2026-09-29
owner: jmbruzos
title: "Token usage of architectural brainstorming before and after WRK-SPEC-FORK-GATES-002 (headless scenario 7, two runs per side)"
captured_at: 2026-09-29T18:00:00Z
source_type: report
files:
  - raw/after-s7-1.json
  - raw/after-s7-2.json
  - raw/before-s7-1.json
  - raw/before-s7-2.json
  - report.md
integrity: "sha256:772bd616eadece0e2891a4d4f9860516df3d96686e9b20a924f7a004201bde2e"
origin: kdd-superpowers
routed_to: []
dependencies:
  - id: FRAG-FORK-TOKENS-002
    relation: supersedes
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-29T18:00:00Z
tags: [capture, fork, tokens, measurement, gates]
---

# FRAG-FORK-TOKENS-003 — Token usage before and after the gate-findings change

Immutable capture. report.md holds the method, the per-run table and the
spread; raw/ holds the `claude -p --output-format json` results. Not
code-derived: no anchors, no `frag-cite-check`. Supersedes
FRAG-FORK-TOKENS-002; the reconciled knowledge cites this fragment in
`sources` at consolidation.
