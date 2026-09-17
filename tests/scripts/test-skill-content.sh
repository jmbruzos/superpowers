#!/usr/bin/env bash
# Structural checks on skill prose: the anchors later skills and prompts rely on exist.
# Later tasks append their own `must_contain` lines below the marker.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
echo "=== Test: skill content ==="
must_contain() { # FILE 'text' 'name'
  if [[ -f "$REPO_ROOT/$1" ]] && grep -qF -- "$2" "$REPO_ROOT/$1"; then pass "$3"; else fail "$3 ($1 lacks: $2)"; fi
}
must_not_contain() {
  if [[ -f "$REPO_ROOT/$1" ]] && grep -qF -- "$2" "$REPO_ROOT/$1"; then fail "$3 ($1 still has: $2)"; else pass "$3"; fi
}

# --- kdd-conventions (Task 009) ---
must_contain skills/kdd-conventions/SKILL.md "name: kdd-conventions" "kdd-conventions skill exists"
must_contain skills/kdd-conventions/SKILL.md "number last" "ID rule: number last"
must_contain skills/kdd-conventions/SKILL.md "scripts/next-id" "SKILL cites next-id"
must_contain skills/kdd-conventions/SKILL.md "human:<id>" "actor convention documented"
must_contain skills/kdd-conventions/SKILL.md "never verifies its own output" "writer ≠ confirmer rule"
must_contain skills/kdd-conventions/SKILL.md ".kdd/" "runtime root .kdd/"
must_contain skills/kdd-conventions/references/artifact-templates.md "activation_frozen: true" "WRK-SPEC template freezes activation"
must_contain skills/kdd-conventions/references/artifact-templates.md "## Compact WRK-SPEC" "compact WRK-SPEC template"
must_contain skills/kdd-conventions/references/artifact-templates.md "## Architecture Impact" "WRK-PLAN template has Architecture Impact"
must_contain skills/kdd-conventions/references/artifact-templates.md "source_type: report" "FRAG template uses source_type report"
must_contain skills/kdd-conventions/references/capturing-from-code.md "No anchor, no claim" "P12 rule 1"
must_contain skills/kdd-conventions/references/capturing-from-code.md "## Observed" "observed section"
must_contain skills/kdd-conventions/references/capturing-from-code.md "## Inferred" "inferred section"
must_contain skills/kdd-conventions/references/capturing-from-code.md "frag-cite-check" "cite-check is mandatory"
must_contain skills/kdd-conventions/references/capturing-from-code.md "characterization test" "characterization tests"
must_contain skills/kdd-conventions/references/adversarial-gates.md "| Attack | Scenario | Result | Evidence |" "attack table contract"
must_contain skills/kdd-conventions/references/adversarial-gates.md "Attack: " "ledger line format"
must_contain skills/kdd-conventions/references/adversarial-gates.md "A6" "gates A1–A6 listed"
# --- later tasks append below this line ---
# --- using-superpowers (Task 010) ---
must_contain skills/using-superpowers/SKILL.md "## Your KDD Environment" "KDD environment section"
must_contain skills/using-superpowers/SKILL.md "toolkit: NOT FOUND" "handles missing toolkit"
must_contain skills/using-superpowers/SKILL.md "kdd:spec-graph import-okf --dry-run" "offers OKF import"
must_contain skills/using-superpowers/SKILL.md "kdd:spec-create" "routes knowledge specs to the toolkit"
must_contain skills/using-superpowers/SKILL.md "Activation is an auditable record" "activation red flag"
must_not_contain skills/using-superpowers/SKILL.md "## Platform Adaptation" "platform adaptation removed"
must_not_contain skills/using-superpowers/SKILL.md "references/codex-tools.md" "no dangling reference links"

