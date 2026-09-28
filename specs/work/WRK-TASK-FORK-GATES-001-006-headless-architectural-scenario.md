---
id: WRK-TASK-FORK-GATES-001-006
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-28
updated: 2026-09-28
owner: jmbruzos
title: "Headless scenario 7: architectural brainstorming with code premises and gate A1"
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

# WRK-TASK-FORK-GATES-001-006 — Headless scenario 7

## Objective

No headless scenario exercises brainstorming's architectural path, so gate
A1 and the new premise verifier are never run end to end. Add scenario 7 to
`test-kdd-flow.sh` — a billing project with specs and code — and assert on
the committed WRK-SPEC and on the session transcript that the verifier and
A1 were dispatched, that A1 attacked the written spec, and that the
persisted Adversarial Review is consistent with its closing line. Then run
it against the installed toolkit.

## Implementation Notes

**Files:**
- Modify: `tests/claude-code/test-kdd-flow.sh` (portable timeout: `TIMEOUT_CMD` after the `TIMEOUT=` line, used at the two `timeout "$TIMEOUT" claude` call sites; new `if want 7; then … fi` block after scenario 6, before `echo ""` / `usage_summary`)
- Test: the scenario itself

**Interfaces:**
- Consumes: dispatch descriptions `Premise verifier: …` (task 004) and `Adversary: A1 spec red-team on …` (task 002); A1 prompt names a `specs/work/WRK-SPEC-` path (tasks 002–003); closing line and `| Attack | Cause | Evidence | Ruling |` (task 001).
- Produces: `KDD_FLOW_SCENARIOS=7` runnable scenario; its usage JSON under `$KDD_FLOW_USAGE/scenario-7.json` when that variable is set (task 007 reads it).

**Premises:**
- `run_scenario` runs every scenario with `CLAUDE_CONFIG_DIR="$CONFIG_DIR"`, so session transcripts land under `$CONFIG_DIR/projects/**/*.jsonl` and survive until the script's `EXIT` trap — `tests/claude-code/test-kdd-flow.sh:32-34`, `:45`; `tests/claude-code/usage-lib.sh:36-39` copies them from there.
- The fixture `tests/scripts/fixtures/specs` has `DOM-BILL-PRORATA-001` (Rules 1–3) and `FRAG-BILL-ROUNDING-001` anchored at `src/billing.js:12-14` with literal `return Math.round(amount * 100) / 100;` — `tests/scripts/fixtures/specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/report.md`.
- This machine has neither `timeout` nor `gtimeout` (`command -v timeout gtimeout` → nothing; no Homebrew coreutils), and `run_scenario` calls `timeout "$TIMEOUT" claude …` (`test-kdd-flow.sh:47`, and Scenario 1 at `:62`) — every headless run fails with `timeout: command not found` until Step 1 adds a fallback. macOS ships `perl`, whose `alarm` + `exec` gives the same kill-after-N-seconds behaviour.
- Tool-use inputs in transcripts are JSON; a subagent dispatch carries `"description":"<text>"` — verify on the first run with `grep -o '"description":"[^"]*"' <transcript>`; if the harness writes `"description": "` (with a space), the `-E '"description": ?"'` patterns below already accept it.

- [ ] **Step 1: Portable timeout**

After the line `TIMEOUT="${CLAUDE_PROMPT_TIMEOUT:-900}"` add:

```bash
# portable timeout: GNU timeout, Homebrew gtimeout, or perl's alarm (macOS ships perl, not timeout)
if command -v timeout >/dev/null; then TIMEOUT_CMD=(timeout "$TIMEOUT")
elif command -v gtimeout >/dev/null; then TIMEOUT_CMD=(gtimeout "$TIMEOUT")
else TIMEOUT_CMD=(perl -e 'alarm shift; exec @ARGV' "$TIMEOUT"); fi
```

Then replace both occurrences of `timeout "$TIMEOUT" claude -p` (in `run_scenario` and in Scenario 1) with `"${TIMEOUT_CMD[@]}" claude -p`. Check: `grep -c 'timeout "\$TIMEOUT" claude' tests/claude-code/test-kdd-flow.sh` → `0`; `perl -e 'alarm shift; exec @ARGV' 2 sleep 5; echo rc=$?` → `rc=142` after 2 s (killed by SIGALRM).

