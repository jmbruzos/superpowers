## 1. Claims about current code (verified at aacdae5; paths relative to `src/` unless they start with `specs/`)

| # | claim (short) | where | verdict | evidence | design-changing? |
|---|---|---|---|---|---|
| 1 | Unmerge recomputes the original over the members that stay (data, lineage, freshness, score) | Spec Problem table; Premises | TRUE | `StewardshipService.java:434` `remainingStaged = loadVersionsOfMembers(...)`; `:466` `saveAndFlush(originalGr)` | – |
| 2 | FORCE_RULE branch only does move, cleanUp, evict and source_count; it never touches L's golden_data/field_lineage | Spec table; Premises | TRUE | `PersistenceStepHandler.java:802-816` (`move`, `cleanUpAfterLosingMember(...)`, `cacheEvictor.evictAfterCommit(previous)`, `refreshSourceCounts`) | – |
| 3 | CONSOLIDATION and PIPELINE_RUN (orphan) only take spans out of non-active, missing, deleted or orphaned records | Spec table; Premises; 003 | TRUE | `PersistenceStepHandler.java:784-795`; `isMissingOrOrphanUnderLock` `:824-834` | – |
| 4 | Manual merge sets the absorbed record to `absorbed` | Spec table | TRUE | `StewardshipService.java:945` `absorbed.setStatus(GoldenRecordStatus.ABSORBED.getValue())` | – |
| 5 | `resolve` only updates review_cases; REVIEW_RESOLUTION is never used | Spec table; Premises | TRUE | `ReviewQueueService.java:~209` `resolveCase(...)`; the only hit is `MembershipOperationKind.java:28` | – |
| 6 | Nothing in main sets ORPHANED; the only setStatus calls are ACTIVE `:389` and ABSORBED `:945` | Premises | TRUE | grep: `StewardshipService.java:389`, `:945`; ORPHANED appears only in reads (`PersistenceStepHandler.java:829`, `DefaultMatchEngine.java:296`) | – |
| 7 | Pin matching: full identity, or by id only for a legacy pin | Rule 2 | TRUE | `StewardshipService.java:2417-2418` `(pin.getPinnedSource() == null \|\| id.source().equals(pin.getPinnedSource()))` | – |
| 8 | The engine sets `previous` only when the value changed | Rule 4 | TRUE | `DefaultMergeEngine.java:207` `(previousValue != null && changed) ? FieldLineagePrevious.of(previousValue, null, now)`. The engine sets source=null; the plan fills it from the stored lineage. | – |
| 9 | The Merge step evaluates the score at `Instant.now()` | Rule 6 | TRUE | `MergeStepHandler.java:256-258` | – |
| 10 | The `golden_record.updated` payload is only goldenRecordId and entityType | KG4 | TRUE | `IngestEventEmitter.java:128-134` | – |
| 11 | Survivors of a manual merge are excluded from admin re-survivorship | Architecture; KG2 | TRUE | `StewardshipService.java:720-731` (GOLDEN_TO_GOLDEN → 409) | – |
| 12 | `reSurvivorshipFromSources`: 5-arg overload package-private, 6-arg private with MergeEngine, create/update chain, null when the list is empty | Premises; 001 | TRUE | `StewardshipService.java:2875`, `:2898-2934` `if (sources.isEmpty()) return null;` | – |
| 13 | `StewardshipServiceTest` builds the service 7 times | A1 attack 2 | TRUE | grep count = 7 | – |
| 14 | lockGoldenRecord Javadoc says "La que pierde un miembro no se escribe" | Components; 003 | TRUE | `PersistenceStepHandler.java:837` | – |
| 15 | L is locked FOR UPDATE before the move, in the same transaction | Premises | TRUE | `PersistenceStepHandler.java:702-726`, `:803-805`; `GoldenRecordJpaRepository.java:63-65` `@Lock(PESSIMISTIC_WRITE)` | – |
| 16 | `refreshSourceCounts` is a native UPDATE at the end of persistMembership | Premises | TRUE | `PersistenceStepHandler.java:814-815` | – |
| 17 | gateway depends on ingest-service; ingest-service depends on merge-engine, persistence, schema-service, core, events | Premises | TRUE | `mdm-api-gateway/pom.xml:28`; `mdm-ingest-service/pom.xml:20-44` | – |
| 18 | Both resolvers are in `com.mdm.ingest.quality` | Premises | TRUE | `StewardshipService.java:40-41` imports | – |
| 19 | `PipelineContext.getSurvivorshipConfig()` exists and MergeStepHandler uses it | Premises | TRUE | `PipelineContext.java:126`; `MergeStepHandler.java:209` | – |
| 20 | A SOURCE_PIN whose record has no value falls back to survivorship with a WARN | Premises | TRUE | `DefaultMergeEngine.java:116-121` | – |
| 21 | `findVersionsOfMembers` returns versions in a deterministic order | Premises | TRUE | `StagedRecordJpaRepository.java:74` `ORDER BY coalesce(s.received_at, s.created_at) ASC, s.source_record_id ASC, s.source ASC, s.created_at ASC` | – |
| 22 | "PersistenceStepHandler no emite eventos de golden record" | Premises | FALSE | It emits `GoldenRecordQualityChanged` (aggregate golden_record) at `PersistenceStepHandler.java:637` `ingestEventEmitter.emitGoldenRecordQualityChanged(...)`. It does not emit `golden_record.updated`. | no |
| 23 | Callers of `emitGoldenRecordUpdated` are `AsyncPipelineExecutor.java:209,222` and `IngestService.java:404,418` | Premises | FALSE (partly) | Only `:222` and `:418` call it; `:209`/`:404` are `emitGoldenRecordCreated` | no |
| 24 | `autoDeactivatePins` emits FIELD_OVERRIDE_AUTO_DEACTIVATED; ConsolidationOverrideMigrator emits after commit, or immediately when no transaction is active | Premises; Error handling | TRUE | `StewardshipService.java:2409-2437`; `ConsolidationOverrideMigrator.java:75-91` | – |
| 25 | main creates no SOURCE_TO_GOLDEN ForceRule; Match reads them through StewardshipRuleProvider | Premises; Architecture | TRUE | only `new ForceRuleEntity()` is at `StewardshipService.java:962` (GOLDEN_TO_GOLDEN); `StewardshipRuleProviderJpaAdapter.java:79` | – |
| 26 | `SourceIdentityPipelineIT#forceRuleMovesLinkedRecord` and `PersistenceStepHandlerTest#forceRuleMove_locksBoth…` exist | Premises | TRUE | `SourceIdentityPipelineIT.java:207`; `PersistenceStepHandlerTest.java:1004` | – |
| 27 | Unmerge recomputes before it deactivates pins; reason `auto_unmerge`; lineage `previous=null` (chain starts at create) | Premises; OQ-4 | TRUE | `StewardshipService.java:434` vs `:526`; `:126` `DEACTIVATION_REASON_AUTO_UNMERGE = "auto_unmerge"`; `:2910` `"create"` | – |
| 28 | Persistence runs in one transaction; GoldenRecordEntity has `@Version` | Premises | TRUE | `PipelineOrchestrator.java:322` `transactionTemplate.execute(...)`; `GoldenRecordEntity.java:41` | – |
| 29 | `spanInstant` is the received_at of the version being moved | A1 attack 1 | TRUE | `PersistenceStepHandler.java:683-685` | – |
| 30 | `PRODUCED` run→GR edge in persistLineageEdges | A1; 003 | TRUE | `PersistenceStepHandler.java:893-897` | – |
| 31 | A lock conflict goes back to Merge; any other persistence failure is retried | Error handling | TRUE | `PipelineOrchestrator.java:337-349`, `:352` | – |
| 32 | jacoco is only in `<pluginManagement>` and no module binds it | 002 Step 5; A2 | TRUE | `src/pom.xml:159-225` (jacoco `:206-208`); no module pom mentions jacoco | – |
| 33 | spring-web is not on the test classpath of mdm-ingest-service | 002; A2 | TRUE | `mdm-ingest-service/pom.xml` has no spring-web; JacksonConfig lives in gateway | – |
| 34 | LineageEdge has 9 components | 003; A2 | TRUE | `LineageEdge.java:26-36` | – |
| 35 | MergeRequest has a 15-arg compatibility constructor; with it the engine uses `Instant.now()` for the incoming value | 001 | TRUE | `MergeRequest.java:73+`; `StewardshipService.java:2910-2917`; `DefaultMergeEngine.java:298` | – |
| 36 | `DefaultMergeEngine(registry, provider)` and the evaluator set as in BlockingKeyEffectTest | 001/002 | TRUE | `DefaultMergeEngine.java:52-53`; `BlockingKeyEffectTest.java:84-86` | – |
| 37 | Repository signatures (`findByIdForUpdate(UUID)`, `findCurrentMembers(String,String)`, `findVersionsOfMembers(t,e,String[],String[])`, `findByGoldenRecordIdAndTenantIdAndActiveAndOverrideType`) | 002 | TRUE | `GoldenRecordJpaRepository.java:65`; `SourceMembershipRepository.java:35`; `StagedRecordJpaRepository.java:76`; `FieldOverrideRuleJpaRepository.java:39-40` | – |
| 38 | QualityScoreInput (6 fields), QualityScoreResult(score, tier), `tierFor`, `LatestSourceReceivedAtResolver.resolve(Collection)` | 002 | TRUE | `QualityScoreResolver.java:61-95`; `LatestSourceReceivedAtResolver.java:47` | – |
| 39 | `evictAfterCommit(String)` registers a sync when a transaction is active | 002 | TRUE | `GoldenRecordCacheEvictor.java:32-46` (no-op without a cache service) | – |
| 40 | Emitter signatures for updated, quality-changed and auto-deactivated | 002 | TRUE | `IngestEventEmitter.java:128,249,273` | – |
| 41 | FieldLineageEntry record and `FieldLineagePrevious.of(Object,String,Instant)` | 002 | TRUE | `FieldLineageEntry.java:19-55` | – |
| 42 | Accessors of FieldOverrideRuleEntity, GoldenRecordEntity and StagedRecordEntity; SurvivorshipConfig, SurvivorshipRule and MembershipSpan shapes | 001/002 | TRUE | `FieldOverrideRuleEntity.java:89-135`; `GoldenRecordEntity.java:102-141`; `StagedRecordEntity.java:91-133`; `SurvivorshipConfig.java:17-21`; `SurvivorshipRule.java:16-22`; `MembershipSpan.java:25-28` | – |
| 43 | The override provider queries the database with no cache, so a pin deactivated and flushed earlier is not applied | 002; 004 | TRUE | `FieldOverrideProviderJpaAdapter.java:49-50` (derived JPA query). The artifact cites `:68`, which is the source-pin finder. | – |
| 44 | Global ObjectMapper: SNAKE_CASE, NON_NULL, JavaTime, FAIL_ON_UNKNOWN_PROPERTIES | 002 | TRUE | `JacksonConfig.java:37-44` | – |
| 45 | When there is no previous score, the tier comparison starts from 0.5 | 002 | TRUE | `PersistenceStepHandler.java:631` | – |
| 46 | PersistenceStepHandler line anchors for the edits (constructors, execute `:244`, MembershipWrite `:675-677`, kind branch `:802-811`, return `:816`, Javadoc `:836-843`) | 003 | TRUE (approximate) | `@Autowired` constructor is at `:134-160`; the 11-arg constructor is at `:217-232` | – |
| 47 | Test anchors: `membershipHandler()` `:900-905`; tests at `:1081`, `:1106`, `:1192`; no test uses the `@Autowired` constructor | 003 | TRUE | `PersistenceStepHandlerTest.java` at those lines; grep finds no construction with the evictor or resolver | – |
| 48 | The only new import the 003 tests need is MemberExitRecalculator | 003 Step 1 | FALSE | The new tests declare `PipelineStepResult result`, but that class (`com.mdm.ingest.pipeline.PipelineStepResult`) is not imported; existing tests use `var`. This is a compile error. | no (executability) |
| 49 | `SourceIdentityPipelineIT` helpers at `:568-717`, ForceRule IT at `:207-260`, phone normalised without spaces | 004 | TRUE | the phone comment is at `:98`, not `:92-93` | – |
| 50 | `@MockitoSpyBean` is already used in ITs | 004 | TRUE | `SourceIdentityRaceIT.java:22,70-71` | – |
| 51 | Columns: `field_override_rules` (V22) + `pinned_source`, `force_rules.source`, `lineage_edges` | 004 | TRUE | `V22:54-70`; `V37:47-48`; `V21:5-14` | – |
| 52 | BaseIntegrationTest API; schema resource has email `source_priority` crm > erp_sap > web, everything else most_recent | 004 | TRUE | `BaseIntegrationTest.java:50-80`; `source-identity-supplier-schema.json` | – |
| 53 | StewardshipService imports at `:19-34` (MergeResult, SurvivorshipConfig, MergeEngine, MergeRequest) | 001 | TRUE | lines 19, 22, 33, 34 | – |
| 54 | The MergeEngine bean already exists in the assembled app (MergeStepHandler injects it); the new package is component-scanned | 002 | TRUE | `MergeStepHandler.java:59,91`; `DefaultMergeEngine.java:36` `@Component`; `MdmApplication` is in `com.mdm` | – |
| 55 | "unlisted claims verified: 14 hold" | Premises footer | UNVERIFIABLE | refers to a verifier run; the 14 claims are not listed | – |

