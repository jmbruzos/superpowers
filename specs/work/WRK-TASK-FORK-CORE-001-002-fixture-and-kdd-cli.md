---
id: WRK-TASK-FORK-CORE-001-002
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "Test fixture specs/, kdd-cli locator, tests/scripts runner"
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
tags: [kdd, fork, task, tooling]
---

# WRK-TASK-FORK-CORE-001-002 — Test fixture `specs/`, `kdd-cli` locator, `tests/scripts` runner

## Objective

Give every later script a validated KDD fixture to run against, one place
that knows where `spec-graph.mjs` is (`kdd-cli`, spec *Scripts* and Skill 1
search order), and a runner for the deterministic test suite.

## Implementation Notes

**Files:**
- Create: `tests/scripts/fixtures/specs/domain/DOM-BILL-PRORATA-001-pro-rata-billing.md`, `tests/scripts/fixtures/specs/work/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md`, `tests/scripts/fixtures/specs/work/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md`, `tests/scripts/fixtures/specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md`, `tests/scripts/fixtures/specs/work/WRK-TASK-BILL-PRORATA-001-002-billing-api-endpoint.md`, `tests/scripts/fixtures/specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/FRAG-BILL-ROUNDING-001.md`, `tests/scripts/fixtures/specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/report.md`
- Create: `skills/using-superpowers/scripts/kdd-cli`, `tests/scripts/lib.sh`, `tests/scripts/run.sh`, `tests/scripts/test-kdd-cli.sh`, `tests/scripts/test-fixture.sh`
- Test: `tests/scripts/test-kdd-cli.sh`, `tests/scripts/test-fixture.sh`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces:
  - `kdd-cli --path` → prints the absolute path of `spec-graph.mjs` (exit 3 + message `kdd toolkit not found` on stderr when absent); `kdd-cli <args…>` → runs `node <spec-graph.mjs> <args…>` and passes its exit code through. Every later script and the hook call the CLI only through this script (spec constraint).
  - `tests/scripts/lib.sh` functions: `pass`, `fail`, `finish` (prints PASS/FAILED and exits), `require_cli` (exports `KDD_CLI` or prints `SKIP: kdd toolkit not found` and exits 0), `make_fixture_repo` (copies the fixture into a fresh `git init` repo, commits, prints its path).
  - Fixture facts later tests rely on: `WRK-TASK-BILL-PRORATA-001-001` activates `DOM-BILL-PRORATA-001@1.0.0` (matches the file, version `1.0.0`); `WRK-TASK-BILL-PRORATA-001-002` activates `DOM-BILL-PRORATA-001@0.9.0` (**pin drift**); both tasks cite `FRAG-BILL-ROUNDING-001` in `sources`; the plan's *Architecture Impact* table has one row; the DOM's Rule 3 reads `Round to 2 decimal places, half-up.`

- [ ] **Step 1: Write the fixture files**

`tests/scripts/fixtures/specs/domain/DOM-BILL-PRORATA-001-pro-rata-billing.md`:

```markdown
---
id: DOM-BILL-PRORATA-001
type: spec
layer: domain
scope: persistent
status: active
confidence: high
version: 1.0.0
created: 2026-09-01
updated: 2026-09-01
owner: billing-team
domain: Billing
subdomain: Pro-rata
title: "Pro-rata billing calculation"
tags: [billing, pro-rata]
---

# DOM-BILL-PRORATA-001 — Pro-rata billing calculation

## Intent

Define the pro-rata amount for mid-cycle activations.

## Definition

- Rule 1: Pro-rata amount = (monthly fee / days in billing period) × remaining days.
- Rule 2: The billing period is always the calendar month.
- Rule 3: Round to 2 decimal places, half-up.

## Acceptance Criteria

- [ ] Activation on the last day of the month is charged one day.
```

`tests/scripts/fixtures/specs/work/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md`:

