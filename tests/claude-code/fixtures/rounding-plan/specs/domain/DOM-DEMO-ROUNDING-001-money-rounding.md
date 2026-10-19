---
id: DOM-DEMO-ROUNDING-001
type: spec
layer: domain
scope: persistent
status: active
confidence: medium
version: 1.0.0
created: 2026-10-18
updated: 2026-10-18
owner: test
domain: demo
subdomain: Money
title: "Money rounding — amounts are rounded half-even to two decimal places"
generated:
  by: claude-code/test
  at: 2026-10-18T12:00:00+02:00
verified:
  - by: human:test
    at: 2026-10-18T12:00:00+02:00
tags: [demo, money, rounding]
---

# DOM-DEMO-ROUNDING-001 — Money rounding

## Concept

Every monetary amount the system stores or shows is a number of euros
rounded to cents.

## Rules

1. **Two decimal places.** A rounded amount has exactly two decimal places.
2. **Half-even.** An amount exactly halfway between two cents rounds to the
   even cent (banker's rounding): `2.345 → 2.34`, `2.355 → 2.36`,
   `0.005 → 0.00`, `0.015 → 0.02`. Anything not exactly halfway rounds to
   the nearest cent: `2.3449 → 2.34`, `2.3451 → 2.35`.
3. **Sign.** Negative amounts round by the same rule on their magnitude:
   `-2.345 → -2.34`, `-0.015 → -0.02`.
4. **Decimal halves.** "Exactly halfway" is judged on the decimal amount as
   written (`2.345`), not on its binary floating-point approximation.

## Constraints

- Half-up rounding (`Math.round(x * 100) / 100`) violates rule 2: it gives
  `2.35` for `2.345` and `0.01` for `0.005`.
