#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
RB="$REPO_ROOT/skills/requesting-code-review/scripts/review-brief"
echo "=== Test: review-brief ==="
require_cli
repo="$(make_fixture_repo)"; trap 'rm -rf "$repo"' EXIT
export KDD_SPEC_GRAPH="$KDD_CLI"

out="$(cd "$repo" && "$RB" specs/work/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md)"; rc=$?
path="$(printf '%s\n' "$out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
[[ "$rc" -eq 0 && "$path" == "$repo/.kdd/sdd/WRK-PLAN-BILL-PRORATA-001/review-brief.md" ]] && pass "spec input → child plan's workspace/review-brief.md" || { fail "spec input → child plan's workspace/review-brief.md"; echo "    rc=$rc out=$out"; }
b="$(cat "$path" 2>/dev/null)"
for h in "# Review brief — WRK-SPEC-BILL-PRORATA-001" "## 1. Acceptance criteria (WRK-SPEC-BILL-PRORATA-001)" "## 2. Constraints (WRK-SPEC-BILL-PRORATA-001)" "## 3. Architecture Impact (WRK-PLAN-BILL-PRORATA-001)" "## 4. Activated knowledge" "### DOM-BILL-PRORATA-001 @1.0.0" "## 5. Evidence (fragments cited in sources)" "### FRAG-BILL-ROUNDING-001"; do
  [[ "$b" == *"$h"* ]] && pass "contains '$h'" || fail "contains '$h'"
done
[[ "$b" == *"Activation on day 15 of a 30-day month charges half the fee."* ]] && pass "acceptance criteria inlined" || fail "acceptance criteria inlined"
[[ "$b" == *"Round to 2 decimal places, half-up (DOM-BILL-PRORATA-001, Rule 3)."* ]] && pass "constraints inlined" || fail "constraints inlined"
[[ "$b" != *"PIN DRIFT"* ]] && pass "no drift for the spec's pins" || fail "no drift for the spec's pins"

out2="$(cd "$repo" && "$RB" specs/work/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md)"
path2="$(printf '%s\n' "$out2" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
[[ "$path2" == "$path" && "$(head -1 "$path2")" == "# Review brief — WRK-SPEC-BILL-PRORATA-001" ]] && pass "plan input resolves its parent spec" || { fail "plan input resolves its parent spec"; echo "    got: $path2"; }

rc=0; (cd "$repo" && "$RB" >/dev/null 2>&1) || rc=$?
[[ "$rc" -eq 2 ]] && pass "usage error exits 2" || fail "usage error exits 2 (rc=$rc)"
finish
