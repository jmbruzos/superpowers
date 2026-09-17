---
id: WRK-TASK-FORK-CORE-001-019
type: spec
layer: work-task
scope: ephemeral
status: completed
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "Headless Claude scenario tests and full suite run"
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
tags: [kdd, fork, task, verification]
---

# WRK-TASK-FORK-CORE-001-019 — Headless Claude scenario tests and full suite run

## Objective

Prove the behaviour, not just the prose: run the fork as a plugin in
headless Claude Code against fixture projects and assert the artifacts the
skills must produce (spec *Testing*, acceptance criteria 2–5, 6, 8, 11).
Then run every suite and record the results in the plan's Execution Log
material.

## Implementation Notes

**Files:**
- Create: `tests/claude-code/test-kdd-flow.sh`, `tests/claude-code/fixtures/hello-plan/specs/work/WRK-SPEC-DEMO-HELLO-001-hello-library.md`, `tests/claude-code/fixtures/hello-plan/specs/work/WRK-PLAN-DEMO-HELLO-001-hello-library.md`, `tests/claude-code/fixtures/hello-plan/specs/work/WRK-TASK-DEMO-HELLO-001-001-hello-function.md`, `tests/claude-code/fixtures/hello-plan/specs/work/WRK-TASK-DEMO-HELLO-001-002-goodbye-function.md`
- Modify: `tests/claude-code/README.md` (list the new test), `tests/claude-code/run-skill-tests.sh` (include it), `tests/claude-code/test-helpers.sh` (`create_test_plan` now copies the hello-plan fixture; delete the inline plan heredoc)
- Test: `tests/claude-code/test-kdd-flow.sh`

**Interfaces:**
- Consumes: the whole plugin (001–018), the `specs/` fixture (002), the `kdd` toolkit directory (`KDD_TOOLKIT_DIR`, default `../knowledge-driven-development/kdd-toolkit`) loaded with a second `--plugin-dir`.
- Produces: the behavioural evidence for the spec's acceptance criteria.

**Isolation.** The developer machine has upstream `superpowers` installed at user scope; two bootstraps would collide. Each scenario runs with `CLAUDE_CONFIG_DIR` pointing at a temp directory into which `~/.claude/.credentials.json` is copied when present (otherwise `ANTHROPIC_API_KEY` must be set), so no user-scope plugins load and only the two `--plugin-dir`s do. State this assumption at the top of the test file.

- [ ] **Step 1: Write the hello-plan fixture (a real, executable plan)**

`WRK-SPEC-DEMO-HELLO-001-hello-library.md` — frontmatter as the kdd-conventions full template with `id: WRK-SPEC-DEMO-HELLO-001`, `status: active`, `confidence: low`, `activates: []`, `equips: []`, `activation_frozen: true`, `owner: test`, `generated` by `claude-code/test`, and this body:

```markdown
# WRK-SPEC-DEMO-HELLO-001 — Hello library

## Problem Statement
A tiny ESM library is needed for exercising the execution skills end to end.

## Proposed Change
Two pure functions in `src/`: `hello()` returning `"Hello, World!"` and `goodbye(name)` returning `` `Goodbye, ${name}!` `` (default name `"World"`; empty string or null falls back to the default). Tests with `node --test`.

## Knowledge Context
No knowledge base in this project; `activates: []`.

## Constraints
- Zero dependencies; `package.json` has `"type": "module"` and `"test": "node --test"`.

## Acceptance Criteria
- [ ] `hello()` returns `"Hello, World!"`.
- [ ] `goodbye("Ana")` returns `"Goodbye, Ana!"`; `goodbye()` / `goodbye("")` / `goodbye(null)` return `"Goodbye, World!"`.
- [ ] `npm test` passes.

## Open Questions
- None.
```

`WRK-PLAN-DEMO-HELLO-001-hello-library.md` — plan template, `parent: WRK-SPEC-DEMO-HELLO-001`, `status: active`, body with the required header, *Approach* (`Goal: build the hello library; Architecture: two files, one test each; Tech Stack: Node ESM, node --test`), *Task Breakdown* rows for `WRK-TASK-DEMO-HELLO-001-001 | hello function | —` and `WRK-TASK-DEMO-HELLO-001-002 | goodbye function | 001`, *Architecture Impact* with the single constraint row (`Zero dependencies… | WRK-SPEC-DEMO-HELLO-001 | package.json created in task 001`), empty *Risk Assessment* row ("none"), *Dependencies*: none.

