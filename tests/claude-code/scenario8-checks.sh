#!/usr/bin/env bash
# Checks for scenario 8 of test-kdd-flow.sh (WRK-TASK-FORK-UPSTREAM-004-004): one run of the
# rounding fixture executed in a given mode.
# Usage: scenario8-checks.sh <project dir> <transcripts dir> <arm>      arm: native | inline-old | sdd
# Prints one "  [PASS] …" / "  [FAIL] …" line per check; exit 1 on any FAIL.
# Transcripts: only the main-session *.jsonl files under <transcripts dir> are read (agent-*.jsonl
# are the subagents' own). Dispatches are recognised by description or by the prompt's opening
# line, since sessions paraphrase descriptions. When the Agent input has no `model`, the subagent
# inherits the dispatching session's model, read from the same transcript line.
# The result text is <transcripts dir minus .transcripts>.result (usage-lib.sh) when it exists,
# else the last assistant text of the main session.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
[[ $# -eq 3 ]] || { echo "usage: scenario8-checks.sh <project dir> <transcripts dir> <native|inline-old|sdd>" >&2; exit 2; }
PROJECT="$1"; TDIR="$2"; ARM="$3"
case "$ARM" in native|inline-old|sdd) ;; *) echo "scenario8-checks.sh: unknown arm '$ARM'" >&2; exit 2 ;; esac
PLAN=WRK-PLAN-DEMO-MONEY-001
T1=WRK-TASK-DEMO-MONEY-001-001
T2=WRK-TASK-DEMO-MONEY-001-002
FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }
check() { if "${@:2}"; then pass "$1"; else fail "$1"; fi; }   # check NAME CMD…

# --- the project ---------------------------------------------------------------------------
check "npm test is green" bash -c 'cd "$1" && npm test >/dev/null 2>&1' _ "$PROJECT"
for t in "$T1" "$T2"; do
  f="$(ls "$PROJECT"/specs/work/$t-*.md 2>/dev/null | head -1)"
  check "$t is status: completed" bash -c '[[ -f "$1" ]] && grep -q "^status: completed" "$1"' _ "$f"
done

status_json="$(cd "$PROJECT" && node "$REPO_ROOT/skills/kdd-conventions/scripts/kdd-status" 2>&1)"
ledger_state="$(node -e '
  const j = JSON.parse(process.argv[1]);
  const p = (j.open_work || []).flatMap(s => s.plans).find(p => p.id === process.argv[2]);
  console.log(p ? p.ledger : "absent");' "$status_json" "$PLAN" 2>/dev/null || echo "unreadable")"
[[ "$ledger_state" == "used" ]] && pass "kdd-status reports the ledger of $PLAN as used" \
  || fail "kdd-status reports the ledger of $PLAN as used (got: $ledger_state)"

ledger="$PROJECT/.kdd/sdd/$PLAN/progress.md"
for pair in "$T1:1" "$T2:2"; do
  t="${pair%%:*}"; pos="${pair##*:}"
  check "the ledger holds the completion line of $t" bash -c \
    '[[ -f "$1" ]] && grep -Eq "^[-* ]*Task ($2|$3): complete" "$1"' _ "$ledger" "$t" "$pos"
done

# --- the transcripts -----------------------------------------------------------------------
# One line per Agent/Task dispatch of the main session: ms-epoch, effective model, flags, description.
dispatches="$(find "$TDIR" -name '*.jsonl' ! -name 'agent-*' -print0 2>/dev/null | xargs -0 node --input-type=module -e '
import { readFileSync } from "node:fs";
const A4 = /^You are an adversary\.\s+Your job is to show that this task.s tests are\s+insufficient/;
const FINAL = /^You are a Senior Code Reviewer/;
const IMPL = /^You are implementing/;
for (const f of process.argv.slice(1)) {
  for (const line of readFileSync(f, "utf8").split("\n")) {
    let d; try { d = JSON.parse(line); } catch { continue; }
    const m = d.message; if (!m || !Array.isArray(m.content)) continue;
    for (const b of m.content) {
      if (b.type !== "tool_use" || (b.name !== "Agent" && b.name !== "Task")) continue;
      const i = b.input || {}, desc = String(i.description || ""), head = String(i.prompt || "").slice(0, 400).trimStart();
      const ts = Date.parse(d.timestamp);
      const flags = [A4.test(head) || /\bA4\b/.test(desc) ? "a4" : "", FINAL.test(head) || /final[^"]*review|whole-branch/i.test(desc) ? "final" : "",
                     IMPL.test(head) || /^implement/i.test(desc) ? "impl" : ""].filter(Boolean).join(",") || "-";
      console.log([Number.isNaN(ts) ? 0 : ts, i.model || m.model || "-", flags, desc.replace(/\s+/g, " ")].join("\t"));
    }
  }
}' 2>/dev/null | sort -n)"
flagged() { awk -F'\t' -v f="$1" '$3 ~ "(^|,)" f "(,|$)"' <<<"$dispatches"; }

a4_first="$(flagged a4 | head -1 | cut -f1)"
[[ -n "$a4_first" ]] && pass "A4 dispatched" || fail "A4 dispatched"
commit_t="$(git -C "$PROJECT" log --format=%ct --fixed-strings --grep="chore($T1): complete" 2>/dev/null | head -1)"
if [[ -n "$a4_first" && -n "$commit_t" ]]; then
  [[ "$a4_first" -lt $((commit_t * 1000)) ]] && pass "the first A4 dispatch is earlier than the commit of chore($T1): complete" \
    || fail "the first A4 dispatch is earlier than the commit of chore($T1): complete (A4 at ${a4_first}ms, commit at ${commit_t}s)"
else
  fail "the first A4 dispatch is earlier than the commit of chore($T1): complete (A4:${a4_first:-none} commit:${commit_t:-none})"
fi

if [[ "$ARM" == native ]]; then
  impl="$(flagged impl | cut -f4 | head -3 | tr '\n' ';')"
  [[ -z "$impl" ]] && pass "Native: no implementer dispatched" || fail "Native: no implementer dispatched ($impl)"
  [[ -n "$(flagged final | awk -F'\t' 'tolower($2) ~ /opus/')" ]] && pass "Native: a final review dispatched with an Opus model" \
    || fail "Native: a final review dispatched with an Opus model (final reviews: $(flagged final | cut -f2,4 | tr '\n' ';'))"

  result="${TDIR%.transcripts}.result"
  if [[ -f "$result" ]]; then text="$(cat "$result")"
  else
    text="$(find "$TDIR" -name '*.jsonl' ! -name 'agent-*' -print0 2>/dev/null | xargs -0 node --input-type=module -e '
    import { readFileSync } from "node:fs";
    let last = "";
    for (const f of process.argv.slice(1)) for (const line of readFileSync(f, "utf8").split("\n")) {
      let d; try { d = JSON.parse(line); } catch { continue; }
      const m = d.message; if (!m || m.role !== "assistant" || !Array.isArray(m.content)) continue;
      const t = m.content.filter(b => b.type === "text").map(b => b.text).join("\n"); if (t) last = t;
    }
    console.log(last);' 2>/dev/null)"
  fi
  [[ "$text" == *"Rulings I made"* ]] && pass 'Native: the result text contains "Rulings I made"' || fail 'Native: the result text contains "Rulings I made"'
fi

if [[ "$FAILURES" -ne 0 ]]; then echo "scenario 8 ($ARM): $FAILURES check(s) failed."; exit 1; fi
exit 0
