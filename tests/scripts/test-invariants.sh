#!/usr/bin/env bash
# Invariants of the kdd-superpowers fork (WRK-SPEC-FORK-CORE-001, P13 and Plugin identity):
#  1. no skill/hook/script/test/doc references the upstream namespace `superpowers:<skill>`
#     (only `kdd-superpowers:<skill>` and the toolkit's `kdd:spec-*` are allowed)
#  2. no file references the upstream paths `.superpowers/` or `docs/superpowers/`
#  3. no non-Claude-Code harness asset exists
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"
FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

echo "=== Test: fork invariants ==="

# 1. namespace: any `superpowers:` not preceded by `kdd-`
hits=$(grep -rn --include='*.md' --include='*.sh' --include='*.json' --include='*.cjs' --include='*.mjs' \
  -E '(^|[^-])superpowers:[a-z]' skills hooks scripts tests docs README.md CLAUDE.md 2>/dev/null \
  | grep -v 'tests/scripts/test-invariants.sh' || true)
if [[ -z "$hits" ]]; then pass "no upstream namespace references"; else fail "no upstream namespace references"; echo "$hits" | sed 's/^/    /'; fi

# 2. paths
hits=$(grep -rn -E '(\.superpowers/|docs/superpowers/)' skills hooks scripts tests docs README.md CLAUDE.md .gitignore 2>/dev/null \
  | grep -v 'tests/scripts/test-invariants.sh' || true)
if [[ -z "$hits" ]]; then pass "no upstream paths"; else fail "no upstream paths"; echo "$hits" | sed 's/^/    /'; fi

# 3. harness assets
for p in .agents .codex-plugin .cursor-plugin .devin-plugin .hermes-plugin .kimi-plugin .opencode .pi \
         AGENTS.md GEMINI.md gemini-extension.json hooks/hooks-cursor.json \
         scripts/package-codex-plugin.sh scripts/sync-to-codex-plugin.sh \
         docs/README.kimi.md docs/README.opencode.md docs/porting-to-a-new-harness.md docs/windows \
         docs/plans docs/superpowers skills/using-superpowers/references \
         tests/antigravity tests/codex tests/codex-plugin-sync tests/devin tests/hermes tests/kimi tests/opencode tests/pi; do
  if [[ -e "$p" ]]; then fail "removed: $p"; else pass "removed: $p"; fi
done

# 4. identity
name=$(node -e 'console.log(JSON.parse(require("fs").readFileSync(".claude-plugin/plugin.json","utf8")).name)')
[[ "$name" == "kdd-superpowers" ]] && pass "plugin.json name is kdd-superpowers" || fail "plugin.json name is kdd-superpowers (got $name)"
mname=$(node -e 'const m=JSON.parse(require("fs").readFileSync(".claude-plugin/marketplace.json","utf8")); console.log(m.name+"/"+m.plugins[0].name)')
[[ "$mname" == "kdd-superpowers/kdd-superpowers" ]] && pass "marketplace.json names are kdd-superpowers" || fail "marketplace.json names are kdd-superpowers (got $mname)"
grep -q '^\.kdd/$' .gitignore && pass ".gitignore ignores .kdd/" || fail ".gitignore ignores .kdd/"

echo ""
if [[ "$FAILURES" -ne 0 ]]; then echo "FAILED: $FAILURES assertion(s)."; exit 1; fi
echo "PASS"
