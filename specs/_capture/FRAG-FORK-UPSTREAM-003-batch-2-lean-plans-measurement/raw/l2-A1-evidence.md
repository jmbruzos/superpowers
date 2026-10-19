Bundle A1 (WRK-SPEC/PLAN/TASKs MDM-LOSING-MEMBER-001), checked against mdm-platform at aacdae5. I worked read-only.

Path abbreviations: PSH = `src/mdm-ingest-service/.../pipeline/steps/PersistenceStepHandler.java`; SS = `src/mdm-api-gateway/.../service/StewardshipService.java`; PSHT and SST are their tests; IT = `src/mdm-app/src/test/java/com/mdm/integration/SourceIdentityPipelineIT.java`; DME = `src/mdm-merge-engine/.../DefaultMergeEngine.java`; IEE = `.../ingest/event/IngestEventEmitter.java`; COM = `.../steps/ConsolidationOverrideMigrator.java`.

### 1. Claims about current code

| # | claim (short) | where | verdict | evidence | design-changing? |
|---|---|---|---|---|---|
| 1 | When the pipeline moves a member out, the losing GR loses its keys and its `source_count` drops, but data, lineage, score and freshness are not recomputed | Spec Problem, Premise 3 | TRUE | PSH:806-809 `move…; cleanUpAfterLosingMember(...); cacheEvictor.evictAfterCommit(previous)`, :815 `refreshSourceCounts` | – |
| 2 | Unmerge recomputes the original GR over the remaining members and persists data, lineage, score and freshness | Spec inventory, Premise 1 | TRUE | SS:434-466 `reSurvivorshipFromSources(remainingStaged…)`, `if (originalGrMergeResult != null) {setGoldenData…}` | – |
| 3 | If unmerge's recompute is null, the old data/lineage/score are kept; freshness is written outside the `if` | Premise 1, OQ-2 | TRUE | SS:452-454 (outside the `if`), :457-465 | – |
| 4 | Consolidation and absorption moves (`moveAllMembers`, `CONSOLIDATION`) leave the absorbed GR `merged`, not `absorbed` | inventory, unlisted premise | TRUE | PSH:759, :784-785; PSH:482 `setStatusEnum(GoldenRecordStatus.MERGED)` | – |
| 5 | An orphan span (`PIPELINE_RUN`, `membership_orphan`) only moves when the previous GR is missing, deleted, orphaned or not active | inventory | TRUE | PSH:786-792, :824-834, :291-293 | – |
| 6 | `ReviewQueueService.resolve` never touches membership; `REVIEW_RESOLUTION` has no caller | inventory, Premise 2 | TRUE | grep membership → empty; only `MembershipOperationKind.java:28 REVIEW_RESOLUTION("review_resolution")` | – |
| 7 | No production code sets a GR to `orphaned`; a ForceRule that removes the only member leaves it `active` | Problem, Premise 6 | TRUE | only reads: PSH:829, `DefaultMatchEngine.java:296` | – |
| 8 | `/impact/upstream` counts as "at risk" the fields whose `field_lineage.source` is a source that left | Problem Statement | **FALSE** | `ImpactAnalysisService.upstream` (:81-115) reads the xref history (`findHistoryByGoldenRecord`) and graph ancestors; it never reads `field_lineage` and has no fields-at-risk output | no (motivation only) |
| 9 | `previous` is locked `FOR UPDATE` before `move` | Arch, Premise 4 | TRUE | PSH:702-726, :803-805, :847 `findByIdForUpdate` | – |
| 10 | `refreshSourceCounts` is a native UPDATE and runs last; a later `saveAndFlush` would overwrite `source_count` | Arch, Premise 5 | TRUE | `SourceMembershipRepositoryAdapter.java:207-221`; PSH:814-815; SS:528-529; no `@DynamicUpdate` in `GoldenRecordEntity` | – |
| 11 | The re-survivorship batch excludes manual-merge survivors; the by-id route answers 409 | Alt B, Premise 13 | TRUE | SS:720-725 `ConflictException.conflict`, :794-803 | – |
| 12 | `StagedRecordJpaRepository.findVersionsOfMembers(String,String,String[],String[])` orders by coalesce, srid, source, created_at | Comp 1, Premise 8, T001 | TRUE | `StagedRecordJpaRepository.java:69-77` `ORDER BY coalesce(s.received_at, s.created_at) ASC, s.source_record_id ASC, s.source ASC, s.created_at ASC` | – |
| 13 | `SourceRecordVersionReader` only has `findLatestVersion`; its only implementation is the adapter | Premise 9, T001 | TRUE | `SourceRecordVersionReader.java`; `SourceRecordVersionReaderAdapter.java:19` | – |
| 14 | The adapter maps null `normalizedData` to `Map.of()` | T001 Step 3 | TRUE | `SourceRecordVersionReaderAdapter.java:42-44` | – |
| 15 | The chain lives privately in the 6-arg `reSurvivorshipFromSources(…, MergeEngine)`; the 5-arg overload is package-private | Comp 2/3, T003 | TRUE | SS:2875 (package-private), :2898-2901 `private` | – |
| 16 | `MergeRequest` fields: create then update, trust 1.0, quality or 0.8, `"re-survivorship-"+UUID`, 15-arg constructor | Comp 2, Premise 7, T002 | TRUE | SS:2910-2930 | – |
| 17 | Callers of `reSurvivorshipFromSources` are at 407, 435, 650, 1264, 1434, 1508, 1520, 1749, 1901, 2514 | Premise 7 | TRUE | grep, exact | – |
| 18 | A second create/update loop exists in `reSurvivorshipFromSourcesWithOverride` (`preview-correction-` prefix, `mergeEngine.merge` at :3120, called from :2016) | A2 attack 7, T003 | TRUE | SS:3086-3123, :2016 | – |
| 19 | `FieldLineageEntry` has no run field, so `pipelineRunId` never reaches the lineage | T003 premise | TRUE | `FieldLineageEntry.java:19-29`; DME never reads `pipelineRunId` | – |
| 20 | `EngineServiceScoreParity` no longer exists | A2, T003 | TRUE | SST:193 "se retiro" (stale mention in SS:2873) | – |
| 21 | StewardshipServiceTest has existing tests of `reSurvivorshipFromSources` that "stay green" | Spec Testing | **FALSE** | no test calls it; only comments (SST:197, :1275) | no |
| 22 | The `MergeEngine` bean has a real `FieldOverrideProvider` | Comp 2, Premise 11 | TRUE | DME:36 `@Component`, :52-53 `@Nullable FieldOverrideProvider`; `FieldOverrideProviderJpaAdapter.java:24` `@Repository` (no cache) | – |
| 23 | Ports and signatures used by `recompute` exist: `findCurrentMembers`, `getActiveSchemaArtifacts(entityType, tenantId)`, `extractSurvivorshipConfig(JsonNode)`, `QualityScoreResolver.resolve(QualityScoreInput)`, `LatestSourceReceivedAtResolver.resolve(Collection<Instant>)` | Comp 2, T002 | TRUE | `SourceMembershipRepository.java:35`; `SchemaService.java:237`; `SchemaArtifactExtractor.java:303`; `QualityScoreResolver.java:61,70`; `LatestSourceReceivedAtResolver.java:47` | – |
| 24 | mdm-api-gateway depends on mdm-ingest-service; `MemberBlockingKeyGenerator`, `QualityScoreResolver` and `LatestSourceReceivedAtResolver` are `@Component` beans and fields of SS | Premise 10 | TRUE | `mdm-api-gateway/pom.xml:28`; SS:171, 179, 224 | – |
| 25 | `emitGoldenRecordUpdated` has 5 args, payload `{goldenRecordId, entityType}`, and no `reason` | Comp 5, A1 attack 5 | TRUE | IEE:128-135 | – |
| 26 | IEE exposes `emitGoldenRecordUpdated`, `emitGoldenRecordQualityChanged` and `emitFieldOverrideAutoDeactivated` with the signatures used | Premise 14, T004/T005 | TRUE | IEE:128, 249, 273-276 | – |
| 27 | `MergeStepHandler.isActive` treats status null or `active` as active | Data flow | TRUE | `MergeStepHandler.java:351-353` | – |
| 28 | Merge scores the attempt with `Instant.now()`; re-survivorship also evaluates at `now()` | Data flow p.3, A1 attack 2 | TRUE | `MergeStepHandler.java:256-258`; SS:656 | – |
| 29 | Pin auto-deactivation predicate and the four fields it sets | Data flow p.2, T005 | TRUE | SS:2416-2418 (full identity, or by id when `pinnedSource == null`), :2419-2422 | – |
| 30 | A legacy pin's lineage has `source="stewardship"` and `sourceRecordId=pinned id` | Data flow, T005 | TRUE | DME:128-138 | – |
| 31 | `goldenData` and `fieldLineage` are written with the same key `field` | T005 premise | TRUE | DME:188, :217 | – |
| 32 | `findActiveGoldenToGoldenTargets(String, List<UUID>) : Set<UUID>` | Data flow, A2, T005 | TRUE | `ForceRuleJpaRepository.java:71-74` | – |
| 33 | `findByGoldenRecordIdAndTenantIdAndActiveAndOverrideType(UUID,String,boolean,String)` exists | T005 | TRUE | `FieldOverrideRuleJpaRepository.java:39` | – |
| 34 | Manual merge creates only `GOLDEN_TO_GOLDEN` rules; no production code creates `SOURCE_TO_GOLDEN` | Premise 17 | TRUE | SS:965; SOURCE_TO_GOLDEN appears only in enum and query | – |
| 35 | Manual merge does not touch `goldenData`; it only recomputes the score | A1 attack 1 | TRUE | SS:1003-1005 | – |
| 36 | The `afterCommit` pattern (register if synchronization is active, otherwise run now) | Data flow p.6, T004 premise | TRUE | COM:85-93. The plan cites :88-95; the file ends at :94 (line drift only) | – |
| 37 | COM uses `FieldOverrideRuleJpaRepository` and deactivates rules from mdm-ingest-service | Premise 15 | TRUE | COM:6, 39-42, 66-69 | – |
| 38 | The tier-change criterion is `maybeEmitQualityTierChange`; today's pipeline emit is inline | Data flow p.6, A1 attack 2, T004 | TRUE | PSH:625-643; emit at :636-638 | – |
| 39 | A stale concurrent merge fails the `@Version`/expected-version check and goes back to Merge; other exceptions retry, then go to dead letter | Error handling, Premise 12 | TRUE | `GoldenRecordEntity.java:41`; PSH:394, :577-592; `PipelineOrchestrator.java:337-374` | – |
| 40 | `resolveActive` follows the `ABSORBED_INTO` chain | A1 attack 4 | TRUE | `MergeStepHandler.java:330-347` | – |
| 41 | `QualityScoreResolver` reads the schema first (so a missing schema fails in Merge) | A1 attack 3 | TRUE | `QualityScoreResolver.java:71` | – |
| 42 | Test schema: `email` uses `source_priority` crm > erp_sap; default rule is `most_recent` | A2 attacks 5/7, T007 | TRUE | `source-identity-supplier-schema.json:66-73` | – |
| 43 | `forceRuleMovesLinkedRecord` does not check `golden_data` or `field_lineage` | Premise 16 | TRUE | IT:207-261 | – |
| 44 | `GoldenRecordJpaRepository.findByIdAndTenantIdForUpdate(UUID,String)` exists | T004 | TRUE | `GoldenRecordJpaRepository.java:76-78` | – |
| 45 | `tierFor(String,String,double)`, and `QualityScoreResult`/`QualityScoreInput` are nested records | T004 | TRUE | `QualityScoreResolver.java:61-68, 95` | – |
| 46 | The `PRODUCED` edge is built as `new LineageEdge(null,"PipelineRun",run,"GoldenRecord",gr,PRODUCED,tenant,now,Map.of("action",…))` | T004 premise | TRUE | PSH:893-897 | – |
| 47 | PSHT adds a `SimpleMeterRegistry` to `Metrics` | T004 | TRUE | PSHT:95, 100 | – |
| 48 | Benchmark builds `DefaultMergeEngine`; evaluator packages | T002 | TRUE | `MergeEngineBenchmark.java:73-77`; `...merge/survivorship/{SurvivorshipRuleEvaluatorRegistry, evaluators/*}` | – |
| 49 | PSH line anchors: `@Autowired` constructor :134-160, `persistMembership` :750-817, `MembershipWrite` :675-677, output :288-296 | T006 | TRUE | as cited | – |
| 50 | An 11-arg convenience constructor is used by `membershipHandler()` | T006 | TRUE | PSH:186-200; PSHT:900-905 | – |
| 51 | An unstubbed `@Mock LosingMemberHandler` returns `null` (enum), so existing tests see `null` | A2 | TRUE | Mockito defaults; PSHT:900-905 | – |
| 52 | The existing ForceRule test fixes the order move → ensureMemberKeys → deleteStaleEntries → replaceMemberKeys → refreshSourceCounts | T006 premise | TRUE | PSHT:1004-1032 | – |
| 53 | IT helpers and signatures (`ingest`, `insertForceRule`, `manualMerge`, `unmerge(List<Object>)`, `goldenData`, `sourceCount`, `keysOfGoldenRecord`, `receivedAtOf`) | T007 | TRUE | IT:579, 621, 626, 650, 661, 702, 708, 713 | – |
| 54 | Source-pin endpoint and body; value-override endpoint; `/api/v1/admin` prefix and re-survivorship route | T007 premise | TRUE | `FieldOverrideLatentIT.java:335-342` (and `SourcePinRequestDto` has `pinned_source`); `StewardshipController.java:102`; `AdminController.java:24, 69` | – |
| 55 | Lineage edges live in `mdm_lineage.lineage_edges` | T007 | TRUE | `V21__create_lineage_edges.sql:5` | – |

