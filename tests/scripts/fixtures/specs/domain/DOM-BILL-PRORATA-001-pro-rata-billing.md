---
id: DOM-BILL-PRORATA-001
type: spec
layer: domain
scope: persistent
status: active
confidence: high
version: 1.0.0
created: 2026-09-01
updated: 2026-09-01
owner: billing-team
domain: Billing
subdomain: Pro-rata
title: "Pro-rata billing calculation"
tags: [billing, pro-rata]
---

# DOM-BILL-PRORATA-001 — Pro-rata billing calculation

## Intent

Define the pro-rata amount for mid-cycle activations.

## Definition

- Rule 1: Pro-rata amount = (monthly fee / days in billing period) × remaining days.
- Rule 2: The billing period is always the calendar month.
- Rule 3: Round to 2 decimal places, half-up.

## Acceptance Criteria

- [ ] Activation on the last day of the month is charged one day.
