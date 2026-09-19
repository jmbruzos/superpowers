# Claude Code Skills Tests

Automated tests for superpowers skills using Claude Code CLI.

## Overview

This test suite verifies that skills are loaded correctly and Claude follows them as expected. Tests invoke Claude Code in headless mode (`claude -p`) and verify the behavior.

## Requirements

- Claude Code CLI installed and in PATH (`claude --version` should work)
- Local superpowers plugin installed (see main README for installation)

## Running Tests

### Run all fast tests (recommended):
```bash
./run-skill-tests.sh
```

### Run integration tests (slow, 10-30 minutes):
```bash
./run-skill-tests.sh --integration
```

### Run specific test:
```bash
./run-skill-tests.sh --test test-subagent-driven-development.sh
```

### Run with verbose output:
```bash
./run-skill-tests.sh --verbose
```

### Set custom timeout:
```bash
./run-skill-tests.sh --timeout 1800  # 30 minutes for integration tests
```

## Test Structure

### test-helpers.sh
Common functions for skills testing:
- `run_claude "prompt" [timeout]` - Run Claude with prompt
- `assert_contains output pattern name` - Verify pattern exists
- `assert_not_contains output pattern name` - Verify pattern absent
- `assert_count output pattern count name` - Verify exact count
- `assert_order output pattern_a pattern_b name` - Verify order
- `create_test_project` - Create temp test directory
- `create_test_plan project_dir` - Copy the hello-plan fixture's `specs/` into project_dir, return the plan path

### Test Files

Each test file:
1. Sources `test-helpers.sh`
2. Runs Claude Code with specific prompts
3. Verifies expected behavior using assertions
4. Returns 0 on success, non-zero on failure

## Example Test

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Test: My Skill ==="

# Ask Claude about the skill
output=$(run_claude "What does the my-skill skill do?" 30)

# Verify response
assert_contains "$output" "expected behavior" "Skill describes behavior"

echo "=== All tests passed ==="
```

## Current Tests

### Fast Tests (run by default)

#### test-subagent-driven-development.sh
Tests skill content and requirements (~2 minutes):
- Skill loading and accessibility
- Workflow ordering (spec compliance before code quality)
- Self-review requirements documented
- Plan reading efficiency documented
- Spec compliance reviewer skepticism documented
- Review loops documented
- Task context provision documented

### Integration Tests (use --integration flag)

#### test-subagent-driven-development-integration.sh
Full workflow execution test (~10-30 minutes):
- Creates real test project with Node.js setup
- Creates implementation plan with 2 tasks
- Executes plan using subagent-driven-development
- Verifies actual behaviors:
  - Plan read once at start (not per task)
  - Full task text provided in subagent prompts
  - Subagents perform self-review before reporting
  - Spec compliance review happens before code quality
  - Spec reviewer reads code independently
  - Working implementation is produced
  - Tests pass
  - Proper git commits created

**What it tests:**
- The workflow actually works end-to-end
- Our improvements are actually applied
- Subagents follow the skill correctly
- Final code is functional and tested

#### test-kdd-flow.sh
Headless Claude Code scenarios for the kdd-superpowers flow, loaded with both
`--plugin-dir` this repo and the `kdd` toolkit plugin (~10-30 minutes total,
six scenarios, up to 15 minutes each):
1. toolkit missing → brainstorming stops with an install instruction and
   writes no work artifact.
2. brainstorming with a knowledge base → a frozen, compact WRK-SPEC that
   activates the pinned domain spec and is transitioned to `active` with a
   `human:test` verification entry.
3. brainstorming without `specs/` → `specs/work` created, `activates: []`
   stated, and a FRAG captured with verifiable anchors at `confidence: low`.
4. writing-plans from an active WRK-SPEC → a WRK-PLAN and WRK-TASK files
   whose task activations stay within the spec's activated set, with an
   Architecture Impact section citing the activated domain spec.
5. subagent-driven-development executes the `hello-plan` fixture end to end
   (see `fixtures/hello-plan/`) — tests pass, the plan/tasks/spec close out,
   and commits carry task IDs.
6. requesting-code-review flags a violation of an activated rule as Critical
   with a Knowledge Compliance section naming the rule.

**Token usage (opt-in):** `KDD_FLOW_USAGE=<dir> bash tests/claude-code/test-kdd-flow.sh`
runs scenarios 2-6 with `--output-format json`, saves `<dir>/scenario-N.json`,
`.result` and the session transcripts, and ends with `usage-summary.py`'s table
(turns, cache write/read, output, cost, duration per scenario, per-model
breakdown, per-subagent breakdown via `analyze-token-usage.py`). Use it as the
before/after for any change to a skill. `usage-lib.sh` holds the helpers;
`tests/scripts/test-usage-summary.sh` tests them without Claude.
`KDD_FLOW_SCENARIOS="5 6"` runs only those scenarios (after a partial failure, or
when iterating on one skill). Credentials are re-copied into the isolated config
dir before each scenario: a full run outlives one OAuth token.

Isolation: each scenario runs with `CLAUDE_CONFIG_DIR` pointing at a fresh
temp directory into which `~/.claude/.credentials.json` is copied when
present (otherwise `ANTHROPIC_API_KEY` must be set in the environment), so
no user-scope plugins (e.g. upstream `superpowers`) load — only the two
`--plugin-dir`s under test. Requires `KDD_TOOLKIT_DIR` (default
`../knowledge-driven-development/kdd-toolkit`) and `KDD_SPEC_GRAPH` (default
`$KDD_TOOLKIT_DIR/cli/spec-graph.mjs`); the test skips itself if either
`claude` or the kdd toolkit is not found. When run from inside a Claude Code
session, it strips the inherited `CLAUDECODE` / `CLAUDE_CODE_*` env vars
before launching the nested headless `claude -p` calls (otherwise they
refuse to start).

#### test-worktree-native-preference.sh
RED-GREEN-REFACTOR validation for the using-git-worktrees skill (~5 minutes):
- RED: skill without Step 1a — agent should use `git worktree add`
- GREEN: skill with Step 1a — agent should use the native EnterWorktree tool
- PRESSURE: same as GREEN under urgency framing with pre-existing `.worktrees/`
- Drill scenario `worktree-creation-under-pressure.yaml` covers the PRESSURE phase only

## Adding New Tests

1. Create new test file: `test-<skill-name>.sh`
2. Source test-helpers.sh
3. Write tests using `run_claude` and assertions
4. Add to test list in `run-skill-tests.sh`
5. Make executable: `chmod +x test-<skill-name>.sh`

## Timeout Considerations

- Default timeout: 5 minutes per test
- Claude Code may take time to respond
- Adjust with `--timeout` if needed
- Tests should be focused to avoid long runs

## Debugging Failed Tests

With `--verbose`, you'll see full Claude output:
```bash
./run-skill-tests.sh --verbose --test test-subagent-driven-development.sh
```

Without verbose, only failures show output.

## CI/CD Integration

To run in CI:
```bash
# Run with explicit timeout for CI environments
./run-skill-tests.sh --timeout 900

# Exit code 0 = success, non-zero = failure
```

## Notes

- Tests verify skill *instructions*, not full execution
- Full workflow tests would be very slow
- Focus on verifying key skill requirements
- Tests should be deterministic
- Avoid testing implementation details
