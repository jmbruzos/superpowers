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
must_contain skills/kdd-conventions/SKILL.md "scripts/transition" "kdd-conventions cites transition"
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
must_contain skills/brainstorming/SKILL.md "scripts/transition" "brainstorming transitions via the script"
must_not_contain skills/brainstorming/SKILL.md "docs/" "no docs/ paths left"
must_contain skills/brainstorming/spec-adversary-prompt.md "| Attack | Scenario | Result | Cause | Evidence |" "A1 prompt uses the design-gate table"
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
must_contain skills/writing-plans/SKILL.md "scripts/transition" "writing-plans transitions via the script"
must_not_contain skills/writing-plans/SKILL.md "Global Constraints" "no Global Constraints header left"
must_contain skills/writing-plans/plan-adversary-prompt.md "| Attack | Scenario | Result | Cause | Evidence |" "A2 prompt uses the design-gate table"

# --- subagent-driven-development (Task 013) ---
must_contain skills/subagent-driven-development/SKILL.md "scripts/task-brief TASK_FILE" "task-brief takes a WRK-TASK file"
must_contain skills/subagent-driven-development/SKILL.md ".kdd/sdd/<WRK-PLAN-ID>/" "workspace keyed by plan id"
must_contain skills/subagent-driven-development/SKILL.md "Knowledge gap:" "knowledge-gap rulings"
must_contain skills/subagent-driven-development/SKILL.md "PIN DRIFT" "pin drift handled"
must_contain skills/subagent-driven-development/SKILL.md "scripts/transition" "SDD transitions via the script"
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
must_contain skills/executing-plans/SKILL.md "scripts/transition" "executing-plans transitions via the script"
must_contain skills/executing-plans/SKILL.md "status: completed" "executing-plans completes tasks"
must_contain skills/executing-plans/SKILL.md ".kdd/sdd/<WRK-PLAN-ID>/progress.md" "executing-plans ledger path"

# --- verification-before-completion (Task 017) ---
must_contain skills/verification-before-completion/SKILL.md "spec-graph validate" "validate as evidence"
must_contain skills/verification-before-completion/SKILL.md "frag-cite-check" "cite-check as evidence"
must_contain skills/verification-before-completion/SKILL.md "export-okf" "OKF export as evidence"
must_contain skills/verification-before-completion/SKILL.md "the file with its version is what counts" "spec red flag"

# --- code review (Task 015) ---
must_contain skills/requesting-code-review/SKILL.md "scripts/review-brief" "mode 1 uses review-brief"
must_contain skills/requesting-code-review/SKILL.md "kdd:spec-context" "mode 2 uses spec-context"
must_contain skills/requesting-code-review/SKILL.md "Pure brownfield" "mode 3 exists"
must_contain skills/requesting-code-review/SKILL.md "{KNOWLEDGE_BRIEF}" "knowledge brief placeholder"
must_contain skills/requesting-code-review/code-reviewer.md "### Knowledge Compliance" "reviewer outputs knowledge verdict"
must_contain skills/requesting-code-review/code-reviewer.md "### Capture Candidates" "reviewer outputs capture candidates"
must_contain skills/requesting-code-review/code-reviewer.md "Gate A5" "A5 before merge"
must_contain skills/requesting-code-review/code-reviewer.md "test that guards it" "A3 contract"
must_contain skills/receiving-code-review/SKILL.md "## When Feedback Conflicts With Knowledge" "receiving: knowledge rule"

# --- finishing-a-development-branch (Task 016) ---
must_contain skills/finishing-a-development-branch/SKILL.md "## Step 1b: Verify Knowledge Integrity" "knowledge integrity step"
must_contain skills/finishing-a-development-branch/SKILL.md "export-okf" "OKF export as evidence"
must_contain skills/finishing-a-development-branch/SKILL.md "## Execution Log" "execution log persisted"
must_contain skills/finishing-a-development-branch/SKILL.md "kdd:spec-consolidate" "consolidation wired"
must_contain skills/finishing-a-development-branch/SKILL.md "frag-adversary-prompt.md" "gate A6 wired"
must_contain skills/finishing-a-development-branch/SKILL.md "pending consolidation" "deferred consolidation state"
must_contain skills/finishing-a-development-branch/SKILL.md "archived" "archive transition"
must_contain skills/finishing-a-development-branch/frag-adversary-prompt.md "| Attack | Scenario | Result | Evidence |" "A6 prompt uses the attack table"

