Evidence check of B2 (losing-member recompute spec, plan and tasks 001-005) against mdm-platform aacdae5. Paths are relative to `src/` unless they start with `specs/`.

Main findings:
- Of 65 claims about current code, 59 are TRUE and 6 are FALSE. Five FALSE claims are line anchors or a test-usage note. One matters: StewardshipService has a second create→update loop that the plan does not know about, so AC9 cannot pass as written.
- There are 3 knowledge violations, all quotable.
- Every task has a runnable test step and the task order is valid.

**1. Claims about current code**

| # | claim (short) | where | verdict | evidence | design-changing? |
|---|---|---|---|---|---|
| 1 | After a FORCE_RULE `move`, the record that loses the member only gets cleanUp, evictAfterCommit and refreshSourceCounts; no golden_data/lineage/score write; no `emitGoldenRecordUpdated` in PSH | Spec P1, Data flow | TRUE | `PersistenceStepHandler.java:806-809` `membershipRepository.move(...); touched.add(previous); cleanUpAfterLosingMember(...); cacheEvictor.evictAfterCommit(previous);`, `:815` `refreshSourceCounts`; grep finds no `emitGoldenRecordUpdated` in PSH | – |
| 2 | That record is locked FOR UPDATE before the move | P2 | TRUE | PSH:723 `lockGoldenRecord(ctx, id, ids)`, :803-805; `GoldenRecordJpaRepository.java:63-65` `@Lock(LockModeType.PESSIMISTIC_WRITE)` | – |
| 3 | refreshSourceCounts is a native UPDATE; no `@DynamicUpdate` | P3, Data flow | TRUE | `SourceMembershipRepositoryAdapter.java:212-219` `em.createNativeQuery("""UPDATE mdm_gold.golden_records g SET source_count = ...`; grep finds no DynamicUpdate | – |
| 4 | unmerge recomputes the original over the remaining members; on `null` it keeps golden_data/lineage | P4, table | TRUE | `StewardshipService.java:434-437`, :457 `if (originalGrMergeResult != null) {` with no else | – |
| 5 | The 5-arg overload is package-private and delegates to the private 6-arg chain at 2898-2933 | P5, Components 1, T001 | TRUE | SS:2875-2879, SS:2898-2933 (`"create"` …, then `for (int i = 1; …) "update"`) | – |
| 6 | Callers at :435, :650, :1434, :1508, :1520; ephemeral engine at :1749-1750 | P5 | TRUE (list incomplete) | All exist. More callers at SS:407, 1264, 1901, 2514 | – |
| 7 | The 6-arg overload is the only create→update loop, so after T001 the chain has a single owner ("único dueño"; AC9 "sin copia propia"; T001 javadoc says the previews use it) | Components 1, AC9, T001 | FALSE | `reSurvivorshipFromSourcesWithOverride` at SS:3086-3123 has its own loop: `String action = (i == 0) ? "create" : "update"; … result = mergeEngine.merge(req);` | yes (AC9 cannot pass after T001 as planned) |
| 8 | The 5-arg overload is called by `StewardshipServiceTest` | T001 Step 5 | FALSE | No call in `StewardshipServiceTest.java`, only comments at :197 and :1275. The claim repeats the code comment at SS:2872 | no |
| 9 | No production code closes spans with REVIEW_RESOLUTION; `ReviewQueueService` does not touch the xref | P6, table | TRUE | Only `MembershipOperationKind.java:28`; grep `embership\|xref` in `ReviewQueueService.java` is empty | – |
| 10 | CONSOLIDATION/PIPELINE_RUN only move from absorbed/missing/deleted/orphaned/non-active records; only FORCE_RULE leaves an active previous record | P7, table | TRUE | PSH:777-792, PSH:824-833 | – |
| 11 | Nothing writes ORPHANED; Match ignores an orphaned ForceRule target; orphaned counts as an orphan record | P8 | TRUE | Only `GoldenRecordStatus.java:16`; `DefaultMatchEngine.java:296`; PSH:829 | – |
| 12 | Module dependencies: gateway → ingest; ingest → merge-engine and persistence | P9 | TRUE | `mdm-api-gateway/pom.xml:28`; `mdm-ingest-service/pom.xml:24,44` | – |
| 13 | `survivorshipConfig` is set before Persistence | P10 | TRUE | `IngestService.java:174`, `AsyncPipelineExecutor.java:173`, `MergeStepHandler.java:210` | – |
| 14 | `golden_record.updated` is consumed by `CacheInvalidationListener`; the evictor is in-process only | P11 | TRUE | `IngestEventEmitter.java:134`; `CacheInvalidationListener.java:67`; `GoldenRecordCacheEvictor.java:36-50` | – |
| 15 | A SOURCE_PIN to a record not among the inputs falls back to survivorship | P12, OQ-1 | TRUE | `DefaultMergeEngine.java:117-120` `fallbackToSurvivorship = true`; :237-255 | – |
| 16 | `findVersionsOfMembers` has a deterministic ORDER BY and an inner join that drops identities without rows | P13, OQ-2 | TRUE | `StagedRecordJpaRepository.java:69-77` `JOIN unnest(...) … ORDER BY coalesce(s.received_at, s.created_at) ASC, s.source_record_id ASC, s.source ASC, s.created_at ASC` | – |
| 17 | No test asserts the recompute of the losing record | P14 | TRUE | SourceIdentityPipelineIT:207-271 and 445-486 assert only xref, keys and source_count | – |
| 18 | ConsolidationOverrideMigrator has a private static `afterCommit` helper | P15 | TRUE | `ConsolidationOverrideMigrator.java:85-91`, used at :75 | – |
| 19 | No production code creates SOURCE_TO_GOLDEN; manual merge creates GOLDEN_TO_GOLDEN | P16, scope | TRUE | `ForceRule.java:13,53`, `V22:32`, `ForceRuleJpaRepository.java:34,46,65`; SS:965 `GOLDEN_TO_GOLDEN.name()` | – |
| 20 | Propagation emits the written record's event in AsyncPipelineExecutor and IngestService | P17, Data flow | TRUE | APE:200-225 (`emitGoldenRecordUpdated` :222); IS:392-421 (:418) | – |
| 21 | PipelineContext has `schemaVersion` and `clearMergeOutput()`; GoldenRecordEntity has `schemaVersion` | P18 | TRUE | `PipelineContext.java:42,108-109,212-225`; `GoldenRecordEntity.java:55-56,131-132` | – |
| 22 | Manual merge sets the absorbed record to `absorbed` | table | TRUE | SS:945 `absorbed.setStatus(GoldenRecordStatus.ABSORBED.getValue())` | – |
| 23 | mdm-ingest-service already imports JPA entities and repositories | KG | TRUE | PSH:27-32 | – |
| 24 | `MAP_TYPE_REF` at :121, used 9 times | T001 | TRUE | SS:121; grep count is 9 | – |
| 25 | `mergeEngine` field at :142; constructor assignment at :317 | T001 | TRUE | SS:142, SS:317 | – |
| 26 | MergeRequest record (:53) has a 15-arg constructor and accessors `incomingSourceRecordId`/`incomingQualityScore`/`existingFieldLineage` | T001 | TRUE | `MergeRequest.java:53-71`, :93-101 | – |
| 27 | `findByIdAndTenantId(UUID,String)` | T002 | TRUE | `GoldenRecordJpaRepository.java:53` | – |
| 28 | `findCurrentMembers(tenant, gr)` returns `List<MembershipSpan>`; SourceRecordIdentity has 4 fields | T002 | TRUE | `SourceMembershipRepository.java:35`; `SourceRecordIdentity.java:16` | – |
| 29 | QualityScoreResolver: `resolve(QualityScoreInput)`, `tierFor(String,String,double)`, `@Component` | T002 | TRUE | `QualityScoreResolver.java:28,61-63,70,95` | – |
| 30 | `LatestSourceReceivedAtResolver.resolve(Collection<Instant>)` ignores nulls; `@Component` | T002 | TRUE | `LatestSourceReceivedAtResolver.java:37,47-51` `filter(Objects::nonNull)` | – |
| 31 | `golden_records.status` has no CHECK constraint | T002 | TRUE | `V9__create_gold_tables.sql:7` `status VARCHAR(64) NOT NULL DEFAULT 'active'`; no later CHECK | – |
| 32 | `setStatusEnum` exists; `getStatusEnum` throws NPE on null | T002, A2 | TRUE | `GoldenRecordEntity.java:110-111` `GoldenRecordStatus.valueOf(status.toUpperCase())` | – |
| 33 | The global ObjectMapper is SNAKE_CASE | T002, T005 | TRUE | `JacksonConfig.java:40` | – |
| 34 | MembershipSpan canonical constructor | T002 | TRUE | `MembershipSpan.java:25-28` | – |
| 35 | The active-status criterion is at `PSH:572-573` | Plan A2, T002 | FALSE (anchor) | The literal is at PSH:583-584 `gr.getStatus() == null \|\| …ACTIVE…equalsIgnoreCase` | no |
| 36 | PSH anchors: fields 92-103, `@Autowired` constructor 134-160, `execute` 244-249, `persistMembership` 802-810 | T003 | TRUE | Matches | – |
| 37 | The 11-arg convenience constructor is at `:209-225` / `:209-219` | T003 | FALSE (anchor) | Javadoc at :210-216; signature and body at :217-232 | no |
| 38 | PipelineContext anchors :78, :186-187, :207-225, :108 | T003 | TRUE | Matches; javadoc literal "Resetea los resultados de merge y persistence…" at :208 | – |
| 39 | Persistence runs inside the orchestrator's `transactionTemplate` | T003 | TRUE | `PipelineOrchestrator.java:322` `transactionTemplate.execute(status -> {` | – |
| 40 | `LineageEdge` record shape | T003 | TRUE | `LineageEdge.java:26-36` | – |
| 41 | `uq_lineage_edge` includes `to_node_id` | T003 | TRUE | `V35__lineage_edge_operation_id.sql:30-32` | – |
| 42 | `LineageEdge`/`LineageEdgeType` already imported; `FORCE_RULE` statically imported | T003 | TRUE | PSH:15-16, PSH:55 | – |
| 43 | Test helpers (including `candidates`, S/X/Y) are at PSHT:897-1060 and 1297-1400 | T003 | FALSE (partly) | `candidates` is at PSHT:556; S/X/Y at :92-94; the rest is in the stated ranges | no |
| 44 | PSHT anchors: mocks 81-90, `membershipHandler` 900, tests at 1192 and 1213, `baseContext` 1343 | T003, A2 | TRUE | Matches | – |
| 45 | `PipelineOrchestratorTest:89` uses the 8-arg constructor | T003 | TRUE | PipelineOrchestratorTest:89 | – |
| 46 | Tier metric labels | T004 | TRUE | PSH:640-642 | – |
| 47 | Emitter method signatures | T004 | TRUE | `IngestEventEmitter.java:128`, :249 | – |
| 48 | Variables in scope at both Propagation sites | T004 | TRUE | APE:181-185; IS:373-376 | – |
| 49 | `stubCompletedRun` and the `*_multiMatchResolvedToUpdate_emitsUpdated` tests exist | T004 | TRUE | AsyncPipelineExecutorTest:192, 225; IngestServiceTest:142 | – |
| 50 | Test schema: survivorship, blocking, normalizers | T005 | TRUE | `source-identity-supplier-schema.json:19-24, 66-75, 87, 94, 101, 108` | – |
| 51 | golden_data is built from normalized data | T005, A2 | TRUE | `MergeStepHandler.java:207`, :225 | – |
| 52 | `insertForceRule` inserts SOURCE_TO_GOLDEN and evicts caches | T005 | TRUE | SourceIdentityPipelineIT:650-658 | – |
| 53 | `forceRuleMovesLinkedRecord` at 207-270; `goldenData` at 713-717 | T005 | TRUE | Matches | – |
| 54 | `@Autowired` fields are at SourceIdentityPipelineIT:24-28 | T005 | FALSE (anchor) | :24-28 are imports; the `@Autowired` fields are at :52-56 | no |
| 55 | BaseIntegrationTest `objectMapper` at :53, `evictAllCaches` at :80 | T005 | TRUE | Matches | – |
| 56 | `getActiveSchemaArtifacts` at :237; `extractSurvivorshipConfig` at :303 | T005 | TRUE | `SchemaService.java:237`; `SchemaArtifactExtractor.java:303` (`@Component` at :52) | – |
| 57 | StewardshipFlowsIT unmerge test at 66-89; :84 reads lineage `source` | T005 | TRUE | Matches | – |
| 58 | JaCoCo 0.8.12 only in `pluginManagement`; no module binds it | A2, T005 | TRUE | `pom.xml:205-223`; no module pom mentions jacoco | – |
| 59 | `resolved_at = Instant.now()` in the engine | A1, AC1 | TRUE | `DefaultMergeEngine.java:99` | – |
| 60 | EventLog has no implementation | A1, OQ-3 | TRUE | `EventLogRepository.java:17`; nothing implements it | – |
| 61 | With no members, cleanUp deletes all of the record's keys | A1 | TRUE | `SearchIndexJpaAdapter.java:258-266` | – |
| 62 | Create sets `schema_version` | A2 | TRUE | PSH:366 | – |
| 63 | Admin re-survivorship skips without writing when there are no sources | Components 2 step 4, OQ-2 | TRUE | SS:645-654, :813 `skipped++` | – |
| 64 | `review_cases` references golden_records | A2 | TRUE | `V19__create_review_cases.sql:8` | – |
| 65 | Every pipeline-opened span has a Silver version | OQ-2 | TRUE | PSH:248 (staged persisted) precedes PSH:264 (membership), same transaction | – |

