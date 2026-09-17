#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
CHECK="$REPO_ROOT/skills/kdd-conventions/scripts/frag-cite-check"
echo "=== Test: frag-cite-check ==="
repo="$(mktemp -d)"; trap 'rm -rf "$repo"' EXIT
git init -q -b main "$repo"
mkdir -p "$repo/src"
cat > "$repo/src/billing.js" <<'JS'
export function round2(amount) {
  // half-up for positive amounts
  return Math.round(amount * 100) / 100;
}
JS
( cd "$repo" && git add -A && git -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -qm init )
sha="$(cd "$repo" && git rev-parse --short=7 HEAD)"

mkfrag() { # $1 = dir name, stdin = report body
  local d="$repo/specs/_capture/$1"; mkdir -p "$d"; cat > "$d/report.md"
  local integ; integ="$(cd "$d" && sha256sum report.md | cut -d' ' -f1)"
  cat > "$d/FRAG-BILL-X-001.md" <<EOF
---
id: FRAG-BILL-X-001
type: fragment
layer: capture
status: ingested
confidence: low
version: 1.0.0
owner: t
captured_at: 2026-09-17T10:00:00+02:00
source_type: report
files:
  - report.md
integrity: "sha256:$integ"
---
# frag
EOF
  echo "$d"
}

good="$(mkfrag good <<EOF
## Observed
- \`src/billing.js:3-3@$sha\`: \`return Math.round(amount * 100) / 100;\`
- \`src/billing.js:1-4@$sha\`: \`export function round2(amount) {\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$good")"; rc=$?
[[ "$rc" -eq 0 && "$out" == "verified 2 anchors" ]] && pass "two valid anchors verify" || { fail "two valid anchors verify"; echo "    rc=$rc out=$out"; }

badlit="$(mkfrag badlit <<EOF
- \`src/billing.js:3-3@$sha\`: \`return Math.floor(amount * 100) / 100;\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$badlit" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"FAIL"*"literal not found"* ]] && pass "wrong literal fails" || { fail "wrong literal fails"; echo "    rc=$rc out=$out"; }

badrange="$(mkfrag badrange <<EOF
- \`src/billing.js:1-2@$sha\`: \`return Math.round(amount * 100) / 100;\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$badrange" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"FAIL"*"literal not found"* ]] && pass "literal outside the range fails" || { fail "literal outside the range fails"; echo "    rc=$rc out=$out"; }

badpath="$(mkfrag badpath <<EOF
- \`src/nope.js:1-1@$sha\`: \`x\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$badpath" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"FAIL"*"no such file"* ]] && pass "missing file fails" || { fail "missing file fails"; echo "    rc=$rc out=$out"; }

none="$(mkfrag none <<EOF
## Observed
Nothing anchored here.
EOF
)"
out="$(cd "$repo" && "$CHECK" "$none" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"no anchors found"* ]] && pass "a FRAG without anchors fails" || { fail "a FRAG without anchors fails"; echo "    rc=$rc out=$out"; }

# unknown sha falls back to the working tree (still verifies), with a WARN on stderr
wt="$(mkfrag wt <<EOF
- \`src/billing.js:3-3@0000000\`: \`return Math.round(amount * 100) / 100;\`
EOF
)"
werr="$(cd "$repo" && "$CHECK" "$wt" 2>&1 1>/dev/null)"
out="$(cd "$repo" && "$CHECK" "$wt")"; rc=$?
[[ "$rc" -eq 0 && "$out" == *"verified 1 anchors"* ]] && pass "unknown sha falls back to the working tree" || { fail "unknown sha falls back to the working tree"; echo "    rc=$rc out=$out"; }
[[ "$werr" == *"WARN"*"not found, checked the working tree"* ]] && pass "fallback to the working tree WARNs on stderr" || { fail "fallback to the working tree WARNs on stderr"; echo "    stderr=$werr"; }

# --strict turns that same fallback into a FAIL
out="$(cd "$repo" && "$CHECK" --strict "$wt" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"FAIL"*"not found in git"* ]] && pass "--strict fails an unknown sha instead of falling back" || { fail "--strict fails an unknown sha instead of falling back"; echo "    rc=$rc out=$out"; }

rc=0; "$CHECK" >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 2 ]] && pass "usage error exits 2" || fail "usage error exits 2 (rc=$rc)"
finish
