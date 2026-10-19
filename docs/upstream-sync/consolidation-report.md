## Consolidation Report: WRK-SPEC-FORK-UPSTREAM-001 … -005 — upstream sync superpowers 6.4.1–7.0.0 / toolkit 1.13 (batches 0–4)

Run unattended on 2026-10-19 (01:30Z) at `6046936`, branch `feat/upstream-7-integration`; not committed.

### Work Summary
- WRK-SPECs: -001 batch 0 (completed), -002 batch 1 (completed, bounded, no plan), -003 batch 2 (**active** — close waits for the human's rework-vs-revert ruling, U-22), -004 batch 3 (completed), -005 batch 4 (completed).
- WRK-PLANs: -003, -004, -005 (all completed); WRK-TASKs -003-001…004, -004-001…005, -005-001…004 (all completed).
- Knowledge activated: DOC-FORK-UPSTREAM-001@0.1.0, DOC-FORK-GATES-001@0.4.0, DOC-FORK-LEDGER-001@0.1.0, DOC-FORK-TOKENS-001@0.3.0 (all draft, low, no `verified`).
- Capabilities equipped: none.
- Evidence: FRAG-FORK-UPSTREAM-001…005; decision log `docs/upstream-sync/decision-log.md` (H-1…H-9, U-1…U-23).

### 1. ADRs to Create
None. Every decision is recorded in the decision log, a WRK-SPEC/PLAN Adversarial Review or now in the DOCs below; none is an undocumented architectural choice.

### 2. Specs Updated (applied)
| Spec | Old → New | Change |
|---|---|---|
| DOC-FORK-UPSTREAM-001 | 0.1.0 → 0.2.0 | §2 Outcome column per batch (0.6.1; 0.7.0→0.7.1/0.7.2 with both regressions; 0.8.0 after the U-22 rework, human ruling pending; 0.9.0, level 2b dropped H-8; 0.10.0, builder check not taken U-16, "Declined to judge" dropped U-20; batch 5 pending the human); patch-release and tag-after-measurement rule; §3.7 names test-executing-plans-scripts.sh (via run.sh shim); new §3.9 pressure tests need a baseline on the before text; §4 harness = script + toolkit-env.sh + helpers + fixtures (U-9), `--model opus`/KDD_FLOW_MODEL (U-11), H-8 narrowing (n=1 unless a gain is claimed; level 2 only for plan/design prose; evidence judge + executability adjudication; no neutral summaries/blind pass; no level 2b), classifier-cut rule, amendment-3 executability counting rule, worse batch held while a ruling is pending, amendments recorded. |
| DOC-FORK-LEDGER-001 | 0.1.0 → 0.2.0 | Writers table (SDD by hand; Native via task-start/task-done) and order vs transition; Native completion suffix `(commits a..b, tests: <cmd> → <last line \| (no output)>)`; identity compared by plan ID in both modes; frontmatter resume signal with each mode's repair (SDD: complete line over active file → run the transition; Native: completed without line → re-run task-done); root settled (plan's working tree, `none` from another checkout, tested); task-done range recovery and its dependency on transition's `chore(<ID>): complete` subject; empty-range exit 3; note forms (Pre-flight:, Attack: … — Ruling:, Final: minor (deferred):, Final: fixed, Final: Ruling:); create-only `.kdd/sdd/.gitignore`; review-package exit 3; workspace lifetime; inconsistencies 1, 2, 4 closed; four new open ones from batch-3 deferred minors; all line citations refreshed at `6046936`. |
| DOC-FORK-GATES-001 | 0.4.0 → 0.5.0 | New sections: execution modes and the gates (SDD vs Native per gate: final test run, A3, A4, knowledge check, A5, Review Focus), gate (b) knowledge-check prompt and its known gap, measured scenario-8 evidence; Review Focus (0.8.0) in the reviewer; the code reviewer after batch 1 ("vision document" kept, "Declined to judge" removed, U-20, classifier evidence); gate A1 stands for 7.0's builder check (U-16). Maintenance: re-run scenario 8 after a mode change. |
| DOC-FORK-TOKENS-001 | 0.3.0 → 0.4.0 | FRAG-FORK-UPSTREAM-001 as latest fixture baseline (supersedes FRAG-FORK-TOKENS-003) with its table; per-batch cost table (batch 1 inside spread; batch 2 lean plans ~18 % cheaper at level 2, plans half as long; batch 3 +10 % s4+s5, Native ~20 % cheaper than SDD; batch 4 +14 % at level 2); How to measure: opt-in scenarios 8/9, per-scenario transcripts (usage-lib.sh), model pin, harness+fixtures copy, classifier-cut discard, result.json caveat; Maintenance: new baseline supersedes FRAG-FORK-UPSTREAM-001. |

