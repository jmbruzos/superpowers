#!/usr/bin/env bash
# scenario8-checks.sh on synthetic data (WRK-TASK-FORK-UPSTREAM-004-004): a project built from the
# rounding fixture with the two `chore(…): complete` commits at known times, and synthetic
# transcript lines. Each transcript-dependent check is seen failing and passing; no Claude needed.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
CHECKS="$REPO_ROOT/tests/claude-code/scenario8-checks.sh"
FIXTURE="$REPO_ROOT/tests/claude-code/fixtures/rounding-plan"
echo "=== Test: scenario 8 checks ==="
require_cli
export KDD_SPEC_GRAPH="$KDD_CLI"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

# --- a synthetic finished project -------------------------------------------------------------
P="$WORK/project"; mkdir -p "$P/tests"
git init -q -b main "$P"
cp -R "$FIXTURE/specs" "$P/specs"; cp "$FIXTURE/package.json" "$P/package.json"
printf 'import test from "node:test";\ntest("ok", () => {});\n' > "$P/tests/ok.test.js"
commit_at() { # EPOCH SUBJECT
  ( cd "$P" && git add -A && GIT_AUTHOR_DATE="$1 +0000" GIT_COMMITTER_DATE="$1 +0000" \
    git -c user.email=t@e -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "$2" )
}
BASE=1792351000   # chore(…-001): complete is committed at BASE+200
commit_at "$BASE" init
for t in 001 002; do sed -i.bak 's/^status: active/status: completed/' "$P"/specs/work/WRK-TASK-DEMO-MONEY-001-$t-*.md; rm -f "$P"/specs/work/*.bak; done
mkdir -p "$P/.kdd/sdd/WRK-PLAN-DEMO-MONEY-001"
printf '%s\n' '# SDD ledger — plan: WRK-PLAN-DEMO-MONEY-001 (specs/work/WRK-PLAN-DEMO-MONEY-001-money-library.md)' \
  'Task WRK-TASK-DEMO-MONEY-001-001: complete (commits a..b, tests: npm test → ok)' \
  'Task WRK-TASK-DEMO-MONEY-001-002: complete (commits c..d, tests: npm test → ok)' > "$P/.kdd/sdd/WRK-PLAN-DEMO-MONEY-001/progress.md"
printf '.kdd/\n' > "$P/.gitignore"
commit_at $((BASE + 200)) "chore(WRK-TASK-DEMO-MONEY-001-001): complete"
commit_at $((BASE + 400)) "chore(WRK-TASK-DEMO-MONEY-001-002): complete"

# --- synthetic transcripts -----------------------------------------------------------------------
iso() { node -e 'console.log(new Date(Number(process.argv[1]) * 1000).toISOString())' "$1"; }
A4_PROMPT='You are an adversary. Your job is to show that this task'"'"'s tests are\ninsufficient: that an implementation can pass all of them'
FINAL_PROMPT='You are a Senior Code Reviewer with expertise in software architecture,\ndesign patterns'
IMPL_PROMPT='You are implementing Task WRK-TASK-DEMO-MONEY-001-002: formatMoney'
dispatch() { # EPOCH SESSION_MODEL DESCRIPTION PROMPT [INPUT_MODEL]
  local model_field=""; [[ -n "${5:-}" ]] && model_field="\"model\": \"$5\", "
  printf '{"type":"assistant","timestamp":"%s","message":{"role":"assistant","model":"%s","content":[{"type":"tool_use","name":"Agent","input":{"description":"%s",%s"prompt":"%s"}}]}}\n' \
    "$(iso "$1")" "$2" "$3" "$model_field" "$4"
}
final_text() { printf '{"type":"assistant","timestamp":"%s","message":{"role":"assistant","model":"claude-opus-5-5","content":[{"type":"text","text":"%s"}]}}\n' "$(iso "$BASE")" "$1"; }
# transcripts NAME → a fresh <WORK>/NAME.transcripts holding one main session, built from stdin
mk() { local d="$WORK/$1.transcripts"; rm -rf "$d"; mkdir -p "$d/proj"; cat > "$d/proj/session.jsonl"; echo "$d"; }
run() { bash "$CHECKS" "$@" 2>&1; }   # PROJECT TRANSCRIPTS ARM
has() { [[ "$1" == *"$2"* ]]; }
expect() { # NAME OUTPUT "[PASS] or [FAIL]" CHECK-TEXT
  if has "$2" "$3 $4"; then pass "$1"; else fail "$1"; echo "$2" | sed 's/^/    /'; fi
}

# a Native run that satisfies everything
good="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 break the tests of WRK-TASK-DEMO-MONEY-001-001" "$A4_PROMPT" sonnet
           dispatch $((BASE + 300)) claude-opus-5-5 "Final whole-branch code review" "$FINAL_PROMPT" opus; } | mk good)"
printf 'Done.\n\nRulings I made:\n- none\n' > "$WORK/good.result"
out="$(run "$P" "$good" native)"; rc=$?
[[ $rc -eq 0 ]] && pass "a satisfying Native run exits 0" || { fail "a satisfying Native run exits 0 (rc=$rc)"; echo "$out" | sed 's/^/    /'; }
for c in "npm test is green" "WRK-TASK-DEMO-MONEY-001-001 is status: completed" "WRK-TASK-DEMO-MONEY-001-002 is status: completed" \
         "kdd-status reports the ledger of WRK-PLAN-DEMO-MONEY-001 as used" \
         "the ledger holds the completion line of WRK-TASK-DEMO-MONEY-001-001" "the ledger holds the completion line of WRK-TASK-DEMO-MONEY-001-002" \
         "A4 dispatched" "the first A4 dispatch is earlier than the commit of chore(WRK-TASK-DEMO-MONEY-001-001): complete" \
         "Native: no implementer dispatched" "Native: a final review dispatched with an Opus model" 'Native: the result text contains "Rulings I made"'; do
  expect "passes: $c" "$out" "[PASS]" "$c"
done

# A4 after the commit (and a later re-run does not rescue it): the order check fails, the dispatch check passes
late="$( { dispatch $((BASE + 300)) claude-opus-5-5 "Adversary: A4 break the tests" "$A4_PROMPT" sonnet
           dispatch $((BASE + 100)) claude-opus-5-5 "Final whole-branch code review" "$FINAL_PROMPT" opus; } | mk late)"
out="$(run "$P" "$late" native)"; rc=$?
expect "A4 after the commit: order check fails" "$out" "[FAIL]" "the first A4 dispatch is earlier than the commit"
expect "A4 after the commit: A4 dispatched still passes" "$out" "[PASS]" "A4 dispatched"
[[ $rc -eq 1 ]] && pass "any FAIL exits 1" || fail "any FAIL exits 1 (rc=$rc)"

# A4 recognised by the prompt's opening line when the description is paraphrased
para="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Attack the tests" "$A4_PROMPT" sonnet
           dispatch $((BASE + 300)) claude-opus-5-5 "Final review" "$FINAL_PROMPT" opus; } | mk para)"
out="$(run "$P" "$para" native)"
expect "A4 recognised by the prompt opening line" "$out" "[PASS]" "the first A4 dispatch is earlier"

# no A4 at all
none="$( { dispatch $((BASE + 300)) claude-opus-5-5 "Final whole-branch code review" "$FINAL_PROMPT" opus; } | mk none)"
out="$(run "$P" "$none" native)"
expect "no A4: A4 dispatched fails" "$out" "[FAIL]" "A4 dispatched"
expect "no A4: order check fails" "$out" "[FAIL]" "the first A4 dispatch is earlier"

# an implementer dispatch: fails in the Native arm, is not a check in the others
impl="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 x" "$A4_PROMPT" sonnet
           dispatch $((BASE + 150)) claude-opus-5-5 "Implement WRK-TASK-002 formatMoney" "$IMPL_PROMPT" haiku
           dispatch $((BASE + 300)) claude-opus-5-5 "Final whole-branch code review" "$FINAL_PROMPT" opus; } | mk impl)"
cp "$WORK/good.result" "$WORK/impl.result"
out="$(run "$P" "$impl" native)"
expect "implementer present: Native fails" "$out" "[FAIL]" "Native: no implementer dispatched"
out="$(run "$P" "$impl" sdd)"
has "$out" "implementer" && fail "the sdd arm has no implementer check" || pass "the sdd arm has no implementer check"
expect "sdd arm still checks A4 order" "$out" "[PASS]" "the first A4 dispatch is earlier"
has "$out" "Opus" && fail "the sdd arm has no Opus final-review check" || pass "the sdd arm has no Opus final-review check"

# implementer recognised by the prompt opening line under a paraphrased description
impl2="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 x" "$A4_PROMPT" sonnet
            dispatch $((BASE + 150)) claude-opus-5-5 "Build formatMoney" "$IMPL_PROMPT" haiku
            dispatch $((BASE + 300)) claude-opus-5-5 "Final whole-branch code review" "$FINAL_PROMPT" opus; } | mk impl2)"
out="$(run "$P" "$impl2" native)"
expect "implementer recognised by the prompt opening line" "$out" "[FAIL]" "Native: no implementer dispatched"

# final review: non-Opus fails; absent model inherits the session model
sonnet="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 x" "$A4_PROMPT" sonnet
             dispatch $((BASE + 300)) claude-opus-5-5 "Final whole-branch code review" "$FINAL_PROMPT" sonnet; } | mk sonnet)"
out="$(run "$P" "$sonnet" native)"
expect "non-Opus final review fails" "$out" "[FAIL]" "Native: a final review dispatched with an Opus model"
inherit="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 x" "$A4_PROMPT" sonnet
              dispatch $((BASE + 300)) claude-opus-5-5 "Final whole-branch code review" "$FINAL_PROMPT"; } | mk inherit)"
out="$(run "$P" "$inherit" native)"
expect "no model in the input: the Opus session model is inherited" "$out" "[PASS]" "Native: a final review dispatched with an Opus model"
inherit2="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 x" "$A4_PROMPT" sonnet
               dispatch $((BASE + 300)) claude-sonnet-5-5 "Final whole-branch code review" "$FINAL_PROMPT"; } | mk inherit2)"
out="$(run "$P" "$inherit2" native)"
expect "no model in the input: a non-Opus session model is inherited" "$out" "[FAIL]" "Native: a final review dispatched with an Opus model"
nofinal="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 x" "$A4_PROMPT" sonnet; } | mk nofinal)"
out="$(run "$P" "$nofinal" native)"
expect "no final review fails" "$out" "[FAIL]" "Native: a final review dispatched with an Opus model"

# "Rulings I made": absent from the result file fails; with no result file, the last assistant text of the session counts
printf 'Done. Nothing else to report.\n' > "$WORK/good.result"
out="$(run "$P" "$good" native)"
expect '"Rulings I made" absent: fails' "$out" "[FAIL]" 'Native: the result text contains "Rulings I made"'
rm -f "$WORK/good.result"
fromtx="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 x" "$A4_PROMPT" sonnet
             dispatch $((BASE + 300)) claude-opus-5-5 "Final whole-branch code review" "$FINAL_PROMPT" opus
             final_text 'Rulings I made: one'; } | mk fromtx)"
out="$(run "$P" "$fromtx" native)"
expect 'no result file: "Rulings I made" read from the last assistant text' "$out" "[PASS]" 'Native: the result text contains "Rulings I made"'
absenttx="$( { dispatch $((BASE + 100)) claude-opus-5-5 "Adversary: A4 x" "$A4_PROMPT" sonnet
               final_text 'All done.'; } | mk absenttx)"
out="$(run "$P" "$absenttx" native)"
expect 'no result file, text without it: fails' "$out" "[FAIL]" 'Native: the result text contains "Rulings I made"'

# project checks: red tests, an incomplete task, a missing ledger line
cp -R "$P" "$WORK/p2"
printf 'import test from "node:test";\ntest("bad", () => { throw new Error("x"); });\n' > "$WORK/p2/tests/ok.test.js"
out="$(run "$WORK/p2" "$good" sdd)"
expect "red npm test fails" "$out" "[FAIL]" "npm test is green"
sed -i.bak 's/^status: completed/status: active/' "$WORK/p2"/specs/work/WRK-TASK-DEMO-MONEY-001-002-*.md; rm -f "$WORK/p2"/specs/work/*.bak
out="$(run "$WORK/p2" "$good" sdd)"
expect "a task not completed fails" "$out" "[FAIL]" "WRK-TASK-DEMO-MONEY-001-002 is status: completed"
expect "the other task still passes" "$out" "[PASS]" "WRK-TASK-DEMO-MONEY-001-001 is status: completed"
sed -i.bak '/001-002: complete/d' "$WORK/p2/.kdd/sdd/WRK-PLAN-DEMO-MONEY-001/progress.md"; rm -f "$WORK/p2"/.kdd/sdd/*/*.bak
out="$(run "$WORK/p2" "$good" sdd)"
expect "a missing completion line fails" "$out" "[FAIL]" "the ledger holds the completion line of WRK-TASK-DEMO-MONEY-001-002"
rm -rf "$WORK/p2/.kdd"
out="$(run "$WORK/p2" "$good" sdd)"
expect "no ledger: kdd-status check fails" "$out" "[FAIL]" "kdd-status reports the ledger of WRK-PLAN-DEMO-MONEY-001 as used"

out="$(bash "$CHECKS" "$P" "$good" bogus 2>&1)"; rc=$?
[[ $rc -eq 2 ]] && pass "an unknown arm exits 2" || fail "an unknown arm exits 2 (rc=$rc)"

finish
