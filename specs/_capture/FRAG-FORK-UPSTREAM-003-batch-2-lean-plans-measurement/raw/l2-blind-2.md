# Blind H1–H10 pass — six designs (T1–T6)

Ground truth: mdm-platform @ aacdae5. Short paths used below:
- PSH = `src/mdm-ingest-service/src/main/java/com/mdm/ingest/pipeline/steps/PersistenceStepHandler.java`
- SURV = `specs/domain/DOM-MDM-SURVIVORSHIP-001-golden-record-survivorship.md`
- PIPE = `specs/domain/DOM-MDM-PIPELINE-001-pipeline.md`
- INTEG = `specs/architecture/ARCH-MDM-INTEGRATION-001-integration-layer.md`
- STEW = `src/mdm-api-gateway/src/main/java/com/mdm/gateway/service/StewardshipService.java`

Facts checked once and reused for every design:
- The manual merge does not touch the survivor's `goldenData`; it only recomputes the score (SURV:829). Re-survivorship excludes survivors with an active `GOLDEN_TO_GOLDEN` rule (INTEG:486).
- Orphaned means "queryable, historical read only" and "does not propagate downstream" (SURV:231). Two rules conflict on the last-member case: SURV:236 says `orphaned` via source_to_golden; PIPE:1652 says `absorbed`.
- A `source_pin` whose pinned record is no longer linked is auto-deactivated, with `FieldOverrideAutoDeactivated` (PIPE:1800, PIPE:1816; STEW:2409 `autoDeactivatePins`).
- The losing record is locked `FOR UPDATE` before move/cleanUp/refresh (PSH:803-815, `lockGoldenRecord` PSH:845-856). Lock or version conflicts become `OptimisticLockingFailureException`, which sends the run back to Merge (PSH:76, PSH:853). `refreshSourceCounts` is a native UPDATE (PSH:814-815).
- `evictAfterCommit(previous)` already runs for the losing record (PSH:809). It evicts L1 and L2 (`GoldenRecordCacheEvictor`:36-50, `GoldenRecordCacheService.evict`:165). `golden_record.updated` drives cross-pod invalidation (`CacheInvalidationListener`). `maybeEmitQualityTierChange` reads `ctx.getQualityScoreResult()`, which is the target's score, not the losing record's (PSH:625-640).
- `GoldenRecordUpdated` is consumed by the Propagation Service to "update downstream" (INTEG:823).
- Only two production paths close a span: unmerge (STEW:2288) and the pipeline (PSH:759, PSH:806). Review resolution closes none. `SOURCE_TO_GOLDEN` appears in no production creator, only in `ForceRule.java`, `ForceRuleJpaRepository` and tests.

## T1

| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | C | For a manual-merge survivor it replaces only the fields whose lineage names the departed record, or that a deactivated pin fixed. Other fields stay. | SURV:829; INTEG:486 |
| H2 | N | No lineage entry may name the departed record outside `previous`, but rebuilding `previous` against persisted values is explicitly not addressed. | SURV §3.1.3 (previous value) |
| H3 | W | Orphaned, but it empties `golden_data` and `field_lineage`, which contradicts "historical read only" for orphaned records. Defines the emission: none. | SURV:231 |
| H4 | C | Pins on the departed record (full identity or legacy id) are deactivated with an event; value overrides keep applying; the `GOLDEN_TO_GOLDEN` rule is untouched; an orphaned target is ignored. | PIPE:1800; PIPE:1661 |
| H5 | C | Runs under the existing `FOR UPDATE` lock, before the native refresh. A rollback undoes everything; a conflict goes back to Merge. | PSH:803-815; PSH:76 |
| H6 | C | Keeps after-commit eviction. Computes the tier crossing from the losing record's recomputed score. All events are published after commit. | PSH:809; PSH:625-640 (criterion only) |
| H7 | C | ForceRule covered. Unmerge kept, with a regression test. Resolution scoped out with a reason: it does not touch membership. | STEW:2288; PSH:806 |
| H8 | N | Integration tests are planned on the move, but it never says how a `SOURCE_TO_GOLDEN` rule comes to exist (no seeding noted). | no prod creator of SOURCE_TO_GOLDEN |
| H9 | C | `QualityScoreResolver` at `Instant.now()`; freshness from the remaining versions only. | SURV §3.7 |
| H10 | C | No `GoldenRecordUpdated` on orphaning, consistent with "orphaned does not propagate downstream". | SURV:231; INTEG:823 |

## T2

| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | N | Recomputing a manual-merge survivor is explicitly not addressed. The unconditional full recompute would overwrite its data. | SURV:829; INTEG:486 |
| H2 | N | Lineage is rebuilt from the remaining members only; `previous` is not addressed, and a chain from `create` drops it. | SURV §3.1.3 |
| H3 | W | Orphaned with `golden_data` and `field_lineage` emptied. It rejects the historical read that the spec mandates for orphaned records. | SURV:231 |
| H4 | W | Pins on the departed record stay active ("no effect"). This conflicts with the rule that a pin whose pinned record is no longer linked is auto-deactivated. | PIPE:1800; STEW:2409 |
| H5 | C | Existing `FOR UPDATE` lock; `saveAndFlush` bumps `@Version`; a conflict goes back to Merge; outcomes are cleared per attempt. | PSH:803-815; PSH:76 |
| H6 | C | `evictAfterCommit` kept. `golden_record.updated` emitted after a completed run. Tier crossing computed from the losing record's own score. | PSH:809; CacheInvalidationListener |
| H7 | C | ForceRule covered; unmerge delegates; resolution scoped out because it closes no spans. | STEW:2288; PSH:806 |
| H8 | C | Notes explicitly that no production code creates `SOURCE_TO_GOLDEN` rules; the gap is reached through stored rules in tests. | ForceRule.java; test-only creators |
| H9 | C | Shared resolver at an instant taken in the handler; freshness over the remaining versions. | SURV §3.7 |
| H10 | W | Emits `golden_record.updated` for an orphaned record and argues it is only cache invalidation. That event feeds the downstream Propagation Service. | SURV:231; INTEG:823 |

## T3

| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | C | Targeted per-field patch. Fields outside the affected set are untouched, explicitly to protect the manual-merge survivor. | SURV:829; INTEG:486 |
| H2 | C | No entry names the departed record. Each changed field gets `previous = {value, source, changed_at}` from the persisted value. | SURV §3.1.3 |
| H3 | C | The last member leaving gives `absorbed`, with an `ABSORBED_INTO` edge and the overrides migrated. It follows PIPE:1652 and states the conflict with SURV. Emits `golden_record.consolidated`. | PIPE:1652; SURV:230 |
| H4 | C | Pins (full and legacy) deactivated with `auto_member_left` and an event; value overrides stay; the `GOLDEN_TO_GOLDEN` rule stays. | PIPE:1800 |
| H5 | C | Already locked `FOR UPDATE`; the version guard retries the concurrent merge; an exception rolls back the whole transaction. | PSH:803-815; PSH:76 |
| H6 | C | `evictAfterCommit`, then `golden_record.updated` once after commit. The tier check uses the recomputed score of the losing record, with the same criterion. | PSH:809; PSH:625-640 |
| H7 | C | ForceRule covered; unmerge null-branch fixed; resolution scoped out because it closes no spans. | STEW:2288 |
| H8 | C | States that only legacy rows and test inserts reach the `FORCE_RULE` branch; the integration tests seed accordingly. | test-only SOURCE_TO_GOLDEN creators |
| H9 | C | `QualityScoreResolver` at the evaluation instant, also in unmerge's null branch. | SURV §3.7 |
| H10 | C | No orphaned state. An absorbed record emits only the absorption notification (`consolidated`), as the spec prescribes. | SURV:230 |

## T4

| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | W | A manual-merge survivor is recomputed in full, reading the exclusion rule as an enumeration. The spec says the manual merge does not touch `goldenData`, and re-survivorship excludes it. | SURV:829; INTEG:486 |
| H2 | N | No entry may cite the departed record (overrides excepted); `previous` is not addressed. | SURV §3.1.3 |
| H3 | C | Orphaned, with data and lineage kept as a read-only snapshot; states the absorbed/orphaned conflict. Emission is defined (see H10). | SURV:231, :236 |
| H4 | C | `DepartedMemberPinDeactivator` mirrors unmerge (legacy, null id); ForceRules untouched; Match ignores an orphaned target. | PIPE:1800; PIPE:1661 |
| H5 | C | Locks the target and the losing record in ascending id order. A version guard against Merge's read throws OLFE and recomputes; the losing record is always written; the result is cleared on retry. | PSH:76; PSH:845-856 |
| H6 | C | Keeps `evictAfterCommit`. Emits `golden_record.updated` after the run for cross-pod eviction. The tier comes from the losing record's own previous score (0.5 if null). | PSH:809; CacheInvalidationListener |
| H7 | C | ForceRule covered; unmerge delegates, with a test; resolution writes no span closures today. | STEW:2288 |
| H8 | N | Postgres integration tests are planned on the move, but rule seeding is not stated. | no prod creator of SOURCE_TO_GOLDEN |
| H9 | C | Merge computes the score with the shared resolver; freshness from the remaining versions only. | SURV §3.7 |
| H10 | W | Downstream propagation is said to be "not addressed", yet `golden_record.updated` is emitted for every write of the losing record, orphaned included. | SURV:231; INTEG:823 |

