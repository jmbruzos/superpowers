---
id: FRAG-FORK-GATES-002
type: fragment
layer: capture
scope: persistent
status: distilled
confidence: low
version: 1.0.0
created: 2026-09-29
updated: 2026-09-29
owner: jmbruzos
title: "A/B of kdd-superpowers 0.2.1 vs 0.3.0 on a real mdm-platform design (RFC-PIPE-039): gate A1 findings and false claims about current code in the final WRK-SPEC"
captured_at: 2026-09-29T00:00:00Z
source_type: report
files:
  - raw/A1-a1-adversary.md
  - raw/A1-result.json
  - raw/A1-wrk-spec.txt
  - raw/A2-a1-adversary.md
  - raw/A2-result.json
  - raw/A2-wrk-spec.txt
  - raw/B1-a1-adversary.md
  - raw/B1-result.json
  - raw/B1-wrk-spec.txt
  - raw/B2-a1-adversary.md
  - raw/B2-result.json
  - raw/B2-wrk-spec.txt
  - report.md
integrity: "sha256:14b95208866738353dfb730de155b429045ea488021a24a0f23e5fb5728950c9"
origin: mdm-platform
routed_to: []
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-09-29T00:00:00Z
tags: [capture, fork, gates, adversarial, measurement, ab-test]
---

# FRAG-FORK-GATES-002 — A/B of the gate tuning on a real mdm-platform design

Immutable capture. report.md holds the method, the four runs, the blind
cause classification of gate A1's findings and the judge's verification of
every claim about current code in each final WRK-SPEC; raw/ holds each
run's `claude -p` JSON result, its committed WRK-SPEC and its A1 adversary
output. Not code-derived for this repository: no anchors, no
`frag-cite-check`. The reconciled knowledge cites this fragment in
`sources`.