```markdown
---
id: WRK-SPEC-BILL-PRORATA-001
type: spec
layer: work-spec
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-10
updated: 2026-09-10
owner: billing-team
title: "Mid-cycle activation billing"
activates:
  - DOM-BILL-PRORATA-001@1.0.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-09-10T10:00:00+02:00
dependencies:
  - id: DOM-BILL-PRORATA-001
    relation: constrained-by
sources:
  - id: FRAG-BILL-ROUNDING-001
    resource: specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/
generated:
  by: claude-code/test
  at: 2026-09-10T10:00:00+02:00
stale_after: 2026-12-10T10:00:00+01:00
tags: [billing]
---

# WRK-SPEC-BILL-PRORATA-001 — Mid-cycle activation billing

## Problem Statement

Mid-cycle activations are billed a full month.

## Proposed Change

Compute the pro-rata amount per DOM-BILL-PRORATA-001.

## Knowledge Context

| Activated Spec | Role |
|---|---|
| DOM-BILL-PRORATA-001 | formula and rounding |

## Constraints

- Round to 2 decimal places, half-up (DOM-BILL-PRORATA-001, Rule 3).

## Acceptance Criteria

- [ ] Activation on day 15 of a 30-day month charges half the fee.

## Open Questions

- None.
```

`tests/scripts/fixtures/specs/work/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md`:

```markdown
---
id: WRK-PLAN-BILL-PRORATA-001
type: spec
layer: work-plan
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-11
updated: 2026-09-11
owner: billing-team
title: "Mid-cycle activation billing — implementation plan"
parent: WRK-SPEC-BILL-PRORATA-001
activates:
  - DOM-BILL-PRORATA-001@1.0.0
equips: []
activation_frozen: true
dependencies:
  - id: WRK-SPEC-BILL-PRORATA-001
    relation: implements
  - id: DOM-BILL-PRORATA-001
    relation: constrained-by
generated:
  by: claude-code/test
  at: 2026-09-11T10:00:00+02:00
stale_after: 2026-12-11T10:00:00+01:00
tags: [billing, plan]
---

# WRK-PLAN-BILL-PRORATA-001 — Implementation plan

## Approach

Add a `prorata(fee, day, daysInMonth)` function.

## Task Breakdown

| Task ID | Description | Dependencies |
|---|---|---|
| WRK-TASK-BILL-PRORATA-001-001 | prorata calculation | — |
| WRK-TASK-BILL-PRORATA-001-002 | billing API endpoint | WRK-TASK-BILL-PRORATA-001-001 |

## Architecture Impact

| Constraint | Source | Impact on plan |
|---|---|---|
| Round to 2 decimal places, half-up | DOM-BILL-PRORATA-001 | rounding helper in task 001 |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Floating point drift | Medium | Low | integer cents |

## Dependencies

- None.
```

`tests/scripts/fixtures/specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md`:

```markdown
---
id: WRK-TASK-BILL-PRORATA-001-001
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-11
updated: 2026-09-11
owner: billing-team
title: "prorata calculation"
parent: WRK-PLAN-BILL-PRORATA-001
activates:
  - DOM-BILL-PRORATA-001@1.0.0
equips: []
dependencies:
  - id: WRK-PLAN-BILL-PRORATA-001
    relation: implements
sources:
  - id: FRAG-BILL-ROUNDING-001
    resource: specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/
generated:
  by: claude-code/test
  at: 2026-09-11T10:00:00+02:00
stale_after: 2026-12-11T10:00:00+01:00
tags: [billing, task]
---

# WRK-TASK-BILL-PRORATA-001-001 — prorata calculation

## Objective

Implement `prorata(fee, day, daysInMonth)`.

## Implementation Notes

- [ ] Step 1: write the failing test.

## Acceptance Criteria

- [ ] `prorata(30, 15, 30)` returns `16.00`.

## Test Plan

1. Unit test with the example above.
```

`tests/scripts/fixtures/specs/work/WRK-TASK-BILL-PRORATA-001-002-billing-api-endpoint.md` — identical to task 001 except: every `001-001` → `001-002`, title `billing API endpoint`, the H1 accordingly, the pin `DOM-BILL-PRORATA-001@0.9.0` (deliberate drift), and the Objective line `Expose the calculation over HTTP.`:

