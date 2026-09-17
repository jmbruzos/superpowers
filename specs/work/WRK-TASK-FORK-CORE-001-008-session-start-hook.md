---
id: WRK-TASK-FORK-CORE-001-008
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "Session-start hook: KDD-ENVIRONMENT block, Claude-only output"
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
tags: [kdd, fork, task, bootstrap]
---

# WRK-TASK-FORK-CORE-001-008 — Session-start hook: `<KDD-ENVIRONMENT>` block, Claude-only output

## Objective

Make the bootstrap probe the project at session start (spec Skill 1
*Hook*): toolkit location, specs directory with counts, open work and
unimported OKF bundles — computed with bash/find/grep only and appended to
the injected `using-superpowers` skill. Emit only the Claude Code JSON
shape (Cursor/Copilot branches go).

## Implementation Notes

**Files:**
- Modify: `hooks/session-start`, `tests/hooks/test-session-start.sh`
- Test: `tests/hooks/test-session-start.sh`

**Interfaces:**
- Consumes: `skills/using-superpowers/scripts/kdd-cli --path` (002); fixture (002).
- Produces: inside `additionalContext`, after the skill text, the block

```
<KDD-ENVIRONMENT>
toolkit: <path> | NOT FOUND
specs_dir: ./specs (knowledge: N · work: M) | NONE
open_work: <WRK-SPEC-ID> (<status>) → <WRK-PLAN-ID> → <k>/<n> tasks done; … | none
okf_bundles: <dir> (okf_version <v>, not imported); … | none
</KDD-ENVIRONMENT>
```

  Task 010's skill text tells the agent how to read these four lines. `open_work` lists work-specs whose `status` is `active` or `completed` (a `completed` one is *pending consolidation*); `knowledge` counts specs whose `layer` is one of architecture/domain/product/feature/documentation; `work` counts `layer: work-*`.

- [ ] **Step 1: Extend the hook test (failing)**

In `tests/hooks/test-session-start.sh`:

1. Delete the two blocks `cursor_home=…` / `assert_command_output "Cursor emits …"` and `copilot_home=…` / `assert_command_output "Copilot CLI emits …"` (and any later block that sets `COPILOT_CLI` or expects shape `cursor`/`sdk`). Keep the `claude-code` and `run-hook-wrapper` blocks.
2. Append before the final summary:

```bash
# --- KDD environment block ---
empty_dir="$TEST_ROOT/empty"; mkdir -p "$empty_dir"
assert_command_output \
    "reports toolkit NOT FOUND and specs_dir NONE in an empty project" \
    "nested" \
    "toolkit: NOT FOUND" \
    "" \
    "$(make_home kdd-empty)" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash -c "cd '$empty_dir' && exec bash '$HOOK_UNDER_TEST'"
assert_command_output \
    "specs_dir NONE, open_work none, okf_bundles none in an empty project" \
    "nested" \
    "specs_dir: NONE" \
    "" \
    "$(make_home kdd-empty2)" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash -c "cd '$empty_dir' && exec bash '$HOOK_UNDER_TEST' | grep -q 'open_work: none' && cd '$empty_dir' && exec bash '$HOOK_UNDER_TEST'"

fake_cli="$TEST_ROOT/spec-graph.mjs"; printf '\n' > "$fake_cli"
proj="$TEST_ROOT/proj"; mkdir -p "$proj"
cp -R "$REPO_ROOT/tests/scripts/fixtures/specs" "$proj/specs"
mkdir -p "$proj/vendor/risk-okf"; printf -- '---\nokf_version: "0.2"\n---\n# index\n' > "$proj/vendor/risk-okf/index.md"
assert_command_output \
    "reports the toolkit path from KDD_SPEC_GRAPH" \
    "nested" \
    "toolkit: $fake_cli" \
    "" \
    "$(make_home kdd-proj)" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" KDD_SPEC_GRAPH="$fake_cli" \
    bash -c "cd '$proj' && exec bash '$HOOK_UNDER_TEST'"
assert_command_output \
    "counts knowledge and work specs" \
    "nested" \
    "specs_dir: ./specs (knowledge: 1 · work: 4)" \
    "" \
    "$(make_home kdd-proj2)" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" KDD_SPEC_GRAPH="$fake_cli" \
    bash -c "cd '$proj' && exec bash '$HOOK_UNDER_TEST'"
assert_command_output \
    "lists open work with its plan and task progress" \
    "nested" \
    "open_work: WRK-SPEC-BILL-PRORATA-001 (active) → WRK-PLAN-BILL-PRORATA-001 → 0/2 tasks done" \
    "" \
    "$(make_home kdd-proj3)" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" KDD_SPEC_GRAPH="$fake_cli" \
    bash -c "cd '$proj' && exec bash '$HOOK_UNDER_TEST'"
assert_command_output \
    "lists OKF bundles outside specs/" \
    "nested" \
    "okf_bundles: vendor/risk-okf (okf_version 0.2, not imported)" \
    "" \
    "$(make_home kdd-proj4)" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" KDD_SPEC_GRAPH="$fake_cli" \
    bash -c "cd '$proj' && exec bash '$HOOK_UNDER_TEST'"
```

