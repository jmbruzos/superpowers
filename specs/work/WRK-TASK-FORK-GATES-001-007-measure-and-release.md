---
id: WRK-TASK-FORK-GATES-001-007
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "Before/after measurement (FRAG-FORK-TOKENS-002) and release 0.3.0"
parent: WRK-PLAN-FORK-GATES-001
activates:
  - DOC-FORK-TOKENS-001@0.1.0
equips: []
dependencies:
  - id: WRK-PLAN-FORK-GATES-001
    relation: implements
sources:
  - id: FRAG-FORK-GATES-001
    resource: specs/_capture/FRAG-FORK-GATES-001-adversarial-gate-audit-mdm/
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-28T11:14:33+02:00 }
stale_after: 2026-12-27T11:14:33+01:00
tags: [fork, gates, task]
---

# WRK-TASK-FORK-GATES-001-007 — Measure and release

## Objective

Measure what the change costs or saves, the way DOC-FORK-TOKENS-001 says:
scenario 4 (writing-plans + A2) at least twice on the skills before this
plan and twice after, plus scenario 7 after only; record the runs in a new
capture fragment that supersedes FRAG-FORK-TOKENS-001; release 0.3.0.

## Implementation Notes

**Files:**
- Create: `specs/_capture/FRAG-FORK-TOKENS-002-gate-tuning-measurements/FRAG-FORK-TOKENS-002.md`, `…/report.md`, `…/raw/*.json`
- Modify: `package.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` (via `scripts/bump-version.sh`)
- Modify: `RELEASE-NOTES.md`

**Interfaces:**
- Consumes: `.kdd/usage/after-s7/scenario-7.json` from task 006; scenario 4 of `tests/claude-code/test-kdd-flow.sh`.
- Produces: FRAG-FORK-TOKENS-002 (consolidation at finishing distils it into DOC-FORK-TOKENS-001 — not this task).

**Premises:**
- `.worktrees/` is gitignored — `.gitignore:1` `.worktrees/`. A worktree there at `f8d369c` carries the skills as they were before this plan; its `tests/claude-code/test-kdd-flow.sh` resolves `REPO_ROOT` to the worktree (`test-kdd-flow.sh:19`), so `--plugin-dir` loads the old skills.
- `scripts/bump-version.sh <version>` updates the three files listed in `.version-bump.json` (`package.json` `version`, `.claude-plugin/plugin.json` `version`, `.claude-plugin/marketplace.json` `plugins.0.version`).
- The FRAG template has no `dependencies` field; whether `spec-graph validate` accepts `dependencies: [{id, relation: supersedes}]` on a fragment is unverified — Step 4 checks it.
- Headless runs need task 006's timeout fallback in `run_scenario` (this machine has neither `timeout` nor `gtimeout`); the "before" worktree at `f8d369c` does not have it — Step 1 runs the before-worktree's script with the fixed `run_scenario` copied in.

- [ ] **Step 1: "Before" runs from a worktree at the baseline commit**

```bash
export KDD_TOOLKIT_DIR=$HOME/.claude/plugins/cache/kdd/kdd/1.6.0
export KDD_SPEC_GRAPH=$KDD_TOOLKIT_DIR/cli/spec-graph.mjs
git worktree add .worktrees/before f8d369c
# the harness, not the skills, must be current: take HEAD's test-kdd-flow.sh (timeout fallback, scenario 7) into the worktree
cp tests/claude-code/test-kdd-flow.sh .worktrees/before/tests/claude-code/test-kdd-flow.sh
for i in 1 2; do
  KDD_FLOW_SCENARIOS=4 KDD_FLOW_USAGE=$PWD/.kdd/usage/before-s4-$i bash .worktrees/before/tests/claude-code/test-kdd-flow.sh 2>&1 | tail -12
done
git worktree remove .worktrees/before
```

Expected: each run ends `PASS` and prints a usage table. A failed run is re-run, not dropped; report how many runs were attempted.

- [ ] **Step 2: "After" runs at HEAD**

