---
id: FRAG-FORK-UPSTREAM-004
type: fragment
layer: capture
scope: persistent
status: distilled
confidence: low
version: 1.0.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Batch 3 level 1: before 0.8.0 vs candidate 1af79fe — Native passes every scenario-8 check twice, scenarios 4–5 do not regress; Native ~20 % cheaper than SDD on the fixture; level 2b dropped by human ruling H-8"
captured_at: 2026-10-18T21:43:27Z
source_type: report
files:
  - raw/chain3.sh
  - raw/preregistration.md
  - raw/run-times.txt
  - raw/s45-before-r1-checks.log
  - raw/s45-before-r1-scenario-4.json
  - raw/s45-before-r1-scenario-5.json
  - raw/s45-before-r2-checks.log
  - raw/s45-before-r2-scenario-4.json
  - raw/s45-before-r2-scenario-5.json
  - raw/s45-cand-r1-checks.log
  - raw/s45-cand-r1-scenario-4.json
  - raw/s45-cand-r1-scenario-5.json
  - raw/s45-cand-r2-checks.log
  - raw/s45-cand-r2-scenario-4.json
  - raw/s45-cand-r2-scenario-5.json
  - raw/s8-inline-old-r1-checks.log
  - raw/s8-inline-old-r1-scenario-8-inline-old.json
  - raw/s8-inline-old-r2-checks.log
  - raw/s8-inline-old-r2-scenario-8-inline-old.json
  - raw/s8-native-r1-checks.log
  - raw/s8-native-r1-scenario-8-native.json
  - raw/s8-native-r2-checks.log
  - raw/s8-native-r2-scenario-8-native.json
  - raw/s8-sdd-r1-checks.log
  - raw/s8-sdd-r1-scenario-8-sdd.json
  - raw/s8-sdd-r2-checks.log
  - raw/s8-sdd-r2-scenario-8-sdd.json
  - report.md
integrity: "sha256:cc4d27da841e3aace597649391db8590a58d45b6f762170c20b871873edc2223"
origin: kdd-superpowers
routed_to: []
dependencies:
  - id: FRAG-FORK-UPSTREAM-003
    relation: relates-to
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T21:43:27Z
tags: [capture, fork, upstream, measurement, executing-plans, native, sdd]
---

# FRAG-FORK-UPSTREAM-004 — Batch 3 level 1

Immutable capture. report.md holds the method, the checks, the usage and what
is inferred; raw/ holds the pre-registration with its amendment, the chain
script and run times, every run's check log and JSON result. Not
code-derived: no anchors, no `frag-cite-check`.
