#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
echo "=== Test: kdd-cli ==="
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# 1. explicit override wins
printf 'console.log("override", process.argv.slice(2).join(" "))\n' > "$TMP/sg.mjs"
out="$(KDD_SPEC_GRAPH="$TMP/sg.mjs" "$KDD_CLI_SCRIPT" --path)"
[[ "$out" == "$TMP/sg.mjs" ]] && pass "--path honours KDD_SPEC_GRAPH" || { fail "--path honours KDD_SPEC_GRAPH"; echo "    got: $out"; }
out="$(KDD_SPEC_GRAPH="$TMP/sg.mjs" "$KDD_CLI_SCRIPT" --specs x stats)"
[[ "$out" == "override --specs x stats" ]] && pass "runs node <cli> with the given args" || { fail "runs node <cli> with the given args"; echo "    got: $out"; }

# 2. plugin-cache discovery under $HOME
mkdir -p "$TMP/home/.claude/plugins/cache/nfq/kdd/1.2.0/cli"
printf 'console.log("cached")\n' > "$TMP/home/.claude/plugins/cache/nfq/kdd/1.2.0/cli/spec-graph.mjs"
out="$(cd "$TMP" && env -u KDD_SPEC_GRAPH HOME="$TMP/home" "$KDD_CLI_SCRIPT" --path)"
[[ "$out" == "$TMP/home/.claude/plugins/cache/nfq/kdd/1.2.0/cli/spec-graph.mjs" ]] && pass "finds ~/.claude/plugins/**/kdd*/cli/spec-graph.mjs" || { fail "finds ~/.claude/plugins/**/kdd*/cli/spec-graph.mjs"; echo "    got: $out"; }

# 3. project-local copies win over the plugin cache
mkdir -p "$TMP/proj/.kdd-toolkit/cli"
printf 'console.log("local")\n' > "$TMP/proj/.kdd-toolkit/cli/spec-graph.mjs"
out="$(cd "$TMP/proj" && env -u KDD_SPEC_GRAPH HOME="$TMP/home" "$KDD_CLI_SCRIPT" --path)"
[[ "$out" == "$TMP/proj/.kdd-toolkit/cli/spec-graph.mjs" ]] && pass "./.kdd-toolkit/cli wins over the plugin cache" || { fail "./.kdd-toolkit/cli wins over the plugin cache"; echo "    got: $out"; }

# 4. nothing found → exit 3 and a message
rc=0; err="$(cd "$TMP" && env -u KDD_SPEC_GRAPH HOME="$TMP/empty" "$KDD_CLI_SCRIPT" --path 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 3 && "$err" == *"kdd toolkit not found"* ]] && pass "exit 3 + message when not found" || { fail "exit 3 + message when not found"; echo "    rc=$rc err=$err"; }
finish