All four: `updated: 2026-10-19`, `generated: {by: claude-code/claude-opus-5-5, at: 2026-10-19T01:30:56Z}`, cited FRAGs added to `sources` (and `distilled-from` where the DOC distils them), `status: draft`, `confidence: low`, no `verified`.

FRAG status flips (frontmatter only; files and integrity untouched, integrity re-checked): FRAG-FORK-UPSTREAM-001…005 `ingested → distilled`; also FRAG-FORK-LEDGER-001 `ingested → distilled` (DOC-FORK-LEDGER-001 has cited it as `distilled-from` since 0.1.0 without the flip).

### 3. New Specs Created
None.

### 4. Confidence Upgrades
None (all remain `low`; no human `verified`, U-1).

### 5. Capability Feedback
n/a (no `equips`).

### 6. Evidence & Tooling — capture candidates
| Candidate | Anchor check at 6046936 | Disposition |
|---|---|---|
| transition:131 — `chore(<ID>): complete` subject task-done greps for (WRK-TASK-004-001) | verifies | **No FRAG**: written into DOC-FORK-LEDGER-001 (*Re-run of task-done*) with the file:line citation. A code-derived FRAG-FORK-LEDGER-002 was drafted but this session's tooling refused to write a `report.md` file; the facts are cited directly in the DOC as 0.1.0 already did. |
| review-package:25-28 — exit 3 for empty range / HEAD not descending (WRK-TASK-004-003; U-8) | verifies (guards at :27-28) | No FRAG: in DOC-FORK-LEDGER-001 (*review-package exit 3*). |
| sdd-workspace create-only `.kdd/sdd/.gitignore` (U-8) | verifies (:44-46) | No FRAG: in DOC-FORK-LEDGER-001 (*Where it lives*). |
| usage-lib.sh per-scenario transcript copy (WRK-TASK-005-003) | verifies (:29, :36-41) | No FRAG (test harness, not product behaviour): documented in DOC-FORK-TOKENS-001 *How to measure*. |

### 7. Open Items (for the human)
| Item | Source | Recommendation |
|---|---|---|
| Batch 2 rework vs revert ruling; WRK-SPEC-FORK-UPSTREAM-003 stays `active` | U-22, spec AC5 | Rule; then close -003. |
| Batch 5 (diagnosing) go / no-go | DOC-FORK-UPSTREAM-001 §2 | Decide. |
| Review all U-* rulings now written into the DOCs (U-9, U-11, U-13, U-16, U-19, U-20, U-22) | decision log | Confirm or overturn; a confirmation can be recorded as `verified` on each DOC (`transition --verify-only`). |
| Native has not executed a real-task plan (level 2b dropped) | H-8 | Accept the gap or reinstate level 2b for a later release. |
| `adversarial-gates.md` table still says A4 "SDD, after A3" and does not name Native's gates (a)/(b) | skills/kdd-conventions/references/adversarial-gates.md:11 vs DOC-FORK-GATES-001 0.5.0 | Small skill edit in a later WRK (out of scope here: no skills/ edits). |
| knowledge-check prompt omits "or a `constrained-by` principle" | WRK-TASK-004-002 deferred minor | Same follow-up WRK. |
| Ledger open inconsistencies 3–6 (task-done root from cwd, bulleted lines, `ℹ duration_ms` result tail, substring first-commit lookup) | DOC-FORK-LEDGER-001 0.2.0 | One small WRK-SPEC for the `task-*` scripts. |
| Gate A6 has not attacked the 0.2.0 ledger additions | DOC-FORK-LEDGER-001 Status | Run A6 if the ledger becomes promotion material. |
| Deferred minors in the three Execution Logs (plan-metrics parsing, scenario-8/9 harness checks, using-superpowers row columns) | WRK-PLAN-003/004/005 | Triage into a harness-hygiene WRK. |

### Recommended Actions (Priority Order)
1. Human ruling on batch 2 (U-22), then close WRK-SPEC-FORK-UPSTREAM-003.
2. Review the diff of the four DOCs and the U-* rulings they now carry; verify where confirmed.
3. Batch 5 go / no-go.
4. Follow-up WRK for adversarial-gates.md + knowledge-check prompt + task-* script minors.

### Post-Consolidation
- `spec-graph validate`: "Validation passed. No issues found. Checked 83 specs, 306 edges."
- `bash tests/scripts/run.sh`: every suite ok, exit 0.
- Archive the batch work artifacts once -003 closes.
