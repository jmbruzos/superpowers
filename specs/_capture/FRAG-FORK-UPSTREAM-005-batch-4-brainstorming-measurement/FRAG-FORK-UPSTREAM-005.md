---
id: FRAG-FORK-UPSTREAM-005
type: fragment
layer: capture
scope: persistent
status: distilled
confidence: low
version: 1.0.0
created: 2026-10-19
updated: 2026-10-19
owner: jmbruzos
title: "Batch 4 levels 1 and 2: before 0.9.0 vs candidate 0705247 — not worse on any deciding metric (L1 35/35, false claims +1.5 < 2, executability defects equal); cost +14 %"
captured_at: 2026-10-19T01:25:06Z
source_type: report
files:
  - raw/chain4.sh
  - raw/l1-before-r1-checks.log
  - raw/l1-before-r1-scenario-2.json
  - raw/l1-before-r1-scenario-3.json
  - raw/l1-before-r1-scenario-7.json
  - raw/l1-before-r1-scenario-9.json
  - raw/l1-cand-r1-checks.log
  - raw/l1-cand-r1-scenario-2.json
  - raw/l1-cand-r1-scenario-3.json
  - raw/l1-cand-r1-scenario-7.json
  - raw/l1-cand-r1-scenario-9.json
  - raw/l2-A1-commits.txt
  - raw/l2-A1-conditions.txt
  - raw/l2-A1-evidence.md
  - raw/l2-A1-result.json
  - raw/l2-A2-commits.txt
  - raw/l2-A2-conditions.txt
  - raw/l2-A2-evidence.md
  - raw/l2-A2-result.json
  - raw/l2-B1-commits.txt
  - raw/l2-B1-conditions.txt
  - raw/l2-B1-evidence.md
  - raw/l2-B1-result.json
  - raw/l2-B2-commits.txt
  - raw/l2-B2-conditions.txt
  - raw/l2-B2-evidence.md
  - raw/l2-B2-result.json
  - raw/l2-exec-adjudication-key.txt
  - raw/l2-exec-adjudication.md
  - raw/mdm-preflight.txt
  - raw/preregistration.md
  - raw/pressure-tests.md
  - raw/run-times.txt
  - report.md
integrity: "sha256:557b3d1f0411a2a4ac04b2d4b703b964fcf72c6bb2ac69b2253bac6541ccaa0f"
origin: kdd-superpowers
routed_to: []
dependencies:
  - id: FRAG-FORK-UPSTREAM-004
    relation: relates-to
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-19T01:25:06Z
tags: [capture, fork, upstream, measurement, brainstorming, using-superpowers, routing]
---

# FRAG-FORK-UPSTREAM-005 — Batch 4 levels 1 and 2

Immutable capture. report.md holds the method, the level-1 and level-2
tables, the verdicts and what is inferred; raw/ holds the pre-registration,
the pressure tests with their baselines, the mdm-platform pre-flight, the
chain script and run times, the level-1 check logs and JSON results, and per
level-2 run its result, conditions, commits and evidence-judge report, plus
the executability adjudication and its key. The plan bundles stay in the
git-ignored measurement directory. Not code-derived: no anchors, no
`frag-cite-check`.
