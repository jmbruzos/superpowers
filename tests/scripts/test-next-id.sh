#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
NEXT_ID="$REPO_ROOT/skills/kdd-conventions/scripts/next-id"
echo "=== Test: next-id ==="
check() { local want="$1"; shift; local got; got="$("$@" 2>/dev/null)"; [[ "$got" == "$want" ]] && pass "$* → $want" || { fail "$* → $want"; echo "    got: $got"; }; }
check "WRK-SPEC-BILL-PRORATA-002" "$NEXT_ID" --specs "$FIXTURE_SPECS" WRK-SPEC-BILL-PRORATA
check "WRK-SPEC-BILL-NEW-001"     "$NEXT_ID" --specs "$FIXTURE_SPECS" WRK-SPEC-BILL-NEW
check "WRK-TASK-BILL-PRORATA-001-003" "$NEXT_ID" --specs "$FIXTURE_SPECS" WRK-TASK-BILL-PRORATA-001
check "FRAG-BILL-ROUNDING-002"    "$NEXT_ID" --specs "$FIXTURE_SPECS" FRAG-BILL-ROUNDING
check "WRK-PLAN-BILL-PRORATA-002" "$NEXT_ID" --specs "$FIXTURE_SPECS" --prefer 001 WRK-PLAN-BILL-PRORATA
check "WRK-PLAN-BILL-OTHER-007"   "$NEXT_ID" --specs "$FIXTURE_SPECS" --prefer 007 WRK-PLAN-BILL-OTHER
# default --specs is ./specs
tmp="$(mktemp -d)"; mkdir -p "$tmp/specs"; cp -R "$FIXTURE_SPECS/." "$tmp/specs/"
check "DOM-BILL-PRORATA-002" bash -c "cd '$tmp' && '$NEXT_ID' DOM-BILL-PRORATA"
rm -rf "$tmp"
# grammar
for bad in "wrk-spec-x" "WRK-SPEC" "WRK-SPEC-BILL-001" "WRK-SPEC-BILL_X" "WRK-SPEC-BILL-"; do
  rc=0; "$NEXT_ID" --specs "$FIXTURE_SPECS" "$bad" >/dev/null 2>&1 || rc=$?
  [[ "$rc" -eq 2 ]] && pass "rejects '$bad' with exit 2" || fail "rejects '$bad' with exit 2 (rc=$rc)"
done
finish
