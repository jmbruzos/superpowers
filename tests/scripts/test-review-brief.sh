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
[[ "$b" == *"Activation on day 15 of a 30-day month charges 16/30 of the fee (the activation day is billed)."* ]] && pass "acceptance criteria inlined" || fail "acceptance criteria inlined"
[[ "$b" == *"Round to 2 decimal places, half-up (DOM-BILL-PRORATA-001, Rule 3)."* ]] && pass "constraints inlined" || fail "constraints inlined"
[[ "$b" != *"PIN DRIFT"* ]] && pass "no drift for the spec's pins" || fail "no drift for the spec's pins"

out2="$(cd "$repo" && "$RB" specs/work/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md)"
path2="$(printf '%s\n' "$out2" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
[[ "$path2" == "$path" && "$(head -1 "$path2")" == "# Review brief — WRK-SPEC-BILL-PRORATA-001" ]] && pass "plan input resolves its parent spec" || { fail "plan input resolves its parent spec"; echo "    got: $path2"; }

# Review Focus (3b): present, absent, no plan
[[ "$b" == *"## 3b. Review Focus (WRK-PLAN-BILL-PRORATA-001)"* && "$b" == *"_(the plan has no Review Focus section)_"* ]] && pass "3b: plan without Review Focus → placeholder" || fail "3b: plan without Review Focus → placeholder"
planf="$repo/specs/work/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md"
cp "$planf" "$planf.orig"
python3 - "$planf" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read()
s=s.replace("## Risk Assessment","## Review Focus\n\n- A 31-day month activated on day 31: one day charged.\n\n## Risk Assessment",1)
open(p,'w').write(s)
PY
(cd "$repo" && "$RB" specs/work/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md >/dev/null)
b3="$(cat "$path")"
s3b="${b3#*## 3b. Review Focus}"; s3b="${s3b%%## 4. Activated knowledge*}"
[[ "$b3" == *"## 3b. Review Focus (WRK-PLAN-BILL-PRORATA-001)"* && "$s3b" == *"- A 31-day month activated on day 31: one day charged."* && "$b3" == *"## 4. Activated knowledge"* ]] && pass "3b: plan's Review Focus verbatim before section 4" || fail "3b: plan's Review Focus verbatim before section 4"
mv "$planf.orig" "$planf"
rm "$planf"
out4="$(cd "$repo" && "$RB" specs/work/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md 2>&1)"
path4="$(printf '%s\n' "$out4" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
b4="$(cat "$path4" 2>/dev/null)"
[[ "$b4" == *"## 3b. Review Focus (no plan)"* && "$b4" == *"_(no WRK-PLAN for this spec)_"* ]] && pass "3b: no plan → no-plan placeholder" || fail "3b: no plan → no-plan placeholder"

rc=0; (cd "$repo" && "$RB" >/dev/null 2>&1) || rc=$?
[[ "$rc" -eq 2 ]] && pass "usage error exits 2" || fail "usage error exits 2 (rc=$rc)"
finish
