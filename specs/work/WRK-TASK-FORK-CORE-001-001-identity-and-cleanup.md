---
id: WRK-TASK-FORK-CORE-001-001
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "Plugin identity, Claude-only cleanup, namespace rename, invariant test"
parent: WRK-PLAN-FORK-CORE-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-FORK-CORE-001
    relation: implements
sources:
  - id: WRK-SPEC-FORK-CORE-001
    resource: specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-17T00:00:00+02:00
stale_after: 2026-12-16T00:00:00+01:00
tags: [kdd, fork, task, cleanup]
---

# WRK-TASK-FORK-CORE-001-001 — Plugin identity, Claude-only cleanup, namespace rename, invariant test

## Objective

Make the repository *be* `kdd-superpowers`: rename the plugin, remove every
non-Claude-Code harness asset and every upstream-only document, rename the
skill namespace, and add the invariant test that keeps `superpowers` out of
paths for good (spec: *Plugin identity*, *Repository cleanup*, P13).

## Implementation Notes

**Files:**
- Modify: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `package.json`, `.version-bump.json`, `.gitignore`, `skills/writing-skills/SKILL.md:12`, `skills/executing-plans/SKILL.md:14`, every `skills/**/*.md` containing `superpowers:`
- Delete (git rm -r): `.agents/`, `.codex-plugin/`, `.cursor-plugin/`, `.devin-plugin/`, `.hermes-plugin/`, `.kimi-plugin/`, `.opencode/`, `.pi/`, `AGENTS.md`, `GEMINI.md`, `gemini-extension.json`, `hooks/hooks-cursor.json`, `scripts/package-codex-plugin.sh`, `scripts/sync-to-codex-plugin.sh`, `docs/README.kimi.md`, `docs/README.opencode.md`, `docs/porting-to-a-new-harness.md`, `docs/windows/`, `docs/plans/`, `docs/superpowers/`, `skills/using-superpowers/references/`, `skills/brainstorming/spec-document-reviewer-prompt.md`, `tests/antigravity/`, `tests/codex/`, `tests/codex-plugin-sync/`, `tests/devin/`, `tests/hermes/`, `tests/kimi/`, `tests/opencode/`, `tests/pi/`, `.pre-commit-config.yaml`, `.github/FUNDING.yml`, `.github/ISSUE_TEMPLATE/platform_support.md`, `assets/superpowers-small.svg`
- Create: `tests/scripts/test-invariants.sh`
- Test: `tests/scripts/test-invariants.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: skill namespace `kdd-superpowers:<skill>` (every later task writes references in this form); `.gitignore` entry `.kdd/` (Task 005 relies on it); `tests/scripts/` directory (Task 002 adds the runner).

- [ ] **Step 1: Write the failing invariant test**

Create `tests/scripts/test-invariants.sh`:

```bash
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
```

- [ ] **Step 2: Run it to verify it fails**

Run: `chmod +x tests/scripts/test-invariants.sh && tests/scripts/test-invariants.sh`
Expected: many `[FAIL]` lines (namespace references, paths, existing harness assets, plugin name `superpowers`), exit 1.

- [ ] **Step 3: Delete the harness assets and upstream-only documents**

```bash
git rm -r -q .agents .codex-plugin .cursor-plugin .devin-plugin .hermes-plugin .kimi-plugin .opencode .pi \
  AGENTS.md GEMINI.md gemini-extension.json hooks/hooks-cursor.json \
  scripts/package-codex-plugin.sh scripts/sync-to-codex-plugin.sh \
  docs/README.kimi.md docs/README.opencode.md docs/porting-to-a-new-harness.md docs/windows \
  docs/plans docs/superpowers skills/using-superpowers/references \
  skills/brainstorming/spec-document-reviewer-prompt.md \
  tests/antigravity tests/codex tests/codex-plugin-sync tests/devin tests/hermes tests/kimi tests/opencode tests/pi \
  .pre-commit-config.yaml .github/FUNDING.yml .github/ISSUE_TEMPLATE/platform_support.md assets/superpowers-small.svg