Supporting facts (not claims): the app ObjectMapper is SNAKE_CASE (`JacksonConfig.java:40`), so stored lineage uses `source_record_id`. `lineage_edges` has `UNIQUE(tenant, edge_type, from, to)`.

### 2. Knowledge violations

| # | violated rule (ID §) | quote | where in artifact |
|---|---|---|---|
| 1 | DOM-MDM-PIPELINE-001 §6.5 (Propósito; Operaciones p.3) | "Separa la lógica de cálculo (Merge) de la lógica de I/O (Persistence), permitiendo reintentar la escritura sin recalcular el merge…"; "Eventos → EventLog: Append de los eventos de dominio calculados por el Merge Engine" | Spec *Architecture* ("Recalculo síncrono… En `PersistenceStepHandler.persistMembership`"). *Components* 2/4: MergeEngine chain, QualityScoreResolver and events computed inside Persistence. T004–T006 |
| 2 | DOM-MDM-PIPELINE-001 §10.8.4 p.3 | "Si el GR origen queda sin registros fuente, se marca como `absorbed`." | Spec *Data flow* p.3 `NoMembers → status = orphaned`; T004. The artifact acknowledges this as a "contested rule" and follows SURVIVORSHIP §3.2 |
| 3 | ADR-001 §"Principios arquitectónicos que SE MANTIENEN" p.2 (also ARCH-MDM-PRINCIPLES-001 P9; open debt RFC-ARCH-001) | "Repository Pattern: ZERO imports directos de JPA fuera de `mdm-persistence`" | T004 *Produces*: the new `LosingMemberHandler` in mdm-ingest-service takes `GoldenRecordJpaRepository`, `FieldOverrideRuleJpaRepository` and `ForceRuleJpaRepository` and mutates `GoldenRecordEntity`/`FieldOverrideRuleEntity` (T005). This also contradicts T001's own AC: "Ningún import de JPA fuera de mdm-persistence" |
| 4 | DOM-MDM-SURVIVORSHIP-001 §3.2 (state table) | "`orphaned` … Consultable: Sí (solo lectura histórica)" | *Data flow* p.3 / AC3: an orphaned GR gets `golden_data = {}` and `field_lineage = {}`, which erases what is left to read. Arguable: the artifact itself logs it as a knowledge gap |
| 5 | DOM-MDM-LINEAGE-001 §3.1.2 and §3.8.2 | Catalogue: "`GoldenRecordUpdated` … `golden_record_id`, `version`, `fields_changed[]`, `previous_values{}`"; "Cambios compatibles (MINOR bump): Se pueden agregar nuevos campos opcionales … → versión 1.1" | *Components* 5 / T004: the payload keeps camelCase `goldenRecordId`, mixed with snake_case keys, and adds `reason` with no `schema_version` bump. Weak: `schema_version` is not implemented anywhere in the code |

