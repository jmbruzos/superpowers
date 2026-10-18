# Upstream sync — decision log

Decisions taken while syncing superpowers 6.4.1–7.0.0 and toolkit 1.13
(DOC-FORK-UPSTREAM-001), most recent last. From 2026-10-18 the work runs
unattended at the human's request; every call below `U-` was taken by the
agent and is waiting for review. Tie-breaks the human set: traceability and
precision over speed; simplicity over over-engineering; KDD over upstream.

Each entry: **id · date · batch** — decision — why — what it costs if wrong
— where it is recorded.

## Taken with the human (before unattended mode)

- **H-1 · 2026-10-18** — integrate in batches, one WRK-SPEC each; measure
  each against the current fork. — `DOC-FORK-UPSTREAM-001`.
- **H-2 · 2026-10-18** — Native keeps every SDD gate before a task is marked
  complete (D1.1 c, D1.2 i). — DOC-FORK-UPSTREAM-001 §3.4.
- **H-3 · 2026-10-18** — orchestrator → batch 3; spec-ask/spec-tui row →
  batch 4; TDD and code-reviewer additions stay in batch 1 (D3). — §2.
- **H-4 · 2026-10-18** — WRK-SPEC-FORK-MODS-002 discarded, moved to
  `.kdd/discarded/`; no batch waits on it. — WRK-SPEC-FORK-UPSTREAM-001
  Adversarial Review.
- **H-5 · 2026-10-18** — policy and protocol as knowledge
  (DOC-FORK-UPSTREAM-001); the umbrella ID reused for batch 0. — `7cce646`,
  `4abff11`.
- **H-6 · 2026-10-18** — fix the scenario-4 fixture contradiction and
  re-run scenario 4 for the baseline. — `16bc221`.

## Taken unattended (review these)

- **U-1 · 2026-10-18 · all** — Specs written unattended move `draft →
  active` **without** a `verified` entry, and stay `confidence: low`. — P6:
  `verified` is only recorded for a human who confirmed *this* artifact; an
  instruction to work unattended is not that. — If you wanted me to verify
  on your behalf, each spec needs one `transition --verify-only`. — this log;
  each spec's frontmatter.
- **U-2 · 2026-10-18 · all** — Nothing outward-facing: no push, no merge to
  `main`, no publish of the marketplace. Release tags are created locally
  only. — The instruction covers decisions, not publishing. — You push and
  merge when you have reviewed. — this log.
- **U-3 · 2026-10-18 · 0** — `79d6e82` restored the `.gitignore` that
  `21e7e26` ("ig", author `t <t@e>`) had reduced to one line. — It broke
  `test-invariants.sh`; the author is the identity `test-kdd-flow.sh` gives
  its temporary projects, so the commit is almost certainly a headless run
  that wrote into this checkout. Root cause not reproduced. — If the change
  was yours, revert `79d6e82`. — commit message.
- **U-4 · 2026-10-18 · 0** — `shellcheck` is not installed, so
  `scripts/lint-shell.sh` was not run on the new scripts (AC2 part); `bash -n`
  passes. I do not install tools unattended. — `! brew install shellcheck`
  and run `bash scripts/lint-shell.sh tests/claude-code/ab/run-one.sh
  tests/claude-code/toolkit-env.sh`. — `c4b64f1`.
- **U-5 · 2026-10-18 · 0** — Release 0.6.1 committed and tagged (`d99d696`)
  before the baseline finished; `FRAG-FORK-UPSTREAM-001` lands after the tag.
  — The tag is the before arm of batch 1 and must hold only batch-0 harness
  changes; the FRAG is data, not part of the arm. — None expected; if you
  want the FRAG inside 0.6.1, move the tag. — `d99d696`.
- **U-6 · 2026-10-18 · 1** — Batch 1 design approved by me (bounded path,
  compact WRK-SPEC-FORK-UPSTREAM-002), with these calls:
  - the dev-path item of the batch-1 row was already done in batch 0
    (`90eb8fa`), so it is not repeated;
  - `code-reviewer.md` gets one KDD sentence per upstream section — an
    activated rule binds as written and a reasonable person's expectation
    fills only silence; the dispatching session rules on "Declined to judge"
    (KDD over upstream: P5);
  - `transition --verify-only` has no built-in fallback for toolkits < 1.13
    (simplicity; the toolkit owns the move, P4);
  - the hook prints `unavailable (no PATH at session start)` from batch 1,
    but the using-superpowers row that tells the agent what to do with it
    stays in batch 4, as DOC-FORK-UPSTREAM-001 §2 says — a rare case
    (broken PATH) runs a few releases without that row;
  - measured at level 1 only, decided on "no check regresses"; cost reported.
  — Cost if wrong: a reworded section or one more release. —
  WRK-SPEC-FORK-UPSTREAM-002.
- **U-7 · 2026-10-18 · 0** — Two harness defects found by the baseline,
  fixed after the 0.6.1 tag: the scenario-4 fixture contradiction (`16bc221`,
  H-6) and piped `grep -q` under `pipefail` (`40e4673`), which scored
  scenario 5's task-ID and execution-log checks as failures although the
  project had both commits (checked by hand in the run-1 project). The
  protocol copies the current harness into every before arm, so the fixes
  apply to both sides; scenarios 4 and 5 of the baseline are re-run (n=2) on
  the fixed harness, and the first runs' figures for them are kept in the
  FRAG as superseded, not averaged. — Precision over speed. — About $5.
  — FRAG-FORK-UPSTREAM-001.
