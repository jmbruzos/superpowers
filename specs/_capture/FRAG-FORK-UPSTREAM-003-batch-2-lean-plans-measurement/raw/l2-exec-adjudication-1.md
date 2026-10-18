# Executability adjudication (pre-registration amendment 3 rule), opus, codes X1..X4 (key: exec-adjudication-key.txt)

| code | arm | defects |
|---|---|---|
| X2 | B1 | 1 — T003 Step 1 tests use PipelineStepResult without import |
| X4 | B2 | 1 — T001 javadoc {@link LosingMemberRecomputer} names a type T002 creates |
| X3 | A1 | 2 — T004 6-arg emitGoldenRecordUpdated overload does not exist; T007 IT step: helper `status(String)` shadows static import, AC5 sketch uses undefined p/emailBefore/emailLineageBefore (one step) |
| X1 | A2 | 2 — T001 Step 1 accessors existingData()/existingLineage do not exist; T005 snippet uses a local `entityType` absent in IngestService |

Before mean 1.0; after mean 2.0. Full adjudicator output in the agent transcript (not-counted list: wrong anchors, wrong descriptions, AC9 incomplete design, camelCase assertions).