`WRK-TASK-DEMO-HELLO-001-001-hello-function.md` — task template, `parent: WRK-PLAN-DEMO-HELLO-001`, `status: active`, `activates: []`, body:

````markdown
# WRK-TASK-DEMO-HELLO-001-001 — hello function

## Objective
Create the package and `hello()`.

## Implementation Notes
**Files:** Create `package.json`, `src/hello.js`, `test/hello.test.js`
**Interfaces:** Produces `export function hello(): string`.

- [ ] **Step 1: Write the failing test**
```js
// test/hello.test.js
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { hello } from '../src/hello.js';
test('hello returns the greeting', () => { assert.equal(hello(), 'Hello, World!'); });
```
- [ ] **Step 2: Run it to verify it fails** — `npm test` → fails (module not found). Create `package.json` first: `{ "name": "hello-lib", "version": "0.0.1", "type": "module", "scripts": { "test": "node --test" } }`.
- [ ] **Step 3: Minimal implementation**
```js
// src/hello.js
export function hello() { return 'Hello, World!'; }
```
- [ ] **Step 4: Run to verify it passes** — `npm test` → 1 pass.
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(WRK-TASK-DEMO-HELLO-001-001): hello()"`

## Acceptance Criteria
- [ ] `hello()` returns `"Hello, World!"` (spec criterion 1).

## Test Plan
1. `npm test`.
````

`WRK-TASK-DEMO-HELLO-001-002-goodbye-function.md` — same shape for `goodbye(name = 'World')` with the fallback rule, test file `test/goodbye.test.js` with four assertions (`"Ana"`, no argument, `""`, `null`), commit subject `feat(WRK-TASK-DEMO-HELLO-001-002): goodbye()`; acceptance criteria map to spec criteria 2 and 3.

Validate the fixture: `node "$KDD_SPEC_GRAPH" --specs tests/claude-code/fixtures/hello-plan/specs validate` → 0 errors.

- [ ] **Step 2: Write `tests/claude-code/test-kdd-flow.sh`**