# --- brainstorming (Task 011) ---
must_contain skills/brainstorming/SKILL.md "kdd:spec-context" "brainstorming discovers via spec-context"
must_contain skills/brainstorming/SKILL.md "compact WRK-SPEC" "bounded path writes a compact WRK-SPEC"
must_contain skills/brainstorming/SKILL.md "Knowledge activation" "knowledge activation design section"
must_contain skills/brainstorming/SKILL.md "activation_frozen: true" "activation is frozen"
must_contain skills/brainstorming/SKILL.md "spec-adversary-prompt.md" "gate A1 wired"
must_contain skills/brainstorming/SKILL.md "capturing-from-code.md" "brownfield capture wired"
must_contain skills/brainstorming/SKILL.md "verified:" "records human verification on approval"
must_contain skills/brainstorming/SKILL.md "draft → active" "status transition on approval"
must_not_contain skills/brainstorming/SKILL.md "docs/" "no docs/ paths left"
must_contain skills/brainstorming/spec-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A1 prompt uses the attack table"
must_not_contain skills/brainstorming/scripts/server.cjs "primeradiant" "companion has no upstream brand URL"
must_not_contain skills/brainstorming/scripts/server.cjs "TELEMETRY" "companion has no telemetry switch"
must_contain skills/brainstorming/scripts/frame-template.html "<title>kdd-superpowers Brainstorming</title>" "companion title renamed"

# --- writing-plans (Task 012) ---
must_contain skills/writing-plans/SKILL.md "status: active" "requires an active WRK-SPEC"
must_contain skills/writing-plans/SKILL.md "one WRK-TASK file per task" "one file per task"
must_contain skills/writing-plans/SKILL.md "WRK-TASK-<path>-<PPP>-<TTT>" "task ID scheme"
must_contain skills/writing-plans/SKILL.md "## Architecture Impact" "Architecture Impact replaces Global Constraints"
must_contain skills/writing-plans/SKILL.md "activates nothing the spec does not" "task activation subset rule"
must_contain skills/writing-plans/SKILL.md "plan-adversary-prompt.md" "gate A2 wired"
must_contain skills/writing-plans/SKILL.md "Activation coverage" "self-review checks activation"
must_contain skills/writing-plans/SKILL.md ".kdd/sdd/" "workspace path named"
must_not_contain skills/writing-plans/SKILL.md "Global Constraints" "no Global Constraints header left"
must_contain skills/writing-plans/plan-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A2 prompt uses the attack table"

# --- subagent-driven-development (Task 013) ---
must_contain skills/subagent-driven-development/SKILL.md "scripts/task-brief TASK_FILE" "task-brief takes a WRK-TASK file"
must_contain skills/subagent-driven-development/SKILL.md ".kdd/sdd/<WRK-PLAN-ID>/" "workspace keyed by plan id"
must_contain skills/subagent-driven-development/SKILL.md "Knowledge gap:" "knowledge-gap rulings"
must_contain skills/subagent-driven-development/SKILL.md "PIN DRIFT" "pin drift handled"
must_contain skills/subagent-driven-development/SKILL.md "status: completed" "task completion transition"
must_contain skills/subagent-driven-development/SKILL.md "test-adversary-prompt.md" "gate A4 wired"
must_contain skills/subagent-driven-development/SKILL.md "Gate A5" "gate A5 in final review"
must_not_contain skills/subagent-driven-development/SKILL.md "Global Constraints" "no Global Constraints left"
must_contain skills/subagent-driven-development/implementer-prompt.md "their rules are requirements" "implementer treats knowledge as requirements"
must_contain skills/subagent-driven-development/implementer-prompt.md "Knowledge notes" "implementer reports knowledge notes"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "## Part 2: Knowledge Compliance" "reviewer has knowledge compliance part"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "### Knowledge Compliance" "reviewer outputs knowledge verdict"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "### Capture Candidates" "reviewer outputs capture candidates"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "test that guards it" "gate A3 contract"
must_not_contain skills/subagent-driven-development/task-reviewer-prompt.md "[GLOBAL_CONSTRAINTS]" "no global-constraints placeholder"
must_contain skills/subagent-driven-development/test-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A4 prompt uses the attack table"
must_contain skills/subagent-driven-development/SKILL.md "any of the three verdicts" "review requires all three verdicts"
must_contain skills/subagent-driven-development/task-reviewer-prompt.md "returns three verdicts" "reviewer summary names three verdicts"
must_not_contain skills/subagent-driven-development/SKILL.md "the global constraints" "no lowercase global-constraints leftover"

# --- executing-plans (Task 014) ---
must_contain skills/executing-plans/SKILL.md "scripts/task-brief" "executing-plans uses task-brief"
must_contain skills/executing-plans/SKILL.md "Knowledge gap:" "executing-plans ledgers knowledge gaps"
must_contain skills/executing-plans/SKILL.md "status: completed" "executing-plans completes tasks"
must_contain skills/executing-plans/SKILL.md ".kdd/sdd/<WRK-PLAN-ID>/progress.md" "executing-plans ledger path"

finish
