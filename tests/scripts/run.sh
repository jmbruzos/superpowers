#!/usr/bin/env bash
# Run every deterministic test under tests/scripts/ (no Claude needed).
set -uo pipefail
cd "$(dirname "$0")"
rc=0
for t in test-*.sh; do
  echo "### $t"
  if bash "$t"; then echo "### $t: ok"; else echo "### $t: FAILED"; rc=1; fi
  echo ""
done
exit $rc