```bash
#!/usr/bin/env bash
# Headless Claude Code scenarios for the kdd-superpowers flow.
# Assumptions: `claude` on PATH; the kdd toolkit at $KDD_TOOLKIT_DIR (default
# ../knowledge-driven-development/kdd-toolkit relative to the repo); credentials in
# ~/.claude/.credentials.json (copied into an isolated CLAUDE_CONFIG_DIR so user-scope
# plugins — e.g. upstream superpowers — do not load) or ANTHROPIC_API_KEY set.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"
KDD_TOOLKIT_DIR="${KDD_TOOLKIT_DIR:-$REPO_ROOT/../knowledge-driven-development/kdd-toolkit}"
KDD_SPEC_GRAPH="${KDD_SPEC_GRAPH:-$KDD_TOOLKIT_DIR/cli/spec-graph.mjs}"
TIMEOUT="${CLAUDE_PROMPT_TIMEOUT:-900}"
FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

command -v claude >/dev/null || { echo "SKIP: claude not found"; exit 0; }
[[ -f "$KDD_SPEC_GRAPH" ]] || { echo "SKIP: kdd toolkit not found at $KDD_TOOLKIT_DIR"; exit 0; }

CONFIG_DIR="$(mktemp -d)"
[[ -f "$HOME/.claude/.credentials.json" ]] && cp "$HOME/.claude/.credentials.json" "$CONFIG_DIR/"
trap 'rm -rf "$CONFIG_DIR"' EXIT

run_scenario() { # DIR PROMPT [extra env…] — runs claude headless in DIR with both plugins
  local dir="$1" prompt="$2"; shift 2
  ( cd "$dir" && env CLAUDE_CONFIG_DIR="$CONFIG_DIR" KDD_SPEC_GRAPH="$KDD_SPEC_GRAPH" "$@" \
      timeout "$TIMEOUT" claude -p "$prompt" --plugin-dir "$REPO_ROOT" --plugin-dir "$KDD_TOOLKIT_DIR" \
      --allowed-tools=all --permission-mode bypassPermissions 2>&1 )
}
new_project() { local d; d="$(mktemp -d)"; git -C "$d" init -q -b main; printf 'node_modules/\n' > "$d/.gitignore"; git -C "$d" add -A; git -C "$d" -c user.email=t@e -c user.name=t commit -qm init; echo "$d"; }
validate() { node "$KDD_SPEC_GRAPH" --specs "$1/specs" validate 2>&1 | tail -1; }

echo "=== Scenario 1: toolkit missing → brainstorming stops with install instruction ==="
p1="$(new_project)"
out="$(cd "$p1" && env CLAUDE_CONFIG_DIR="$CONFIG_DIR" KDD_SPEC_GRAPH=/nonexistent HOME="$CONFIG_DIR" \
      timeout "$TIMEOUT" claude -p "Let's make a react todo list" --plugin-dir "$REPO_ROOT" --allowed-tools=all --permission-mode bypassPermissions 2>&1)"
assert_contains "$out" "kdd" "mentions the kdd toolkit" || FAILURES=$((FAILURES+1))
assert_contains "$out" "install\|KDD_SPEC_GRAPH" "gives an install instruction" || FAILURES=$((FAILURES+1))
[[ ! -d "$p1/specs/work" ]] && pass "no work artifact written" || fail "no work artifact written"

echo "=== Scenario 2: brainstorming with a knowledge base → frozen WRK-SPEC ==="
p2="$(new_project)"; cp -R "$REPO_ROOT/tests/scripts/fixtures/specs" "$p2/specs"; rm -rf "$p2/specs/work"; git -C "$p2" add -A; git -C "$p2" -c user.email=t@e -c user.name=t commit -qm specs
out="$(run_scenario "$p2" "Use kdd-superpowers:brainstorming, bounded path. I want a helper that computes the pro-rata amount for a mid-cycle activation in this billing project. I approve the design and the activation in advance and I will not answer questions: pick sensible defaults, write the compact WRK-SPEC, validate it, commit it, and transition it to active with verified by human:test.")"
spec="$(ls "$p2"/specs/work/WRK-SPEC-*.md 2>/dev/null | head -1)"
[[ -n "$spec" ]] && pass "WRK-SPEC written under specs/work" || fail "WRK-SPEC written under specs/work"
if [[ -n "$spec" ]]; then
  grep -q "activation_frozen: true" "$spec" && pass "activation frozen" || fail "activation frozen"
  grep -q "DOM-BILL-PRORATA-001@" "$spec" && pass "activates the pinned DOM" || fail "activates the pinned DOM"
  grep -q "^status: active" "$spec" && pass "status active" || fail "status active"
  grep -q "human:test" "$spec" && pass "human verified entry" || fail "human verified entry"
  [[ "$(validate "$p2")" == *"0 error"* || "$(validate "$p2")" == *"passed"* ]] && pass "validates" || fail "validates: $(validate "$p2")"
  grep -q "^## Problem Statement" "$spec" && ! grep -q "^## Open Questions" "$spec" && pass "compact body" || fail "compact body"
fi

echo "=== Scenario 3: brainstorming without specs/ → specs/work created, activates [], FRAG anchored ==="
p3="$(new_project)"; mkdir -p "$p3/src"; printf 'export function round2(a) {\n  return Math.round(a * 100) / 100;\n}\n' > "$p3/src/money.js"; git -C "$p3" add -A; git -C "$p3" -c user.email=t@e -c user.name=t commit -qm code
out="$(run_scenario "$p3" "Use kdd-superpowers:brainstorming, bounded path. Add a formatMoney(amount) helper next to src/money.js that returns the rounded amount with two decimals as a string. Capture what src/money.js already does as a fragment first. I approve everything in advance; do not ask questions; write the compact WRK-SPEC, validate, commit.")"
[[ -d "$p3/specs/work" ]] && pass "specs/work created" || fail "specs/work created"
spec3="$(ls "$p3"/specs/work/WRK-SPEC-*.md 2>/dev/null | head -1)"
[[ -n "$spec3" ]] && grep -q "activates: \[\]" "$spec3" && pass "activates: [] stated" || fail "activates: [] stated"
frag="$(ls -d "$p3"/specs/_capture/FRAG-*/ 2>/dev/null | head -1)"
if [[ -n "$frag" ]]; then
  pass "FRAG captured"
  (cd "$p3" && "$REPO_ROOT/skills/kdd-conventions/scripts/frag-cite-check" "$frag" >/dev/null 2>&1) && pass "FRAG anchors verify" || fail "FRAG anchors verify"
  grep -q "^confidence: low" "$frag"/FRAG-*.md && pass "FRAG born low confidence" || fail "FRAG born low confidence"
else fail "FRAG captured"; fi

echo "=== Scenario 4: writing-plans from an active WRK-SPEC → plan + task files ==="
p4="$(new_project)"; cp -R "$REPO_ROOT/tests/scripts/fixtures/specs" "$p4/specs"; rm -f "$p4"/specs/work/WRK-PLAN-* "$p4"/specs/work/WRK-TASK-*; git -C "$p4" add -A; git -C "$p4" -c user.email=t@e -c user.name=t commit -qm specs
out="$(run_scenario "$p4" "Use kdd-superpowers:writing-plans for WRK-SPEC-BILL-PRORATA-001 (specs/work). Two tasks are enough. Write the WRK-PLAN and the WRK-TASK files, validate, and when you offer the execution choice assume I chose Subagent-Driven: activate them and commit. Do not execute the plan.")"
plan="$(ls "$p4"/specs/work/WRK-PLAN-BILL-PRORATA-*.md 2>/dev/null | head -1)"
[[ -n "$plan" ]] && pass "WRK-PLAN written" || fail "WRK-PLAN written"
n="$(ls "$p4"/specs/work/WRK-TASK-BILL-PRORATA-001-*.md 2>/dev/null | wc -l | tr -d ' ')"
[[ "$n" -ge 1 ]] && pass "WRK-TASK files written ($n)" || fail "WRK-TASK files written"
for t in "$p4"/specs/work/WRK-TASK-*.md; do
  [[ -f "$t" ]] || continue
  grep -A5 "^activates:" "$t" | grep -E '^\s+- ' | grep -vq "DOM-BILL-PRORATA-001@1.0.0" && fail "task activations ⊆ spec ($(basename "$t"))" || pass "task activations ⊆ spec ($(basename "$t"))"
done
[[ -n "$plan" ]] && grep -q "^## Architecture Impact" "$plan" && grep -q "DOM-BILL-PRORATA-001" "$plan" && pass "Architecture Impact cites the DOM" || fail "Architecture Impact cites the DOM"
[[ "$(validate "$p4")" == *"0 error"* || "$(validate "$p4")" == *"passed"* ]] && pass "plan + tasks validate" || fail "plan + tasks validate: $(validate "$p4")"

echo "=== Scenario 5: subagent-driven-development executes the hello plan ==="
p5="$(new_project)"; cp -R "$SCRIPT_DIR/fixtures/hello-plan/specs" "$p5/specs"; git -C "$p5" add -A; git -C "$p5" -c user.email=t@e -c user.name=t commit -qm plan
out="$(run_scenario "$p5" "Use kdd-superpowers:subagent-driven-development to execute specs/work/WRK-PLAN-DEMO-HELLO-001-hello-library.md. Work on this branch (I consent). Run through the final review; when finishing-a-development-branch presents its menu, choose option 3 (keep as-is) and stop.")"
(cd "$p5" && npm test >/dev/null 2>&1) && pass "hello library tests pass" || fail "hello library tests pass"
[[ -f "$p5/.kdd/sdd/WRK-PLAN-DEMO-HELLO-001/progress.md" ]] && pass "ledger under .kdd/sdd/<plan id>/" || fail "ledger under .kdd/sdd/<plan id>/ (may have been deleted after final review — then check git log)"
grep -q "^status: completed" "$p5"/specs/work/WRK-TASK-DEMO-HELLO-001-001-*.md && pass "task 001 completed" || fail "task 001 completed"
grep -q "^status: completed" "$p5"/specs/work/WRK-TASK-DEMO-HELLO-001-002-*.md && pass "task 002 completed" || fail "task 002 completed"
grep -q "^status: completed" "$p5"/specs/work/WRK-PLAN-DEMO-HELLO-001-*.md && pass "plan completed" || fail "plan completed"
git -C "$p5" log --format=%s | grep -q "WRK-TASK-DEMO-HELLO-001-001" && pass "commits carry task IDs" || fail "commits carry task IDs"
grep -q "^## Execution Log" "$p5"/specs/work/WRK-PLAN-DEMO-HELLO-001-*.md && pass "execution log persisted by finishing" || fail "execution log persisted by finishing"
grep -q "^status: completed\|^status: archived" "$p5"/specs/work/WRK-SPEC-DEMO-HELLO-001-*.md && pass "spec closed" || fail "spec closed"

echo "=== Scenario 6: code review flags an activated-rule violation as Critical ==="
p6="$(new_project)"; cp -R "$REPO_ROOT/tests/scripts/fixtures/specs" "$p6/specs"; mkdir -p "$p6/src"
printf 'export function round2(a) { return Math.floor(a * 100) / 100; }\n' > "$p6/src/billing.js"
git -C "$p6" add -A; git -C "$p6" -c user.email=t@e -c user.name=t commit -qm "feat: floor rounding"
out="$(run_scenario "$p6" "Use kdd-superpowers:requesting-code-review in mode kdd-work for WRK-SPEC-BILL-PRORATA-001: review the last commit (BASE=HEAD~1, HEAD=HEAD) with review-brief and the code-reviewer template, and paste the reviewer's full report.")"
assert_contains "$out" "Knowledge Compliance" "report has a knowledge compliance section" || FAILURES=$((FAILURES+1))
assert_contains "$out" "Critical" "violation is Critical" || FAILURES=$((FAILURES+1))
assert_contains "$out" "half-up\|Rule 3\|DOM-BILL-PRORATA-001" "names the violated rule" || FAILURES=$((FAILURES+1))

echo ""
if [[ "$FAILURES" -ne 0 ]]; then echo "FAILED: $FAILURES assertion(s)."; exit 1; fi
echo "PASS"
```

