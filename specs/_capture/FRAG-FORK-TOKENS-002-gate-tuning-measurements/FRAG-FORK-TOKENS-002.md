---
id: FRAG-FORK-TOKENS-002
type: fragment
layer: capture
scope: persistent
status: ingested
confidence: low
version: 1.0.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "Token usage of the kdd-superpowers flow — before and after WRK-SPEC-FORK-GATES-001 (headless, scenarios 4 and 7)"
captured_at: 2026-09-28T17:50:50+02:00
source_type: report
files:
  - raw/after-s4-1.json
  - raw/after-s4-2.json
  - raw/after-s4-3.json
  - raw/after-s7.json
  - raw/before-s4-1.json
  - raw/before-s4-2.json
  - raw/before-s4-3.json
  - report.md
integrity: "sha256:5b3f498ab3a4e6c96803b7f75104b0551df887714b9f5b1476797aa70532b4f4"
origin: kdd-superpowers
routed_to: []
dependencies:
  - id: FRAG-FORK-TOKENS-001
    relation: supersedes
generated:
  by: claude-code/claude-sonnet-5
  at: 2026-09-28T17:50:50+02:00
tags: [capture, fork, tokens, measurement, gates]
---

# FRAG-FORK-TOKENS-002 — Token usage before and after the gate tuning

Immutable capture. report.md holds the method, the per-run table and the
spread; raw/ holds the `claude -p --output-format json` results. Not
code-derived: no anchors, no `frag-cite-check`. Supersedes
FRAG-FORK-TOKENS-001; the reconciled knowledge cites this fragment in
`sources` at consolidation.
