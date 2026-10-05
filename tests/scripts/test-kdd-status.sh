#!/usr/bin/env bash
# kdd-status (WRK-SPEC-FORK-MODS-001): phases, ledger reading, root, errors.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
KDD_STATUS="$REPO_ROOT/skills/kdd-conventions/scripts/kdd-status"
KDD_STATUS_LIB="$REPO_ROOT/skills/kdd-conventions/scripts/kdd-status-lib.mjs"
echo "=== Test: kdd-status ==="
require_cli
export KDD_SPEC_GRAPH="$KDD_CLI"

W=specs/work
SPEC=$W/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md
PLAN=$W/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md
T1=$W/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md
T2=$W/WRK-TASK-BILL-PRORATA-001-002-billing-api-endpoint.md
LEDGER_DIR=.kdd/sdd/WRK-PLAN-BILL-PRORATA-001
IDENTITY="# SDD ledger — plan: WRK-PLAN-BILL-PRORATA-001 ($PLAN)"
TMPS=()
trap 'rm -rf "${TMPS[@]}"' EXIT

q() { node -e 'const d=JSON.parse(require("fs").readFileSync(0,"utf8")); const v=(new Function("d","return "+process.argv[1]))(d); console.log(typeof v==="string"?v:JSON.stringify(v))' "$1"; }
fresh() { repo="$(make_fixture_repo)"; TMPS+=("$repo"); }
run() { out="$(cd "${1:-$repo}" && "$KDD_STATUS" --json)"; rc=$?; }
set_status() { awk -v s="$2" '!d && /^status: /{print "status: " s; d=1; next} {print}' "$repo/$1" > "$repo/$1.tmp" && mv "$repo/$1.tmp" "$repo/$1"; }
ledger() { mkdir -p "$repo/$LEDGER_DIR"; printf '%s\n' "$@" > "$repo/$LEDGER_DIR/progress.md"; }
check() { local got; got="$(printf '%s' "$out" | q "$2")"; [[ "$got" == "$3" ]] && pass "$1" || { fail "$1"; echo "    $2 → $got (want $3)"; }; }
P='d.open_work[0].plans[0]'

fresh; run
[[ "$rc" -eq 0 ]] && pass "exit 0" || fail "exit 0 (rc=$rc)"
check "no ledger: phase executing" 'd.phase' 'executing'
check "no ledger: 0/2" "$P.done+'/'+$P.total" '0/2'
check "no ledger: ledger none" "$P.ledger" 'none'
check "no ledger: no current task" 'String(d.focus.task)' 'null'
check "no ledger: focus spec/plan" "d.focus.spec+' '+d.focus.plan" 'WRK-SPEC-BILL-PRORATA-001 WRK-PLAN-BILL-PRORATA-001'
check "no ledger: nothing pending consolidation" 'd.pending_consolidation.length' '0'
check "root is the git toplevel" 'd.root' "$repo"

ledger "$IDENTITY" "Task WRK-TASK-BILL-PRORATA-001-001: complete (commits a1b2c3d..d4e5f6a, review clean)"; run
check "ledger by id: 1/2" "$P.done+'/'+$P.total" '1/2'
check "ledger by id: ledger used" "$P.ledger" 'used'
check "ledger by id: current is 002" 'd.focus.task' 'WRK-TASK-BILL-PRORATA-001-002'
check "ledger by id: task states" "$P.tasks.map(t=>t.state).join(',')" 'done,in-progress'

ledger "$IDENTITY" "- Task 1: complete (commits a1b2c3d..d4e5f6a, review clean)"; run
check "ledger by position: 1/2" "$P.done+'/'+$P.total" '1/2'

ledger "$IDENTITY" "Task 10: complete (commits a1b2c3d..d4e5f6a, review clean)"; run
check "Task 10 does not complete task 1" "$P.done" '0'

ledger "# SDD ledger — plan: WRK-PLAN-OTHER-001 (specs/work/other.md)" "Task 1: complete (commits a..b, review clean)"; run
check "mismatch: flagged" "$P.ledger" 'mismatch'
check "mismatch: 0/2" "$P.done+'/'+$P.total" '0/2'
check "mismatch: no current task" 'String(d.focus.task)' 'null'

ledger "$IDENTITY" "Ruling: r1 — a — b" "noise" "Task 1: Ruling: r2 — x" "Knowledge gap: g1" "Attack: A — Ruling: r3" "Task 2: parked — f — Ruling: r4" "Task 1: fix round 1/5 (1 addressed, 0 open; commits a..b)" "Knowledge gap: g2"; run
check "tail keeps 5 lines" "$P.ledger_tail.length" '5'
check "tail drops the oldest" "$P.ledger_tail[0]" 'Task 1: Ruling: r2 — x'
check "tail ends with the newest" "$P.ledger_tail[4]" 'Knowledge gap: g2'