(The second empty-project assertion is written so that it fails unless
`open_work: none` is present — the helper checks one `contains` string, so
the grep guards the second.)

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/hooks/test-session-start.sh`
Expected: the six new assertions FAIL (`context did not contain expected text`), the two Claude Code ones pass.

- [ ] **Step 3: Rewrite `hooks/session-start`**

Replace the file with:

```bash
#!/usr/bin/env bash
# SessionStart hook for the kdd-superpowers plugin (Claude Code only).
# Injects the using-superpowers skill plus a <KDD-ENVIRONMENT> probe of the
# current project, computed with bash/find/grep only (no node at session start).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md" 2>&1 || echo "Error reading using-superpowers skill")

# --- KDD environment probe ---------------------------------------------------
kdd_environment() {
  local toolkit specs_line open_line okf_line
  toolkit="$("${PLUGIN_ROOT}/skills/using-superpowers/scripts/kdd-cli" --path 2>/dev/null || true)"
  [ -n "$toolkit" ] || toolkit="NOT FOUND"

  if [ -d ./specs ]; then
    local k w
    k=$(grep -rlE '^layer:[[:space:]]*(architecture|domain|product|feature|documentation)[[:space:]]*$' ./specs --include='*.md' 2>/dev/null | wc -l | tr -d ' ')
    w=$(grep -rlE '^layer:[[:space:]]*work-(spec|plan|task)[[:space:]]*$' ./specs --include='*.md' 2>/dev/null | wc -l | tr -d ' ')
    specs_line="./specs (knowledge: ${k} · work: ${w})"

    # open work: active/completed WRK-SPECs → their plans → task progress
    local entries="" f id st plans p pid tasks done_
    while IFS= read -r f; do
      id=$(sed -n 's/^id:[[:space:]]*//p' "$f" | head -1 | tr -d ' \r')
      st=$(sed -n 's/^status:[[:space:]]*//p' "$f" | head -1 | tr -d ' \r')
      [ -n "$id" ] || continue
      case "$st" in active|completed) ;; *) continue ;; esac
      plans=$(grep -rlE "^parent:[[:space:]]*${id}[[:space:]]*$" ./specs --include='*.md' 2>/dev/null || true)
      if [ -z "$plans" ]; then
        entries="${entries}${entries:+; }${id} (${st})"
        continue
      fi
      while IFS= read -r p; do
        pid=$(sed -n 's/^id:[[:space:]]*//p' "$p" | head -1 | tr -d ' \r')
        tasks=$(grep -rlE "^parent:[[:space:]]*${pid}[[:space:]]*$" ./specs --include='*.md' 2>/dev/null || true)
        done_=0
        [ -z "$tasks" ] || done_=$(printf '%s\n' "$tasks" | xargs -r grep -lE '^status:[[:space:]]*(completed|archived)[[:space:]]*$' 2>/dev/null | wc -l | tr -d ' ')
        entries="${entries}${entries:+; }${id} (${st}) → ${pid} → ${done_}/$(printf '%s\n' "$tasks" | grep -c . ) tasks done"
      done <<< "$plans"
    done < <(grep -rlE '^layer:[[:space:]]*work-spec[[:space:]]*$' ./specs --include='*.md' 2>/dev/null | sort)
    open_line="${entries:-none}"
  else
    specs_line="NONE"
    open_line="none"
  fi

  # OKF bundles outside specs/: index.md files declaring okf_version
  local bundles="" idx dir ver
  while IFS= read -r idx; do
    dir=$(dirname "$idx"); dir="${dir#./}"
    ver=$(sed -n 's/^okf_version:[[:space:]]*//p' "$idx" | head -1 | tr -d '"'"'"' \r')
    bundles="${bundles}${bundles:+; }${dir} (okf_version ${ver:-?}, not imported)"
  done < <(find . -maxdepth 5 -name index.md -not -path './specs/*' -not -path '*/node_modules/*' -not -path './.git/*' -not -path './.kdd/*' 2>/dev/null \
           | xargs -r grep -l '^okf_version:' 2>/dev/null | sort)
  okf_line="${bundles:-none}"

  printf '<KDD-ENVIRONMENT>\ntoolkit: %s\nspecs_dir: %s\nopen_work: %s\nokf_bundles: %s\n</KDD-ENVIRONMENT>' \
    "$toolkit" "$specs_line" "$open_line" "$okf_line"
}
kdd_env_content="$(kdd_environment)"

