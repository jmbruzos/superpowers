| # | claim (short) | where | verdict | evidence | design-changing? |
|---|---|---|---|---|---|
| 1 | force_rule branch: after `move` only cleanUp/evict/refreshSourceCounts; L's golden_data, lineage, score, version, pins and events untouched | Spec Problem; CP1 | TRUE | `PersistenceStepHandler.java:806` `membershipRepository.move(id, grId, at, kind, operationId);` `:808` `cleanUpAfterLosingMember(...)` `:815` `refreshSourceCounts` | — |
| 2 | `moveAllMembers` only in consolidation | CP1 | TRUE | `PersistenceStepHandler.java:759` inside `if ("consolidate"...)` | — |
| 3 | L locked FOR UPDATE before move | CP2 | TRUE | `PersistenceStepHandler.java:723` `lockGoldenRecord(ctx, id, ids)`, `:804`; `GoldenRecordJpaRepository.java:63-65` `@Lock(LockModeType.PESSIMISTIC_WRITE)` | — |
| 4 | Last member leaving: L stays `active` with source_count 0 | Spec Problem | TRUE | no status write in `persistMembership` (`:750-817`); `SourceMembershipRepositoryAdapter.java:212-216` count from xref | — |
| 5 | unmerge recomputes the original over the remaining xref members | Spec Problem; CP3 | TRUE | `StewardshipService.java:434-435` `loadVersionsOfMembers(..., remaining)` → `reSurvivorshipFromSources(` | — |
| 6 | unmerge overwrites golden_data/field_lineage with `valueToTree` at `StewardshipService.java:455-456` | CP3; 004 Premises | FALSE (line) | literal is at `:458-459` `originalGr.setGoldenData(objectMapper.valueToTree(...))`; `:455-456` is `QualityScoreResult originalGrResult = null;`. Behaviour true | no |
| 7 | unmerge deactivates source_pins to separated records | Spec Problem | TRUE | `StewardshipService.java:526` `autoDeactivatePins(originalGrId, ...)`; `:2409-2418` | — |
| 8 | unmerge refuses to separate all members | CP3 | TRUE | `StewardshipService.java:2256-2258` `"Cannot separate all source records..."` | — |
| 9 | `reSurvivorshipFromSources` chains create then update with `goldenRecordId = grId` | CP4 | TRUE | `StewardshipService.java:2898-2935` (`"create"` `:2911`, `"update"` `:2925`, `grId` passed) | — |
| 10 | Silver versions ordered coalesce(received_at, created_at), srid, source, created_at | CP4; 001 | TRUE | `StagedRecordJpaRepository.java:74` `ORDER BY coalesce(s.received_at, s.created_at) ASC, s.source_record_id ASC, s.source ASC, s.created_at ASC` | — |
| 11 | trust 1.0, default quality 0.8, 15-arg `MergeRequest` ctor | 002 | TRUE | `StewardshipService.java:2913-2914` `1.0, ... : 0.8`; `MergeRequest.java:93` 15-arg ctor | — |
| 12 | `reSurvivorshipFromSources` returns null without sources | 002; A2 | TRUE | `StewardshipService.java:2902-2904` `if (sources.isEmpty()) { return null; }` | — |
| 13 | DefaultMergeEngine resolves source_pin from incoming then `existingRecords()` lineage, else falls back | CP5 | TRUE | `DefaultMergeEngine.java:237-257` `findPinnedSourceValue`; `:118-122` `fallbackToSurvivorship = true` | — |
| 14 | `SourceRecordVersionReader` only `findLatestVersion`; record has no qualityScore | CP6 | TRUE | `SourceRecordVersionReader.java:27`, `:38-39` `record SourceRecordVersion(identity, stagedRecordId, normalizedData, receivedAt, createdAt)` | — |
| 15 | Adapter is the only implementation and only production constructor; test builds 5-arg record | CP6; 001 | TRUE | `SourceRecordVersionReaderAdapter.java:19`, `:45`; `MemberBlockingKeyGeneratorTest.java:75` | — |
| 16 | `StagedRecordEntity.getQualityScore()` returns BigDecimal | 001 | TRUE | `StagedRecordEntity.java:123` `public BigDecimal getQualityScore()` | — |
| 17 | ingest-service depends on merge-engine, persistence, core; gateway on ingest-service | CP7 | TRUE | `mdm-ingest-service/pom.xml:20,24,44`; `mdm-api-gateway/pom.xml:28` | — |
| 18 | QualityScoreResolver / LatestSourceReceivedAtResolver in ingest-service, used by StewardshipService | CP8 | TRUE | `mdm-ingest-service/.../quality/`; `StewardshipService.java:171`, `:179` | — |
| 19 | No production code sets ORPHANED | CP9 | TRUE | only `DefaultMatchEngine.java:296`, `PersistenceStepHandler.java:829`, `GoldenRecordStatus.java:16` | — |
| 20 | Post-persistence events only for the context's golden record | CP10 | TRUE | `AsyncPipelineExecutor.java:222`, `IngestService.java:418` `emitGoldenRecordUpdated(context.getGoldenRecordId(), ...)` | — |
| 21 | Concurrent run checks expected version and retrocedes to Merge | CP11 | TRUE | `PersistenceStepHandler.java:577-595` `assertExpectedVersion`; `PipelineOrchestrator.java:337` `catch (OptimisticLockingFailureException e)` | — |
| 22 | `refreshSourceCounts` is a native UPDATE that does not bump `@Version` | CP11 | TRUE | `SourceMembershipRepositoryAdapter.java:212-216` `UPDATE mdm_gold.golden_records g SET source_count = ...`; `GoldenRecordEntity.java:41-43` | — |
| 23 | Review resolution does not move spans (`REVIEW_RESOLUTION` unused) | CP12 | TRUE | only `MembershipOperationKind.java:28` | — |
| 24 | Only production ForceRule creation is GOLDEN_TO_GOLDEN | CP13 | TRUE | `StewardshipService.java:962-965` sole `new ForceRuleEntity()` | — |
| 25 | A ForceRule moves the record on its next ingestion | CP13 | TRUE | `SourceIdentityPipelineIT.java:236-239` span `opened_by_kind = force_rule` | — |
| 26 | `forceRuleMovesLinkedRecord` checks spans, keys, source_count, not L's golden_data/lineage | CP14 | TRUE | `SourceIdentityPipelineIT.java:207-261` | — |
| 27 | Manual merge / consolidation: only non-active records lose all members | Spec Problem | TRUE | xref move callers: `StewardshipService.java:995` (moveAllMembers), `:2288` (unmerge), `PersistenceStepHandler.java:759`, `:806` | — |
| 28 | `emitGoldenRecordUpdated` carries only goldenRecordId and entityType | Constraints; A1 | TRUE | `IngestEventEmitter.java:128-134` `Map.of("goldenRecordId", ..., "entityType", ...)` | — |
| 29 | ConsolidationOverrideMigrator deactivates with `system:pipeline` over FieldOverrideRuleJpaRepository and publishes after commit | Components | TRUE | `ConsolidationOverrideMigrator.java:35`, `:66-77`, `:85-93` `registerSynchronization(... afterCommit ...)` | — |
| 30 | Events are best-effort ("errors logged, not propagated") | Alternatives | TRUE | `CLAUDE.md:134`; `IngestEventEmitter.java:313-315` catch + `log.warn` | — |
| 31 | F's GoldenRecordQualityChanged is emitted inside the transaction, before the recompute | E1; A2 | TRUE | `PersistenceStepHandler.java:260` `persistGoldenRecord(ctx)` → `:418` `maybeEmitQualityTierChange(...)` (direct emit) | — |
| 32 | Tier comparator `maybeEmitQualityTierChange` at :625-640 with 0.5 default | 005 | TRUE | `PersistenceStepHandler.java:625`, `:632` `previousScore != null ? ... : 0.5` | — |
| 33 | Data flow: "bloquea L y F → staged → escribe F" | Spec Data flow | FALSE | staged is persisted first (`PersistenceStepHandler.java:248` `persistStagedRecord(ctx)`), then lock (`:257` `lockGoldenRecordsBeforeMove`) | no |
| 34 | Non-active L: absorbed → `consolidation`; missing/deleted/orphaned → `pipeline_run` with `membership_orphan` | Spec Architecture | FALSE | under a ForceRule the FORCE_RULE branch is evaluated first (`PersistenceStepHandler.java:777-780`), so any non-active L reaches `force_rule`; corrected by E1 | yes (corrected by E1) |
| 35 | Members without Silver versions: L intact "same criterion as unmerge and /admin/re-survivorship" | E1; A2 | FALSE (partly) | admin path leaves L intact (`StewardshipService.java:646-647`); unmerge still overwrites `latest_source_received_at` with `resolve([])` = null regardless (`:452-454`) | no |
| 36 | null status counts as active | 004; A2 | TRUE | `PersistenceStepHandler.java:583-584` `gr.getStatus() == null \|\| ...ACTIVE...` | — |
| 37 | FORCE_RULE evaluated before the orphan case | E1; 004 | TRUE | `PersistenceStepHandler.java:777` before `:786` `isMissingOrOrphanUnderLock` | — |
| 38 | `findByGoldenRecordIdAndTenantIdAndActiveAndOverrideType` exists at :39 | 003 | TRUE | `FieldOverrideRuleJpaRepository.java:39` | — |
| 39 | called with `OverrideType.SOURCE_PIN.name()` | 003 | TRUE | `StewardshipService.java:2411-2413` | — |
| 40 | `getPinnedSource()` used at `StewardshipService.java:2416` | 003 Premises | FALSE (line) | used at `:2418`; getter at `FieldOverrideRuleEntity.java:113`. Behaviour true | no |
| 41 | `emitFieldOverrideAutoDeactivated` 10-arg signature | 003 | TRUE | `IngestEventEmitter.java:273-276` | — |
| 42 | `emitGoldenRecordQualityChanged` signature; `tierFor(String,String,double)` | 005 | TRUE | `IngestEventEmitter.java:249-253`; `QualityScoreResolver.java:95` | — |
| 43 | `QualityScoreResolver.resolve(QualityScoreInput)` 6-field input; `LatestSourceReceivedAtResolver.resolve(Collection<Instant>)` | 002 | TRUE | `QualityScoreResolver.java:61-63`, `:70`; `LatestSourceReceivedAtResolver.java:47` | — |
| 44 | `SourceMembershipRepository.findCurrentMembers(String,String)` | 002 | TRUE | `SourceMembershipRepository.java:35` | — |
| 45 | `GoldenRecordJpaRepository.findByIdForUpdate(UUID)` exists | 004 | TRUE | `GoldenRecordJpaRepository.java:65` | — |
| 46 | golden_data/field_lineage are JsonNode; version is `@Version` | 004 Premises | TRUE | `GoldenRecordEntity.java:39`, `:53`, `:41-43` | — |
| 47 | `MergeStepHandler:256-258` uses `Instant.now()` inline, not stored | 004 Premises | TRUE | `MergeStepHandler.java:258` `latestSourceReceivedAt, java.time.Instant.now()));` | — |
| 48 | Merge uses `ctx.getSurvivorshipConfig()` | A1 | TRUE | `MergeStepHandler.java:210` | — |
| 49 | Constructors :135-230, `persistMembership` :750-817, test-null collaborators :101, :145-163 | 004; A2 | TRUE | `PersistenceStepHandler.java:135`, `:750`, `:817`, `:101` | — |
| 50 | `afterCommit` of `ConsolidationOverrideMigrator.java:116-125` | 005 Premises | FALSE | file has 94 lines; `private static void afterCommit` is at `:85-93` (private: PersistenceStepHandler must duplicate it) | no |
| 51 | Existing tests `PersistenceStepHandlerTest:1004` (force rule) and `:1192` (consolidate) | 004 | TRUE | `PersistenceStepHandlerTest.java:1004`, `:1192` | — |
| 52 | SIPIT `:445` concurrent span test, `awaitSessionWaitingOnLock` :489 (waits for >0), `resetSpan` :639, helpers ingest/insertForceRule/sourceCount/goldenData/manualMerge | 004, 006 | TRUE | `SourceIdentityPipelineIT.java:445`, `:489-505` `if (rs.getLong(1) > 0) return;`, `:579`, `:626`, `:639`, `:650`, `:708`, `:713` | — |
| 53 | SIPIT `:276-297` fixture has the absorbed record as target | A2 | TRUE | `SourceIdentityPipelineIT.java:276` `forceRuleToAbsorbedTargetMovesRecordToTheSurvivor` | — |
| 54 | Schema: `most_recent` default; email `source_priority [crm, erp_sap, web]`; exact tax_id strategy | 004; A2 | TRUE | `source-identity-supplier-schema.json:31-38`, `:67`, `:70-72` | — |
| 55 | `StewardshipFlowsIT.unmerge_recomputesSurvivorshipOnBothGoldenRecords` :68 separates `web_portal:S3` | 006 | TRUE | `StewardshipFlowsIT.java:68`, `:72` | — |
| 56 | `AdminReSurvivorshipIT` has `@MockitoSpyBean EventPublisher` and `eventsFor`/`eventsOfType` :298-311 | 005 | TRUE | `AdminReSurvivorshipIT.java:75`, `:298-311` | — |
| 57 | `EndToEndIngestIT:213` uses `/ingest/async` | 005 | TRUE | `EndToEndIngestIT.java:213` | — |
| 58 | `pinned_source` from V37; `uq_field_override_active`; override columns | 004 | TRUE | `V37__source_record_xref.sql:48`; `V22__create_stewardship_rules.sql:54-72` | — |
| 59 | Golden record id is a global PK | A1 | TRUE | `V9__create_gold_tables.sql:3` `id UUID PRIMARY KEY` | — |
| 60 | Persistence transaction is READ COMMITTED (no isolation override) | 006 Premises | TRUE | no `isolation`/`setIsolationLevel` under `src/` (PostgreSQL default) | — |
| 61 | A recompute failure follows persistence failure path (retry, DLQ) | Error handling | TRUE | `PipelineOrchestrator.java:352-370` generic `catch (Exception e)` → retry, then `handleDeadLetter` | — |
| 62 | Retries record `OPTIMISTIC_LOCK_RETRY` | 006 | TRUE | `PipelineOrchestrator.java:345-346` | — |
| 63 | ForceRule to deleted/orphaned target is ignored with warning | Architecture | TRUE | `DefaultMatchEngine.java:272-273`, `:295-296` | — |
| 64 | Admin re-survivorship refuses manual-merge survivors | A1 | TRUE | `StewardshipService.java:720-731` | — |
| 65 | Survivorship config loaded from active schema | A1 | TRUE | `StewardshipService.java:2720-2722` | — |
| 66 | An orphaned record remains queryable | A1 | TRUE | `GoldenRecordController.java:61-65` list takes any `status` | — |
| 67 | IT expectations: golden_data equals raw literals (`legal_name "Lima Logistica SL"`, `"Zeta Transportes"`, `phone "+34 699 000 001"`) | 004 Step 2; 006 Step 1 | FALSE | golden_data stores normalized data (`MergeStepHandler.java:207` `ctx.getNormalizedData()`); schema normalizes legal_name to uppercase (`source-identity-supplier-schema.json:87`) and phone to E.164 (`:101`); cf. `FullPipelineIT.java:466` asserts `"NEW NAME UPDATED"` | yes (ITs fail after correct implementation) |
| 68 | Regression ITs `SourceIdentityRaceIT`, `StewardshipMembershipIT`, `BlockingKeyRebuildIT`, `CacheInvalidationNatsIT` exist | 001, 004, 005 | TRUE | `src/mdm-app/src/test/java/com/mdm/integration/*.java` | — |
| 69 | Endpoint `POST /api/v1/admin/re-survivorship/{id}` | AC1; 004 | TRUE | `AdminController.java:24` `@RequestMapping("/api/v1/admin")`, `:69` `@PostMapping("/re-survivorship/{goldenRecordId}")` | — |

