#!/usr/bin/env bash
# One run of the real-task study (DOC-FORK-UPSTREAM-001 §4, level 2): brainstorming +
# writing-plans for RFC-PIPE-039 on mdm-platform, headless, in a disposable worktree.
# Portable form of the script behind FRAG-FORK-GATES-003/-004/-005.
#
# Usage: run-one.sh <label> <plugin-dir> [<plugin-dir>...]
#   The plugin dirs are the arm (e.g. a kdd-superpowers worktree and "$KDD_TOOLKIT_DIR").
# Environment:
#   MDM_REPO     mdm-platform checkout (required)
#   MDM_BASE     commit the run starts from (default aacdae5)
#   MODEL        claude --model (default opus)
#   AB_OUT       results root (default <repo>/.kdd/ab); the run writes AB_OUT/<label>/
#   AB_WAIT      1 appends prompts/k-wait.txt to the task prompt (default 1, as K3-K5)
#   AB_TIMEOUT   seconds (default 5400)
#   KDD_SPEC_GRAPH / KDD_TOOLKIT_DIR   see ../toolkit-env.sh
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"

if [[ $# -lt 2 ]]; then
  echo "usage: run-one.sh <label> <plugin-dir> [<plugin-dir>...]  (MDM_REPO required)" >&2
  exit 2
fi
label="$1"; shift
MDM_REPO="${MDM_REPO:-}"
[[ -d "$MDM_REPO/.git" ]] || { echo "MDM_REPO is not a git checkout: '$MDM_REPO'" >&2; exit 2; }
MDM_BASE="${MDM_BASE:-aacdae5}"
MODEL="${MODEL:-opus}"
AB_OUT="${AB_OUT:-$REPO_ROOT/.kdd/ab}"
AB_WAIT="${AB_WAIT:-1}"
AB_TIMEOUT="${AB_TIMEOUT:-5400}"
source "$HERE/../toolkit-env.sh" || exit 3

if command -v timeout >/dev/null; then TIMEOUT_CMD=(timeout "$AB_TIMEOUT")
elif command -v gtimeout >/dev/null; then TIMEOUT_CMD=(gtimeout "$AB_TIMEOUT")
else TIMEOUT_CMD=(perl -e 'alarm shift; exec @ARGV' "$AB_TIMEOUT"); fi

PROMPT="$(sed 1d "$HERE/prompts/k-task.txt")"
[[ "$AB_WAIT" == 1 ]] && PROMPT="$PROMPT $(sed 1d "$HERE/prompts/k-wait.txt")"

out="$AB_OUT/$label"; mkdir -p "$out"
wt="$AB_OUT/wt/$label"; cfg="$(mktemp -d)"
[[ -f "$HOME/.claude/.credentials.json" ]] && cp "$HOME/.claude/.credentials.json" "$cfg/"
git -C "$MDM_REPO" worktree add --detach "$wt" "$MDM_BASE" >/dev/null 2>&1 || { echo "worktree add failed: $wt" >&2; exit 2; }
git -C "$wt" config user.email ab@test; git -C "$wt" config user.name ab-test
plugargs=(); for p in "$@"; do plugargs+=(--plugin-dir "$p"); done
{ echo "label=$label base=$MDM_BASE model=$MODEL wait=$AB_WAIT"; echo "toolkit=$KDD_SPEC_GRAPH"; claude --version; printf 'plugin-dir %s\n' "$@"; } > "$out/conditions.txt"

start=$(date +%s)
( cd "$wt" && env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_CHILD_SESSION \
    -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN \
    -u CLAUDE_CODE_SESSION_ATTENDED -u CLAUDE_CODE_EXECPATH \
    CLAUDE_CONFIG_DIR="$cfg" KDD_SPEC_GRAPH="$KDD_SPEC_GRAPH" \
    "${TIMEOUT_CMD[@]}" claude -p "$PROMPT" --model "$MODEL" "${plugargs[@]}" \
      --allowed-tools=all --permission-mode bypassPermissions --output-format json ) > "$out/result.json" 2> "$out/stderr.txt"
echo "exit=$? start=$start wall=$(( $(date +%s) - start ))s" > "$out/run.txt"
mkdir -p "$out/transcripts"; find "$cfg/projects" -name '*.jsonl' -exec cp {} "$out/transcripts/" \; 2>/dev/null
git -C "$wt" log --format='%h %s' "$MDM_BASE..HEAD" > "$out/commits.txt"
git -C "$wt" diff --stat "$MDM_BASE..HEAD" > "$out/diffstat.txt"
mkdir -p "$out/artifacts"
git -C "$wt" diff --name-only "$MDM_BASE..HEAD" | while read -r f; do mkdir -p "$out/artifacts/$(dirname "$f")"; cp "$wt/$f" "$out/artifacts/$f" 2>/dev/null; done
git -C "$wt" status --porcelain > "$out/uncommitted.txt"
git -C "$MDM_REPO" worktree remove --force "$wt" >/dev/null 2>&1
rm -rf "$cfg"
