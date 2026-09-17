# Exploration report — rounding in billing

## Observed

- `src/billing.js:12-14@abc1234`: `return Math.round(amount * 100) / 100;`

## Inferred

- Rounding is half-up for positive amounts (rests on the observation above).

## Absences

- `grep -rn "ROUND_HALF_EVEN" src/` → 0 results.