# --- docs (Task 018) ---
must_contain README.md "# kdd-superpowers" "README title"
must_contain README.md "/plugin install kdd-superpowers" "README install command"
must_contain README.md "Requires the \`kdd\` toolkit plugin" "README states the dependency"
must_contain README.md "derived from" "README attributes upstream"
must_not_contain README.md "Visual companion telemetry" "README has no telemetry section"
must_contain CLAUDE.md "P13" "CLAUDE.md lists the principles"
must_contain CLAUDE.md "tests/scripts/run.sh" "CLAUDE.md says how to test"
must_not_contain CLAUDE.md "94% PR rejection rate" "CLAUDE.md is no longer upstream's PR policy"
must_contain LICENSE "obra/superpowers" "LICENSE carries the derivation note"

# --- final review wave (chronicle lifecycle, bounded finishing, requirements verdict) ---
must_not_contain skills/subagent-driven-development/SKILL.md "rm -rf <workspace>" "SDD does not delete the workspace"
must_contain skills/finishing-a-development-branch/SKILL.md "rm -rf .kdd/sdd/<WRK-PLAN-ID>/" "finishing deletes the workspace after the execution log"
must_contain skills/finishing-a-development-branch/SKILL.md "Bounded work" "finishing handles bounded work"
must_contain skills/finishing-a-development-branch/SKILL.md "scripts/transition" "finishing transitions via the script"
must_contain skills/executing-plans/SKILL.md "main/master" "executing-plans keeps the main-branch guard"
must_contain skills/requesting-code-review/code-reviewer.md "### Requirements Compliance" "code reviewer has a requirements verdict"

