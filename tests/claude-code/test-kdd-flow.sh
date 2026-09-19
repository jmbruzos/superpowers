#!/usr/bin/env bash
# Headless Claude Code scenarios for the kdd-superpowers flow.
# Assumptions: `claude` on PATH; the kdd toolkit at $KDD_TOOLKIT_DIR (default
# ../knowledge-driven-development/kdd-toolkit relative to the repo); credentials in
# ~/.claude/.credentials.json (copied into an isolated CLAUDE_CONFIG_DIR so user-scope
# plugins — e.g. upstream superpowers — do not load) or ANTHROPIC_API_KEY set.
#
# Nested-session note: when this test itself runs inside a Claude Code session
# (e.g. a Claude agent executing this file), the child `claude -p` inherits
# CLAUDECODE / CLAUDE_CODE_* env vars and refuses to start ("already inside a
# Claude Code session"). run_scenario and Scenario 1's inline command therefore
# invoke claude via `env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT
# -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID
# -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN
# -u CLAUDE_CODE_SESSION_ATTENDED -u CLAUDE_CODE_EXECPATH …` to strip those
# vars before launching the nested headless run.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"
source "$SCRIPT_DIR/usage-lib.sh"   # KDD_FLOW_USAGE=<dir> → per-scenario token usage (WRK-SPEC-FORK-TOKENS-001)
KDD_TOOLKIT_DIR="${KDD_TOOLKIT_DIR:-$REPO_ROOT/../knowledge-driven-development/kdd-toolkit}"
KDD_SPEC_GRAPH="${KDD_SPEC_GRAPH:-$KDD_TOOLKIT_DIR/cli/spec-graph.mjs}"
TIMEOUT="${CLAUDE_PROMPT_TIMEOUT:-900}"
FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

command -v claude >/dev/null || { echo "SKIP: claude not found"; exit 0; }
[[ -f "$KDD_SPEC_GRAPH" ]] || { echo "SKIP: kdd toolkit not found at $KDD_TOOLKIT_DIR"; exit 0; }

CONFIG_DIR="$(mktemp -d)"
[[ -f "$HOME/.claude/.credentials.json" ]] && cp "$HOME/.claude/.credentials.json" "$CONFIG_DIR/"
trap 'rm -rf "$CONFIG_DIR"' EXIT

run_scenario() { # DIR PROMPT [extra env…] — runs claude headless in DIR with both plugins
  local dir="$1" prompt="$2"; shift 2
  local raw; raw="$(mktemp)"
  # re-copy the credentials: the isolated copy cannot refresh once the user's own session has
  # rotated the token, and a full run outlives one token (observed: authentication_failed mid-run)
  [[ -f "$HOME/.claude/.credentials.json" ]] && cp "$HOME/.claude/.credentials.json" "$CONFIG_DIR/"
  ( cd "$dir" && env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_CHILD_SESSION \
      -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN \
      -u CLAUDE_CODE_SESSION_ATTENDED -u CLAUDE_CODE_EXECPATH \
      CLAUDE_CONFIG_DIR="$CONFIG_DIR" KDD_SPEC_GRAPH="$KDD_SPEC_GRAPH" "$@" \
      timeout "$TIMEOUT" claude -p "$prompt" --plugin-dir "$REPO_ROOT" --plugin-dir "$KDD_TOOLKIT_DIR" \
      --allowed-tools=all --permission-mode bypassPermissions $(usage_args) 2>&1 ) > "$raw"
  usage_record "$raw" "$CONFIG_DIR"   # prints the result text; with KDD_FLOW_USAGE also saves the JSON
  rm -f "$raw"
}
new_project() { local d; d="$(mktemp -d)"; git -C "$d" init -q -b main; printf 'node_modules/\n' > "$d/.gitignore"; git -C "$d" add -A; git -C "$d" -c user.email=t@e -c user.name=t commit -qm init; echo "$d"; }
validate() { node "$KDD_SPEC_GRAPH" --specs "$1/specs" validate 2>&1; }
want() { [[ -z "${KDD_FLOW_SCENARIOS:-}" || " $KDD_FLOW_SCENARIOS " == *" $1 "* ]]; }   # KDD_FLOW_SCENARIOS="5 6" runs only those

if want 1; then
echo "=== Scenario 1: toolkit missing → brainstorming stops with install instruction ==="
p1="$(new_project)"
out="$(cd "$p1" && env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_CHILD_SESSION \
      -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN \
      -u CLAUDE_CODE_SESSION_ATTENDED -u CLAUDE_CODE_EXECPATH \
      CLAUDE_CONFIG_DIR="$CONFIG_DIR" KDD_SPEC_GRAPH=/nonexistent HOME="$CONFIG_DIR" \
      timeout "$TIMEOUT" claude -p "Let's make a react todo list" --plugin-dir "$REPO_ROOT" --allowed-tools=all --permission-mode bypassPermissions 2>&1)"
