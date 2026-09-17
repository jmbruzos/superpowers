#!/usr/bin/env bash
# Shared helpers for the deterministic (no Claude) test suite under tests/scripts/.
# Source it: . "$(dirname "$0")/lib.sh"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURE_SPECS="$REPO_ROOT/tests/scripts/fixtures/specs"
KDD_CLI_SCRIPT="$REPO_ROOT/skills/using-superpowers/scripts/kdd-cli"
FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }
finish() {
  echo ""
  if [[ "$FAILURES" -ne 0 ]]; then echo "FAILED: $FAILURES assertion(s)."; exit 1; fi
  echo "PASS"
}
# Export KDD_CLI (path to spec-graph.mjs) or skip the whole test file.
require_cli() {
  if KDD_CLI="$("$KDD_CLI_SCRIPT" --path 2>/dev/null)"; then export KDD_CLI; return 0; fi
  echo "SKIP: kdd toolkit not found (set KDD_SPEC_GRAPH to spec-graph.mjs)"; exit 0
}
# Copy the fixture into a fresh git repo (specs/ at its root), commit, print the repo path.
make_fixture_repo() {
  local root; root="$(mktemp -d)"
  git init -q -b main "$root"
  cp -R "$FIXTURE_SPECS" "$root/specs"
  ( cd "$root" && git add -A && git -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -qm "fixture" )
  ( cd "$root" && git rev-parse --show-toplevel )
}
