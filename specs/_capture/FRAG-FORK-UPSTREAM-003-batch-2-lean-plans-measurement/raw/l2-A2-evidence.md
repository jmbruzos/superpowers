**Claims about current code (aacdae5)**

| # | claim (short) | where | verdict | evidence | design-changing? |
|---|---|---|---|---|---|
| 1 | Unmerge recomputes the original GR over the remaining members' versions, in the same method | Spec premise 1, Problem | TRUE | `StewardshipService.java:434` `remainingStaged = loadVersionsOfMembers(...)`; `:456-462` `setGoldenData`/`setFieldLineage`/`setQualityScore` inside `if (originalGrMergeResult != null)` | – |
| 2 | Class-level `@Transactional` | premise 1 | TRUE | `StewardshipService.java:114` | – |
| 3 | A FORCE_RULE move only calls `cleanUpAfterLosingMember` and does not rewrite L's data; `setGoldenData` appears only at :364/:403/:472 | premise 2, Problem | TRUE | `PersistenceStepHandler.java:806-809` (`move`, `cleanUpAfterLosingMember(...)`, `evictAfterCommit(previous)`); `:863-870`; `setGoldenData` at 364, 403, 472 | – |
| 4 | L that loses its only member stays `active` with `source_count = 0` | Problem | TRUE | the branch never touches status; `:815` `refreshSourceCounts` | – |
| 5 | Nobody publishes `golden_record.updated` for L; it gets local eviction only | premise 16 | TRUE | `PersistenceStepHandler.java:809`; `IngestService.java:418` and `AsyncPipelineExecutor.java:222` emit only for `context.getGoldenRecordId()` | – |
| 6 | Nobody writes `REVIEW_RESOLUTION`; `ReviewQueueService` does not touch the xref | premise 3 | TRUE | only `MembershipOperationKind.java:28`; `ReviewQueueService.java:53` constructor takes only `ReviewCaseJpaRepository` | – |
| 7 | StewardshipService repeats the create+update chain in **three private methods** (both `reSurvivorshipFromSources` overloads plus `WithOverride`) | Problem, comp. 2, task 001 | FALSE | Only two copies exist. The 5-arg overload is package-private and only delegates (`:2875-2880` `return reSurvivorshipFromSources(..., mergeEngine)`). The chain lives at `:2898-2937` and `:3086-3121`. | no |
| 8 | Manual merge and consolidation move all members of the absorbed GRs and leave them non-active | premise 4 | TRUE | `StewardshipService.java:945` `ABSORBED`, `:995` `moveAllMembers`; `PersistenceStepHandler.java:759`, `:482` `MERGED` | – |
| 9 | The orphan branch acts only when the previous GR is missing, `deleted` or `orphaned`, under FOR UPDATE | premise 5 | TRUE | `PersistenceStepHandler.java:787`, `:823-834` | – |
| 10 | Field lineage lives only in `golden_records.field_lineage`; `getFieldLineage` is a stub | premise 6 | TRUE | `GraphStoreJpaAdapter.java:279-282` returns `List.of()`; only V10 mentions `mdm_lineage.field_lineage` | – |
| 11 | The `DefaultMergeEngine` bean carries the FieldOverrideProvider; a value-less `source_pin` falls back to survivorship | premise 7 | TRUE | `DefaultMergeEngine.java:36` `@Component`, `:52-53`, `:118-120` `fallbackToSurvivorship = true` | – |
| 12 | `findVersionsOfMembers` order | premise 8 | TRUE | `StagedRecordJpaRepository.java:74` `ORDER BY coalesce(s.received_at, s.created_at) ASC, s.source_record_id ASC, s.source ASC, s.created_at ASC` | – |
| 13 | `lockGoldenRecordsBeforeMove` locks the target and the previous GR in ascending id order | premise 9 | TRUE | `PersistenceStepHandler.java:257`, `:702-724`; `GoldenRecordJpaRepository.java:63-65` `PESSIMISTIC_WRITE` | – |
| 14 | MergeStepHandler reads `membership()`, whose record carries `conflictFromGoldenRecordId` and `forceRuleId` | premise 10 | TRUE | `MergeStepHandler.java:309`; `MembershipResolution.java:29-30` (today only `kind` and `target` are used) | – |
| 15 | On `OptimisticLockingFailureException` the orchestrator re-resolves membership, clears merge output and re-merges with a fresh read | premise 11 | TRUE | `PipelineOrchestrator.java:275-290` (`setFreshGoldenRecordRead(true)`, `clearMergeOutput()`, `rematchIfMembershipChanged`, `"merging_retry"`), `:337` | – |
| 16 | `SourceRecordVersionReader` has only `findLatestVersion`, and its record has no quality score | premise 12 | TRUE | `SourceRecordVersionReader.java` (5-component record); adapter `toSourceRecordVersion` | – |
| 17 | `ORPHANED` exists; the match ignores a ForceRule whose target is deleted or orphaned | premise 13, D3 | TRUE | `GoldenRecordStatus.java:16`; `DefaultMatchEngine.java:295-299` | – |
| 18 | api-gateway and ingest-service depend on merge-engine, which depends only on core | premise 14 | TRUE | the three `pom.xml` files | – |
| 19 | Unmerge deactivates pins after the recompute | premise 15 | TRUE | `StewardshipService.java:435`, `:526` | – |
| 20 | PersistenceStepHandler already emits `GoldenRecordQualityChanged` | premise 17 | TRUE | `PersistenceStepHandler.java:418`, `:637` `ingestEventEmitter.emitGoldenRecordQualityChanged` | – |
| 21 | ConsolidationOverrideMigrator deactivates with `system:pipeline` inside the Persistence transaction | premise 18 | TRUE | `ConsolidationOverrideMigrator.java:35`, `:66-69`; `PersistenceStepHandler.java:499` | – |
| 22 | `refreshSourceCounts` is a native UPDATE that does not bump `version` (premise 19 is correctly ruled false) | premise 19, task 004 step 5 | TRUE | `SourceMembershipRepositoryAdapter.java:207-221` | – |
| 23 | Manual merge does not touch `goldenData` (premise U2) | D2 | TRUE | `StewardshipService.java:1003-1005` "No re-survivorship: goldenData itself is not touched by manual merge" | – |
| 24 | `reSurvivorship` refuses manual-merge survivors | A1 attack 1(+) | TRUE | `StewardshipService.java:719-731` | – |
| 25 | Chain details: trust 1.0, quality or 0.8, last three args null, id `"re-survivorship-"+UUID` | comp. 1, task 001 | TRUE | `StewardshipService.java:2905-2937` | – |
| 26 | `WithOverride` uses the `mergeEngine` bean, id `"preview-correction-"`, and puts the override on the `overrideStagedRecordId` row | task 001 | TRUE | `StewardshipService.java:3097-3120` | – |
| 27 | A 15-arg `MergeRequest` constructor exists | task 001 | TRUE | `MergeRequest.java:93-101` | – |
| 28 | Accessor names `existingData()` / `existingLineage` | task 001 step 1 | FALSE | The accessor is `existingGoldenData()` (`MergeRequest.java:56`). The task flags this itself ("usa los nombres reales"). | no |
| 29 | `StagedRecordEntity.getQualityScore()` returns BigDecimal | task 002 | TRUE | `StagedRecordEntity.java:123` | – |
| 30 | `SourceRecordIdentity` has a 4-arg constructor; `MemberBlockingKeyGeneratorTest:75` uses the 5-arg version | task 002 | TRUE | `SourceRecordIdentity.java:16`; `MemberBlockingKeyGeneratorTest.java:75` | – |
| 31 | `findVersionsOfMembers(String, String, String[], String[])` signature | task 002 | TRUE | `StagedRecordJpaRepository.java:76-77` | – |
| 32 | `clearMergeOutput` is at :212-225 | task 003 | TRUE | `PipelineContext.java:212-225` | – |
| 33 | MergeStepHandler constructor at :91-103, `execute` at :146-285 | task 003 | TRUE | `MergeStepHandler.java:90-103`, `:146-276` | – |
| 34 | `GoldenRecordFullData` carries `version` and `status` | task 003 | TRUE | `GoldenRecordLookup.java:88-95` | – |
| 35 | APIs exist: `findCurrentMembers`, `resolve`, `QualityScoreInput`, `tierFor`, `lookup` | task 003 | TRUE | `SourceMembershipRepository.java:35`; `LatestSourceReceivedAtResolver.java:47` (takes `Collection`); `QualityScoreResolver.java:61, 70, 95`; `MergeStepHandler.lookup` | – |
| 36 | PersistenceStepHandler: constructors :156-245, output :282-292, FORCE_RULE branch :802-811 | task 004 | TRUE (ranges drift) | constructors are at `:134-232`, output at `:288-297`, branch at `:802-810` | no |
| 37 | Guard: a null expected version is a conflict | task 004 | TRUE | `PersistenceStepHandler.java:585` `if (expected != null && gr != null && gr.getVersion() == expected && active)` | – |
| 38 | A null previous score falls back to 0.5 | comp. 6 | TRUE | `PersistenceStepHandler.java:632` | – |
| 39 | `setStatusEnum` exists; `getVersion` is the JPA `@Version`; the OverrideType import path | task 004 | TRUE | `GoldenRecordEntity.java:41, 104, 111`; `StewardshipService.java:16` | – |
| 40 | `autoDeactivatePins` criterion; the repository finder signature | task 004 | TRUE | `StewardshipService.java:2409-2420`; `FieldOverrideRuleJpaRepository.java:39-40` | – |
| 41 | Emitter blocks emit `golden_record.updated` only on COMPLETED | comp. 7, task 005 | TRUE | `IngestService.java:392-421`, `AsyncPipelineExecutor.java:200-225` | – |
| 42 | The `event` package does not depend on `pipeline`; a null survivor goes into a HashMap; arity is 5/10/10 | task 005 | TRUE | `IngestEventEmitter.java:128, 249, 273-286` | – |
| 43 | Schema fixture: 4 properties, email `source_priority [crm, erp_sap, web]`, default `most_recent`, `legal_name` uppercased | task 006 | TRUE | `source-identity-supplier-schema.json:87` and the `x-mdm` survivorship block | – |
| 44 | Normalised `golden_data`; field_weights default to 1.0 | task 006 | TRUE | `FullPipelineIT.java:466`; `AsyncNatsE2EIT.java:104-105`; `SchemaCompiler` around `:290-296` (`weight = 1.0`) | – |
| 45 | SourceIdentityPipelineIT setup at :62-85, `forceRuleMovesLinkedRecord` at :206-273, helpers exist | task 006 | TRUE | `SourceIdentityPipelineIT.java:62, 207-273, 579, 600, 650, 702, 708` | – |
| 46 | `@MockitoSpyBean` pattern; the unmerge IT separates S3; no NATS in base IT | task 006 | TRUE | `SourceIdentityRaceIT.java:70-71`; `StewardshipFlowsIT.java:66-90`; `BaseIntegrationTest.java:20` | – |
| 47 | Smaller line citations hold | A1/A2 tables | TRUE | `DefaultMergeEngineTest.java:49-57`; `GoldenQualityScoreCalculator.java:19-21`; `StewardshipService.java:2418, 2428-2434, 443-454`; `MergeStepHandler.java:241` | – |
| 48 | RFC-PIPE-039 is `accepted` (commit `2356db2`) | plan, Dependencies | TRUE on branch | At aacdae5 it is still `status: draft`. `2356db2` is not an ancestor of aacdae5; it exists only on `wrk/member-loss-001-a2`. | no |

