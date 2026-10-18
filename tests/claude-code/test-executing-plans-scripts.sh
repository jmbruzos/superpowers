#!/usr/bin/env bash
# Tests for executing-plans' Native bookkeeping scripts over WRK-TASK files:
# scripts/task-start writes the brief, the ledger identity line and BASE in one
# call; scripts/task-done runs the task's final test command, transitions the
# task to completed and records the completion line, and records nothing for a
# failing task. Set EP_SCRIPTS to a directory of stand-in scripts to check that
# every case fails against scripts that do nothing.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EP_SCRIPTS="${EP_SCRIPTS:-$REPO_ROOT/skills/executing-plans/scripts}"
FIXTURE="$SCRIPT_DIR/fixtures/rounding-plan"

FAILURES=0
TEST_ROOT=""

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}
check() { # check NAME CONDITION-EXIT-STATUS
    if [[ "$2" -eq 0 ]]; then pass "$1"; else fail "$1"; fi
}

cleanup() {
    if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false

main() {
    echo "=== Test: executing-plans scripts ==="

    if ! "$REPO_ROOT/skills/using-superpowers/scripts/kdd-cli" --path >/dev/null 2>&1; then
        echo "SKIP: kdd toolkit not found (set KDD_SPEC_GRAPH to spec-graph.mjs)"
        exit 0
    fi

    TEST_ROOT="$(mktemp -d)"
    trap cleanup EXIT

    git init -q -b main "$TEST_ROOT/repo"
    local repo
    repo="$(cd "$TEST_ROOT/repo" && git rev-parse --show-toplevel)"
    cp -R "$FIXTURE/specs" "$FIXTURE/package.json" "$repo/"
    ( cd "$repo" && git add -A && git commit -qm fixture )

    local W=specs/work
    local PLAN_ID=WRK-PLAN-DEMO-MONEY-001
    local T1_ID=WRK-TASK-DEMO-MONEY-001-001
    local T2_ID=WRK-TASK-DEMO-MONEY-001-002
    local PLAN="$repo/$W/$PLAN_ID-money-library.md"
    local T1="$repo/$W/$T1_ID-round-money.md"
    local T2="$repo/$W/$T2_ID-format-money.md"
    local DIR="$repo/.kdd/sdd/$PLAN_ID"
    local LEDGER="$DIR/progress.md"
    local identity="# SDD ledger — plan: $PLAN_ID ($W/$PLAN_ID-money-library.md)"
    local out rc

    # --- no arguments: usage ---
    rc=0; (cd "$repo" && bash "$EP_SCRIPTS/task-start" >/dev/null 2>&1) || rc=$?
    [[ "$rc" -eq 2 ]]; check "task-start without arguments exits 2" $?
    rc=0; (cd "$repo" && bash "$EP_SCRIPTS/task-done" >/dev/null 2>&1) || rc=$?
    [[ "$rc" -eq 2 ]]; check "task-done without arguments exits 2" $?

    # --- task-start: a ledger naming another plan is refused and left alone ---
    mkdir -p "$DIR"
    printf '%s\n' "# SDD ledger — plan: WRK-PLAN-OTHER-001 (specs/work/other.md)" "Task 1: complete (commits a..b)" > "$LEDGER"
    local before; before="$(cat "$LEDGER")"
    rc=0; (cd "$repo" && bash "$EP_SCRIPTS/task-start" "$PLAN" "$T1" >/dev/null 2>&1) || rc=$?
    [[ "$rc" -eq 2 && "$(cat "$LEDGER")" == "$before" ]]; check "task-start refuses a ledger of another plan (exit 2, ledger unchanged)" $?
    rm -f "$LEDGER"

    # --- task-start: a task of another plan is refused, no ledger is created ---
    sed 's/^parent: .*/parent: WRK-PLAN-OTHER-001/' "$T1" > "$TEST_ROOT/other-task.md"
    rc=0; (cd "$repo" && bash "$EP_SCRIPTS/task-start" "$PLAN" "$TEST_ROOT/other-task.md" >/dev/null 2>&1) || rc=$?
    [[ "$rc" -eq 2 && ! -e "$LEDGER" ]]; check "task-start refuses a task of another plan (exit 2, no ledger)" $?

    # --- task-start: brief, BASE and the identity line, from a subdirectory ---
    local head0; head0="$(cd "$repo" && git rev-parse HEAD)"
    rc=0; out="$(cd "$repo/specs" && bash "$EP_SCRIPTS/task-start" "$PLAN" "$T1" 2>&1)" || rc=$?
    local brief; brief="$(printf '%s\n' "$out" | sed -n 's/^brief: //p')"
    local base; base="$(printf '%s\n' "$out" | sed -n 's/^base: //p')"
    local base1="$base"
    [[ "$rc" -eq 0 && "$brief" == "$DIR/$T1_ID-brief.md" && -s "$brief" ]]; check "task-start prints a brief path in the plan's workspace and writes it" $?
    [[ "$base" =~ ^[0-9a-f]{40}$ && "$base" == "$head0" ]]; check "task-start prints BASE as the 40-hex HEAD" $?
    [[ "$(head -n 1 "$LEDGER" 2>/dev/null)" == "$identity" && "$(wc -l < "$LEDGER" | tr -d ' ')" -eq 1 ]]; check "task-start creates the ledger with the identity line" $?
    out="$(cd "$repo" && bash "$EP_SCRIPTS/task-start" "$PLAN" "$T1" 2>&1)"; rc=$?
    [[ "$rc" -eq 0 && "$(cat "$LEDGER")" == "$identity" ]]; check "task-start on an existing ledger of the plan leaves it alone" $?

    # --- task-done: no commit since BASE ---
    rc=0; (cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" "$base" -- true >/dev/null 2>&1) || rc=$?
    [[ "$rc" -eq 3 && "$(cat "$LEDGER")" == "$identity" ]]; check "task-done with no commit since BASE exits 3 and records nothing" $?

    # --- task-done: a failing command records nothing ---
    ( cd "$repo" && echo x > work1.txt && git add work1.txt && git commit -qm "feat($T1_ID): work 1" )
    local h1; h1="$(cd "$repo" && git rev-parse --short=7 HEAD)"
    rc=0; out="$(cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" "$base" -- sh -c 'echo "FAILED (errors=1)"; exit 1' 2>&1)" || rc=$?
    [[ "$rc" -eq 1 && "$out" == *FAILED* ]]; check "task-done exits with the command's status and shows its output" $?
    [[ "$(cat "$LEDGER")" == "$identity" ]] && grep -q '^status: active' "$T1"; check "a failing command leaves the task active and the ledger without a line" $?

    # --- task-done: the transition fails (red graph) after the tests passed ---
    cp "$T1" "$TEST_ROOT/t1.bak"
    awk '/^dependencies:/{print; print "  - id: WRK-NOPE-999"; print "    relation: depends-on"; next} {print}' "$TEST_ROOT/t1.bak" > "$T1"
    rc=0; out="$(cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" "$base" -- true 2>&1)" || rc=$?
    [[ "$rc" -eq 4 && "$out" == *"tests passed, transition failed — nothing recorded"* ]]; check "task-done exits 4 when the tests pass but the transition fails" $?
    [[ "$(cat "$LEDGER")" == "$identity" ]] && grep -q '^status: active' "$T1"; check "a failed transition records no line and leaves the task active" $?
    cp "$TEST_ROOT/t1.bak" "$T1"

    # --- task-done: success from a subdirectory; a silent command ---
    local commits_before; commits_before="$(cd "$repo" && git rev-list --count HEAD)"
    rc=0; out="$(cd "$repo/specs" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" "$base" -- true 2>&1)" || rc=$?
    local b7="${base:0:7}"
    local line1="Task $T1_ID: complete (commits $b7..$h1, tests: true → (no output))"
    [[ "$rc" -eq 0 ]] && grep -q '^status: completed' "$T1"; check "task-done -- true completes the task" $?
    [[ "$(cd "$repo" && git log -1 --format=%s)" == "chore($T1_ID): complete" && "$(cd "$repo" && git rev-list --count HEAD)" -eq $((commits_before + 1)) ]]; check "task-done leaves one chore(<task>): complete commit" $?
    [[ "$(sed -n 2p "$LEDGER")" == "$line1" && "$(wc -l < "$LEDGER" | tr -d ' ')" -eq 2 ]]; check "ledger line: range ends at the work commit, silent command is (no output)" $?
    [[ "$rc" -eq 0 && "$(cd "$repo" && git log -1 --format=%s)" == "chore($T1_ID): complete" && "$(cd "$repo" && git status --porcelain | grep -v '^??' | wc -l | tr -d ' ')" -eq 0 && "$(cd "$repo" && git show --stat --format= HEAD | grep -c '|')" -eq 1 ]]; check "the complete commit holds the task file alone, tracked files are clean" $?
    [[ -f "$DIR/$T1_ID-tests.log" ]]; check "task-done keeps the test output in the workspace" $?

    # --- re-runs ---
    local snap; snap="$(cat "$LEDGER")"; local n_commits; n_commits="$(cd "$repo" && git rev-list --count HEAD)"
    rc=0; (cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" "$base" -- true >/dev/null 2>&1) || rc=$?
    [[ "$rc" -eq 0 && "$(sed -n 2p "$LEDGER")" == "$line1" && "$(cat "$LEDGER")" == "$snap" && "$(cd "$repo" && git rev-list --count HEAD)" -eq "$n_commits" ]]; check "re-run with the line present is a no-op (exit 0)" $?

    grep -v "^Task $T1_ID: complete" "$LEDGER" > "$TEST_ROOT/ledger.tmp"; cp "$TEST_ROOT/ledger.tmp" "$LEDGER"
    # a BASE that disagrees with the task's own range is refused before the tests run,
    # naming the base recovered from git (the parent of the task's first commit)
    local nol; nol="$(cat "$LEDGER")"
    rc=0; out="$(cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" HEAD -- touch "$TEST_ROOT/ran" 2>&1)" || rc=$?
    [[ "$rc" -eq 3 && "$out" == *"recovered BASE ${b7}"* && "$out" != *"nothing to close"* && "$(cat "$LEDGER")" == "$nol" && ! -e "$TEST_ROOT/ran" && "$(cd "$repo" && git rev-list --count HEAD)" -eq "$n_commits" ]]; check "re-run on a completed task with BASE=HEAD exits 3 naming the recovered BASE, runs and writes nothing" $?
    rc=0; out="$(cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" HEAD~1 -- touch "$TEST_ROOT/ran" 2>&1)" || rc=$?
    [[ "$rc" -eq 3 && "$out" == *"recovered BASE ${b7}"* && "$(cat "$LEDGER")" == "$nol" && ! -e "$TEST_ROOT/ran" ]]; check "re-run on a completed task with BASE=HEAD~1 exits 3 instead of recording an empty range" $?
    rc=0; (cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" "$base" -- true >/dev/null 2>&1) || rc=$?
    [[ "$rc" -eq 0 && "$(sed -n 2p "$LEDGER")" == "$line1" && "$(cat "$LEDGER")" == "$snap" && "$(cd "$repo" && git rev-list --count HEAD)" -eq "$n_commits" ]]; check "re-run on a completed task without its line writes the line once, same range, no commit" $?

    # --- task 002: the last non-blank line, and a task already recorded but still active ---
    ( cd "$repo" && bash "$EP_SCRIPTS/task-start" "$PLAN" "$T2" >/dev/null 2>&1 ) ; base="$(cd "$repo" && git rev-parse HEAD)"
    ( cd "$repo" && echo y > work2.txt && git add work2.txt && git commit -qm "feat($T2_ID): work 2" )
    local h2; h2="$(cd "$repo" && git rev-parse --short=7 HEAD)"
    rc=0; out="$(cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T2" "$base" -- echo ok 2>&1)" || rc=$?
    [[ "$rc" -eq 0 && "$(grep "^Task $T2_ID: complete" "$LEDGER")" == "Task $T2_ID: complete (commits ${base:0:7}..$h2, tests: echo ok → ok)" ]]; check "the line ends with the command's last non-blank output" $?

    # task 001 goes back to active with its line present: SDD died between line and transition
    sed 's/^status: completed/status: active/' "$T1" > "$TEST_ROOT/t1.tmp" && cp "$TEST_ROOT/t1.tmp" "$T1"
    ( cd "$repo" && git add "$T1" && git commit -qm "reopen 001" )
    rc=0; (cd "$repo" && bash "$EP_SCRIPTS/task-done" "$PLAN" "$T1" "$base1" -- true >/dev/null 2>&1) || rc=$?
    [[ "$rc" -eq 0 ]] && grep -q '^status: completed' "$T1" && [[ "$(grep -c "^Task $T1_ID: complete" "$LEDGER")" -eq 1 ]]; check "an active task whose line is present gets the transition and no second line" $?

    echo
    if [[ "$FAILURES" -eq 0 ]]; then
        echo "PASS"
    else
        echo "FAIL ($FAILURES)"
        exit 1
    fi
}

main "$@"