## 2. Knowledge violations

| # | violated rule (ID §) | quote | where in artifact |
|---|---|---|---|
| 1 | DOM-MDM-PIPELINE-001 §10.8.4 p.3 | "**Recálculo del GR origen** (sin el registro fuente que se mueve). Si el GR origen queda sin registros fuente, se marca como `absorbed`." | Architecture rule 3 (0 members → `orphaned`); 002 `setStatus(ORPHANED)`; AC3. The artifact acknowledges this as KG1 and follows SURVIVORSHIP §3.2 instead. |
| 2 | DOM-MDM-SURVIVORSHIP-001 §3.2 | `orphaned` — "Consultable: Sí (solo lectura histórica) · Participa en matching: No · Propaga downstream: No" | Rule 7 / AC7: `golden_record.updated(L)` is published after commit when L becomes orphaned (002 `publishAfterCommit(…, null, null)`). The artifact rejected this point at A2 and records it as KG7. |
| 3 | DOM-MDM-LINEAGE-001 event catalogue | "`GoldenRecordUpdated` \| Persistence \| `golden_record_id`, `version`, `fields_changed[]`, `previous_values{}` \| Golden record actualizado." | Rule 7: the existing emitter is reused with only `{goldenRecordId, entityType}` (KG4). |
| 4 | DOM-MDM-PIPELINE-001 §6.5 | "**Emisión de eventos**: No emite eventos al Event Bus (eso es responsabilidad de Propagation)." | MemberExitRecalculator runs inside the Persistence step and publishes `golden_record.updated`, `GoldenRecordQualityChanged` and `FieldOverrideAutoDeactivated` (Data flow, rule 7). Later amendments already allow the tier event (SURV §3.7.3) and the consolidation pin event (PIPE §10.9.5), but nothing allows `golden_record.updated` from Persistence. |
| 5 | DOC-MDM-CONVENTIONS-001 §5 "Escrituras invisibles por dirty checking" | "Un test que solo verifique `verify(repo, never()).saveAndFlush(any())` no detecta la escritura. Para afirmar 'esta operación no toca el golden record', relee la entidad y compara su columna `@Version`" | 002 `notActive_nothingWritten` and `missingRecord_nothingWritten`: the "sin escribir nada" part of AC5 is checked only with `never().saveAndFlush`, and the entity is managed (`findByIdForUpdate`). The IT in 004 does not cover AC5. |

## 3. Executability

- Every task has a runnable test step:
  - 001: `mvn test -Dtest=SurvivorshipFoldTest`, plus the stewardship unit tests and ITs.
  - 002: `mvn test -Dtest=MemberExitRecalculatorTest`, plus the jacoco command.
  - 003: `mvn test -Dtest=PersistenceStepHandlerTest`, plus the module unit tests.
  - 004: `mvn verify -Dit.test=MemberExitPipelineIT`, plus a full verify.
- The ITs need Docker. The red control in 004 is a manual edit-and-revert, but 004 still has a real run step.
- One compile defect will make 003 Step 4 fail until it is fixed: `PipelineStepResult` is used in the new tests but not imported (claim 48).
- The task order is valid: 001 → 002 (`SurvivorshipFold`) → 003 (`MemberExitRecalculator`) → 004 (the spy bean and the `member_exit` output). No task uses anything a later task creates. 002 explicitly leaves the real-provider pin check to 004 as a test-plan choice; nothing depends on it.

`claims=55 TRUE=51 FALSE=3 UNVERIFIABLE=1 design-changing-FALSE=0 violations=5 tasks-without-runnable-test=0 order-valid=yes`