Note on Scenario 4's activation check: the fixture's spec activates only
`DOM-BILL-PRORATA-001@1.0.0`, so any task activation line that is not that
pin is outside the set — the `grep -A5 … | grep -vq` line is the check.

- [ ] **Step 3: Wire it in**

- `tests/claude-code/run-skill-tests.sh`: add `test-kdd-flow.sh` to whatever list it iterates (or note it runs only with `--integration` if the runner distinguishes; follow the existing pattern for `test-subagent-driven-development-integration.sh`).
- `tests/claude-code/README.md`: add a line for `test-kdd-flow.sh` describing the six scenarios and the isolation assumption.
- `tests/claude-code/test-helpers.sh`: replace the body of `create_test_plan` with `cp -R "$SCRIPT_DIR/fixtures/hello-plan/specs" "$project_dir/specs"; echo "$project_dir/specs/work/WRK-PLAN-DEMO-HELLO-001-hello-library.md"` (keep the function signature), and delete the old heredoc. Check `test-subagent-driven-development-integration.sh` still works with the returned path (it passes the plan path to the prompt).

- [ ] **Step 4: Run everything**

```bash
export KDD_SPEC_GRAPH="$(cd .. && pwd)/knowledge-driven-development/apps/spec-graph/spec-graph.mjs"
node "$KDD_SPEC_GRAPH" --specs tests/claude-code/fixtures/hello-plan/specs validate   # 0 errors
bash tests/scripts/run.sh                                                               # all ok
bash tests/hooks/test-session-start.sh                                                  # PASS
bash tests/claude-code/test-sdd-workspace.sh                                            # PASS
(cd tests/brainstorm-server && npm test)                                                # all suites pass
bash tests/version-bump/test-bump-version.sh && bash tests/shell-lint/test-lint-shell.sh
bash tests/claude-code/test-kdd-flow.sh                                                 # PASS (slow)
```

Expected: every command green. Scenario failures that are LLM variance
(the agent chose different wording) are fixed by tightening the prompt,
never by loosening an artifact assertion — the artifacts are the contract.
Record the run (commands, durations, any scenario re-run) in your report:
finishing will carry it into the plan's Execution Log.

- [ ] **Step 5: Commit**

```bash
git add tests/claude-code
git commit -m "test(WRK-TASK-FORK-CORE-001-019): headless KDD flow scenarios and hello-plan fixture"
```

## Acceptance Criteria

- [ ] Six scenarios pass on Claude Code with the toolkit loaded (spec AC 2, 3, 4, 5, 6, 8, 10, 11 behaviourally).
- [ ] All deterministic suites pass (spec AC 12).

## Test Plan

1. `tests/claude-code/test-kdd-flow.sh` — the six scenarios.
2. Full suite run as listed in Step 4.
