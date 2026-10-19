| code | # | defect (short) | kind a/b/c | report location |
|---|---|---|---|---|
| Y1 | 1 | T004 `apply_noMembers_…` verifies `emitGoldenRecordUpdated` with 6 `any()`; no 6-arg overload exists (old 5, new 9), so it does not compile | c | §3 "Two steps will not compile", bullet 1 |
| Y1 | 2 | T007 adds helper `String status(String)` to IT, shadowing the static import `MockMvcResultMatchers.status`; `status().isConflict()` (and IT:576) no longer compile | c | §3 "Two steps will not compile", bullet 2 |
| Y1 | 3 | T007 AC5 test uses variables `p`, `emailBefore`, `emailLineageBefore` that are never defined | c | §3 "Smaller gaps", bullet 1 |
| Y3 | 1 | T001 Step 1 names `MergeRequest` accessors `existingData()` / `existingLineage`, which do not exist (real: `existingGoldenData()`, `existingFieldLineage()`); the step only hedges "usa los nombres reales" | c | Claims table #28 |
| Y3 | 2 | T005 snippet uses a local `entityType` in `IngestService` that does not exist there (only `dto.entityType()`; confirmed at aacdae5) | c | Executability, "Minor defects", bullet 2 |
| Y4 | 1 | T003 new tests declare `PipelineStepResult result` without importing `com.mdm.ingest.pipeline.PipelineStepResult`; compile error | c | Claims table #48; §3 bullet 3 |
| Y6 | 1 | T001 javadoc `{@link LosingMemberRecomputer}` names a type created only in the later T002 (harmless for the build, since no doclint is configured, but it names a type that does not exist at that point) | c | §3 bullet 2 |

| code | not counted | why |
|---|---|---|
| Y1 | T003 makes the 6-arg overload package-private although it says signatures "no cambian"; red is visibility-only | Wrong description, and the step compiles |
| Y1 | T004/T005 unit tests assert camelCase `sourceRecordId` with a plain ObjectMapper | Behaviour/assertion mismatch; nothing named is missing |
| Y1 | AC9 covered only by combining several tests | Test-coverage remark; every task still has a runnable test |
| Y1 | COM `afterCommit` cited at :88-95 (file ends at :94) | Wrong line anchor |
| Y1 | Claims #8 and #21 FALSE | Wrong descriptions of behaviour or tests, not steps that fail |
| Y2 | 003 cites the 11-arg constructor at :208-221 (claim 39) | Wrong line anchor |
| Y2 | 005/004 Step 2 have no red run first | Test steps still run (rule a needs no runnable test at all) |
| Y2 | 005 Step 4 hard-codes a machine-local CLI path | The path exists; not a missing name |
| Y2 | 003 test 2 must stub `activeOverrideFields` on a mock | Fixture detail; the method is created by 002, earlier |
| Y2 | Claim 56 (IT inserts the rule "por repositorio" but SIPIT uses JDBC) | Wrong description |
| Y3 | Task 001 AC says "4 tests" but six are listed | Description inconsistency |
| Y3 | Claim 7 (three copies of the chain; there are two) | Wrong description |
| Y3 | Claim 36 (PSH ranges drift) | Wrong line anchors |
| Y3 | Claim 48 (RFC-PIPE-039 `accepted` only on another branch) | Not a code name in a step |
| Y4 | Claims #22, #23 FALSE (PSH emits no events; extra emit call sites) | Wrong descriptions |
| Y4 | 004 red control is a manual edit-and-revert | Task still has a runnable test step |
| Y4 | Knowledge violation #5 (`never().saveAndFlush` check) | Knowledge violation |
| Y5 | Task 004 test 2 expects the value override stored raw; code normalizes it (claim 58) | Wrong behaviour assumption: the test compiles and fails at runtime |
| Y5 | Task 002 test 5 `InOrder … mergeEngine.merge` vs a mock replayer | Fixture/behaviour ambiguity; test compiles, may fail at runtime |
| Y5 | Task 004 Step 4 `node <kdd-cli> … validate` placeholder | Placeholder, and the task's `mvn verify` gate is runnable |
| Y5 | Claims #49, #59 (SST:979 registry detail; `setUp` anchor) | Description detail / wrong line anchor |
| Y5 | Claims #64-67 UNVERIFIABLE | Not shown to fail |
| Y6 | T001 AC / WRK-SPEC AC9 "no create→update loop left" fails because of `reSurvivorshipFromSourcesWithOverride` | Acceptance check failing because the design is incomplete |
| Y6 | Claim 8 (T001 Step 5 says SST calls the 5-arg overload) | Wrong description; the overload exists and is package-private |
| Y6 | Claims 35, 37, 43, 54 | Wrong line anchors |

| code | defects |
|---|---|
| Y1 | 3 |
| Y2 | 0 |
| Y3 | 2 |
| Y4 | 1 |
| Y5 | 0 |
| Y6 | 1 |