assert_contains "$out" "kdd" "mentions the kdd toolkit" || FAILURES=$((FAILURES+1))
assert_contains "$out" "install\|KDD_SPEC_GRAPH" "gives an install instruction" || FAILURES=$((FAILURES+1))
[[ ! -d "$p1/specs/work" ]] && pass "no work artifact written" || fail "no work artifact written"

fi
if want 2; then
echo "=== Scenario 2: brainstorming with a knowledge base → frozen WRK-SPEC ==="
p2="$(new_project)"; cp -R "$REPO_ROOT/tests/scripts/fixtures/specs" "$p2/specs"; rm -rf "$p2/specs/work"; git -C "$p2" add -A; git -C "$p2" -c user.email=t@e -c user.name=t commit -qm specs
USAGE_SCENARIO=2
out="$(run_scenario "$p2" "Use kdd-superpowers:brainstorming, bounded path. I want a helper that computes the pro-rata amount for a mid-cycle activation in this billing project. I approve the design and the activation in advance and I will not answer questions: pick sensible defaults, write the compact WRK-SPEC, validate it, commit it, and transition it to active with verified by human:test.")"
spec="$(ls "$p2"/specs/work/WRK-SPEC-*.md 2>/dev/null | head -1)"
[[ -n "$spec" ]] && pass "WRK-SPEC written under specs/work" || fail "WRK-SPEC written under specs/work"
if [[ -n "$spec" ]]; then
  grep -q "activation_frozen: true" "$spec" && pass "activation frozen" || fail "activation frozen"
  grep -q "DOM-BILL-PRORATA-001@" "$spec" && pass "activates the pinned DOM" || fail "activates the pinned DOM"
  grep -q "^status: active" "$spec" && pass "status active" || fail "status active"
  grep -q "human:test" "$spec" && pass "human verified entry" || fail "human verified entry"
  [[ "$(validate "$p2")" == *"0 error"* || "$(validate "$p2")" == *"passed"* ]] && pass "validates" || fail "validates: $(validate "$p2")"
  grep -q "^## Problem Statement" "$spec" && ! grep -q "^## Open Questions" "$spec" && pass "compact body" || fail "compact body"
fi

fi
if want 3; then
echo "=== Scenario 3: brainstorming without specs/ → specs/work created, activates [], FRAG anchored ==="
p3="$(new_project)"; mkdir -p "$p3/src"; printf 'export function round2(a) {\n  return Math.round(a * 100) / 100;\n}\n' > "$p3/src/money.js"; git -C "$p3" add -A; git -C "$p3" -c user.email=t@e -c user.name=t commit -qm code
USAGE_SCENARIO=3
out="$(run_scenario "$p3" "Use kdd-superpowers:brainstorming, bounded path. Add a formatMoney(amount) helper next to src/money.js that returns the rounded amount with two decimals as a string. Capture what src/money.js already does as a fragment first. I approve everything in advance; do not ask questions; write the compact WRK-SPEC, validate, commit.")"
[[ -d "$p3/specs/work" ]] && pass "specs/work created" || fail "specs/work created"
spec3="$(ls "$p3"/specs/work/WRK-SPEC-*.md 2>/dev/null | head -1)"
[[ -n "$spec3" ]] && grep -q "activates: \[\]" "$spec3" && pass "activates: [] stated" || fail "activates: [] stated"
frag="$(ls -d "$p3"/specs/_capture/FRAG-*/ 2>/dev/null | head -1)"
if [[ -n "$frag" ]]; then
  pass "FRAG captured"
  (cd "$p3" && "$REPO_ROOT/skills/kdd-conventions/scripts/frag-cite-check" "$frag" >/dev/null 2>&1) && pass "FRAG anchors verify" || fail "FRAG anchors verify"
  grep -q "^confidence: low" "$frag"/FRAG-*.md && pass "FRAG born low confidence" || fail "FRAG born low confidence"
else fail "FRAG captured"; fi

fi
if want 4; then
echo "=== Scenario 4: writing-plans from an active WRK-SPEC → plan + task files ==="
p4="$(new_project)"; cp -R "$REPO_ROOT/tests/scripts/fixtures/specs" "$p4/specs"; rm -f "$p4"/specs/work/WRK-PLAN-* "$p4"/specs/work/WRK-TASK-*; git -C "$p4" add -A; git -C "$p4" -c user.email=t@e -c user.name=t commit -qm specs
USAGE_SCENARIO=4
out="$(run_scenario "$p4" "Use kdd-superpowers:writing-plans for WRK-SPEC-BILL-PRORATA-001 (specs/work). Two tasks are enough. Write the WRK-PLAN and the WRK-TASK files, validate, and when you offer the execution choice assume I chose Subagent-Driven: activate them and commit. Do not execute the plan.")"
plan="$(ls "$p4"/specs/work/WRK-PLAN-BILL-PRORATA-*.md 2>/dev/null | head -1)"
[[ -n "$plan" ]] && pass "WRK-PLAN written" || fail "WRK-PLAN written"
n="$(ls "$p4"/specs/work/WRK-TASK-BILL-PRORATA-001-*.md 2>/dev/null | wc -l | tr -d ' ')"
[[ "$n" -ge 1 ]] && pass "WRK-TASK files written ($n)" || fail "WRK-TASK files written"
for t in "$p4"/specs/work/WRK-TASK-*.md; do
  [[ -f "$t" ]] || continue
  awk '/^activates:/{f=1; next} f && /^[[:space:]]+- /{print; next} f{exit}' "$t" | grep -vq "DOM-BILL-PRORATA-001@1.0.0" && fail "task activations ⊆ spec ($(basename "$t"))" || pass "task activations ⊆ spec ($(basename "$t"))"