# --- adversarial gate tuning (WRK-TASK-FORK-GATES-001-001) ---
must_contain skills/kdd-conventions/references/adversarial-gates.md "## Design gates (A1, A2): cause, detail cap, persisted table" "design-gate addendum"
must_contain skills/kdd-conventions/references/adversarial-gates.md "| Attack | Scenario | Result | Cause | Evidence |" "design gates add a Cause column"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`code-reality\`" "cause: code-reality defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`spec-rule\`" "cause: spec-rule defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`ambiguity\`" "cause: ambiguity defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`knowledge-gap\`" "cause: knowledge-gap defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "\`internal\`" "cause: internal defined"
must_contain skills/kdd-conventions/references/adversarial-gates.md "At most 3 full rows per attack" "detail cap"
must_contain skills/kdd-conventions/references/adversarial-gates.md "+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>" "one-line overflow keeps every BROKEN finding"
must_contain skills/kdd-conventions/references/adversarial-gates.md "| Attack | Cause | Evidence | Ruling |" "persisted BROKEN table"
must_contain skills/kdd-conventions/references/adversarial-gates.md "the written WRK-SPEC, after its self-review" "A1 attacks the written spec"
must_contain skills/kdd-conventions/references/artifact-templates.md "## Code Premises" "WRK-SPEC template has Code Premises"
must_contain skills/kdd-conventions/references/artifact-templates.md "| Premise | Listed | Verified by | Result |" "Code Premises table"
must_contain skills/kdd-conventions/references/artifact-templates.md "| Attack | Cause | Evidence | Ruling |" "templates persist the BROKEN table"
must_not_contain skills/kdd-conventions/references/artifact-templates.md "one line per BROKEN attack — attack · ruling" "one-liner persistence replaced"

# --- A1 prompt (WRK-TASK-FORK-GATES-001-002) ---
must_contain skills/brainstorming/spec-adversary-prompt.md "[WRK_SPEC_PATH]" "A1 attacks the written WRK-SPEC"
must_not_contain skills/brainstorming/spec-adversary-prompt.md "DRAFT_PATH" "A1 has no draft input"
must_contain skills/brainstorming/spec-adversary-prompt.md "## Code Premises" "A1 re-verifies Code Premises"
must_contain skills/brainstorming/spec-adversary-prompt.md "premises re-verified: <N> hold" "A1 summarizes premises that hold"
must_contain skills/brainstorming/spec-adversary-prompt.md "At most 3 full rows per attack" "A1 detail cap"
must_contain skills/brainstorming/spec-adversary-prompt.md "+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>" "A1 lists every further BROKEN finding"
must_contain skills/brainstorming/spec-adversary-prompt.md "(code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)" "A1 closing line breakdown"

# --- brainstorming order (WRK-TASK-FORK-GATES-001-003) ---
if grep -rqF -- "-draft.md" "$REPO_ROOT/skills/brainstorming"; then fail "brainstorming has no A1 draft file"; else pass "brainstorming has no A1 draft file"; fi
sr_line=$(grep -nF '**Spec self-review**' "$REPO_ROOT/skills/brainstorming/SKILL.md" | head -1 | cut -d: -f1)
a1_line=$(grep -nF '**Gate A1 — spec red-team**' "$REPO_ROOT/skills/brainstorming/SKILL.md" | head -1 | cut -d: -f1)
if [[ -n "$sr_line" && -n "$a1_line" && "$sr_line" -lt "$a1_line" ]]; then pass "self-review precedes gate A1"; else fail "self-review precedes gate A1 (self-review:$sr_line A1:$a1_line)"; fi
must_contain skills/brainstorming/SKILL.md "gate A1 on the written spec" "path bullet states the new order"
must_contain skills/brainstorming/SKILL.md "run gate A1 again" "A1 re-run rule"
must_contain skills/brainstorming/SKILL.md "only after gate A1 is adjudicated" "architectural commit waits for A1"
must_contain skills/brainstorming/SKILL.md "Adjudicate every \`BROKEN\` finding — full rows and one-liners" "A1 one-liners are adjudicated too"
must_contain skills/brainstorming/SKILL.md "\"Gate A1 on the written spec; adjudicate; commit\"" "dot flow has the new A1 node"

# --- code premises (WRK-TASK-FORK-GATES-001-004) ---
must_contain skills/brainstorming/premise-verifier-prompt.md "Premise verifier: " "verifier dispatch description"
must_contain skills/brainstorming/premise-verifier-prompt.md "model: [mid tier — REQUIRED]" "verifier is mid tier"
must_contain skills/brainstorming/premise-verifier-prompt.md "Work read-only. Do not modify files, do not commit, do not dispatch subagents." "verifier is read-only"
must_contain skills/brainstorming/premise-verifier-prompt.md "| Premise | Listed | Verified by | Result |" "verifier returns the premises table"
must_contain skills/brainstorming/premise-verifier-prompt.md "\`unverifiable\`" "verifier can say unverifiable"
must_contain skills/brainstorming/SKILL.md "premise-verifier-prompt.md" "brainstorming dispatches the verifier"
must_contain skills/brainstorming/SKILL.md "**Code premises**" "design has a Code premises section"
must_contain skills/brainstorming/SKILL.md "none — no existing code" "greenfield wording"
must_contain skills/brainstorming/SKILL.md "\"The specs cover it, I don't need to read the code\"" "premises red flag"
must_contain skills/brainstorming/SKILL.md "→ Code Premises" "WRK-SPEC body order includes Code Premises"

# --- writing-plans and A2 (WRK-TASK-FORK-GATES-001-005) ---
must_contain skills/writing-plans/SKILL.md "*Code Premises*" "writing-plans reads the spec's Code Premises"
must_contain skills/writing-plans/SKILL.md "**Premises:**" "WRK-TASK states its own premises"
must_contain skills/writing-plans/SKILL.md "| Attack | Cause | Evidence | Ruling |" "A2 persists the BROKEN table"
must_contain skills/kdd-conventions/references/artifact-templates.md "**Premises:**" "WRK-TASK template has Premises"
must_contain skills/writing-plans/plan-adversary-prompt.md "7. Code premise:" "A2 attack 7"
must_contain skills/writing-plans/plan-adversary-prompt.md "At most 3 full rows per attack" "A2 detail cap"
must_contain skills/writing-plans/plan-adversary-prompt.md "+ <attack #> · <scenario in one sentence> · <Cause> · <evidence path:lines>" "A2 lists every further BROKEN finding"
must_contain skills/writing-plans/plan-adversary-prompt.md "(code-reality a · spec-rule b · ambiguity c · knowledge-gap d · internal e)" "A2 closing line breakdown"
must_contain skills/writing-plans/SKILL.md "more than 4 tasks; the spec activates a spec with \`confidence: low\` or no \`verified\`; the work touches security, money or regulatory logic" "A2 trigger unchanged"

# --- gates hold their findings (WRK-TASK-FORK-GATES-002-001) ---
must_contain skills/brainstorming/premise-verifier-prompt.md "[DESIGN_FILE" "verifier reads the design file"
must_contain skills/brainstorming/premise-verifier-prompt.md "not what the design will change" "verifier extracts claims about today, not proposals"
must_contain skills/brainstorming/premise-verifier-prompt.md "\`unlisted\`" "verifier marks unlisted claims"
must_contain skills/brainstorming/SKILL.md ".kdd/brainstorm/<topic>-design.md" "brainstorming hands the design file to the verifier"
must_contain skills/brainstorming/SKILL.md "is in \`.gitignore\`" "design file written only once .kdd/ is ignored"
must_contain skills/brainstorming/SKILL.md "| Premise | Listed | Verified by | Result |" "brainstorming names the four-column table"
must_contain skills/brainstorming/SKILL.md "dispatch the verifier again on the changed statements only" "re-verification after a design change"
must_contain skills/brainstorming/SKILL.md "unlisted claims verified: <N> hold" "unlisted holds summarised"
must_contain skills/brainstorming/SKILL.md "\"The gate runs in the background — I'll wrap up and rule when it reports\"" "pending-gate red flag"
must_contain skills/brainstorming/SKILL.md "Wait for its table before any next step" "brainstorming waits for its gates"
must_contain skills/brainstorming/SKILL.md "rejected only with a permitting quote" "A1 applies the permitting-quote rule"
must_contain skills/brainstorming/SKILL.md "attack on an activated rule changes the design" "P10: a broken rule attack still changes the design"
must_contain skills/writing-plans/SKILL.md "Wait for its table before any next step" "writing-plans waits for A2"
must_contain skills/writing-plans/SKILL.md "rejected only with a permitting quote" "A2 applies the permitting-quote rule"
must_contain skills/subagent-driven-development/SKILL.md "Never end your turn while a child you dispatched is still running" "SDD never ends a turn with live children"
must_contain skills/kdd-conventions/references/adversarial-gates.md "**Dispatched gates are synchronous.**" "synchronous-gate rule"
must_contain skills/kdd-conventions/references/adversarial-gates.md "In a non-interactive run, ending the turn ends the run" "non-interactive clause"
must_contain skills/kdd-conventions/references/adversarial-gates.md "Rejecting a \`spec-rule\` finding" "permitting-quote rule section"
must_contain skills/kdd-conventions/references/adversarial-gates.md "a narrower reading of the violated rule" "narrower reading excluded"
must_contain skills/kdd-conventions/references/adversarial-gates.md "the violated rule quoted back" "violated rule quoted back excluded"
must_contain skills/kdd-conventions/references/adversarial-gates.md "Knowledge gap: contested rule —" "contested-rule gap prefix"
must_contain skills/kdd-conventions/references/adversarial-gates.md "Knowledge gap: conflict —" "conflict gap prefix"
must_contain skills/kdd-conventions/references/adversarial-gates.md "rejected → <ID> § <section> \"<literal>\"" "permitting-quote ruling format"
must_contain skills/kdd-conventions/references/artifact-templates.md "unlisted claims verified: <N> hold" "template summarises unlisted holds"
must_contain skills/kdd-conventions/SKILL.md ".kdd/brainstorm/<topic>-design.md" "locations table lists the design file"
finish
