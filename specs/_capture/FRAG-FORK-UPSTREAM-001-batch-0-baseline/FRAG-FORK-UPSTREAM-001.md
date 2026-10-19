---
id: FRAG-FORK-UPSTREAM-001
type: fragment
layer: capture
scope: persistent
status: distilled
confidence: low
version: 1.0.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Batch-0 baseline: fork 0.6.0 skills on toolkit 1.13.0 and Opus 5.5, test-kdd-flow.sh scenarios 1–7, two passes (plus two supplementary Sonnet passes)"
captured_at: 2026-10-18T11:44:54Z
source_type: report
files:
  - raw/opus-r1-checks.log
  - raw/opus-r1-scenario-2.json
  - raw/opus-r1-scenario-3.json
  - raw/opus-r1-scenario-4.json
  - raw/opus-r1-scenario-5.json
  - raw/opus-r1-scenario-6.json
  - raw/opus-r1-scenario-7.json
  - raw/opus-r2-checks.log
  - raw/opus-r2-scenario-2.json
  - raw/opus-r2-scenario-3.json
  - raw/opus-r2-scenario-4.json
  - raw/opus-r2-scenario-5.json
  - raw/opus-r2-scenario-6.json
  - raw/opus-r2-scenario-7.json
  - raw/sonnet-r1-checks.log
  - raw/sonnet-r1-scenario-2.json
  - raw/sonnet-r1-scenario-3.json
  - raw/sonnet-r1-scenario-4.json
  - raw/sonnet-r1-scenario-5.json
  - raw/sonnet-r1-scenario-6.json
  - raw/sonnet-r1-scenario-7.json
  - raw/sonnet-r2-checks.log
  - raw/sonnet-r2-scenario-2.json
  - raw/sonnet-r2-scenario-3.json
  - raw/sonnet-r2-scenario-4.json
  - raw/sonnet-r2-scenario-5.json
  - raw/sonnet-r2-scenario-6.json
  - raw/sonnet-r2-scenario-7.json
  - report.md
integrity: "sha256:9d0c5fa6c2b5aed6765845b8a91f2f46b2e171db0137be1a06a4f9272b1b194d"
origin: kdd-superpowers
routed_to: []
dependencies:
  - id: FRAG-FORK-TOKENS-003
    relation: supersedes
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T11:44:54Z
tags: [capture, fork, upstream, measurement, baseline, tokens]
---

# FRAG-FORK-UPSTREAM-001 — Batch-0 baseline

Immutable capture. report.md holds the method, the checks and the per-scenario
usage; raw/ holds each run's `claude -p --output-format json` result and the
harness check log. Not code-derived: no anchors, no `frag-cite-check`.
Supersedes FRAG-FORK-TOKENS-003 as the latest fixture measurement; the before
arm of batch 1 (FRAG-FORK-UPSTREAM-002).
