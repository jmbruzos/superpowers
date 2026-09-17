---
id: WRK-SPEC-BILL-PRORATA-001
type: spec
layer: work-spec
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-09-10
updated: 2026-09-10
owner: billing-team
title: "Mid-cycle activation billing"
activates:
  - DOM-BILL-PRORATA-001@1.0.0
equips: []
activation_frozen: true
activation_resolved_at: 2026-09-10T10:00:00+02:00
dependencies:
  - id: DOM-BILL-PRORATA-001
    relation: constrained-by
sources:
  - id: FRAG-BILL-ROUNDING-001
    resource: specs/_capture/FRAG-BILL-ROUNDING-001-half-up-rounding/
generated:
  by: claude-code/test
  at: 2026-09-10T10:00:00+02:00
stale_after: 2026-12-10T10:00:00+01:00
tags: [billing]
---

# WRK-SPEC-BILL-PRORATA-001 — Mid-cycle activation billing

## Problem Statement

Mid-cycle activations are billed a full month.

## Proposed Change

Compute the pro-rata amount per DOM-BILL-PRORATA-001.

## Knowledge Context

| Activated Spec | Role |
|---|---|
| DOM-BILL-PRORATA-001 | formula and rounding |

## Constraints

- Round to 2 decimal places, half-up (DOM-BILL-PRORATA-001, Rule 3).

## Acceptance Criteria

- [ ] Activation on day 15 of a 30-day month charges half the fee.

## Open Questions

- None.
