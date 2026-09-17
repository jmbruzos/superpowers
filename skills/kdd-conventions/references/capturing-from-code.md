# Capturing knowledge from code

Use this whenever a skill records what existing code does as a `FRAG-*`
(brainstorming in brownfield, code review capture candidates, later:
debugging). A hallucinated fragment is worse than none: it enters the graph
looking like evidence and consolidation distills it into a DOM. These rules
make that impossible by construction.

## The seven rules

1. **No anchor, no claim.** Every sentence describing behaviour cites where it comes from and quotes the code verbatim, copied from tool output — never from memory. An unanchored statement is a placeholder: anchor it or delete it.
2. **Observed ≠ Inferred, in separate sections.** *Observed* holds only anchored facts. *Inferred* holds interpretation, and every inference names the observations it rests on. Whatever may be wrong lives in *Inferred*, visibly.
3. **Absences are anchored too.** "There is no validation of X" is a claim. Record the exact search commands and their result (`grep -rn … → 0 results`). No command, no absence.
4. **Cite-check before writing.** Run `skills/kdd-conventions/scripts/frag-cite-check <FRAG-DIR>` from the repo root. One failed anchor blocks the FRAG. This is `verification-before-completion` applied to evidence.
5. **Honest trust.** The FRAG is born `confidence: low`, `generated` by you, with no `verified`. Only a human adds `verified`. Consolidation distills an unverified FRAG at most into a `confidence: low` spec with mandatory review. Never raise your own confidence.
6. **For computable rules, the evidence is a test.** A formula, a rounding, an ordering of validations: write a characterization test against the current code, run it, and put the *observed* result in the FRAG (the test file goes in `files[]`). Reserve this for rules worth it; structure and conventions do not need it.
7. **Promotion needs an adversary.** Before a FRAG becomes DOM/ARCH (consolidation), gate A6 dispatches a reviewer with only the FRAG and repo access to refute each claim. Capture does not pay this cost; promotion does.

## Anchor format

Inside any file listed in the FRAG's `files[]`, one list item per claim:

```
- `<path>:<start>-<end>@<sha>`: `<literal>`
```

- `<path>` repo-relative; `<start>-<end>` 1-based inclusive line range (single line: `12-12`); `<sha>` the commit you read it at (`git rev-parse --short=7 HEAD`); `<literal>` one line of code copied verbatim (no backticks inside).
- Prefer the narrowest range that contains the literal. Several claims about one function are several anchors.

## `report.md` structure

```markdown
# Exploration report — <topic> (<repo>, <sha>)

## Scope
What was explored and why (the work that needed it). Only what the work touches.

## Observed
- `src/billing.js:12-14@abc1234`: `return Math.round(amount * 100) / 100;`
- `src/billing.js:40-40@abc1234`: `if (days <= 0) throw new RangeError('days');`

## Inferred
- Rounding is half-up for positive amounts (rests on: billing.js:12-14).
- Zero or negative day counts are rejected before any calculation (rests on: billing.js:40-40).

## Absences
- `grep -rn "ROUND_HALF_EVEN\|bankers" src/` → 0 results.

## Tests run (if any)
- `tests/characterize-rounding.test.js` — `round2(0.125) === 0.13` observed on <sha>.
```

## Procedure

1. Decide the scope from the work at hand (spec or task). Do not explore beyond it.
2. Read the code with tools; paste literals from tool output into *Observed* with anchors as you go.
3. Write *Inferred* last, each line pointing at its observations.
4. Record every search that came back empty under *Absences*, with the command.
5. Allocate the ID with `next-id FRAG-<AREA>-<CONCEPT>`; create the directory per `artifact-templates.md`; compute `integrity`.
6. Run `frag-cite-check --strict <dir>`; fix or delete anything it rejects; recompute `integrity` if the report changed.
7. Run `<kdd-cli> --specs specs validate`.
8. Cite the FRAG from the artifact that needed it (`sources`, and in prose as "observed in FRAG-…").

## Red Flags

| Thought | Reality |
|---------|---------|
| "I read that function a minute ago, I remember what it does" | Memory is not an anchor. Re-read and paste. |
| "It obviously validates the input somewhere" | Find it or record the search that failed. |
| "The inference is safe, I'll put it under Observed" | Observed is for literals only. Interpretation goes to Inferred. |
| "Cite-check is overkill for two anchors" | Two wrong anchors become a DOM that constrains future work. Run it. |
