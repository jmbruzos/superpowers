#!/usr/bin/env bash
# plan-metrics.mjs: implementation-code share, proportion and Review Focus form (WRK-TASK-FORK-UPSTREAM-003-003).
set -uo pipefail
. "$(dirname "$0")/lib.sh"
PM="$REPO_ROOT/tests/claude-code/plan-metrics.mjs"
FX="$REPO_ROOT/tests/claude-code/fixtures"
echo "=== Test: plan-metrics ==="
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
field() { node -e 'const j=JSON.parse(process.argv[1]);console.log(j[process.argv[2]])' "$1" "$2"; }

out="$(node "$PM" "$FX"/hello-plan/specs/work/WRK-PLAN-DEMO-HELLO-001-*.md 2>&1)"
[[ "$(field "$out" impl_code_share)" != "0" && "$(node -e 'console.log(JSON.parse(process.argv[1]).impl_code_share>0)' "$out")" == "true" ]] && pass "hello-plan: impl_code_share > 0" || { fail "hello-plan: impl_code_share > 0"; echo "    $out"; }
[[ "$(field "$out" review_focus)" == "absent" ]] && pass "hello-plan: review_focus absent" || fail "hello-plan: review_focus absent"
[[ "$(field "$out" tasks)" == "2" ]] && pass "hello-plan: 2 tasks" || fail "hello-plan: 2 tasks"

out="$(node "$PM" "$FX"/rounding-plan/specs/work/WRK-PLAN-DEMO-MONEY-001-*.md 2>&1)"
[[ "$(field "$out" impl_code_share)" == "0" ]] && pass "rounding-plan: impl_code_share = 0" || { fail "rounding-plan: impl_code_share = 0"; echo "    $out"; }

# Temp plan copy with a fork-shaped task and an indented fence.
copy() { rm -rf "$tmp/w"; mkdir -p "$tmp/w"; cp "$FX"/hello-plan/specs/work/*.md "$tmp/w/"; rm -f "$tmp/w"/WRK-TASK-DEMO-HELLO-001-002-*; }
copy
t="$(ls "$tmp"/w/WRK-TASK-DEMO-HELLO-001-001-*.md)"
awk '/^---$/{n++} {print} n==2 && !done {done=1; exit}' "$t" > "$tmp/head.md"
{ cat "$tmp/head.md"; cat <<'EOT'

# Body

- [ ] **Step 3: Write the failing unit tests**
```js
test('f', () => {});
```
- [ ] **Step 4: Implement `f`**
  ```js
  export function f() {
    const x = 1;
    return x;
  }
  ```
- [ ] **Step 5: Commit**
EOT
} > "$t"
body=$(( $(wc -l < "$t") - $(wc -l < "$tmp/head.md") ))
out="$(node "$PM" "$tmp"/w/WRK-PLAN-*.md 2>&1)"
want="$(node -e 'console.log(Number((6/Number(process.argv[1])).toFixed(3)))' "$body")"
[[ "$(field "$out" impl_code_share)" == "$want" ]] && pass "fork-shaped task: only the Step-4 fence counts (4 body lines + 2 delimiters = 6/$body)" || { fail "fork-shaped task: only the Step-4 fence counts"; echo "    want $want got $out"; }

plan="$(ls "$tmp"/w/WRK-PLAN-*.md)"
rf() { cp "$FX"/hello-plan/specs/work/WRK-PLAN-DEMO-HELLO-001-*.md "$plan"; printf '\n## Review Focus\n\n%s\n\n## Other\n\nx\n' "$1" >> "$plan"; field "$(node "$PM" "$plan")" review_focus; }
[[ "$(rf $'- a\n- b')" == "lines:2" ]] && pass "Review Focus two bullets → lines:2" || fail "Review Focus two bullets → lines:2"
[[ "$(rf $'none — every input class the spec implies is tested:\n- x → T-1: t')" == "none-per-class:1" ]] && pass "Review Focus none per class → none-per-class:1" || fail "Review Focus none per class"
[[ "$(rf 'none')" == "none-bare" ]] && pass "Review Focus none alone → none-bare" || fail "Review Focus none alone"
# a numbered list is a list too (batch-2 level-1 after-run 1 wrote "1. … 2. …", read as lines:0 before this case)
[[ "$(rf $'1. a\n2. b\n3. c')" == "lines:3" ]] && pass "Review Focus numbered list → lines:3" || fail "Review Focus numbered list → lines:3 (got $(rf $'1. a\n2. b\n3. c'))"
[[ "$(rf $'none — every input class the spec implies is tested:')" == "none-bare" ]] && pass "none per class without bullets → none-bare" || fail "none per class without bullets"

node "$PM" "$t" >/dev/null 2>&1; [[ $? -eq 3 ]] && pass "non-plan file → exit 3" || fail "non-plan file → exit 3"
node "$PM" >/dev/null 2>&1; [[ $? -eq 2 ]] && pass "no arguments → exit 2" || fail "no arguments → exit 2"
finish
