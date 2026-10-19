**Blind judge: batch 2, level 2, H1–H10 on S1–S4**

I checked every score against mdm-platform at aacdae5. File paths below are relative to `src/`. Specs are cited by ID and line.

### S1
| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | W | It fully recomputes the manual-merge survivor, arguing that the exclusion "covers rule changes, not membership changes". The code says a recompute erases the steward's decision. | `StewardshipService.java:711-733` (409 "would discard the steward's decision"); DOM-MDM-SURVIVORSHIP-001 L829 (manual merge "no toca goldenData") |
| H2 | C | No lineage entry may name the departed record. `previous` is rebuilt against the persisted values: the stored value if it changed, null if not. | DOM-MDM-SURVIVORSHIP-001 L702 |
| H3 | C | The record becomes `orphaned` and keeps its data, lineage and score as a read-only snapshot. `golden_record.updated` is emitted, with no score and no tier event. | DOM-MDM-SURVIVORSHIP-001 L231 ("solo lectura histórica"), L236 |
| H4 | C | Pins on the departed record (full or legacy identity) are deactivated before the fold and emit `FieldOverrideAutoDeactivated`. The GOLDEN_TO_GOLDEN rule is untouched. | DOM-MDM-PIPELINE-001 L1800 (§10.9.4 pt 2); `StewardshipService.java:2409-2438` |
| H5 | C | It runs under the existing FOR UPDATE lock, after move and cleanup and before the native `refreshSourceCounts`. A whole-step rollback is retried, and an optimistic-lock failure goes back to Merge. | `PersistenceStepHandler.java:797-815`, `:76`, `:799` |
| H6 | C | The record is evicted after commit and `golden_record.updated` is published, which invalidates the cache on other pods. The tier uses the losing record's own previous score, or 0.5. | `GoldenRecordCacheEvictor`; `CacheInvalidationListener.java:45,67`; `PersistenceStepHandler.java:625-646` |
| H7 | C | ForceRule is covered. Unmerge already recomputes, so it is left alone. Review resolution moves no membership today. | Unmerge recomputes at `StewardshipService.java:427-466`; no review code writes spans (only Stewardship, Merge and Persistence touch membership) |
| H8 | N | Handler and integration tests of the move are planned, but nothing says the SOURCE_TO_GOLDEN rules are seeded. | No production code creates them; only the query at `ForceRuleJpaRepository.java:46` |
| H9 | C | The resolver computes the score at the recalculation instant, with freshness taken from the remaining members only. | DOM-MDM-SURVIVORSHIP-001 §3.7.2 L812 |
| H10 | C | It states the "orphaned does not propagate" rule. Its only emission is `golden_record.updated`, used as the cache channel, which matches the stewardship precedent. | DOM-MDM-SURVIVORSHIP-001 L231; `StewardshipService.java:2973-2990` (RFC-PERF-004) |

### S2
| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | N | It says outright that recomputing the survivor is not addressed. | — |
| H2 | N | The lineage part is right (no entry names the departed record). `previous` is not addressed, and the chain starts in create mode, which makes it null. | DOM-MDM-SURVIVORSHIP-001 L702 |
| H3 | W | It empties `golden_data` and `field_lineage` on orphaning. That conflicts with the "historical read-only" status. (It does flag the absorbed vs. orphaned conflict.) | DOM-MDM-SURVIVORSHIP-001 L231 vs DOM-MDM-PIPELINE-001 L1652 |
| H4 | W | Pins on the departed record are left active, on the argument that they have no effect. The rule says they are deactivated automatically. | DOM-MDM-PIPELINE-001 L1800; precedent `StewardshipService.java:504` |
| H5 | C | It runs under the existing lock; `@Version` is bumped; a conflict goes back to Merge; outcomes are cleared on each attempt. | `PersistenceStepHandler.java:715-726, 797-815` |
| H6 | C | It evicts after commit, Propagation emits `golden_record.updated`, and the tier uses the losing record's own previous score. | `CacheInvalidationListener.java:67` |
| H7 | C | ForceRule is covered, unmerge delegates to the shared chain, and it says review resolution closes no spans. | as S1 |
| H8 | C | It says explicitly that no production code creates SOURCE_TO_GOLDEN rules and that the path is reached through stored rules. | `ForceRuleJpaRepository.java:46` is the only reference |
| H9 | C | The shared resolver runs at an instant taken in Persistence, with freshness from remaining versions. | §3.7.2 |
| H10 | C | It states the rule and argues that `golden_record.updated` is cache invalidation, not data propagation. | L231; `StewardshipService.java:2973-2976` |

