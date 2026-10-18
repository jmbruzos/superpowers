#!/usr/bin/env bash
# The execution fixture with an activated numeric rule (WRK-SPEC-FORK-UPSTREAM-001 AC3):
# one task activates a money-rounding rule, so gate A4's condition holds for it.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
FX="$REPO_ROOT/tests/claude-code/fixtures/rounding-plan/specs"
echo "=== Test: rounding-plan fixture ==="
require_cli
[[ -d "$FX" ]] || { fail "fixtures/rounding-plan/specs exists"; finish; }

out="$(node "$KDD_CLI" --specs "$FX" validate 2>&1)"
[[ "$out" == *"No issues found"* ]] && pass "fixture validates with no issues" || { fail "fixture validates with no issues"; echo "$out" | sed 's/^/    /'; }

json="$(node "$KDD_CLI" --specs "$FX" filter --format json)"
# filter's JSON carries no `activates`: read it from each file's frontmatter
count() {
  local n=0 f
  for f in "$FX"/work/*.md; do
    awk 'NR==1&&$0!="---"{exit 1} /^---$/{c++; if(c==2) exit; next} c==1' "$f" > "$f.fm.tmp" || { rm -f "$f.fm.tmp"; continue; }
    grep -q "^layer: $1\$" "$f.fm.tmp" && awk '/^activates:/{a=1;next} a&&/^  - /{print;next} {a=0}' "$f.fm.tmp" | grep -q 'DOM-DEMO-ROUNDING-001@' && n=$((n+1))
    rm -f "$f.fm.tmp"
  done
  echo "$n"
}
[[ "$(count work-task)" -eq 1 ]] && pass "exactly one WRK-TASK activates DOM-DEMO-ROUNDING-001" || fail "exactly one WRK-TASK activates DOM-DEMO-ROUNDING-001 (got $(count work-task))"
[[ "$(count work-spec)" -eq 1 ]] && pass "the WRK-SPEC activates DOM-DEMO-ROUNDING-001" || fail "the WRK-SPEC activates DOM-DEMO-ROUNDING-001"
n_tasks="$(printf '%s' "$json" | node -e "const j=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log(j.filter(n=>n.layer==='work-task'&&n.status==='active').length)")"
[[ "$n_tasks" -eq 2 ]] && pass "the plan has two active tasks" || fail "the plan has two active tasks (got $n_tasks)"

dom="$(grep -rl '^id: DOM-DEMO-ROUNDING-001$' "$FX")"
grep -q 'half-even' "$dom" && grep -q '0\.005' "$dom" && pass "the rule states an exact value (half-even, 0.005 case)" \
  || fail "the rule states an exact value (half-even, 0.005 case)"
finish
