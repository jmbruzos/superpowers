#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK_UNDER_TEST="$REPO_ROOT/hooks/session-start"
WRAPPER_UNDER_TEST="$REPO_ROOT/hooks/run-hook.cmd"

FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() {
    echo "  [PASS] $1"
}

fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

make_home() {
    local name="$1"
    local home="$TEST_ROOT/$name/home"
    mkdir -p "$home"
    printf '%s\n' "$home"
}

assert_command_output() {
    local description="$1"
    local shape="$2"
    local contains="$3"
    local not_contains="$4"
    local home="$5"
    shift 5

    local output
    if ! output="$(env -i PATH="${PATH:-}" HOME="$home" "$@" 2>&1)"; then
        fail "$description"
        echo "    hook exited non-zero"
        echo "$output" | sed 's/^/      /'
        return
    fi

    if printf '%s' "$output" | \
        EXPECT_SHAPE="$shape" \
        EXPECT_CONTAINS="$contains" \
        EXPECT_NOT_CONTAINS="$not_contains" \
        node -e '
const fs = require("fs");

const input = fs.readFileSync(0, "utf8");
let payload;
try {
  payload = JSON.parse(input);
} catch (error) {
  console.error(`invalid JSON: ${error.message}`);
  process.exit(1);
}

function hasOwn(object, key) {
  return Object.prototype.hasOwnProperty.call(object, key);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

const shape = process.env.EXPECT_SHAPE;
let context;

if (shape === "nested") {
  if (!hasOwn(payload, "hookSpecificOutput")) {
    fail("missing hookSpecificOutput");
  }
  if (hasOwn(payload, "additional_context") || hasOwn(payload, "additionalContext")) {
    fail("nested output also included a top-level context field");
  }
  const hookOutput = payload.hookSpecificOutput;
  if (!hookOutput || typeof hookOutput !== "object" || Array.isArray(hookOutput)) {
    fail("hookSpecificOutput is not an object");
  }
  if (hookOutput.hookEventName !== "SessionStart") {
    fail(`unexpected hookEventName: ${hookOutput.hookEventName}`);
  }
  context = hookOutput.additionalContext;
} else if (shape === "cursor") {
  if (hasOwn(payload, "hookSpecificOutput")) {
    fail("cursor output included hookSpecificOutput");
  }
  if (!hasOwn(payload, "additional_context")) {
    fail("cursor output missing additional_context");
  }
  if (hasOwn(payload, "additionalContext")) {
    fail("cursor output included additionalContext");
  }
  context = payload.additional_context;
} else if (shape === "sdk") {
  if (hasOwn(payload, "hookSpecificOutput")) {
    fail("sdk output included hookSpecificOutput");
  }
  if (!hasOwn(payload, "additionalContext")) {
    fail("sdk output missing additionalContext");
  }
  if (hasOwn(payload, "additional_context")) {
    fail("sdk output included additional_context");
  }
  context = payload.additionalContext;
} else {
  fail(`unknown expected shape: ${shape}`);
}

if (typeof context !== "string" || context.trim() === "") {
  fail("injected context was empty");
}

const expectedText = process.env.EXPECT_CONTAINS || "";
if (expectedText && !context.includes(expectedText)) {
  fail(`context did not contain expected text: ${expectedText}`);
}

const forbiddenTexts = (process.env.EXPECT_NOT_CONTAINS || "")
  .split("\u001f")
  .filter(Boolean);
for (const forbiddenText of forbiddenTexts) {
  if (context.includes(forbiddenText)) {
    fail(`context contained forbidden text: ${forbiddenText}`);
  }
}
'; then
        pass "$description"
    else
        fail "$description"
        echo "    output:"
        echo "$output" | sed 's/^/      /'
    fi
}

echo "SessionStart hook output tests"

# Registration shape: the hook must declare shell:"bash" so Claude Code on
# Windows dispatches via Git Bash (or fails with an actionable error) instead
# of PowerShell/cmd.exe, whose parsers break on the quoted command string
# (PowerShell ParserError; cmd.exe quote-stripping on paths with metacharacters).
if node -e '
const hooks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
const entry = hooks.hooks.SessionStart[0].hooks[0];
if (entry.shell !== "bash") {
  console.error(`SessionStart hook shell is ${JSON.stringify(entry.shell)}, expected "bash"`);
  process.exit(1);
}
if (!/run-hook\.cmd" session-start$/.test(entry.command)) {
  console.error(`unexpected SessionStart command shape: ${entry.command}`);
  process.exit(1);
}
' "$REPO_ROOT/hooks/hooks.json"; then
    pass "hooks.json registers SessionStart with shell:bash dispatch"
else
    fail "hooks.json registers SessionStart with shell:bash dispatch"
fi

claude_home="$(make_home claude-code)"
assert_command_output \
    "Claude Code emits nested SessionStart additionalContext" \
    "nested" \
    "" \
    "" \
    "$claude_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$HOOK_UNDER_TEST"

wrapper_home="$(make_home run-hook-wrapper)"
assert_command_output \
    "run-hook.cmd wrapper dispatches to the named session-start script" \
    "nested" \
    "" \
    "" \
    "$wrapper_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$WRAPPER_UNDER_TEST" session-start

legacy_home="$(make_home legacy-warning-removed)"
mkdir -p "$legacy_home/.config/superpowers/skills"
assert_command_output \
    "SessionStart omits obsolete legacy custom-skill warning" \
    "nested" \
    "" \
    "Superpowers now uses"$'\037'"~/.config/superpowers/skills"$'\037'"~/.claude/skills"$'\037'"legacy" \
    "$legacy_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$HOOK_UNDER_TEST"

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
phantom_file="$proj/specs/work/WRK-TASK-BILL-PRORATA-001-003-phantom.md"
cat > "$phantom_file" <<'PHANTOM_EOF'
---
id: WRK-TASK-BILL-PRORATA-001-003
type: spec
layer: work-task
status: active
parent: WRK-PLAN-BILL-PRORATA-001
owner: t
confidence: low
version: 0.1.0
---

# WRK-TASK-BILL-PRORATA-001-003 — phantom

Embedded example, must not be read as real frontmatter:

```
id: WRK-SPEC-PHANTOM-001
layer: work-spec
status: active
layer: domain
```
PHANTOM_EOF
assert_command_output \
    "does not treat a fenced-example layer/status/id/parent as real frontmatter (open_work)" \
    "nested" \
    "open_work: WRK-SPEC-BILL-PRORATA-001 (active) → WRK-PLAN-BILL-PRORATA-001 → 0/3 tasks done" \
    "PHANTOM" \
    "$(make_home kdd-proj3b)" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" KDD_SPEC_GRAPH="$fake_cli" \
    bash -c "cd '$proj' && exec bash '$HOOK_UNDER_TEST'"
assert_command_output \
    "does not treat a fenced-example layer/status/id/parent as real frontmatter (specs_dir counts)" \
    "nested" \
    "specs_dir: ./specs (knowledge: 1 · work: 5)" \
    "" \
    "$(make_home kdd-proj3c)" \
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

if [[ "$FAILURES" -gt 0 ]]; then
    echo "STATUS: FAILED ($FAILURES failure(s))"
    exit 1
fi

echo "STATUS: PASSED"