```

- [ ] **Step 4: Rewrite the identity files**

`.claude-plugin/plugin.json`:

```json
{
  "name": "kdd-superpowers",
  "description": "Knowledge-Driven Development workflow for Claude Code: superpowers' brainstorm → plan → subagent execution → review → finish discipline, producing KDD work artifacts with frozen knowledge activation, brownfield capture and consolidation. Requires the kdd toolkit plugin.",
  "version": "0.1.0",
  "author": {
    "name": "NFQ Advisory"
  },
  "homepage": "https://github.com/jmbruzos/superpowers",
  "repository": "https://github.com/jmbruzos/superpowers",
  "license": "MIT",
  "keywords": ["kdd", "knowledge-driven-development", "skills", "tdd", "workflows", "specs"]
}
```

`.claude-plugin/marketplace.json`:

```json
{
  "name": "kdd-superpowers",
  "description": "Marketplace for the kdd-superpowers plugin (superpowers adapted to Knowledge-Driven Development)",
  "owner": {
    "name": "NFQ Advisory"
  },
  "plugins": [
    {
      "name": "kdd-superpowers",
      "description": "Knowledge-Driven Development workflow for Claude Code. Requires the kdd toolkit plugin.",
      "version": "0.1.0",
      "source": "./",
      "author": {
        "name": "NFQ Advisory"
      }
    }
  ]
}
```

`package.json` (the `main`, `pi` and `pi-package` entries belonged to other harnesses):

```json
{
  "name": "kdd-superpowers",
  "version": "0.1.0",
  "description": "kdd-superpowers skills and session bootstrap for Claude Code",
  "type": "module",
  "keywords": ["kdd", "skills", "tdd", "workflow"]
}
```

`.version-bump.json` — keep only the three surviving files:

```json
{
  "files": [
    { "path": "package.json", "field": "version" },
    { "path": ".claude-plugin/plugin.json", "field": "version" },
    { "path": ".claude-plugin/marketplace.json", "field": "plugins.0.version" }
  ],
  "audit": {
    "exclude": [
      "CHANGELOG.md",
      "RELEASE-NOTES.md",
      "node_modules",
      ".git",
      ".version-bump.json",
      "scripts/bump-version.sh",
      "specs"
    ]
  }
}
```

`.gitignore` — the line `.superpowers/` becomes `.kdd/` (the sed in Step 5 does it; verify).

- [ ] **Step 5: Rename the skill namespace everywhere**

```bash
grep -rl -E '(^|[^-])superpowers:[a-z]' skills hooks tests docs README.md CLAUDE.md \
  | xargs sed -i -E 's/(^|[^-])superpowers:([a-z])/\1kdd-superpowers:\2/g'
grep -rn -E '(^|[^-])superpowers:[a-z]' skills hooks tests docs README.md CLAUDE.md || echo "namespace clean"
```

Then rename the upstream *paths* mechanically — the semantic changes to the
workspace (Task 005) and the visual companion (Task 011) build on this
rename, and prose examples get corrected for free:

```bash
grep -rl -E '(\.superpowers/|docs/superpowers/(plans|specs))' skills hooks tests docs .gitignore \
  | xargs sed -i -E -e 's#docs/superpowers/(plans|specs)#specs/work#g' -e 's#\.superpowers/#.kdd/#g'
grep -rn -E '(\.superpowers/|docs/superpowers/)' skills hooks tests docs .gitignore || echo "paths clean"
```

(`skills/subagent-driven-development/scripts/sdd-workspace` now creates
`.kdd/sdd/<plan-basename>/`, `tests/claude-code/test-sdd-workspace.sh`
expects that, and `start-server.sh` uses `.kdd/brainstorm/` — all still
consistent with each other.)

Then fix the two lines that pointed at deleted references:

`skills/writing-skills/SKILL.md` line 12 becomes:

```markdown
**Personal skills live in your runtime's skills directory** (`~/.claude/skills/` on Claude Code).
```

`skills/executing-plans/SKILL.md` line 14 becomes:

```markdown
**Note:** If subagents are available (they are on Claude Code), use kdd-superpowers:subagent-driven-development instead of this skill.
```

- [ ] **Step 6: Run the invariant test and the surviving test suites**

Run: `tests/scripts/test-invariants.sh`
Expected: all `[PASS]`, final line `PASS`.

Run: `tests/version-bump/test-bump-version.sh && tests/shell-lint/test-lint-shell.sh`
Expected: both pass (the version-bump test reads `.version-bump.json`; if it asserts on the old file list, update its expectations to the three files above and re-run).

Run: `tests/hooks/test-session-start.sh`
Expected: passes (the hook still emits the skill; its text now says `kdd-superpowers:using-superpowers`). If the test greps for the literal `superpowers:using-superpowers`, change the expectation to `kdd-superpowers:using-superpowers`.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "chore(WRK-TASK-FORK-CORE-001-001): rename to kdd-superpowers, remove non-Claude harness assets, add invariant test"
```

## Acceptance Criteria

- [ ] `tests/scripts/test-invariants.sh` passes (spec AC 1, AC 13 — asset removal).
- [ ] `.claude-plugin/plugin.json` name is `kdd-superpowers`, version `0.1.0`; marketplace matches.
- [ ] No file under `skills/`, `hooks/`, `tests/`, `docs/` references `superpowers:<skill>` without the `kdd-` prefix.
- [ ] `.gitignore` contains `.kdd/` and no longer `.superpowers/`.

## Test Plan

1. `tests/scripts/test-invariants.sh` (new, deterministic).
2. `tests/version-bump/test-bump-version.sh`, `tests/shell-lint/test-lint-shell.sh`, `tests/hooks/test-session-start.sh` (existing) still pass.
