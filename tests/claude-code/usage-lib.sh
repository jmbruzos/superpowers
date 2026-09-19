#!/usr/bin/env bash
# Opt-in token-usage capture for the headless flow scenarios (WRK-SPEC-FORK-TOKENS-001).
# Source it. With KDD_FLOW_USAGE=<dir> set, run_scenario adds `--output-format json`,
# saves <dir>/<scenario>.json plus the session transcripts, and the run ends with
# usage-summary.py's table. Without the variable every function is a no-op and
# test-kdd-flow.sh behaves exactly as before.
USAGE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage_args() { [[ -n "${KDD_FLOW_USAGE:-}" ]] && printf -- '--output-format json'; return 0; }

# usage_result_of JSON — print the `result` text of a `claude -p --output-format json` run
usage_result_of() {
  [[ -f "${1:-}" ]] || return 1
  python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("result",""))' "$1"
}

# usage_record RAW CONFIG_DIR — RAW holds the JSON stdout of one scenario; names it
# scenario-N.json under $KDD_FLOW_USAGE, copies transcripts newer than the previous
# scenario, and prints the `result` text so callers can keep asserting on prose.
# The name is scenario-$USAGE_SCENARIO when the caller sets it (test-kdd-flow.sh does,
# at top level, so it reaches the `$(...)` subshell); otherwise N counts the .result
# files already there — a counter in a shell variable would not survive the subshell.
usage_record() {
  local raw="$1" cfg="$2"
  [[ -n "${KDD_FLOW_USAGE:-}" ]] || { cat "$raw"; return 0; }
  mkdir -p "$KDD_FLOW_USAGE"
  local n; n="$(find "$KDD_FLOW_USAGE" -maxdepth 1 -name 'scenario-*.result' | wc -l)"
  local name="scenario-${USAGE_SCENARIO:-$((n + 1))}"
  mkdir -p "$KDD_FLOW_USAGE/$name.transcripts"
  if usage_result_of "$raw" > "$KDD_FLOW_USAGE/$name.result" 2>/dev/null; then
    cp "$raw" "$KDD_FLOW_USAGE/$name.json"
  else
    # not JSON (timeout, crash): keep the text as the result, no usage row
    cp "$raw" "$KDD_FLOW_USAGE/$name.result"
  fi
  if [[ -d "$cfg/projects" ]]; then
    local marker="$KDD_FLOW_USAGE/.last"
    if [[ -f "$marker" ]]; then find "$cfg/projects" -name '*.jsonl' -newer "$marker" -exec cp {} "$KDD_FLOW_USAGE/$name.transcripts/" \;
    else find "$cfg/projects" -name '*.jsonl' -exec cp {} "$KDD_FLOW_USAGE/$name.transcripts/" \; ; fi
    touch "$marker"
  fi
  cat "$KDD_FLOW_USAGE/$name.result"
}

usage_summary() { [[ -n "${KDD_FLOW_USAGE:-}" ]] && python3 "$USAGE_LIB_DIR/usage-summary.py" "$KDD_FLOW_USAGE"; return 0; }