```bash
for i in 1 2; do
  KDD_FLOW_SCENARIOS=4 KDD_FLOW_USAGE=$PWD/.kdd/usage/after-s4-$i bash tests/claude-code/test-kdd-flow.sh 2>&1 | tail -12
done
python3 tests/claude-code/usage-summary.py .kdd/usage/after-s7
```

Expected: `PASS` per run. If the spread within a side exceeds the difference between sides for cost or output tokens, run a third pair (DOC-FORK-TOKENS-001 §How to measure) and say so in the report.

- [ ] **Step 3: Write the fragment**

```bash
D=specs/_capture/FRAG-FORK-TOKENS-002-gate-tuning-measurements
mkdir -p $D/raw
for s in before-s4-1 before-s4-2 after-s4-1 after-s4-2 after-s7; do
  f=$(ls .kdd/usage/$s/scenario-*.json | head -1); cp "$f" "$D/raw/$s.json"
done
```

`$D/report.md` — structure (fill every table cell from `usage-summary.py` output of each directory; no estimates):

```markdown
# Token usage before and after WRK-SPEC-FORK-GATES-001 — headless runs, <date>

Measurement report. Not code-derived: no anchors. Every number is read from a
`claude -p --output-format json` result kept verbatim under `raw/`.

## Method
- Claude Code <`claude --version`>, headless, isolated CLAUDE_CONFIG_DIR, kdd toolkit 1.6.0.
- Before: skills at `f8d369c` (worktree). After: skills at `<HEAD sha>`.
- Scenario 4 (writing-plans, 2 tasks, gate A2) twice per side; scenario 7 (architectural brainstorming, premise verifier, gate A1) after only — it does not exist before this change.

## Observed
| Run | Scenario | Turns | Cache write | Cache read | Output | Cost | Duration |
|---|---|---|---|---|---|---|---|
(one row per raw/*.json)

## Observed — spread
| Side | Scenario | Cost min–max | Output min–max |
|---|---|---|---|

## Observed — gate tables in the runs
(for each run: the A1/A2 closing line as written in the produced WRK-SPEC / WRK-PLAN, from the transcripts)

## Inferred
(each line names the rows it rests on; say plainly when the before/after difference is inside the spread)
```

Then compute integrity and write the fragment file:

```bash
( cd $D && cat $(printf '%s\n' raw/*.json report.md | sort) | shasum -a 256 | cut -d' ' -f1 )
```

`$D/FRAG-FORK-TOKENS-002.md`:

```yaml
---
id: FRAG-FORK-TOKENS-002
type: fragment
layer: capture
scope: persistent
status: ingested
confidence: low
version: 1.0.0
created: <date>
updated: <date>
owner: jmbruzos
title: "Token usage of the kdd-superpowers flow — before and after WRK-SPEC-FORK-GATES-001 (headless, scenarios 4 and 7)"
captured_at: <datetime>
source_type: report
files:
  - raw/after-s4-1.json
  - raw/after-s4-2.json
  - raw/after-s7.json
  - raw/before-s4-1.json
  - raw/before-s4-2.json
  - report.md
integrity: "sha256:<hash from the command above>"
origin: kdd-superpowers
routed_to: []
dependencies:
  - id: FRAG-FORK-TOKENS-001
    relation: supersedes
generated:
  by: claude-code/<model-id>
  at: <datetime>
tags: [capture, fork, tokens, measurement, gates]
---

# FRAG-FORK-TOKENS-002 — Token usage before and after the gate tuning

Immutable capture. report.md holds the method, the per-run table and the
spread; raw/ holds the `claude -p --output-format json` results. Not
code-derived: no anchors, no `frag-cite-check`. Supersedes
FRAG-FORK-TOKENS-001; the reconciled knowledge cites this fragment in
`sources` at consolidation.
```

The `files` list is sorted by name — the order `computeFragmentIntegrity` hashes them in (`spec-graph.mjs` sorts `files` before hashing).

- [ ] **Step 4: Validate**