fresh; set_status "$SPEC" draft; run
check "draft spec: spec-review" 'd.phase' 'spec-review'
check "draft spec: listed as open" 'd.open_work[0].status' 'draft'

fresh; rm "$repo/$PLAN"; run
check "no plan: planning" 'd.phase' 'planning'

fresh; rm "$repo/$T1" "$repo/$T2"; run
check "plan without tasks: planning" 'd.phase' 'planning'

fresh; sed 's/^id: WRK-PLAN-BILL-PRORATA-001$/id: WRK-PLAN-BILL-PRORATA-002/' "$repo/$PLAN" > "$repo/$W/WRK-PLAN-BILL-PRORATA-002-second.md"
set_status "$W/WRK-PLAN-BILL-PRORATA-002-second.md" draft; run
check "second draft plan: two plans" 'd.open_work[0].plans.length' '2'
check "second draft plan: executing" 'd.phase' 'executing'

fresh; set_status "$T1" completed; set_status "$T2" completed; run
check "all tasks done: finishing" 'd.phase' 'finishing'
check "all tasks done: 2/2" "$P.done+'/'+$P.total" '2/2'

fresh; set_status "$SPEC" completed; set_status "$PLAN" completed; set_status "$T1" completed; set_status "$T2" completed; run
check "completed spec: phase" 'd.phase' 'consolidation-pending'
check "completed spec: pending list" 'd.pending_consolidation.join(",")' 'WRK-SPEC-BILL-PRORATA-001'

fresh; set_status "$SPEC" archived; run
check "archived spec: idle" 'd.phase' 'idle'

fresh; run "$repo/specs/work"
check "subdirectory: root is toplevel" 'd.root' "$repo"

plain="$(mktemp -d)"; TMPS+=("$plain"); cp -R "$FIXTURE_SPECS" "$plain/specs"; run "$plain"
check "outside git: root is cwd" 'd.root' "$(cd "$plain" && pwd -P)"
check "outside git: still computed" 'd.phase' 'executing'

empty="$(mktemp -d)"; TMPS+=("$empty"); run "$empty"
[[ "$rc" -eq 0 ]] && pass "no specs: exit 0" || fail "no specs: exit 0 (rc=$rc)"
check "no specs: idle" 'd.phase+" "+d.open_work.length' 'idle 0'
check "no specs: says so" 'd.error+" / "+d.message' 'no-specs / no specs/ in this project'

fresh; nohome="$(mktemp -d)"; TMPS+=("$nohome")
out="$(cd "$repo" && env -u KDD_SPEC_GRAPH HOME="$nohome" "$KDD_STATUS" --json)"; rc=$?
[[ "$rc" -eq 0 ]] && pass "no toolkit: exit 0" || fail "no toolkit: exit 0 (rc=$rc)"
check "no toolkit: error" 'd.error' 'toolkit-not-found'
check "no toolkit: message from kdd-cli" 'd.message.startsWith("kdd toolkit not found")' 'true'

stubdir="$(mktemp -d)"; TMPS+=("$stubdir")
cat > "$stubdir/stub.mjs" << 'EOF'
const layer = process.argv[process.argv.indexOf('--layer') + 1];
console.log(JSON.stringify(layer === 'work-spec'
  ? [{ id: 'WRK-SPEC-STUB-001', layer: 'work-spec', status: 'active', title: 'stub', parent: null }]
  : []));
EOF
fresh; out="$(cd "$repo" && KDD_SPEC_GRAPH="$stubdir/stub.mjs" "$KDD_STATUS" --json)"
check "stub toolkit: its spec is the open work" 'd.open_work.map(s=>s.id).join(",")' 'WRK-SPEC-STUB-001'
check "stub toolkit: planning" 'd.phase' 'planning'

(cd "$repo" && "$KDD_STATUS" --bogus >/dev/null 2>&1); [[ $? -eq 2 ]] && pass "bad argument: exit 2" || fail "bad argument: exit 2"

[[ "$(grep -v '^import' "$KDD_STATUS" | grep -c 'readFileSync\|readdirSync')" == 1 ]] && pass "one file read in the CLI (the ledger)" || fail "one file read in the CLI (the ledger)"
grep -q "progress.md" "$KDD_STATUS" && pass "the read is the ledger" || fail "the read is the ledger"
! grep -q "node:fs" "$KDD_STATUS_LIB" && pass "lib does no I/O" || fail "lib does no I/O"
! grep -q "spec-graph" "$KDD_STATUS" "$KDD_STATUS_LIB" && pass "no toolkit path" || fail "no toolkit path"

finish