**Knowledge violations**

| # | violated rule (ID §) | quote | where in artifact |
|---|---|---|---|
| 1 | ADR-001, "Principios arquitectónicos que SE MANTIENEN" #2 (and ARCH-MDM-PRINCIPLES-001 P9) | "Repository Pattern: ZERO imports directos de JPA fuera de `mdm-persistence`" | Task 004: the new `DepartedMemberPinDeactivator` in mdm-ingest-service reads and saves through `FieldOverrideRuleJpaRepository` / `FieldOverrideRuleEntity`. This also contradicts the spec's own AC10. `ConsolidationOverrideMigrator` already does the same, so there is precedent, but the debt grows. |
| 2 | DOM-MDM-PIPELINE-001 §10.8.4 point 3 | "Si el GR origen queda sin registros fuente, se marca como `absorbed`." | D3 / component 6 / AC2 set `orphaned`. The artifact acknowledges this as G1, and DOM-MDM-SURVIVORSHIP-001 §3.2 supports `orphaned`. |
| 3 | DOM-MDM-SURVIVORSHIP-001 §3.2, `orphaned` row | "`orphaned` … Propaga downstream: No" | Component 7 / task 005 `noQualityChangeWhenSameTierOrNoNewTier`: for an orphaned L ("newTier null (orphaned) → sí emitGoldenRecordUpdated") it still publishes `golden_record.updated`. This one is debatable: the event also serves cross-pod cache invalidation. |

**Executability**
- Every task has a red step and a green step with a concrete `mvn` command: 001, 002, 003, 004 and 005 run unit tests; 006 runs ITs through failsafe plus `mvn -q verify`. Task 006 needs Docker for Testcontainers.
- The order is valid: 001 and 002 have no dependencies; 003 uses both; 004 uses 003; 005 uses 004; 006 uses 001–005. No task consumes something a later task creates. `LosingGoldenRecordWrite` and its `PipelineContext` field are created in 004 and first consumed in 005.
- Minor defects that don't block execution:
  - Task 001's AC says "4 tests de arriba", but six are listed.
  - Task 005's snippet assumes a local `entityType` in `IngestService`. There isn't one there; it has to use `dto.entityType()`.

`claims=48 TRUE=46 FALSE=2 UNVERIFIABLE=0 design-changing-FALSE=0 violations=3 tasks-without-runnable-test=0 order-valid=yes`