Run: `skills/using-superpowers/scripts/kdd-cli --specs specs validate`
Expected: `Validation passed`. If it rejects `supersedes` on a fragment, remove the `dependencies` block, keep the "Supersedes FRAG-FORK-TOKENS-001" sentence in the body, recompute nothing (the frontmatter is not hashed), re-validate, and report it as a `Knowledge gap:` concern.

- [ ] **Step 5: Release**

```bash
scripts/bump-version.sh 0.3.0
scripts/bump-version.sh --check
```

Add at the top of `RELEASE-NOTES.md`, under `# Release notes`:

```markdown
## 0.3.0 — adversarial gates A1/A2 tuned

Implements WRK-SPEC-FORK-GATES-001, from an audit of three executed plans
(FRAG-FORK-GATES-001: 46 % of A1's recorded BROKEN findings were unchecked
premises about existing code):
- brainstorming lists the design's *Code premises* and checks them with a
  mid-tier read-only verifier (`premise-verifier-prompt.md`) before gate A1;
  the WRK-SPEC gains `## Code Premises`; writing-plans reads them and each
  WRK-TASK states any further premise on a `**Premises:**` line.
- Gate A1 attacks the written, self-reviewed WRK-SPEC (no draft file); the
  commit follows adjudication; A1 re-runs when the human review changes
  substance.
- A1 and A2 tables carry a Cause (`code-reality`, `spec-rule`, `ambiguity`,
  `knowledge-gap`, `internal`), at most 3 full rows per attack with every
  further BROKEN finding as a one-liner (all adjudicated), and a closing line
  with the breakdown; `## Adversarial Review` persists every BROKEN finding
  as `| Attack | Cause | Evidence | Ruling |`. A2 gains attack 7 *Code
  premise*. A3–A6 unchanged.
- `test-kdd-flow.sh` scenario 7 runs the architectural path headless.
- Cost before/after: FRAG-FORK-TOKENS-002 — <one sentence with the measured
  difference and the spread, from report.md>.
```

- [ ] **Step 6: Final checks**

Run: `bash tests/scripts/run.sh 2>&1 | grep -E '^### |\[FAIL\]' | diff .kdd/baseline-run.txt -` — Expected: no output.
Run:

```bash
bash tests/hooks/test-session-start.sh 2>&1 | grep -E '\[FAIL\]|^PASS|^FAILED' | diff .kdd/baseline-session-start.txt -
bash tests/claude-code/test-sdd-workspace.sh 2>&1 | grep -E '\[FAIL\]|^PASS|^FAILED' | diff .kdd/baseline-sdd-workspace.txt -
(cd tests/brainstorm-server && npm test 2>&1 | grep -Ei 'fail|pass') | diff .kdd/baseline-brainstorm-server.txt -
```

Expected: no output from any of the three diffs (task 001 wrote the baselines).

- [ ] **Step 7: Commit**

```bash
git add specs/_capture/FRAG-FORK-TOKENS-002-gate-tuning-measurements package.json .claude-plugin/plugin.json .claude-plugin/marketplace.json RELEASE-NOTES.md
git commit -m "chore(WRK-TASK-FORK-GATES-001-007): release 0.3.0 — gate tuning; FRAG-FORK-TOKENS-002 measures before/after"
```

## Acceptance Criteria

- [ ] Scenario 4 ran ≥ 2 times per side (before at `f8d369c`, after at HEAD) and scenario 7 once after; spread per side reported; after-only stated for scenario 7 (WRK-SPEC AC9).
- [ ] FRAG-FORK-TOKENS-002 records every run with raw JSON, supersedes FRAG-FORK-TOKENS-001 (or records why it cannot), validates, and is cited from RELEASE-NOTES (WRK-SPEC AC9; DOC-FORK-TOKENS-001 §Maintenance).
- [ ] Version 0.3.0 in the three files; RELEASE-NOTES entry (WRK-SPEC AC10).
- [ ] No new test failures against the baseline (WRK-SPEC AC7).

## Test Plan

Steps 4 and 6; `bump-version.sh --check` reports no drift.
