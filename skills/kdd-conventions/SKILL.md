---
name: kdd-conventions
description: Use when writing or updating any KDD artifact (WRK-SPEC, WRK-PLAN, WRK-TASK, FRAG) or transitioning its status — IDs, locations, state transitions, trust family, and the scripts that enforce them
---

# KDD Conventions

Every artifact kdd-superpowers writes is a KDD spec: complete frontmatter,
validated by `spec-graph validate`, living in `specs/`. This skill is the
single place those conventions are written down. Workflow skills cite it;
they do not restate it.

**Announce at start:** "Using kdd-conventions to write <artifact>."

## Identifiers — semantic path, number last

IDs are a readable path of uppercase segments with the number **last**:
`WRK-SPEC-RISK-VAR-ENGINE-001`, `DOM-RISK-VAR-001`, `FRAG-BILL-ROUNDING-001`.
This is the grammar `spec-graph` accepts (`^PREFIX(-[A-Z0-9]+)*-\d{3}$`);
the number disambiguates within a semantic path, it is not a global counter.

- Segments are `[A-Z0-9]+`, joined by `-`; 2–4 semantic segments (area + concept) after the type prefix.
- **Reuse before inventing**: run `<kdd-cli> --specs specs filter --format json` and take an existing area when one fits. Use nested areas only if the project already does.
- Work chain: the WRK-PLAN inherits the WRK-SPEC's path; tasks are `WRK-TASK-<path>-<PPP>-<TTT>` (PPP = plan number, TTT = position in the plan's Task Breakdown). A plan prefers its spec's number (`next-id --prefer`).
- Allocate with this skill's `scripts/next-id [--specs DIR] [--prefer NNN] TYPE-PATH` — never by hand.
- Files: `specs/work/<ID>-<lowercase-slug>.md`; fragments: `specs/_capture/<ID>-<slug>/<ID>.md` plus the raw files. `title` in the frontmatter carries the full name.
- The human confirms the proposed ID together with the activation (brainstorming, *Knowledge activation* section). An ID is immutable once committed.

## Locations

| What | Where | Tracked |
|---|---|---|
| Work artifacts (WRK-SPEC / WRK-PLAN / WRK-TASK) | `specs/work/` | yes |
| Capture fragments (FRAG) | `specs/_capture/<ID>-<slug>/` | yes |
| Knowledge/agentic specs the project owns | wherever the project keeps them under `specs/` | yes |
| SDD ledger, briefs, reports, review packages | `.kdd/sdd/<WRK-PLAN-ID>/` | no (gitignored) |
| Visual companion sessions | `.kdd/brainstorm/<session>/` | no |
| Ad-hoc review briefs (modes 2–3) | `.kdd/review/` | no |

No path written by this plugin contains `superpowers`. Runtime state goes
under `.kdd/`; the plugin adds `.kdd/` to the project's `.gitignore` the
first time it creates it (append the line if absent). `.kdd/` is ignored
twice on purpose: the plugin appends `.kdd/` to the project `.gitignore`
when it first creates the directory, and `.kdd/sdd/` carries its own
self-ignoring `.gitignore` for worktrees that predate it.

## Status transitions — who moves what, when

| Artifact | Born | → | By |
|---|---|---|---|
| WRK-SPEC | `draft` (brainstorming writes it) | `active` when your human partner approves the written spec (full or compact) | brainstorming |
| WRK-SPEC | `active` | `completed` at finishing, before the integration menu | finishing-a-development-branch |
| WRK-SPEC | `completed` | `archived` once consolidation is applied | finishing-a-development-branch |
| WRK-PLAN / WRK-TASK | `draft` (writing-plans) | `active` when an execution mode is chosen | writing-plans |
| WRK-TASK | `active` | `completed` when its task review is clean (in the task's closing commit) | SDD / executing-plans |
| WRK-PLAN | `active` | `completed` when the final review is clean | SDD / executing-plans |
| WRK-PLAN / WRK-TASK | `completed` | `archived` once consolidation is applied | finishing |
| FRAG | `ingested` | `distilled` when a spec cites it in `sources` after consolidation | consolidation (`kdd:spec-consolidate`) |

Every transition also updates `updated:`. Never skip a state.

## Trust family — on everything you write

```yaml
generated:
  by: claude-code/<model-id>        # actor convention: <producer>/<version>
  at: <ISO 8601 with offset>
sources:                            # what the content rests on: activated specs, FRAGs, external docs
  - id: <SPEC-or-FRAG-ID>
    resource: <path or URL>
stale_after: <ISO 8601, +90 days for ephemeral work artifacts>
```

- `verified` is written **only on behalf of a human who explicitly confirmed**, as `- by: human:<id>` with `at:` — writer ≠ confirmer. A skill never verifies its own output. Ask for the id once (`git config user.email` local-part is a fine default to propose); never invent one.
- `confidence` is capped by trust: unverified ⇒ `low`. New artifacts are born `confidence: low`; the human's `verified` lifts them (`validate` warns otherwise — treat the warning as an error).
- `activates` holds Knowledge-axis refs only, `equips` Agentic-axis refs only, both pinned `ID@version`. `FRAG-*` and deliverable projections are never activated; cite them in `sources`.

## Validate before you call it written

```bash
<kdd-cli> --specs specs validate
```

0 errors is the bar; warnings about your own artifact are yours to fix. Use
`skills/using-superpowers/scripts/kdd-cli` to find the CLI — never hard-code
its path.

## References

- `references/artifact-templates.md` — frontmatter and body for WRK-SPEC (full and compact), WRK-PLAN, WRK-TASK, FRAG.
- `references/capturing-from-code.md` — how to turn code into evidence without hallucinating (P11/P12).
- `references/adversarial-gates.md` — the common contract for gates A1–A6.

## Red Flags

| Thought | Reality |
|---------|---------|
| "I'll number it 001, it's the first one" | Run `next-id`. The path may already have specs elsewhere in the tree. |
| "The spec is basically right, I'll set confidence medium" | Confidence is capped by trust. Unverified is `low`. Let the human lift it. |
| "I'll mark it verified — the human said 'looks good'" | Record `verified` only after an explicit approval of *this* artifact, with their id. |
| "Validate warns, but not about my file" | Read the warning. If it names your artifact, fix it; if not, say so out loud. |
