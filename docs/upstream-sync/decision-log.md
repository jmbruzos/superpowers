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