- **U-8 · 2026-10-18 · 1** — Rulings on the batch-1 code review (opus
  reviewer, `98ad282..2c44b96`, verdict "With fixes", 0 Critical):
  - Important 1 (empty PATH runs `./cat` and friends from the project) —
    fixed in `8279228`: an empty, `.` or relative PATH element marks the PATH
    broken and no command is looked up. Consequence, accepted: a user whose
    real PATH contains `.` or `::` gets `unavailable` lines instead of the
    probe (security over convenience; your PATH has neither).
  - Minor 1 (probe guard list differs from the spec: `node` dropped,
    `grep sed head dirname` added) — ruling: the code is right. The probe
    never runs node (`kdd-cli --path` only resolves a path), and it does run
    the four added commands; a missing node then means the toolkit cannot
    run, so `NOT FOUND` is honest. The spec text stays as approved; this line
    is the correction.
  - Minors 2–4 — fixed in `8279228`.
  - Declined to judge: what SDD does on `review-package` exit 3 → batch 3
    (execution modes); `unavailable` guidance → batch 4 (as specified);
    `kdd-cli`'s `sort -V` and `env bash` shebang under a partial PATH →
    dropped: the guard checks every command the probe uses, and a PATH
    without `bash` cannot start the hook at all.
  - Capture candidates (`review-package` exit-3 contract, create-only
    `.kdd/sdd/.gitignore`) → proposed at batch-1 consolidation for
    DOC-FORK-LEDGER-001 (the workspace contract), not written now.
  — Cost if wrong: a reworded probe line or one more release. —
  `8279228`, WRK-SPEC-FORK-UPSTREAM-002.
- **U-9 · 2026-10-18 · 0/1** — The "harness" copied into a before arm is
  `tests/claude-code/test-kdd-flow.sh`, `toolkit-env.sh` **and the fixtures
  the scenarios read** (`tests/scripts/fixtures`, `tests/claude-code/fixtures`):
  scenario 4 reads its fixture from the arm's own tree, so copying only the
  script would have re-run the contradictory fixture. DOC-FORK-UPSTREAM-001
  §4 says "the current test-kdd-flow.sh"; it is corrected at batch-1
  consolidation, not now (editing an activated DOC mid-batch would drift the
  pins of WRK-SPEC-FORK-UPSTREAM-001/-002). — Precision. — None. —
  this log; FRAG-FORK-UPSTREAM-001/-002 Method.
- **U-10 · 2026-10-18 · all** — The `generated.at` / `activation_resolved_at`
  times I wrote by hand in DOC-FORK-UPSTREAM-001 (12:00), WRK-SPEC-FORK-
  UPSTREAM-001 v0.2.0 (12:30) and -002 (15:00) run ahead of the commit clock
  (`449baf9` was committed at 11:41 +02:00). Left as is: rewriting the DOC
  would change its hash and break the pins that froze it. From now on these
  fields take `date -Iseconds`. — Cost: cosmetic, a timestamp up to ~4 h
  early. — this log.
- **U-11 · 2026-10-18 · 0/1** — The batch-0 baseline ran on
  `claude-sonnet-5-5`: `test-kdd-flow.sh` passed no `--model` and the
  account default moved from Opus (FRAG-FORK-TOKENS-003's main session) to
  Sonnet. The protocol fixes `--model opus`, so: the harness pins
  `KDD_FLOW_MODEL` (default `opus`, `155d911`); the in-flight batch-1 run
  was stopped; both arms (0.6.1 and 0.7.0) run on Opus, scenarios 1–7 × 2,
  alternating before/after; the Sonnet runs stay in FRAG-FORK-UPSTREAM-001
  as supplementary data. Pre-registration amended before any after-run
  (`f5a4b46`). — Precision over speed and cost: an Opus pass costs roughly
  2–3× a Sonnet one (estimate $15–25 per pass, four passes). — If you
  prefer Sonnet for level 1, set `KDD_FLOW_MODEL=sonnet` and say so in the
  protocol. — `155d911`, `f5a4b46`.
- **U-12 · 2026-10-18 · 2** — Batch 2 designed and adjudicated unattended
  (WRK-SPEC-FORK-UPSTREAM-003, full path; premise verifier 13/13 hold, U7
  false as a quotation; gate A1 17/18 BROKEN, all accepted — table in the
  spec). Calls worth your review:
  - **KDD over upstream:** the handoff does *not* get upstream's per-plan
    mode recommendation yet; recommending today's gate-less executing-plans
    would break DOC-FORK-UPSTREAM-001 §3.4. It comes with batch 3.
  - **Amends WRK-SPEC-FORK-CORE-001's WRK-TASK design** ("steps with real
    code"): the test step keeps real code; the implementation step gives a
    signature. That line was 6.3.0's step shape, not a KDD principle.
  - An advance approval that names the plan ("I approve … the plan in
    advance") counts as the plan review and is quoted in the activation
    commit; it keeps the headless scenarios and the RFC-PIPE-039 prompt
    unchanged across arms.
  - Deciding metrics are relative to the before arm (no fixed 25 %
    threshold); level 2 cannot show lean plans execute as well — batch 3's
    level 2b is that check and can reopen batch 2.
  — Cost if wrong: one more batch-2 iteration. — WRK-SPEC-FORK-UPSTREAM-003.
