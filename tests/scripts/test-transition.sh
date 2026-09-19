#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
require_cli
TRANSITION="$REPO_ROOT/skills/kdd-conventions/scripts/transition"
echo "=== Test: transition ==="
TODAY="$(date +%F)"

# Fresh fixture repo with a git identity so the script's commits succeed.
repo() { local r; r="$(make_fixture_repo)"; git -C "$r" config user.email t@example.com; git -C "$r" config user.name t; git -C "$r" config commit.gpgsign false; echo "$r"; }
TASK=specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md
SPEC=specs/work/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md
FRAG="$(cd "$FIXTURE_SPECS" && ls _capture/*/FRAG-*.md | head -1)"
status_of() { grep -m1 '^status:' "$1" | awk '{print $2}'; }
updated_of() { grep -m1 '^updated:' "$1" | awk '{print $2}'; }

# 1. valid transition: active → completed, updated today, committed alone with the chore message
r="$(repo)"
( cd "$r" && "$TRANSITION" "$TASK" completed >/dev/null 2>&1 ); rc=$?
[[ $rc -eq 0 ]] && pass "active → completed exits 0" || fail "active → completed exits 0 (rc=$rc)"
[[ "$(status_of "$r/$TASK")" == "completed" ]] && pass "status rewritten to completed" || fail "status rewritten to completed (got $(status_of "$r/$TASK"))"
[[ "$(updated_of "$r/$TASK")" == "$TODAY" ]] && pass "updated set to today" || fail "updated set to today (got $(updated_of "$r/$TASK"))"
msg="$(git -C "$r" log -1 --format=%s)"
[[ "$msg" == "chore(WRK-TASK-BILL-PRORATA-001-001): completed" ]] && pass "commit message chore(<ID>): completed" || fail "commit message chore(<ID>): completed (got '$msg')"
[[ -z "$(git -C "$r" status --porcelain)" ]] && pass "tree clean after commit" || fail "tree clean after commit"
n="$(git -C "$r" show --stat --format= HEAD | grep -c '|')"
[[ "$n" -eq 1 ]] && pass "commit touches only the transitioned file" || fail "commit touches only the transitioned file ($n files)"
rm -rf "$r"

# 2. invalid origin (skipping a state) is refused: exit non-zero, file byte-identical, no commit
r="$(repo)"; before="$(sha1sum < "$r/$TASK")"; head0="$(git -C "$r" rev-parse HEAD)"
( cd "$r" && "$TRANSITION" "$TASK" archived >/dev/null 2>&1 ); rc=$?
[[ $rc -ne 0 ]] && pass "active → archived refused (non-zero)" || fail "active → archived refused (rc=$rc)"
[[ "$(sha1sum < "$r/$TASK")" == "$before" ]] && pass "refused transition leaves the file byte-identical" || fail "refused transition leaves the file byte-identical"
[[ "$(git -C "$r" rev-parse HEAD)" == "$head0" ]] && pass "refused transition commits nothing" || fail "refused transition commits nothing"
# same-state and unknown state are refused too
( cd "$r" && "$TRANSITION" "$TASK" active >/dev/null 2>&1 ) && fail "active → active refused" || pass "active → active refused"
( cd "$r" && "$TRANSITION" "$TASK" done >/dev/null 2>&1 ) && fail "unknown status refused" || pass "unknown status refused"
rm -rf "$r"

# 3. draft → active with --verified: appends the human entry (key absent) and uses the spec(...) message
r="$(repo)"
sed -i 's/^status: active$/status: draft/' "$r/$SPEC"; git -C "$r" commit -qam draft
grep -q '^verified:' "$r/$SPEC" && fail "precondition: fixture spec has no verified key" || pass "precondition: fixture spec has no verified key"
( cd "$r" && "$TRANSITION" --verified human:test "$SPEC" active >/dev/null 2>&1 ); rc=$?
[[ $rc -eq 0 ]] && pass "draft → active --verified exits 0" || fail "draft → active --verified exits 0 (rc=$rc)"
[[ "$(status_of "$r/$SPEC")" == "active" ]] && pass "status active" || fail "status active"
grep -A2 '^verified:' "$r/$SPEC" | grep -q 'by: human:test' && pass "verified entry by human:test appended" || fail "verified entry by human:test appended"
grep -A2 '^verified:' "$r/$SPEC" | grep -qE "at: ${TODAY}T" && pass "verified entry carries a timestamp" || fail "verified entry carries a timestamp"
msg="$(git -C "$r" log -1 --format=%s)"
[[ "$msg" == "spec(WRK-SPEC-BILL-PRORATA-001): approved — active, human-verified" ]] && pass "commit message spec(<ID>): approved — active, human-verified" || fail "commit message spec(...) (got '$msg')"
( cd "$r" && "$KDD_CLI_SCRIPT" --specs specs validate >/dev/null 2>&1 ) && pass "graph validates after --verified" || fail "graph validates after --verified"
# key present: a second human entry is appended under the same key
sed -i 's/^status: active$/status: draft/' "$r/$SPEC"; git -C "$r" commit -qam draft-again
( cd "$r" && "$TRANSITION" --verified human:other "$SPEC" active >/dev/null 2>&1 )
[[ "$(grep -c '^verified:' "$r/$SPEC")" -eq 1 ]] && pass "single verified key" || fail "single verified key"
grep -q 'by: human:other' "$r/$SPEC" && pass "second entry appended under it" || fail "second entry appended under it"
rm -rf "$r"

