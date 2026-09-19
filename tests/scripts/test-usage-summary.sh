#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
echo "=== Test: usage capture (usage-lib.sh + usage-summary.py) ==="
LIB="$REPO_ROOT/tests/claude-code/usage-lib.sh"
SUMMARY="$REPO_ROOT/tests/claude-code/usage-summary.py"
FIX="$REPO_ROOT/tests/scripts/fixtures/usage"
[[ -f "$LIB" ]] && pass "usage-lib.sh exists" || fail "usage-lib.sh exists"
[[ -f "$SUMMARY" ]] && pass "usage-summary.py exists" || fail "usage-summary.py exists"
. "$LIB" 2>/dev/null

# usage_result_of: the assertions of test-kdd-flow read the `result` text, not the JSON
out="$(usage_result_of "$FIX/scenario-5.json" 2>/dev/null)"
[[ "$out" == *"5/5 passing"* ]] && pass "usage_result_of prints the result field" || { fail "usage_result_of prints the result field"; echo "    got: $out"; }
out="$(usage_result_of /nonexistent.json 2>/dev/null)"; rc=$?
[[ $rc -ne 0 ]] && pass "usage_result_of fails on a missing file" || fail "usage_result_of fails on a missing file"

# usage_args: empty without KDD_FLOW_USAGE, json format with it
out="$(env -u KDD_FLOW_USAGE bash -c ". '$LIB'; usage_args")"
[[ -z "$out" ]] && pass "no extra args without KDD_FLOW_USAGE" || fail "no extra args without KDD_FLOW_USAGE (got '$out')"
out="$(KDD_FLOW_USAGE=/tmp/x bash -c ". '$LIB'; usage_args")"
[[ "$out" == "--output-format json" ]] && pass "--output-format json with KDD_FLOW_USAGE" || fail "--output-format json with KDD_FLOW_USAGE (got '$out')"

# usage_record: names scenario-N, keeps json + result + transcripts, prints the result text
tmp="$(mktemp -d)"; cfg="$tmp/cfg"; mkdir -p "$cfg/projects/p"; echo '{"type":"user"}' > "$cfg/projects/p/main.jsonl"
out="$(KDD_FLOW_USAGE="$tmp/out" bash -c ". '$LIB'; usage_record '$FIX/scenario-5.json' '$cfg'")"
[[ "$out" == *"5/5 passing"* ]] && pass "usage_record prints the result text" || fail "usage_record prints the result text"
[[ -f "$tmp/out/scenario-1.json" && -f "$tmp/out/scenario-1.result" ]] && pass "usage_record saves scenario-1.json and .result" || fail "usage_record saves scenario-1.json and .result"
[[ -f "$tmp/out/scenario-1.transcripts/main.jsonl" ]] && pass "usage_record copies the transcripts" || fail "usage_record copies the transcripts"
# each run_scenario call happens inside $(...) — the counter must survive subshells
out="$(KDD_FLOW_USAGE="$tmp/out" bash -c ". '$LIB'; usage_record '$FIX/scenario-5.json' '$cfg'")"
[[ -f "$tmp/out/scenario-2.json" && -f "$tmp/out/scenario-1.json" ]] && pass "second call in a fresh subshell becomes scenario-2" || fail "second call in a fresh subshell becomes scenario-2 ($(ls "$tmp/out"))"
out="$(KDD_FLOW_USAGE="$tmp/out" USAGE_SCENARIO=6 bash -c ". '$LIB'; usage_record '$FIX/scenario-5.json' '$cfg'")"
[[ -f "$tmp/out/scenario-6.json" ]] && pass "USAGE_SCENARIO names the file" || fail "USAGE_SCENARIO names the file ($(ls "$tmp/out"))"
rm -f "$tmp/out/scenario-6".*
printf 'plain text, not json\n' > "$tmp/raw.txt"
out="$(KDD_FLOW_USAGE="$tmp/out" bash -c ". '$LIB'; usage_record '$tmp/raw.txt' '$cfg'")"
[[ "$out" == "plain text, not json" && -f "$tmp/out/scenario-3.result" && ! -f "$tmp/out/scenario-3.json" ]] && pass "non-JSON output is passed through as the result (no usage row)" || fail "non-JSON output is passed through ($out; $(ls "$tmp/out"))"
out="$(env -u KDD_FLOW_USAGE bash -c ". '$LIB'; usage_record '$tmp/raw.txt' '$cfg'")"
[[ "$out" == "plain text, not json" ]] && pass "without KDD_FLOW_USAGE usage_record is cat" || fail "without KDD_FLOW_USAGE usage_record is cat"
rm -rf "$tmp"

# usage-summary.py: one row per JSON, the numbers from the fixture, cost and turns
tbl="$(python3 "$SUMMARY" "$FIX" 2>&1)"
echo "$tbl" | grep -q '^scenario' && pass "summary prints a header" || fail "summary prints a header"
row="$(echo "$tbl" | grep '^scenario-5 ')"
[[ -n "$row" ]] && pass "one row per scenario JSON" || fail "one row per scenario JSON"
[[ "$row" == *" 26 "* ]] && pass "row carries num_turns" || fail "row carries num_turns ($row)"
[[ "$row" == *"1383.6k"* ]] && pass "row carries cache_read in k" || fail "row carries cache_read in k ($row)"
[[ "$row" == *"2.93"* ]] && pass "row carries total_cost_usd" || fail "row carries total_cost_usd ($row)"
echo "$tbl" | grep -q 'claude-haiku-4-5' && pass "per-model breakdown from modelUsage" || fail "per-model breakdown from modelUsage"
# empty dir: header only, exit 0
tmp="$(mktemp -d)"; python3 "$SUMMARY" "$tmp" >/dev/null 2>&1 && pass "empty dir exits 0" || fail "empty dir exits 0"; rm -rf "$tmp"
finish
