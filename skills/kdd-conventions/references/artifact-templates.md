# Artifact templates

Angle-bracket fields are filled in; everything else is literal. Dates are
`YYYY-MM-DD`; datetimes carry an offset. Body headings are the KDD anatomy
for each layer — keep them, in this order.

## Full WRK-SPEC (architectural path)

```yaml
---
id: <WRK-SPEC-PATH-NNN>
type: spec
layer: work-spec
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: <date>
updated: <date>
owner: <team-or-person>
title: "<full name>"
activates:
  - <KNOWLEDGE-ID>@<version>
equips: []
activation_frozen: true
activation_resolved_at: <datetime>
dependencies:
  - id: <KNOWLEDGE-ID>
    relation: constrained-by
sources:
  - id: <FRAG-ID>
    resource: specs/_capture/<FRAG-ID>-<slug>/
generated:
  by: claude-code/<model-id>
  at: <datetime>
stale_after: <datetime +90d>
tags: [<area>, <concept>]
---
```

Body:

```markdown
# <ID> — <title>

## Problem Statement
## Proposed Change
### Architecture
### Components
### Data flow
### Error handling
### Testing
## Knowledge Context
| Activated Spec | Role in this work |
|---|---|
(FRAGs cited as evidence go here too, marked "evidence, not activated")
## Constraints
(verbatim rules from activated specs, each with its source ID and rule number; FRAG-observed behaviour with its anchor)
## Acceptance Criteria
- [ ] (testable)
## Open Questions
## Adversarial Review
(only when a gate ran: one line per BROKEN attack — attack · ruling)
```

Add `- id: <FEAT-ID>\n    relation: implements` under `dependencies` when the work materializes a FEAT.

## Compact WRK-SPEC (bounded path)

Same frontmatter. Body only:

```markdown
# <ID> — <title>

## Problem Statement
## Proposed Change
## Knowledge Context
## Acceptance Criteria
```

## WRK-PLAN

```yaml
---
id: <WRK-PLAN-PATH-NNN>
type: spec
layer: work-plan
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: <date>
updated: <date>
owner: <team-or-person>
title: "<spec title> — implementation plan"
parent: <WRK-SPEC-ID>
activates:
  - <subset of the spec's activates, same pins>
equips: []
activation_frozen: true
dependencies:
  - id: <WRK-SPEC-ID>
    relation: implements
  - id: <KNOWLEDGE-ID>
    relation: constrained-by
sources:
  - id: <WRK-SPEC-ID>
    resource: specs/work/<spec file>
generated: { by: claude-code/<model-id>, at: <datetime> }
stale_after: <datetime +90d>
tags: [<area>, plan]
---
```

Body:

```markdown
# <ID> — <title>

> **For agentic workers:** REQUIRED SUB-SKILL: Use kdd-superpowers:subagent-driven-development (recommended) or kdd-superpowers:executing-plans to implement this plan task-by-task. Each task is its own WRK-TASK file; steps use checkbox (`- [ ]`) syntax.

## Approach
**Goal:** … **Architecture:** … **Tech Stack:** …
## Task Breakdown
| Task ID | Description | Dependencies |
|---|---|---|
(table order = execution order)
## Architecture Impact
| Constraint | Source | Impact on plan |
|---|---|---|
(rules copied verbatim from activated specs)
## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
## Dependencies
## Execution Log
(appended at finishing: rulings, Knowledge gaps, broken attacks, pending capture candidates)
## Adversarial Review
(only when a gate ran: one line per BROKEN attack — attack · ruling)
```

## WRK-TASK

```yaml
---
id: <WRK-TASK-PATH-PPP-TTT>
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: <date>
updated: <date>
owner: <team-or-person>
title: "<component name>"
parent: <WRK-PLAN-ID>
activates:
  - <2–5 specs this task touches, pins inherited>
equips: []
dependencies:
  - id: <WRK-PLAN-ID>
    relation: implements
sources:
  - id: <FRAG-ID>
    resource: specs/_capture/<FRAG-ID>-<slug>/
generated: { by: claude-code/<model-id>, at: <datetime> }
stale_after: <datetime +90d>
tags: [<area>, task]
---
```

Body:

```markdown
# <ID> — <title>

## Objective
## Implementation Notes
**Files:** Create / Modify / Test with exact paths
**Interfaces:** Consumes / Produces with exact signatures
- [ ] **Step 1: Write the failing test** (code block)
- [ ] **Step 2: Run it to verify it fails** (command + expected)
- [ ] **Step 3: Minimal implementation** (code block)
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** (`<type>(<TASK-ID>): …`)
## Acceptance Criteria
- [ ] (each maps to a spec criterion or an activated rule)
## Test Plan
```

## FRAG (captured from code)

Directory `specs/_capture/<FRAG-ID>-<slug>/` with `<FRAG-ID>.md` and the raw files (`report.md`, optional characterization tests).

```yaml
---
id: <FRAG-PATH-NNN>
type: fragment
layer: capture
scope: persistent
status: ingested
confidence: low
version: 1.0.0
created: <date>
updated: <date>
owner: <team-or-person>
domain: <domain if the project has a taxonomy>
title: "<what was observed, where>"
captured_at: <datetime>
source_type: report
files:
  - report.md
integrity: "sha256:<sha256sum of the files, sorted by name — recompute after any edit>"
origin: <repo or service name>
routed_to: []
generated: { by: claude-code/<model-id>, at: <datetime> }
tags: [capture, <area>]
---
# <ID> — <title>

Immutable capture. Anchored observations live in report.md; the reconciled
knowledge, once distilled, cites this fragment in `sources`.
```

`report.md` structure is defined in `capturing-from-code.md`.
