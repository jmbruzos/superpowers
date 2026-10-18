---
id: FRAG-FORK-UPSTREAM-002
type: fragment
layer: capture
scope: persistent
status: ingested
confidence: low
version: 1.0.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Batch 1 level 1: before 0.6.1 vs after 0.7.1/0.7.2, scenarios 1–7 × 2 — not worse; two regressions of 0.7.0 found and fixed (hook in POSIX mode, classifier cut of the reviewer)"
captured_at: 2026-10-18T13:35:35Z
source_type: report
files:
  - raw/after-070-r1-checks.log
  - raw/after-070-r2-checks.log
  - raw/after-071-r1-checks.log
  - raw/after-071-r1-scenario-2.json
  - raw/after-071-r1-scenario-3.json
  - raw/after-071-r1-scenario-4.json
  - raw/after-071-r1-scenario-7.json
  - raw/after-071-r2-checks.log
  - raw/after-071-r2-scenario-2.json
  - raw/after-071-r2-scenario-3.json
  - raw/after-071-r2-scenario-4.json
  - raw/after-071-r2-scenario-7.json
  - raw/after-072-r1-checks.log
  - raw/after-072-r1-scenario-5.json
  - raw/after-072-r1-scenario-6.json
  - raw/after-072-r2-checks.log
  - raw/after-072-r2-scenario-5.json
  - raw/after-072-r2-scenario-6.json
  - raw/preregistration.md
  - raw/scenario6-diagnostics.txt
  - report.md
integrity: "sha256:88f4ef3f2c7f778286959ae94981b0b522865c1bd9ffbe466d3ef10ab7c83e6f"
origin: kdd-superpowers
routed_to: []
dependencies:
  - id: FRAG-FORK-UPSTREAM-001
    relation: relates-to
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T13:35:35Z
tags: [capture, fork, upstream, measurement, regression, hooks, code-review]
---

# FRAG-FORK-UPSTREAM-002 — Batch 1 level 1

Immutable capture. report.md holds the method, the two regressions with their
evidence, the checks and the usage; raw/ holds the pre-registration with its
amendments, the after-arm JSON results and check logs, the 0.7.0 check logs and
the scenario-6 diagnostics. The before arm is FRAG-FORK-UPSTREAM-001. Not
code-derived: no anchors, no `frag-cite-check`.