- [ ] **Step 2: Add the scenario block**

Insert into `tests/claude-code/test-kdd-flow.sh`, after the `fi` that closes scenario 6 and before the `echo ""` line:

```bash
if want 7; then
echo "=== Scenario 7: brainstorming, architectural path → code premises verified, gate A1 on the written spec ==="
p7="$(new_project)"; cp -R "$REPO_ROOT/tests/scripts/fixtures/specs" "$p7/specs"; rm -rf "$p7/specs/work"; mkdir -p "$p7/src"
printf '%s\n' '// Billing helpers.' '//' '// round2 rounds a positive amount to cents, half-up.' '//' '//' '//' '//' '//' '//' '//' '//' \
  'export function round2(amount) {' '  return Math.round(amount * 100) / 100;' '}' '' \
  'export function prorata(monthlyFee, daysInMonth, remainingDays) {' '  return round2((monthlyFee / daysInMonth) * remainingDays);' '}' > "$p7/src/billing.js"
git -C "$p7" add -A; git -C "$p7" -c user.email=t@e -c user.name=t commit -qm "specs and billing code"
USAGE_SCENARIO=7
out="$(run_scenario "$p7" "Use kdd-superpowers:brainstorming, architectural path. I want a monthly statement module for this billing project: for each customer it lists every mid-cycle activation with its pro-rata charge and a monthly total, reusing src/billing.js. I approve every design section and the activation in advance and I will not answer questions: pick sensible defaults, adjudicate every BROKEN finding of gate A1 yourself (accept it unless its evidence is wrong), and stop once the WRK-SPEC is committed — do not transition it to active and do not invoke writing-plans.")"
spec7wt="$(ls "$p7"/specs/work/WRK-SPEC-*.md 2>/dev/null | head -1)"
[[ -n "$spec7wt" ]] && pass "WRK-SPEC written under specs/work" || fail "WRK-SPEC written under specs/work"
if [[ -n "$spec7wt" ]]; then
  rel7="specs/work/$(basename "$spec7wt")"
  git -C "$p7" log --format=%s -- "$rel7" | grep -q "^spec(" && pass "WRK-SPEC committed" || fail "WRK-SPEC committed"
  git -C "$p7" diff --quiet HEAD -- "$rel7" && pass "committed WRK-SPEC equals the working tree" || fail "committed WRK-SPEC equals the working tree (review appended after the commit?)"
  spec7="$(mktemp)"; git -C "$p7" show "HEAD:$rel7" > "$spec7" 2>/dev/null   # every check below reads the committed version
  grep -q "^## Code Premises" "$spec7" && pass "Code Premises section" || fail "Code Premises section"
  grep -q "^## Adversarial Review" "$spec7" && pass "Adversarial Review section" || fail "Adversarial Review section"
  closing="$(grep -Eo '[0-9]+ attempted, [0-9]+ BROKEN \(code-reality [0-9]+ · spec-rule [0-9]+ · ambiguity [0-9]+ · knowledge-gap [0-9]+ · internal [0-9]+\)' "$spec7" | head -1)"
  [[ -n "$closing" ]] && pass "closing line parses ($closing)" || fail "closing line parses"
  m="$(sed -E 's/^[0-9]+ attempted, ([0-9]+) BROKEN.*/\1/' <<<"$closing")"
  rows="$(awk '/^## Adversarial Review/{s=1; next} s && /^## /{exit} s && /^\| Attack \| Cause \| Evidence \| Ruling \|/{t=1; next} t && /^\|[-| ]+\|$/{next} t && /^\|/{n++; next} t && !/^\|/{t=0} END{print n+0}' "$spec7")"
  [[ -n "$m" && "$rows" == "$m" ]] && pass "BROKEN table has M=$m rows" || fail "BROKEN table has M rows (closing M=$m, table rows=$rows)"
  [[ "$(validate "$p7")" == *"0 error"* || "$(validate "$p7")" == *"passed"* ]] && pass "validates" || fail "validates: $(validate "$p7")"
fi
tx="$(grep -rlE '"description": ?"Adversary: A1' "$CONFIG_DIR/projects" --include='*.jsonl' 2>/dev/null | head -1)"
[[ -n "$tx" ]] && pass "gate A1 dispatched" || fail "gate A1 dispatched"
grep -rqE '"description": ?"Premise verifier' "$CONFIG_DIR/projects" --include='*.jsonl' 2>/dev/null && pass "premise verifier dispatched" || fail "premise verifier dispatched"
if [[ -n "$tx" ]]; then
  a1_input="$(grep -E '"description": ?"Adversary: A1' "$tx" | head -1)"
  grep -q 'specs/work/WRK-SPEC-' <<<"$a1_input" && ! grep -q -- '-draft.md' <<<"$a1_input" && pass "A1 prompt names the WRK-SPEC file" || fail "A1 prompt names the WRK-SPEC file"
  # order: the first tool call that writes the WRK-SPEC file (Write, or Bash writing it) comes before the A1 dispatch
  write_line="$(grep -nE '"name": ?"(Write|Bash)"' "$tx" | grep -E 'specs/work/WRK-SPEC-' | grep -vE '"name": ?"Bash".*"command": ?"(cat|ls|grep|sed -n|head|git (log|show|diff))' | head -1 | cut -d: -f1)"
  a1_line="$(grep -nE '"description": ?"Adversary: A1' "$tx" | head -1 | cut -d: -f1)"
  [[ -n "$write_line" && -n "$a1_line" && "$write_line" -lt "$a1_line" ]] && pass "WRK-SPEC written before gate A1" || fail "WRK-SPEC written before gate A1 (write line:$write_line A1 line:$a1_line)"
fi
rm -f "${spec7:-}"

fi
```