done
[[ -n "$plan" ]] && grep -q "^## Architecture Impact" "$plan" && grep -q "DOM-BILL-PRORATA-001" "$plan" && pass "Architecture Impact cites the DOM" || fail "Architecture Impact cites the DOM"
[[ "$(validate "$p4")" == *"0 error"* || "$(validate "$p4")" == *"passed"* ]] && pass "plan + tasks validate" || fail "plan + tasks validate: $(validate "$p4")"

fi
if want 5; then
echo "=== Scenario 5: subagent-driven-development executes the hello plan ==="
p5="$(new_project)"; cp -R "$SCRIPT_DIR/fixtures/hello-plan/specs" "$p5/specs"; git -C "$p5" add -A; git -C "$p5" -c user.email=t@e -c user.name=t commit -qm plan
USAGE_SCENARIO=5
out="$(run_scenario "$p5" "Use kdd-superpowers:subagent-driven-development to execute specs/work/WRK-PLAN-DEMO-HELLO-001-hello-library.md. Work on this branch (I consent). Run through the final review; when finishing-a-development-branch presents its menu, choose option 3 (keep as-is) and stop.")"
(cd "$p5" && npm test >/dev/null 2>&1) && pass "hello library tests pass" || fail "hello library tests pass"
if [[ -f "$p5/.kdd/sdd/WRK-PLAN-DEMO-HELLO-001/progress.md" ]]; then
  pass "ledger under .kdd/sdd/<plan id>/"
elif git -C "$p5" log --format=%s | grep -qi "WRK-PLAN-DEMO-HELLO-001.*execution log"; then
  pass "ledger under .kdd/sdd/<plan id>/ (deleted by finishing after the execution log commit; git log shows the execution log commit)"
else
  fail "ledger under .kdd/sdd/<plan id>/ (deleted by finishing after the execution log commit, and no execution-log commit found in git log)"
fi
grep -q "^status: completed" "$p5"/specs/work/WRK-TASK-DEMO-HELLO-001-001-*.md && pass "task 001 completed" || fail "task 001 completed"
grep -q "^status: completed" "$p5"/specs/work/WRK-TASK-DEMO-HELLO-001-002-*.md && pass "task 002 completed" || fail "task 002 completed"
grep -q "^status: completed" "$p5"/specs/work/WRK-PLAN-DEMO-HELLO-001-*.md && pass "plan completed" || fail "plan completed"
git -C "$p5" log --format=%s | grep -q "WRK-TASK-DEMO-HELLO-001-001" && pass "commits carry task IDs" || fail "commits carry task IDs"
grep -q "^## Execution Log" "$p5"/specs/work/WRK-PLAN-DEMO-HELLO-001-*.md && pass "execution log persisted by finishing" || fail "execution log persisted by finishing"
grep -q "^status: completed\|^status: archived" "$p5"/specs/work/WRK-SPEC-DEMO-HELLO-001-*.md && pass "spec closed" || fail "spec closed"

fi
if want 6; then
echo "=== Scenario 6: code review flags an activated-rule violation as Critical ==="
p6="$(new_project)"; cp -R "$REPO_ROOT/tests/scripts/fixtures/specs" "$p6/specs"; mkdir -p "$p6/src"
printf 'export function round2(a) { return Math.floor(a * 100) / 100; }\n' > "$p6/src/billing.js"
git -C "$p6" add -A; git -C "$p6" -c user.email=t@e -c user.name=t commit -qm "feat: floor rounding"
USAGE_SCENARIO=6
out="$(run_scenario "$p6" "Use kdd-superpowers:requesting-code-review in mode kdd-work for WRK-SPEC-BILL-PRORATA-001: review the last commit (BASE=HEAD~1, HEAD=HEAD) with review-brief and the code-reviewer template, and paste the reviewer's full report.")"
assert_contains "$out" "Knowledge Compliance" "report has a knowledge compliance section" || FAILURES=$((FAILURES+1))
assert_contains "$out" "Critical" "violation is Critical" || FAILURES=$((FAILURES+1))
assert_contains "$out" "half-up\|Rule 3\|DOM-BILL-PRORATA-001" "names the violated rule" || FAILURES=$((FAILURES+1))

fi
echo ""
usage_summary   # only with KDD_FLOW_USAGE
if [[ "$FAILURES" -ne 0 ]]; then echo "FAILED: $FAILURES assertion(s)."; exit 1; fi
echo "PASS"