| # | violated rule (ID §) | quote | where in artifact |
|---|---|---|---|
| 1 | DOM-MDM-PIPELINE-001 §10.8.4 p.3 | "**Recálculo del GR origen** (sin el registro fuente que se mueve). Si el GR origen queda sin registros fuente, se marca como `absorbed`." | Spec Architecture ("pasa a `orphaned`"), AC3, task 002 `ORPHANED`, task 004 step 4. Acknowledged as a knowledge gap against SURVIVORSHIP §3.2, but it still contradicts an activated spec |
| 2 | DOM-MDM-SURVIVORSHIP-001 §3.2 (state table) | "`orphaned` \| ... \| Sí (solo lectura histórica) \| No \| No" | Spec Architecture and AC3: `golden_data = {}`, `field_lineage = {}`, so the historical read of the record returns nothing (A1 ruling "golden_data y field_lineage vacíos") |
| 3 | DOM-MDM-LINEAGE-001 §3.8.1 / §3.8.2 | "**MINOR**: Cambios compatibles (nuevos campos opcionales, extensiones). Mismo tipo de evento, nueva versión." | Task 005 `emitGoldenRecordMemberLeft` adds `status`, `reason`, `version`, `fields_changed`, `previous_values`, `pipeline_run_id` to `golden_record.updated` ("mismo `eventType` y agregado") with no version bump (`IngestEventEmitter.java:30` `EVENT_VERSION = 1`) |