- [ ] **Step 3: Syntax check**

Run: `bash -n tests/claude-code/test-kdd-flow.sh && echo OK` — Expected: `OK`.

- [ ] **Step 4: Run the scenario against the installed toolkit (a SKIP is a failure of this step)**

```bash
export KDD_TOOLKIT_DIR=$HOME/.claude/plugins/cache/kdd/kdd/1.6.0
export KDD_SPEC_GRAPH=$KDD_TOOLKIT_DIR/cli/spec-graph.mjs
mkdir -p .kdd/usage
CLAUDE_PROMPT_TIMEOUT=2700 KDD_FLOW_SCENARIOS=7 KDD_FLOW_USAGE=.kdd/usage/after-s7 bash tests/claude-code/test-kdd-flow.sh 2>&1 | tee .kdd/usage/after-s7.log | tail -25
```

Expected: every scenario-7 line `[PASS]`, final `PASS`, and no `SKIP:` line. If an assertion fails, read `.kdd/usage/after-s7/scenario-7.transcripts/` and decide: skill defect (report DONE_WITH_CONCERNS with the evidence — tasks 002–004 own the prose) or assertion defect (fix the assertion, keep its intent, re-run). Never weaken an assertion to pass.

- [ ] **Step 5: Commit**

```bash
git add tests/claude-code/test-kdd-flow.sh
git commit -m "test(WRK-TASK-FORK-GATES-001-006): headless scenario 7 — architectural brainstorming verifies code premises and runs gate A1 on the written spec; portable timeout"
```

`.kdd/usage/` is gitignored; task 007 reads it.

## Acceptance Criteria

- [ ] Scenario 7 exists and runs with `KDD_FLOW_SCENARIOS=7` (WRK-SPEC AC8).
- [ ] It asserts, on the committed WRK-SPEC and the transcript: premise verifier dispatched; A1 dispatched with a `specs/work/WRK-SPEC-` path and no draft; the WRK-SPEC written before the A1 dispatch; committed version equals the working tree; `## Code Premises`; `## Adversarial Review` whose closing line parses and whose table has M data rows; validate passes (WRK-SPEC AC8).
- [ ] Headless runs work on a machine without `timeout`/`gtimeout` (perl fallback), unchanged where `timeout` exists.
- [ ] It passed once against kdd 1.6.0 with no SKIP; the log is in `.kdd/usage/after-s7.log` (WRK-SPEC AC8).

## Test Plan

Step 2 (syntax), Step 3 (real run).
