#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
TASK_BRIEF="$REPO_ROOT/skills/subagent-driven-development/scripts/task-brief"
echo "=== Test: task-brief ==="
require_cli
repo="$(make_fixture_repo)"; trap 'rm -rf "$repo"' EXIT
export KDD_SPEC_GRAPH="$KDD_CLI"

out="$(cd "$repo" && "$TASK_BRIEF" specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md)"; rc=$?
path="$(printf '%s\n' "$out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
[[ "$rc" -eq 0 && "$path" == "$repo/.kdd/sdd/WRK-PLAN-BILL-PRORATA-001/WRK-TASK-BILL-PRORATA-001-001-brief.md" ]] \
  && pass "writes <workspace of parent plan>/<TASK-ID>-brief.md" || { fail "writes <workspace of parent plan>/<TASK-ID>-brief.md"; echo "    rc=$rc out=$out"; }
b="$(cat "$path" 2>/dev/null)"
for h in "# Task brief — WRK-TASK-BILL-PRORATA-001-001" "## 1. Task" "## 2. Architecture Impact (WRK-PLAN-BILL-PRORATA-001)" "## 3. Activated knowledge" "### DOM-BILL-PRORATA-001 @1.0.0" "## 4. Evidence (fragments cited in sources)" "### FRAG-BILL-ROUNDING-001"; do
  [[ "$b" == *"$h"* ]] && pass "contains '$h'" || fail "contains '$h'"
done
[[ "$b" == *"Implement \`prorata(fee, day, daysInMonth)\`"* ]] && pass "task text is inlined" || fail "task text is inlined"
[[ "$b" == *"Round to 2 decimal places, half-up"* ]] && pass "activated DOM body is inlined" || fail "activated DOM body is inlined"
[[ "$b" == *"| Round to 2 decimal places, half-up | DOM-BILL-PRORATA-001 |"* ]] && pass "plan Architecture Impact row is inlined" || fail "plan Architecture Impact row is inlined"
[[ "$b" == *"Math.round(amount * 100) / 100"* ]] && pass "FRAG report.md is inlined" || fail "FRAG report.md is inlined"
[[ "$b" != *"PIN DRIFT"* ]] && pass "no PIN DRIFT when pin matches" || fail "no PIN DRIFT when pin matches"
[[ "$b" != *"## 3b. Equipped capabilities"* ]] && pass "no equips section when equips is empty" || fail "no equips section when equips is empty"

out2="$(cd "$repo" && "$TASK_BRIEF" specs/work/WRK-TASK-BILL-PRORATA-001-002-billing-api-endpoint.md)"
path2="$(printf '%s\n' "$out2" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
b2="$(cat "$path2" 2>/dev/null)"
[[ "$b2" == *"**PIN DRIFT:** pinned 0.9.0, file is 1.0.0"* ]] && pass "PIN DRIFT header on version mismatch" || { fail "PIN DRIFT header on version mismatch"; }

# sources entry with id as a later key, not the first
task3="$repo/specs/work/WRK-TASK-BILL-PRORATA-001-003-prorata-calculation.md"
sed -e 's/^id: WRK-TASK-BILL-PRORATA-001-001$/id: WRK-TASK-BILL-PRORATA-001-003/' \
    -e 's/^  - id: FRAG-BILL-ROUNDING-001$/  - resource: specs\/_capture\/FRAG-BILL-ROUNDING-001-half-up-rounding\//' \
    -e 's/^    resource: specs\/_capture\/FRAG-BILL-ROUNDING-001-half-up-rounding\/$/    id: FRAG-BILL-ROUNDING-001/' \
    "$repo/specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md" > "$task3"
out4="$(cd "$repo" && "$TASK_BRIEF" specs/work/WRK-TASK-BILL-PRORATA-001-003-prorata-calculation.md)"
path4="$(printf '%s\n' "$out4" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
b4="$(cat "$path4" 2>/dev/null)"
[[ "$b4" == *"### FRAG-BILL-ROUNDING-001"* ]] && pass "sources id is found when it is not the first key" || fail "sources id is found when it is not the first key"

# explicit OUTFILE
out3="$(cd "$repo" && "$TASK_BRIEF" specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md "$repo/explicit-brief.md")"
[[ -s "$repo/explicit-brief.md" && "$out3" == *"$repo/explicit-brief.md"* ]] && pass "honours explicit OUTFILE" || fail "honours explicit OUTFILE"

rc=0; (cd "$repo" && "$TASK_BRIEF" >/dev/null 2>&1) || rc=$?
[[ "$rc" -eq 2 ]] && pass "usage error exits 2" || fail "usage error exits 2 (rc=$rc)"
finish