## T5

| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | W | A manual-merge survivor is recomputed in full, on the claim that the exclusion covers only rule changes. The manual merge leaves `goldenData` as the steward's decision. | SURV:829; INTEG:486 |
| H2 | C | `previous` is rebuilt against the persisted state (stored value and source, recalculation instant); no entry names the departed record. | SURV §3.1.3 |
| H3 | C | Orphaned, with data, lineage and score kept as a historical snapshot. Emission is defined (see H10). | SURV:231 |
| H4 | C | Pins (full or legacy) deactivated and flushed before the fold; the `GOLDEN_TO_GOLDEN` rule untouched. Value overrides are not discussed. | PIPE:1800 |
| H5 | C | Inside the persistence transaction, under the held lock, before the native refresh. A full rollback; OLFE goes back to Merge. | PSH:803-815; PSH:76 |
| H6 | C | Eviction plus `golden_record.updated` after commit. The tier crossing uses the losing record's previous score, or 0.5. | PSH:809; PSH:625-640 |
| H7 | C | ForceRule covered; unmerge unchanged; resolution does not move membership today. | STEW:2288 |
| H8 | N | Integration tests run on the move, but rule seeding is not stated. | no prod creator of SOURCE_TO_GOLDEN |
| H9 | C | `QualityScoreResolver` at the recalculation instant; `LatestSourceReceivedAtResolver` over the remaining versions. | SURV §3.7 |
| H10 | W | Publishes `golden_record.updated` on orphaning despite citing the rule that orphaned records do not propagate. That event is the Propagation Service's input. | SURV:231; INTEG:823 |

## T6

| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | C | A manual-merge survivor gets a selective recompute: only the fields whose lineage named the departed record change. | SURV:829; INTEG:486 |
| H2 | C | No entry names the departed identity. A changed field gets `previous` from the old stored value and entry; an unchanged one gets null. | SURV §3.1.3 |
| H3 | C | Orphaned per SURV over PIPE (states the conflict); snapshot kept; pins deactivated; rules pointing at it are ignored. | SURV:231, :236; PIPE:1652 |
| H4 | C | `SOURCE_PIN` on the departed record (same id, and same source if set) deactivated with an event; value overrides keep applying; ForceRules only read. | PIPE:1800 |
| H5 | C | Locked by the caller and re-read `FOR UPDATE`. Any failure rolls back; lock conflicts go back to Merge; others retry, then go to the DLQ. | PSH:803-815; PSH:76 |
| H6 | C | `evictAfterCommit` plus `golden_record.updated` after commit. It explicitly does not reuse `maybeEmitQualityTierChange`, which compares against the target, and uses the losing record's own scores. | PSH:625-640 |
| H7 | N | ForceRule covered and unmerge switched to the shared replay, but review resolution is scoped out without a reason. | STEW:2288 (no span closure in resolution) |
| H8 | N | Nine integration tests on the move, but rule seeding is not stated. | no prod creator of SOURCE_TO_GOLDEN |
| H9 | C | `QualityScoreResolver` at one `Instant.now()`; freshness over the remaining versions. | SURV §3.7 |
| H10 | W | Emits `golden_record.updated` for an orphaned record and says no rule covers it, yet SURV:231 says orphaned does not propagate downstream. | SURV:231; INTEG:823 |

## Summary

| design | C | W | N |
|---|---|---|---|
| T1 | 7 | 1 | 2 |
| T2 | 5 | 3 | 2 |
| T3 | 10 | 0 | 0 |
| T4 | 6 | 2 | 2 |
| T5 | 7 | 2 | 1 |
| T6 | 7 | 1 | 2 |

## What separates them

- H1: T4 and T5 fully recompute the manual-merge survivor, against SURV:829 and INTEG:486. T1, T3 and T6 patch only the departed record's fields. T2 never considers the case.
- H10 and H3 trade off. Those that keep the orphaned snapshot (T4, T5, T6) emit `golden_record.updated` downstream. T1 suppresses the event but empties the data, and T2 does both wrong. Only T3 (absorbed plus `consolidated`) satisfies both, by taking the PIPE:1652 side of a spec conflict.
- H2 `previous`: only T3, T5 and T6 rebuild it from the persisted state.
- H8: only T2 and T3 recognise that `SOURCE_TO_GOLDEN` rules exist only in tests and legacy rows.
- H4: T2 alone leaves pins on the departed record active, contrary to PIPE:1800.
