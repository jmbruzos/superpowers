# Release notes

## 0.4.0 — gates hold their findings

Implements WRK-SPEC-FORK-GATES-002, from the superpowers-vs-kdd-superpowers
study (FRAG-FORK-GATES-003: a run ended while gate A2 was still in the
background, and a `spec-rule` finding was rejected by narrowing the rule):
- **Dispatched gates are synchronous** (`adversarial-gates.md`): A1, A2, A4,
  A6 and the premise verifier are waited for; in a non-interactive run,
  ending the turn ends the run. brainstorming gains the Red Flags row "The
  gate runs in the background — I'll wrap up and rule when it reports";
  writing-plans says the same at A2, and subagent-driven-development's
  waiting rule forbids ending a turn with a live child.
- **Rejecting a `spec-rule` finding (A1, A2) needs a permitting quote** from an
  activated spec or a constrained-by principle that explicitly scopes the
  violated rule, recorded as
  `rejected → <ID> § <section> "<literal>"`. The WRK-SPEC or WRK-PLAN itself,
  a narrower reading of the violated rule, or the rule quoted back do not
  count. Without such a quote the finding is accepted; a disputed rule is
  recorded as `Knowledge gap: contested rule — …`, and two contradicting
  activated rules as `Knowledge gap: conflict — …`.
- **The premise verifier also checks unlisted claims.** Before dispatching
  it, brainstorming saves the approved sections to
  `.kdd/brainstorm/<topic>-design.md`. The verifier extracts every other
  statement about today's code from that file. Its table and `## Code
  Premises` gain a `Listed` column; `## Code Premises` keeps only the listed
  premises plus the unlisted claims that failed, then the line
  "unlisted claims verified: <N> hold".
- `test-kdd-flow.sh` scenario 7 checks the following: the design file is
  written before the verifier dispatch, gate A1 is dispatched, and the
  verifier's own reply carries the Listed column.
- **Cost** (FRAG-FORK-TOKENS-003, scenario 7, n = 2 per side): +8 % cost and
  +14 % wall time. The two sides' ranges do not overlap.
- **Quality** (FRAG-FORK-GATES-004, the FRAG-FORK-GATES-003 task, n = 2):
  - Both 0.4.0 runs accepted gate A1's manual-merge-survivor finding and
    changed the design, and both got it right (H1). All five earlier runs
    had got it wrong.
  - Blind hard points were 8 and 9, against 5–9 for 0.3.0 and 6–7 for
    superpowers 6.3.0.
  - No `spec-rule` finding was rejected.
  - Accepting a contested finding can move the error: K4 dropped the
    orphan's update event and lost cross-pod cache invalidation (H6), which
    all five earlier runs had right; K5 kept the event and lost H10,
    recording the two rules' conflict instead of resolving it.
  - Cost did not rise on this task: mean $18.68 against $19.18 for 0.3.0.

## 0.3.0 — adversarial gates A1/A2 tuned

Implements WRK-SPEC-FORK-GATES-001, from an audit of three executed plans
(FRAG-FORK-GATES-001: 46 % of A1's recorded BROKEN findings were unchecked
premises about existing code):
- brainstorming lists the design's *Code premises* and checks them with a
  mid-tier read-only verifier (`premise-verifier-prompt.md`) before gate A1;
  the WRK-SPEC gains `## Code Premises`; writing-plans reads them and each
  WRK-TASK states any further premise on a `**Premises:**` line.
- Gate A1 attacks the written, self-reviewed WRK-SPEC (no draft file); the
  commit follows adjudication; A1 re-runs when the human review changes
  substance.
- A1 and A2 tables carry a Cause (`code-reality`, `spec-rule`, `ambiguity`,
  `knowledge-gap`, `internal`), at most 3 full rows per attack with every
  further BROKEN finding as a one-liner (all adjudicated), and a closing line
  with the breakdown; `## Adversarial Review` persists every BROKEN finding
  as `| Attack | Cause | Evidence | Ruling |`. A2 gains attack 7 *Code
  premise*. A3–A6 unchanged.
- `test-kdd-flow.sh` scenario 7 runs the architectural path headless.
- Cost before/after: FRAG-FORK-TOKENS-002 — on scenario 4 (a trivial 2-task
  plan, 3 runs per side), the before/after difference in cost ($1.87 to
  $2.12) and output tokens (58.1k to 62.0k) is smaller than the before
  side's own run-to-run spread ($1.53-$2.06, 44.9k-68.4k), so this
  measurement does not show a token saving or cost from the gate tuning at
  this task size.

## 0.2.1 — transition delegates to the toolkit

Implements WRK-SPEC-FORK-TRANSITION-001: `kdd-conventions/scripts/transition` calls
`spec-graph transition` when the resolved toolkit has it (kdd >= 1.4.0) and keeps the
built-in frontmatter rewrite as fallback for older toolkits (one-line notice on stderr).
Same interface, outputs and exit codes; `TRANSITION_TRACE=1` prints the mode.

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