# 4. --verified requires a human:<id> actor; a bare id is a usage error (exit 2) and touches nothing
r="$(repo)"; before="$(sha1sum < "$r/$TASK")"
( cd "$r" && "$TRANSITION" --verified test "$TASK" completed >/dev/null 2>&1 ); rc=$?
[[ $rc -eq 2 ]] && pass "--verified without human: prefix exits 2" || fail "--verified without human: prefix exits 2 (rc=$rc)"
[[ "$(sha1sum < "$r/$TASK")" == "$before" ]] && pass "usage error touches nothing" || fail "usage error touches nothing"
rm -rf "$r"

# 5. --no-commit: file changed, tree dirty, HEAD unchanged
r="$(repo)"; head0="$(git -C "$r" rev-parse HEAD)"
( cd "$r" && "$TRANSITION" --no-commit "$TASK" completed >/dev/null 2>&1 ); rc=$?
[[ $rc -eq 0 ]] && pass "--no-commit exits 0" || fail "--no-commit exits 0 (rc=$rc)"
[[ "$(status_of "$r/$TASK")" == "completed" ]] && pass "--no-commit still rewrites status" || fail "--no-commit still rewrites status"
[[ -n "$(git -C "$r" status --porcelain)" && "$(git -C "$r" rev-parse HEAD)" == "$head0" ]] && pass "--no-commit leaves the tree dirty, HEAD unchanged" || fail "--no-commit leaves the tree dirty, HEAD unchanged"
rm -rf "$r"

# 6. red validate: the file is restored and nothing is committed
r="$(repo)"; head0="$(git -C "$r" rev-parse HEAD)"; before="$(sha1sum < "$r/$TASK")"
sed -i '/^layer:/d' "$r/specs/domain/"DOM-BILL-PRORATA-001*.md; git -C "$r" commit -qam broken   # graph now fails validate
( cd "$r" && "$TRANSITION" "$TASK" completed >/dev/null 2>&1 ); rc=$?
[[ $rc -ne 0 ]] && pass "red validate exits non-zero" || fail "red validate exits non-zero (rc=$rc)"
[[ "$(sha1sum < "$r/$TASK")" == "$before" ]] && pass "red validate restores the file" || fail "red validate restores the file"
[[ "$(git -C "$r" log --format=%s -1)" == "broken" ]] && pass "red validate commits nothing" || fail "red validate commits nothing"
rm -rf "$r"

# 7. FRAG transitions belong to the toolkit: refused
r="$(repo)"
( cd "$r" && "$TRANSITION" "specs/$FRAG" distilled >/dev/null 2>&1 ) && fail "FRAG refused" || pass "FRAG refused"
rm -rf "$r"

# 8. --specs DIR: file outside ./specs, validate against DIR
r="$(repo)"; mkdir -p "$r/kb"; git -C "$r" mv specs kb/specs; git -C "$r" commit -qm moved
( cd "$r" && "$TRANSITION" --specs kb/specs "kb/$TASK" completed >/dev/null 2>&1 ); rc=$?
[[ $rc -eq 0 ]] && pass "--specs DIR honoured" || fail "--specs DIR honoured (rc=$rc)"
rm -rf "$r"

# 9. usage errors exit 2
( "$TRANSITION" >/dev/null 2>&1 ); [[ $? -eq 2 ]] && pass "no args → exit 2" || fail "no args → exit 2"
( "$TRANSITION" /nonexistent.md completed >/dev/null 2>&1 ); [[ $? -eq 2 ]] && pass "missing file → exit 2" || fail "missing file → exit 2"
finish