# --- JSON escaping (bash parameter substitution — one pass per character class) ---
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

using_superpowers_escaped=$(escape_for_json "$using_superpowers_content")
kdd_env_escaped=$(escape_for_json "$kdd_env_content")
session_context="<EXTREMELY_IMPORTANT>\nYou have kdd-superpowers.\n\n**Below is the full content of your 'kdd-superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_superpowers_escaped}\n</EXTREMELY_IMPORTANT>\n\n${kdd_env_escaped}"

# Claude Code hook output. Uses printf instead of a heredoc (bash 5.3+ heredoc hang, upstream #571).
printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context" | cat

exit 0
```

- [ ] **Step 4: Run the hook test**

Run: `bash tests/hooks/test-session-start.sh`
Expected: all `[PASS]` (registration shape, two Claude Code shapes, six KDD assertions).

- [ ] **Step 5: Check it by hand in the fork itself and commit**

Run: `cd <repo-root> && CLAUDE_PLUGIN_ROOT=$PWD KDD_SPEC_GRAPH=$KDD_SPEC_GRAPH bash hooks/session-start | node -e 'const j=JSON.parse(require("fs").readFileSync(0,"utf8")); console.log(j.hookSpecificOutput.additionalContext.split("<KDD-ENVIRONMENT>")[1])'`
Expected: `toolkit: …/spec-graph.mjs`, a `specs_dir: ./specs (knowledge: … · work: …)` line (the counts include the fixture files embedded verbatim in WRK-TASK-FORK-CORE-001-002 — grep counts `layer:` lines, not specs), `open_work: WRK-SPEC-FORK-CORE-001 (active) → WRK-PLAN-FORK-CORE-001 → <k>/19 tasks done`, `okf_bundles: none`.

```bash
git add hooks/session-start tests/hooks/test-session-start.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-008): session-start probes the KDD environment; Claude Code output only"
```

## Acceptance Criteria

- [ ] Hook emits valid nested JSON with the four-line block in all states: toolkit found/not found, specs present/absent, open work with progress, OKF bundle detected (spec AC 2).
- [ ] No `additional_context`/top-level `additionalContext` shapes remain.

## Test Plan

1. `tests/hooks/test-session-start.sh` — registration + 2 shape + 6 environment assertions.
