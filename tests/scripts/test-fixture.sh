#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
echo "=== Test: fixture validates ==="
require_cli
out="$(node "$KDD_CLI" --specs "$FIXTURE_SPECS" validate 2>&1)"; rc=$?
if [[ "$rc" -eq 0 && "$out" == *"0 error(s)"* || "$out" == *"Validation passed"* ]]; then pass "fixture has 0 validation errors"; else fail "fixture has 0 validation errors"; echo "$out" | sed 's/^/    /'; fi
n="$(node "$KDD_CLI" --specs "$FIXTURE_SPECS" filter --format json | node -e 'const j=JSON.parse(require("fs").readFileSync(0,"utf8"));console.log(j.length)')"
[[ "$n" -eq 6 ]] && pass "fixture has 6 specs (1 DOM, 1 SPEC, 1 PLAN, 2 TASK, 1 FRAG)" || { fail "fixture has 6 specs"; echo "    got: $n"; }
finish
