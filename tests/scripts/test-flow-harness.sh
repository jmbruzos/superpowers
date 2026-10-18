#!/usr/bin/env bash
# The headless harness finds the toolkit by itself (WRK-SPEC-FORK-UPSTREAM-001 AC1):
# tests/claude-code/toolkit-env.sh derives KDD_SPEC_GRAPH and KDD_TOOLKIT_DIR from
# kdd-cli, and an explicit environment wins.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
ENV_SH="$REPO_ROOT/tests/claude-code/toolkit-env.sh"
echo "=== Test: headless harness toolkit resolution ==="
require_cli

# Defaults: a fake plugin root, reached the way kdd-cli reaches an override.
fake="$(mktemp -d)"; trap 'rm -rf "$fake"' EXIT
mkdir -p "$fake/cli" "$fake/skills/spec-context"
printf '// fake\n' > "$fake/cli/spec-graph.mjs"

got="$(env -u KDD_TOOLKIT_DIR KDD_SPEC_GRAPH="$fake/cli/spec-graph.mjs" bash -c '. "$1" && printf "%s|%s" "$KDD_SPEC_GRAPH" "$KDD_TOOLKIT_DIR"' _ "$ENV_SH" 2>&1)"
[[ "$got" == "$fake/cli/spec-graph.mjs|$fake" ]] && pass "KDD_TOOLKIT_DIR defaults to the plugin root above the CLI" \
  || { fail "KDD_TOOLKIT_DIR defaults to the plugin root above the CLI"; echo "    got: $got"; }

got="$(env -u KDD_SPEC_GRAPH -u KDD_TOOLKIT_DIR bash -c '. "$1" && printf "%s|%s" "$KDD_SPEC_GRAPH" "$KDD_TOOLKIT_DIR"' _ "$ENV_SH" 2>&1)"
cli="${got%%|*}"; dir="${got#*|}"
[[ -f "$cli" && "$cli" == "$dir/cli/spec-graph.mjs" && -d "$dir/skills" ]] && pass "with no KDD_* set, both point at one installed toolkit" \
  || { fail "with no KDD_* set, both point at one installed toolkit"; echo "    got: $got"; }

other="$(mktemp -d)"; mkdir -p "$other/skills"
got="$(KDD_SPEC_GRAPH="$fake/cli/spec-graph.mjs" KDD_TOOLKIT_DIR="$other" bash -c '. "$1" && printf "%s" "$KDD_TOOLKIT_DIR"' _ "$ENV_SH" 2>&1)"
rm -rf "$other"
[[ "$got" == "$other" ]] && pass "an explicit KDD_TOOLKIT_DIR wins" || { fail "an explicit KDD_TOOLKIT_DIR wins"; echo "    got: $got"; }

loose="$(mktemp -d)"; printf '// fake\n' > "$loose/spec-graph.mjs"
out="$(env -u KDD_TOOLKIT_DIR KDD_SPEC_GRAPH="$loose/spec-graph.mjs" bash -c '. "$1"; echo "rc=$?"' _ "$ENV_SH" 2>&1)"
rm -rf "$loose"
[[ "$out" == *"KDD_TOOLKIT_DIR"* && "$out" == *"rc=1"* ]] && pass "a CLI outside a plugin root asks for KDD_TOOLKIT_DIR" \
  || { fail "a CLI outside a plugin root asks for KDD_TOOLKIT_DIR"; echo "    got: $out"; }

grep -q 'toolkit-env.sh' "$REPO_ROOT/tests/claude-code/test-kdd-flow.sh" && pass "test-kdd-flow.sh sources toolkit-env.sh" \
  || fail "test-kdd-flow.sh sources toolkit-env.sh"

hits="$(cd "$REPO_ROOT" && grep -rln 'knowledge-driven-development' CLAUDE.md docs tests 2>/dev/null | grep -v '^tests/scripts/test-flow-harness.sh$')"
[[ -z "$hits" ]] && pass "no doc or test points at ../knowledge-driven-development" \
  || { fail "no doc or test points at ../knowledge-driven-development"; echo "$hits" | sed 's/^/    /'; }
finish
