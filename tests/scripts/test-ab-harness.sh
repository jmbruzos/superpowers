#!/usr/bin/env bash
# The real-task A/B study lives in the repository (WRK-SPEC-FORK-UPSTREAM-001 AC2):
# a portable run script and the prompts the FRAG-FORK-GATES-003/-004/-005 runs used.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
AB="$REPO_ROOT/tests/claude-code/ab"
echo "=== Test: A/B study harness ==="

run="$AB/run-one.sh"
if [[ -f "$run" ]]; then
  bash -n "$run" && pass "run-one.sh parses" || fail "run-one.sh parses"
  ! grep -q '/Users/' "$run" && pass "run-one.sh has no machine path" || fail "run-one.sh has no machine path"
  ! grep -Eq 'kdd/[0-9]+\.[0-9]+\.[0-9]+' "$run" && pass "run-one.sh pins no toolkit version" || fail "run-one.sh pins no toolkit version"
  grep -q 'toolkit-env.sh' "$run" && pass "run-one.sh resolves the toolkit through toolkit-env.sh" || fail "run-one.sh resolves the toolkit through toolkit-env.sh"
  for v in MDM_REPO MDM_BASE MODEL AB_OUT; do
    grep -q "\${$v:-" "$run" && pass "run-one.sh takes $v from the environment" || fail "run-one.sh takes $v from the environment"
  done
  out="$(env -u MDM_REPO bash "$run" 2>&1)"; rc=$?
  [[ "$rc" -eq 2 && "$out" == *usage* ]] && pass "run-one.sh without arguments prints usage, exit 2" \
    || { fail "run-one.sh without arguments prints usage, exit 2"; echo "    rc=$rc out=$out"; }
else
  fail "tests/claude-code/ab/run-one.sh exists"
fi

for p in k-task k-wait evidence-judge neutral-summary blind-pass; do
  f="$AB/prompts/$p.txt"
  if [[ -s "$f" ]] && head -1 "$f" | grep -q '^# source: ' && [[ "$(sed 1d "$f" | wc -c)" -gt 40 ]]; then
    pass "prompts/$p.txt has a source line and a body"
  else
    fail "prompts/$p.txt has a source line and a body"
  fi
done
grep -q 'RFC-PIPE-039' "$AB/prompts/k-task.txt" 2>/dev/null && pass "k-task names RFC-PIPE-039" || fail "k-task names RFC-PIPE-039"
grep -q 'never end your turn while a' "$AB/prompts/k-wait.txt" 2>/dev/null && pass "k-wait is the wait sentence" || fail "k-wait is the wait sentence"
[[ -s "$AB/README.md" ]] && pass "ab/README.md exists" || fail "ab/README.md exists"
finish