```bash
sed -e 's/001-001/001-002/g' -e 's/prorata calculation/billing API endpoint/' \
    -e 's/DOM-BILL-PRORATA-001@1.0.0/DOM-BILL-PRORATA-001@0.9.0/' \
    -e 's/Implement `prorata(fee, day, daysInMonth)`./Expose the calculation over HTTP./' \
    tests/scripts/fixtures/specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md \
    > tests/scripts/fixtures/specs/work/WRK-TASK-BILL-PRORATA-001-002-billing-api-endpoint.md
```

`tests/scripts/fixtures/specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/report.md`:

```markdown
# Exploration report — rounding in billing

## Observed

- `src/billing.js:12-14@abc1234`: `return Math.round(amount * 100) / 100;`

## Inferred

- Rounding is half-up for positive amounts (rests on the observation above).

## Absences

- `grep -rn "ROUND_HALF_EVEN" src/` → 0 results.
```

`tests/scripts/fixtures/specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/FRAG-BILL-ROUNDING-001.md`
(the `integrity` value is `sha256:` + `sha256sum report.md`; with the report above it is
`89045314a8177fe92f669d32aec609d2dafc89c64c6e2e30eed6e1be8388ab53` — recompute if you change the report):

```markdown
---
id: FRAG-BILL-ROUNDING-001
type: fragment
layer: capture
scope: persistent
status: ingested
confidence: low
version: 1.0.0
created: 2026-09-09
updated: 2026-09-09
owner: billing-team
domain: Billing
subdomain: Pro-rata
title: "Rounding behaviour observed in billing code"
captured_at: 2026-09-09T12:00:00+02:00
source_type: report
files:
  - report.md
integrity: "sha256:89045314a8177fe92f669d32aec609d2dafc89c64c6e2e30eed6e1be8388ab53"
origin: billing-service
routed_to: []
generated:
  by: claude-code/test
  at: 2026-09-09T12:00:00+02:00
tags: [capture, billing, rounding]
---

# FRAG-BILL-ROUNDING-001 — Rounding behaviour observed in billing code

Immutable capture. See report.md for anchored observations.
```

- [ ] **Step 2: Write the shared test library and runner**

`tests/scripts/lib.sh`:

```bash
#!/usr/bin/env bash
# Shared helpers for the deterministic (no Claude) test suite under tests/scripts/.
# Source it: . "$(dirname "$0")/lib.sh"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURE_SPECS="$REPO_ROOT/tests/scripts/fixtures/specs"
KDD_CLI_SCRIPT="$REPO_ROOT/skills/using-superpowers/scripts/kdd-cli"
FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }
finish() {
  echo ""
  if [[ "$FAILURES" -ne 0 ]]; then echo "FAILED: $FAILURES assertion(s)."; exit 1; fi
  echo "PASS"
}
# Export KDD_CLI (path to spec-graph.mjs) or skip the whole test file.
require_cli() {
  if KDD_CLI="$("$KDD_CLI_SCRIPT" --path 2>/dev/null)"; then export KDD_CLI; return 0; fi
  echo "SKIP: kdd toolkit not found (set KDD_SPEC_GRAPH to spec-graph.mjs)"; exit 0
}
# Copy the fixture into a fresh git repo (specs/ at its root), commit, print the repo path.
make_fixture_repo() {
  local root; root="$(mktemp -d)"
  git init -q -b main "$root"
  cp -R "$FIXTURE_SPECS" "$root/specs"
  ( cd "$root" && git add -A && git -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -qm "fixture" )
  ( cd "$root" && git rev-parse --show-toplevel )
}
```

`tests/scripts/run.sh`:

```bash
#!/usr/bin/env bash
# Run every deterministic test under tests/scripts/ (no Claude needed).
set -uo pipefail
cd "$(dirname "$0")"
rc=0
for t in test-*.sh; do
  echo "### $t"
  if bash "$t"; then echo "### $t: ok"; else echo "### $t: FAILED"; rc=1; fi
  echo ""
done
exit $rc
```