### S3
| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | C | Targeted recalculation: only fields whose lineage names the departed record, or that a deactivated pin fixed, change. The rest of the steward's data stays, and the 409 is kept. | `StewardshipService.java:711-733`; L829 |
| H2 | N | The lineage part is right. Rebuilding `previous` is not addressed, and the create-mode chain makes it null. | L702 |
| H3 | W | It empties data and lineage on orphaning but keeps the score, which is internally inconsistent. That conflicts with "historical read-only". It emits nothing. | DOM-MDM-SURVIVORSHIP-001 L231 |
| H4 | C | Pins are deactivated with the same predicate unmerge uses, value overrides keep applying, and ForceRules are addressed. | L1800; `StewardshipService.java:2416-2418` |
| H5 | C | It runs under the lock taken before the move, before `refreshSourceCounts`, with no exceptions caught. A stale merge fails the version check and goes back to Merge. | `PersistenceStepHandler.java:797-815` |
| H6 | W | When the record is orphaned it publishes no `golden_record.updated`. Only the local eviction runs, so other pods keep stale cache entries. | `GoldenRecordCacheEvictor` is local only; `CacheInvalidationListener.java:45,67` |
| H7 | C | ForceRule is covered, unmerge gets a regression test, and review touches no membership. | as S1 |
| H8 | N | Seeding SOURCE_TO_GOLDEN rules is not mentioned. | `ForceRuleJpaRepository.java:46` |
| H9 | C | The score is recomputed at `Instant.now()`, and for a targeted change over the resulting data. | §3.7.2 |
| H10 | C | It follows the rule literally: nothing is emitted on orphaning, and an orphaning event is to be proposed later. | L231 |

### S4
| H | score | one-line reason | citation |
|---|---|---|---|
| H1 | W | It fully recomputes the survivor, reading the rule as "an enumeration, not an invariant". The 409 guard in the code is exactly that invariant. | `StewardshipService.java:711-733`; `ForceRuleJpaRepository.java:62-73` |
| H2 | N | The lineage part is right, apart from a stewardship value override. `previous` is not addressed. | L702 |
| H3 | C | The record becomes `orphaned` with its data kept as a snapshot. It notes the absorbed vs. orphaned conflict and emits `golden_record.updated`. | L231, L236; DOM-MDM-PIPELINE-001 L1652 |
| H4 | C | `DepartedMemberPinDeactivator` mirrors unmerge, including the legacy and null-id cases. ForceRules are addressed. | L1800; `StewardshipService.java:2409-2438` |
| H5 | C | It locks in ascending id order and checks the losing record against the version read in Merge. A mismatch raises an optimistic-lock failure and membership is re-resolved; the recompute is cleared on retry. | `PersistenceStepHandler.java:719-725, 845-855` |
| H6 | C | It keeps `evictAfterCommit`, emits `golden_record.updated` after a completed run, and computes the tier from the losing record's own prior score. | `CacheInvalidationListener.java:67` |
| H7 | C | ForceRule is covered, unmerge goes through the shared calculator, and review writes no closures. | as S1 |
| H8 | N | Seeding SOURCE_TO_GOLDEN rules is not mentioned. | `ForceRuleJpaRepository.java:46` |
| H9 | C | Merge computes the score with the shared resolver, with freshness from remaining versions only. | §3.7.2 |
| H10 | N | Downstream propagation is "not addressed". It emits `golden_record.updated` for an orphaned record without discussing the rule. | L231 |

### Summary
| design | C | W | N |
|---|---|---|---|
| S1 | 8 | 1 | 1 |
| S2 | 6 | 2 | 2 |
| S3 | 6 | 2 | 2 |
| S4 | 6 | 1 | 3 |

### What separates the designs
- **H1 (manual-merge survivor):** only S3 keeps the steward's decision. S1 and S4 argue their way around the 409 guard at `StewardshipService.java:711-733`, and S2 does not address it.
- **H2 (`previous`):** only S1 rebuilds it. The other three use the create-mode chain, which loses it without saying so, the same way unmerge does today.
- **H3/H6/H10 (orphaning):** S1 and S4 keep a snapshot and emit `golden_record.updated` for cache invalidation. S2 and S3 empty the data, which goes against "historical read-only". S3 also skips the cross-pod invalidation.
- **H4 (pins):** only S2 leaves pins on the departed record active, against DOM-MDM-PIPELINE-001 §10.9.4 pt 2.
- **H8 (seeding):** only S2 recognises that the ForceRule path needs seeded rules.

Two scores are judgment calls. Scoring the data-emptying in S2 and S3 as W rests on how "solo lectura histórica" is read. Scoring H8 as N for S1, S3 and S4 is strict: they do plan tests on the ForceRule branch, and their summaries just never say the rules are seeded.