### 3. Plan executability

- **Runnable test steps:** all seven tasks have runnable Maven commands; 007 also needs Docker. tasks-without-runnable-test = 0.
- **Order:** valid. Each task depends only on earlier ones (001 → 002 → 003/004 → 005 → 006 → 007), and the `emitGoldenRecordUpdated` overload is created in 004, the same task that uses it.
- **Two steps will not compile as written:**
  - T004 `apply_noMembers_…` calls `verify(emitter, never()).emitGoldenRecordUpdated(any()×6)`. No 6-arg overload exists (the old one has 5 args, the new one 9), so it is a compile error.
  - T007 adds a helper `String status(String gr)` to IT. That shadows the static import `MockMvcResultMatchers.status` (IT:34), which IT:576 and the new AC5 `status().isConflict()` both use. Result: a compile error, and Step 2's "red" on the base commit becomes a compile failure, not an assertion failure.
- **Smaller gaps:**
  - T007's AC5 test is only a sketch: `p`, `emailBefore` and `emailLineageBefore` are never defined.
  - T003 says the signatures "no cambian", but Step 3 makes the 6-arg overload package-private. Its Step 2 "red" is visibility only (a characterization test).
  - T004/T005 unit tests assert camelCase `sourceRecordId` using a plain ObjectMapper, while production writes snake_case (ADR-003).
  - AC9 is covered only by combining several tests.

claims=55 TRUE=53 FALSE=2 UNVERIFIABLE=0 design-changing-FALSE=0 violations=5 tasks-without-runnable-test=0 order-valid=yes