- [ ] **Step 3: Write the failing tests for `kdd-cli`**

`tests/scripts/test-kdd-cli.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
echo "=== Test: kdd-cli ==="
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# 1. explicit override wins
printf 'console.log("override", process.argv.slice(2).join(" "))\n' > "$TMP/sg.mjs"
out="$(KDD_SPEC_GRAPH="$TMP/sg.mjs" "$KDD_CLI_SCRIPT" --path)"
[[ "$out" == "$TMP/sg.mjs" ]] && pass "--path honours KDD_SPEC_GRAPH" || { fail "--path honours KDD_SPEC_GRAPH"; echo "    got: $out"; }
out="$(KDD_SPEC_GRAPH="$TMP/sg.mjs" "$KDD_CLI_SCRIPT" --specs x stats)"
[[ "$out" == "override --specs x stats" ]] && pass "runs node <cli> with the given args" || { fail "runs node <cli> with the given args"; echo "    got: $out"; }

# 2. plugin-cache discovery under $HOME
mkdir -p "$TMP/home/.claude/plugins/cache/nfq/kdd/1.2.0/cli"
printf 'console.log("cached")\n' > "$TMP/home/.claude/plugins/cache/nfq/kdd/1.2.0/cli/spec-graph.mjs"
out="$(cd "$TMP" && env -u KDD_SPEC_GRAPH HOME="$TMP/home" "$KDD_CLI_SCRIPT" --path)"
[[ "$out" == "$TMP/home/.claude/plugins/cache/nfq/kdd/1.2.0/cli/spec-graph.mjs" ]] && pass "finds ~/.claude/plugins/**/kdd*/cli/spec-graph.mjs" || { fail "finds ~/.claude/plugins/**/kdd*/cli/spec-graph.mjs"; echo "    got: $out"; }

# 3. project-local copies win over the plugin cache
mkdir -p "$TMP/proj/.kdd-toolkit/cli"
printf 'console.log("local")\n' > "$TMP/proj/.kdd-toolkit/cli/spec-graph.mjs"
out="$(cd "$TMP/proj" && env -u KDD_SPEC_GRAPH HOME="$TMP/home" "$KDD_CLI_SCRIPT" --path)"
[[ "$out" == "$TMP/proj/.kdd-toolkit/cli/spec-graph.mjs" ]] && pass "./.kdd-toolkit/cli wins over the plugin cache" || { fail "./.kdd-toolkit/cli wins over the plugin cache"; echo "    got: $out"; }

# 4. nothing found → exit 3 and a message
rc=0; err="$(cd "$TMP" && env -u KDD_SPEC_GRAPH HOME="$TMP/empty" "$KDD_CLI_SCRIPT" --path 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 3 && "$err" == *"kdd toolkit not found"* ]] && pass "exit 3 + message when not found" || { fail "exit 3 + message when not found"; echo "    rc=$rc err=$err"; }
finish
```

- [ ] **Step 4: Run to verify it fails**

Run: `chmod +x tests/scripts/*.sh && bash tests/scripts/test-kdd-cli.sh`
Expected: FAIL (script missing: `No such file or directory`).

- [ ] **Step 5: Write `kdd-cli`**

`skills/using-superpowers/scripts/kdd-cli`:

```bash
#!/usr/bin/env bash
# Locate the kdd toolkit's spec-graph CLI. The only place in kdd-superpowers
# that knows where spec-graph.mjs lives (WRK-SPEC-FORK-CORE-001, Skill 1).
#
# Usage: kdd-cli --path              print the resolved spec-graph.mjs path
#        kdd-cli <spec-graph args>   run: node <spec-graph.mjs> <args>
# Exit 3 (and a message on stderr) when no CLI can be found.
#
# Search order:
#   1. $KDD_SPEC_GRAPH                          explicit override (dev machines, CI)
#   2. ./node_modules/.bin/spec-graph           npm-installed in the project
#   3. ./.kdd-toolkit/cli/spec-graph.mjs        toolkit vendored as a submodule
#   4. ~/.claude/plugins/**/kdd*/cli/spec-graph.mjs   plugin cache / manual clone
set -euo pipefail

resolve() {
  if [[ -n "${KDD_SPEC_GRAPH:-}" && -f "$KDD_SPEC_GRAPH" ]]; then printf '%s\n' "$KDD_SPEC_GRAPH"; return 0; fi
  if [[ -x ./node_modules/.bin/spec-graph ]]; then printf '%s\n' "$(cd ./node_modules/.bin && pwd)/spec-graph"; return 0; fi
  if [[ -f ./.kdd-toolkit/cli/spec-graph.mjs ]]; then printf '%s\n' "$(cd ./.kdd-toolkit/cli && pwd)/spec-graph.mjs"; return 0; fi
  local hit
  hit="$(find "${HOME:-/nonexistent}/.claude/plugins" -maxdepth 7 -type f -path '*kdd*/cli/spec-graph.mjs' 2>/dev/null | sort | head -1)"
  if [[ -n "$hit" ]]; then printf '%s\n' "$hit"; return 0; fi
  return 1
}

cli="$(resolve)" || { echo "kdd toolkit not found: install the kdd plugin or set KDD_SPEC_GRAPH=/path/to/spec-graph.mjs" >&2; exit 3; }

if [[ "${1:-}" == "--path" ]]; then printf '%s\n' "$cli"; exit 0; fi
case "$cli" in
  *.mjs) exec node "$cli" "$@" ;;
  *)     exec "$cli" "$@" ;;
esac
```

- [ ] **Step 6: Run the kdd-cli test**

Run: `chmod +x skills/using-superpowers/scripts/kdd-cli && bash tests/scripts/test-kdd-cli.sh`
Expected: 5 `[PASS]`, `PASS`.

- [ ] **Step 7: Write the fixture test**

`tests/scripts/test-fixture.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
echo "=== Test: fixture validates ==="
require_cli
out="$(node "$KDD_CLI" --specs "$FIXTURE_SPECS" validate 2>&1)"; rc=$?
if [[ "$rc" -eq 0 && "$out" == *"0 error(s)"* || "$out" == *"Validation passed"* ]]; then pass "fixture has 0 validation errors"; else fail "fixture has 0 validation errors"; echo "$out" | sed 's/^/    /'; fi
n="$(node "$KDD_CLI" --specs "$FIXTURE_SPECS" filter --format json | node -e 'const j=JSON.parse(require("fs").readFileSync(0,"utf8"));console.log(j.length)')"
[[ "$n" -eq 6 ]] && pass "fixture has 6 specs (1 DOM, 1 SPEC, 1 PLAN, 2 TASK, 1 FRAG)" || { fail "fixture has 6 specs"; echo "    got: $n"; }
finish
```

- [ ] **Step 8: Run it**

Run: `export KDD_SPEC_GRAPH="$(cd .. && pwd)/knowledge-driven-development/apps/spec-graph/spec-graph.mjs"; bash tests/scripts/test-fixture.sh`
Expected: 2 `[PASS]`, `PASS`. (Without the variable: `SKIP: kdd toolkit not found …`, exit 0.)

- [ ] **Step 9: Run the whole deterministic suite and commit**

Run: `bash tests/scripts/run.sh`
Expected: `test-fixture.sh: ok`, `test-invariants.sh: ok`, `test-kdd-cli.sh: ok`, exit 0.

```bash
git add tests/scripts skills/using-superpowers/scripts/kdd-cli
git commit -m "test(WRK-TASK-FORK-CORE-001-002): specs fixture, kdd-cli locator, deterministic test runner"
```

## Acceptance Criteria

- [ ] `kdd-cli --path` resolves in the four documented ways and exits 3 with a message otherwise.
- [ ] The fixture validates with `spec-graph validate` (0 errors) and contains the pin-drift task.
- [ ] `tests/scripts/run.sh` runs all three tests and exits 0.

## Test Plan

1. `tests/scripts/test-kdd-cli.sh` — 5 assertions (override, run-through, cache discovery, local precedence, not-found).
2. `tests/scripts/test-fixture.sh` — validation + spec count (skips without CLI).
