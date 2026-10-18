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
# grep -q closes a pipe early; under pipefail the writer's SIGPIPE turns a match into a failure
# (baseline run 1, scenario 5: commits with task IDs present, check failed)
hits="$(grep -nE '\| *grep -[a-zA-Z]*q' "$REPO_ROOT/tests/claude-code/test-kdd-flow.sh")"
[[ -z "$hits" ]] && pass "test-kdd-flow.sh pipes into no grep -q" || { fail "test-kdd-flow.sh pipes into no grep -q"; echo "$hits" | sed 's/^/    /'; }

# every headless run pins the model (DOC-FORK-UPSTREAM-001 §4: --model opus); the account default
# moved from Opus to Sonnet between FRAG-FORK-TOKENS-003 and the batch-0 baseline
n_runs="$(grep -c 'claude -p ' "$REPO_ROOT/tests/claude-code/test-kdd-flow.sh")"
n_pinned="$(grep 'claude -p ' "$REPO_ROOT/tests/claude-code/test-kdd-flow.sh" | grep -c -- '--model "$KDD_FLOW_MODEL"')"
[[ "$n_runs" -ge 2 && "$n_pinned" -eq "$n_runs" ]] && pass "every claude -p in test-kdd-flow.sh passes --model \$KDD_FLOW_MODEL" \
  || fail "every claude -p in test-kdd-flow.sh passes --model \$KDD_FLOW_MODEL ($n_pinned of $n_runs)"
grep -q 'KDD_FLOW_MODEL="${KDD_FLOW_MODEL:-opus}"' "$REPO_ROOT/tests/claude-code/test-kdd-flow.sh" && pass "KDD_FLOW_MODEL defaults to opus" || fail "KDD_FLOW_MODEL defaults to opus"

# scenario 8 (Native vs old inline vs SDD) is a paid comparison run: opt-in only
FLOW="$REPO_ROOT/tests/claude-code/test-kdd-flow.sh"
helper="$(grep -E '^want_explicit\(\)' "$FLOW" | sed 's/ *#.*$//')"   # drop the trailing comment
if [[ -n "$helper" ]]; then
  r1="$(KDD_FLOW_SCENARIOS="" bash -c "$helper"'; want_explicit 8 && echo yes || echo no')"
  r2="$(KDD_FLOW_SCENARIOS="5 6" bash -c "$helper"'; want_explicit 8 && echo yes || echo no')"
  r3="$(KDD_FLOW_SCENARIOS="5 8" bash -c "$helper"'; want_explicit 8 && echo yes || echo no')"
  r4="$(KDD_FLOW_SCENARIOS="18" bash -c "$helper"'; want_explicit 8 && echo yes || echo no')"
  [[ "$r1|$r2|$r3|$r4" == "no|no|yes|no" ]] && pass "want_explicit is true only when KDD_FLOW_SCENARIOS names the scenario" \
    || fail "want_explicit is true only when KDD_FLOW_SCENARIOS names the scenario (got $r1|$r2|$r3|$r4)"
else fail "test-kdd-flow.sh defines want_explicit"; fi
n="$(grep -cE '^if want_explicit 8 && \[\[ -n "\$\{KDD_FLOW_USAGE:-\}" \]\]; then' "$FLOW")"
[[ "$n" -eq 1 ]] && pass "scenario 8 is guarded by want_explicit 8 and KDD_FLOW_USAGE" || fail "scenario 8 is guarded by want_explicit 8 and KDD_FLOW_USAGE"
[[ "$(grep -c '^if want 8' "$FLOW")" -eq 0 ]] && pass "scenario 8 is not run by want (an empty list never selects it)" || fail "scenario 8 is not run by want"
for arm in native inline-old sdd; do
  n="$(grep -cE "^ *$arm\\)" "$FLOW")"
  [[ "$n" -ge 1 ]] && pass "scenario 8 has the $arm arm prompt" || fail "scenario 8 has the $arm arm prompt"
done
grep -q 'KDD_FLOW_ARM8:-native' "$FLOW" && pass "KDD_FLOW_ARM8 defaults to native" || fail "KDD_FLOW_ARM8 defaults to native"
grep -q 'scenario8-checks.sh' "$FLOW" && pass "scenario 8 calls scenario8-checks.sh" || fail "scenario 8 calls scenario8-checks.sh"
grep -q 'USAGE_SCENARIO="8-\$' "$FLOW" && pass "scenario 8 usage name is scenario-8-<arm>" || fail "scenario 8 usage name is scenario-8-<arm>"
n="$(grep -c 'CONFIG_DIR/projects' <(sed -n '/^if want_explicit 8/,/^fi$/p' "$FLOW"))"
[[ "$n" -eq 0 ]] && pass "scenario 8 never reads \$CONFIG_DIR/projects" || fail "scenario 8 never reads \$CONFIG_DIR/projects"

finish
