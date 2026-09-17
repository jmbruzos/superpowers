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

finish
