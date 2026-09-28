# Adversarial gate outcomes in mdm-platform — three executed plans, 2026-09-26/27

Audit report. Not code-derived for this repository: no `path:lines@sha`
anchors into kdd-superpowers. Every figure is read from committed work
artifacts of `mdm-platform` (HEAD `aacdae5`, read 2026-09-28): the
`## Adversarial Review` sections of the WRK-SPECs and WRK-PLANs and the
WRK-PLANs' `## Execution Log`. Line numbers below are into those files at
that HEAD.

## Method

- Selected the three most recent WRK-PLANs that were executed to
  completion (all three and their specs `status: archived`).
- Extracted every BROKEN attack recorded for gates A1, A2, A5 and A6, and
  every `Ruling:` / `Knowledge gap:` / fix-round line of the Execution Log.
- **Limitation.** The committed `## Adversarial Review` sections are
  condensed one-liners ("attack · ruling"), as the artifact template asks.
  The attack tables with their Evidence column were not persisted and no
  earlier revision exists in git (each spec's first commit already carries
  A1). The root cause of each BROKEN row below is therefore *inferred from
  the one-liner*, not read from a Cause column.
- Spot-checked WRK-TASK path/line/signature claims against the code with
  `git show <plan-commit>:<path>`.

## Observed — the three plans

| Plan | Tasks | A1 attempted/BROKEN | A2 attempted/BROKEN | Task fix rounds | Final-review fix waves |
|---|---|---|---|---|---|
| WRK-PLAN-MDM-SOURCE-IDENTITY-001 (SI) | 13 | 42 / 36 | 31 / 22 | 8 (tasks 001, 004, 006×2, 010, 011, 013) | 3 |
| WRK-PLAN-MDM-MULTI-MATCH-CONSOLIDATION-001 (MM) | 5 | 24 / 18 | 22 / 7 | 1 (task 005) | 1 |
| WRK-PLAN-MDM-MERGE-CONCURRENCY-001 (MC) | 4 | 18 / 12 | 17 / 7 | 0 | 1 |

## Observed — BROKEN rows by inferred root cause

Buckets: **code-reality** (the artifact assumed something false or
unverified about existing code), **spec-rule** (violates or weakens a rule
of an activated spec), **ambiguity** (two readings, trivially satisfiable
criterion, untestable step), **knowledge-gap** (no spec settles it),
**internal** (interface mismatch, order trap, uncovered criterion,
out-of-set activation, scope leak), **rejected** (ruling rejected it).

| Gate | code-reality | spec-rule | ambiguity | knowledge-gap | internal | rejected | Rows | Rows citing source code |
|---|---|---|---|---|---|---|---|---|
| SI A1 | 8 | 11 | 5 | 2 | 2 | 0 | 28 one-liners for 36 BROKEN | 0 |
| MM A1 | 8 | 5 | 4 | 0 | 2 | 0 | 19 | 0 |
| MC A1 | 11 | 0 | 1 | 0 | 0 | 0 | 12 | 1 |
| **A1 total** (59 recorded one-liners for 66 BROKEN) | **27 (46 % of 59)** | **16 (27 %)** | **10** | **2** | **4** | **0** | **59** | **1** |
| SI A2 | 6 | 7 | 3 | 1 | 4 | 1 | 22 | 0 |
| MM A2 | 3 | 0 | 1 | 0 | 3 | 0 | 7 | 2 |
| MC A2 | 1 | 1 | 3 | 0 | 2 | 0 | 7 | 1 |
| **A2 total** | **10 (28 %)** | **8** | **7** | **1** | **9 (25 %)** | **1** | **36** | **3** |
| SI A6 (FRAG promotion) | 7 | 0 | 0 | 0 | 0 | 0 | 7 | 7 |

## Observed — representative one-liners (verbatim)

- MC spec:278 — "A1-5/A1-6/A1-7 (T2/T3 verdes hoy: field override protege el campo; NATS evicta aunque se suprima el evictor; frescura 1.0 en ambos lados)" — code-reality.
- MC spec:281 — "A1-14 (anclas desplazadas) · corregidas: update 256-300, consolidate 302-357." — code-reality.
- MM spec:187 — "A1-18 (premisa falsa: la fusión manual confirmada no recalcula) · corregido en ADR-021" — code-reality.
- SI plan:200 — "28. `tenant_id NOT NULL` en V37 rompía el INSERT legado · aceptado: NOT NULL pasa a V38." — code-reality.
- MM plan:174 — "A2-5 (ancla de `removeEdge` equivocada en 001) · `GraphStoreRepository.java:96`." — code-reality.
- SI plan:202 — "29. Lectores de la xref antes que sus escritores · aceptado: reordenado" — internal (order trap).
- SI plan:187 — "20. 004 no activaba FEAT-MDM-BLOCKING-001 · aceptado." — internal (out-of-set activation).
- MC plan:111 — "A2-5 (`git worktree add … main` falla … y `exit≠0` se cumpliría sin ejecutar nada)" — ambiguity (trivially satisfiable).
- SI plan:178 — "12. Historial por registro mezclaría operaciones de otra fuente · **rechazado**" — rejected.

## Observed — A1 rows target Constraints and Acceptance Criteria

All three specs' first commits (post-A1) contain `## Constraints` and
`## Acceptance Criteria`, and A1 rows target them (SI spec:390-391, MM
spec:180, MC spec:277, MC spec:282). Whether the pre-A1 draft already had
those sections cannot be established: no pre-A1 revision exists in git.

## Observed — execution-time premises that were false

- SI plan:234 — "Ruling: accept unmerge taking findByIdAndTenantIdForUpdate (outside brief) — without it rebuild↔unmerge deadlocked; the brief's premise (unmerge already locks) was false". The premise was in the controller's final-review fix brief, not in a WRK-TASK. `git grep "ForUpdate\|PESSIMISTIC"` at `b355cb3` in mdm-persistence and the gateway → 0 results.
- MC plan:130 — "se acepta que la ingesta concurrente de los ITs envíe también `legal_name` — el schema de test lo exige y sin él la ingesta daba 400; corrección de fixture del plan".
- SI plan:221 — "005's IT … stays @Disabled and 006 must re-enable it … plan defect (AC of 005 depended on 006)".
- No `NEEDS_CONTEXT` status appears in any Execution Log.

## Observed — WRK-TASK anchors against the code

Six claims spot-checked (MM-003, MM-004 line ranges and signatures at
`468c9c4`; MC-003 ranges at `770c8cd`; SI plan anchors at `b355cb3`): all
match. Paths, line ranges and signatures in task files were correct after
the gates.

## Inferred

- Nearly half of what A1 breaks is a premise about current behaviour that
  the author never checked (rests on: A1 totals; MC A1 one-liners; MM
  spec:187). The adversary finds it; the author could have, cheaper.
- Plans do not invent paths or signatures; what escapes to execution is
  behavioural premises (rests on: anchor spot-check; SI plan:234; MC
  plan:130).
- A2's internal attacks catch real defects that the writing-plans
  self-review missed (rests on: A2 internal = 9, including SI plan:187,
  SI plan:202).
- Gate outputs are large (A1 18–42 rows) and their persisted form loses the
  evidence needed to measure them (rests on: Method limitation; 1 of 59 A1
  one-liners cites code).
- The gates move defects earlier: MC and MM ran their tasks with 0–1 fix
  rounds (rests on: fix-round column).
