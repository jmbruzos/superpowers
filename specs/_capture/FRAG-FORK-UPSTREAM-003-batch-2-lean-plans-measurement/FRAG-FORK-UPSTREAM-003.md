---
id: FRAG-FORK-UPSTREAM-003
type: fragment
layer: capture
scope: persistent
status: ingested
confidence: low
version: 1.0.0
created: 2026-10-18
updated: 2026-10-18
owner: jmbruzos
title: "Batch 2 levels 1 and 2: before 0.7.1 vs candidate vs reworked candidate — the candidate was worse on plan executability (test code naming absent symbols); the reworked candidate is not worse on any deciding metric and is cheaper"
captured_at: 2026-10-18T18:37:10Z
source_type: report
files:
  - raw/l1-after-r1-checks.log
  - raw/l1-after-r1-plan-metrics.txt
  - raw/l1-after-r1-scenario-4.json
  - raw/l1-after-r1-scenario-5.json
  - raw/l1-after-r1-scenario-6.json
  - raw/l1-after-r2-checks.log
  - raw/l1-after-r2-plan-metrics.txt
  - raw/l1-after-r2-scenario-4.json
  - raw/l1-after-r2-scenario-5.json
  - raw/l1-after-r2-scenario-6.json
  - raw/l1-after-s6-repeat-checks.log
  - raw/l1-after-s6-repeat-scenario-6.json
  - raw/l1-before-r1-checks.log
  - raw/l1-before-r1-plan-metrics.txt
  - raw/l1-before-r1-scenario-4.json
  - raw/l1-before-r1-scenario-5.json
  - raw/l1-before-r1-scenario-6.json
  - raw/l1-before-r2-checks.log
  - raw/l1-before-r2-plan-metrics.txt
  - raw/l1-before-r2-scenario-4.json
  - raw/l1-before-r2-scenario-5.json
  - raw/l1-before-r2-scenario-6.json
  - raw/l1-before-s6-repeat-checks.log
  - raw/l1-before-s6-repeat-scenario-6.json
  - raw/l1-reworked-r1-checks.log
  - raw/l1-reworked-r1-plan-metrics.txt
  - raw/l1-reworked-r1-scenario-4.json
  - raw/l1-reworked-r2-checks.log
  - raw/l1-reworked-r2-plan-metrics.txt
  - raw/l1-reworked-r2-scenario-4.json
  - raw/l2-A1-commits.txt
  - raw/l2-A1-conditions.txt
  - raw/l2-A1-evidence.md
  - raw/l2-A1-result.json
  - raw/l2-A2-commits.txt
  - raw/l2-A2-conditions.txt
  - raw/l2-A2-evidence.md
  - raw/l2-A2-result.json
  - raw/l2-A3-commits.txt
  - raw/l2-A3-conditions.txt
  - raw/l2-A3-evidence.md
  - raw/l2-A3-result.json
  - raw/l2-A4-commits.txt
  - raw/l2-A4-conditions.txt
  - raw/l2-A4-evidence.md
  - raw/l2-A4-result.json
  - raw/l2-B1-commits.txt
  - raw/l2-B1-conditions.txt
  - raw/l2-B1-evidence.md
  - raw/l2-B1-result.json
  - raw/l2-B2-commits.txt
  - raw/l2-B2-conditions.txt
  - raw/l2-B2-evidence.md
  - raw/l2-B2-result.json
  - raw/l2-blind-1-key.txt
  - raw/l2-blind-1.md
  - raw/l2-blind-2-key.txt
  - raw/l2-blind-2.md
  - raw/l2-exec-adjudication-1-key.txt
  - raw/l2-exec-adjudication-1.md
  - raw/l2-exec-adjudication-2-key.txt
  - raw/l2-exec-adjudication-2.md
  - raw/l2-neutral/T1.md
  - raw/l2-neutral/T2.md
  - raw/l2-neutral/T3.md
  - raw/l2-neutral/T4.md
  - raw/l2-neutral/T5.md
  - raw/l2-neutral/T6.md
  - raw/mdm-preflight.txt
  - raw/preregistration.md
  - report.md
integrity: "sha256:aeff123b6765c02d9ff54ec0ebe46408c77a1253d833019903b2c2c1d928e3a2"
origin: kdd-superpowers
routed_to: []
dependencies:
  - id: FRAG-FORK-UPSTREAM-002
    relation: relates-to
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-10-18T18:37:10Z
tags: [capture, fork, upstream, measurement, writing-plans, lean-plans, review-focus]
---

# FRAG-FORK-UPSTREAM-003 — Batch 2 levels 1 and 2

Immutable capture. report.md holds the method, the level-1 and level-2
tables, the verdict per deciding metric and what is inferred; raw/ holds the
pre-registration with its four amendments, the mdm-platform pre-flight, the
level-1 check logs, JSON results and plan metrics of every arm, the level-2
result, conditions and commits per run, the six evidence-judge reports, the
two executability adjudications and the two blind passes with their keys,
and the six neutral summaries. The plan bundles stay in the git-ignored
measurement directory (`.kdd/upstream-sync/measure/b2-l2-judge/bundles/`).
Not code-derived: no anchors, no `frag-cite-check`.
