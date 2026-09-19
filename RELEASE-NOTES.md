# Release notes

## 0.2.0 — transition script and token-usage measurement

Implements WRK-SPEC-FORK-TOKENS-001 (token footprint):
- `kdd-conventions/scripts/transition FILE STATUS [--verified human:<id>] [--no-commit]` —
  one-step status move (status, updated, human verified, validate, conventional commit),
  restricted to the transitions of the conventions table; named at every status move in
  brainstorming, writing-plans, subagent-driven-development, executing-plans and finishing.
- `KDD_FLOW_USAGE=<dir>` on `tests/claude-code/test-kdd-flow.sh` — per-scenario token usage
  (JSON, transcripts, summary table); `KDD_FLOW_SCENARIOS` runs a subset; credentials are
  re-copied per scenario.
- `DOC-FORK-TOKENS-001` and `FRAG-FORK-TOKENS-001` — where the tokens go and the two
  measured runs behind it.

## 0.1.0 — first release of kdd-superpowers

Derived from superpowers v6.3.0 (obra/superpowers, commit b36e082). Claude Code only.
Implements WRK-SPEC-FORK-CORE-001 (sub-project 1: core flow): KDD work artifacts with
frozen activation, deterministic briefs, knowledge-compliance review, adversarial gates
A1–A6, brownfield capture with anchored claims, consolidation at finish, OKF conformance
by construction. Upstream's release history is in this repository's git log before
this commit.