**2. Knowledge violations**

| # | violated rule (ID §) | quote | where in artifact |
|---|---|---|---|
| 1 | DOM-MDM-PIPELINE-001 §10.8.4 step 3 | "**Recálculo del GR origen** (sin el registro fuente que se mueve). Si el GR origen queda sin registros fuente, se marca como `absorbed`." | Spec Components 2 step 3 (`ORPHANED`: `status = orphaned`); T002 `setStatusEnum(GoldenRecordStatus.ORPHANED)`; AC3. The artifact follows DOM-MDM-SURVIVORSHIP-001 §3.2 instead and records it as a contested rule: the two specs conflict. |
| 2 | ADR-001 §"Principios arquitectónicos que SE MANTIENEN" item 2; ARCH-MDM-PRINCIPLES-001 P9 | "**Repository Pattern**: ZERO imports directos de JPA fuera de `mdm-persistence`" / "Toda interacción con el almacenamiento se realiza a través de una capa de abstracción (Repository Pattern)" | T001 `MemberSurvivorshipChain` and T002 `LosingMemberRecomputer` (in mdm-ingest-service) import `com.mdm.persistence.entity.*` and `GoldenRecordJpaRepository`/`StagedRecordJpaRepository`. Spec Knowledge Context acknowledges this as a "contested rule". RFC-ARCH-001 is still open. |
| 3 | DOM-MDM-SURVIVORSHIP-001 §3.2 (state table) | "`orphaned` \| … No tiene registros fuente activos. \| Sí (solo lectura histórica) \| No \| No" | OQ-3, Components 2 step 3, AC3 and T002 set `golden_data = {}` and `field_lineage = {}` on an orphaned record, so nothing is left to read historically. The artifact argues the history can be rebuilt from the xref and Silver. |

**3. Plan executability**
- Every task has runnable red and green steps with `mvn` commands:
  - 001: Steps 0, 2, 4 and 6.
  - 002 and 003: Steps 2 and 4/5, plus a module run in 003.
  - 004: Steps 2, 4, 5 and 7.
  - 005: Steps 2–4, which need Docker/Testcontainers. The `jacoco.csv` columns 8 and 9 the plan uses (LINE_MISSED and LINE_COVERED) are correct.
- The order 001→002→003→004→005 is valid; no task consumes something a later task creates. The only forward reference is a javadoc `{@link LosingMemberRecomputer}` in T001, which names a class created in T002. It is harmless: no doclint or javadoc plugin is configured. T005 Step 2's red check on the T001 commit works because the IT only needs `MemberSurvivorshipChain`.
- One check will fail as written: T001's AC "StewardshipService no contiene ya el bucle create→update" (WRK-SPEC AC9). The second loop at SS:3086-3123 (claim 7) stays after T001.

`claims=65 TRUE=59 FALSE=6 UNVERIFIABLE=0 design-changing-FALSE=1 violations=3 tasks-without-runnable-test=0 order-valid=yes`