Executability:
- Every task (001–006) has a runnable test command. 001–005 run red, then green. 006 has no red step: its tests characterize existing behaviour, and the version-bump check is done by hand-commenting `saveAndFlush(L)`.
- Order is valid: 001→002→004→005→006 and 003→004. No task uses something a later task creates. 004 consumes 002/003, 005 consumes 004's `LosingMemberWrite`, 006 reuses 004's fixture.
- Defects that break execution:
  - (a) The IT literals in 004 and 006 ignore the schema's normalizers (row 67). Those ITs fail even with a correct implementation.
  - (b) Task 004's Interfaces declare `Kind { RECOMPUTED, ORPHANED }`, but 002 and 004 Step 4/tests use `UNRESOLVED`.
  - (c) Task 004's Test Plan says 6 unit tests, but Step 1 lists 8.
  - (d) Task 005 cites a non-existent line range for a private static helper (row 50), so PersistenceStepHandler must re-implement it.
  - (e) Commands use `-Dtest=none -DfailIfNoTests=false` (and `-am -Dtest=X` for unit tests) on Spring Boot 3.4.4 / surefire 3. These may need `-Dsurefire.failIfNoSpecifiedTests=false`, as `WRK-PLAN-MDM-MERGE-CONCURRENCY-001:63` uses. Not verified by running.

claims=69 TRUE=62 FALSE=7 UNVERIFIABLE=0 design-changing-FALSE=2 violations=3 tasks-without-runnable-test=0 order-valid=yes
