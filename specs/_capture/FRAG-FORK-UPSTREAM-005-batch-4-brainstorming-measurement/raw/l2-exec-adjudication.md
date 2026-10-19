| code | # | defect (short) | kind a/b/c | report location |
|---|---|---|---|---|
| Z1 | 1 | 001 Step 1 copies an INSERT from `SourceIdentityMigrationIT`, a file that does not exist at aacdae5 (confirmed: no such file in `git ls-files`). The step adds "o equivalente", but as written it names a file that does not exist | c | claims row 45 |
| Z2 | 1 | T006 Step 4 coverage `awk` reads `mdm-ingest-service/target/site/jacoco/jacoco.csv`, which is never generated, because jacoco is only in `pluginManagement` and no earlier step binds it | c | claims row 80; executability bullet 2 |

| code | not counted | why |
|---|---|---|
| Z1 | 002 parity test asserts the wrong `phone` winner (row 51) | Wrong expected value. It names only existing elements and compiles, so it is a behaviour error, not (a)/(b)/(c) |
| Z1 | 005 ITs assert raw-cased `legal_name` (row 69) | Wrong literal, a behaviour error. It compiles and names existing elements |
| Z1 | Line drifts (rows 43, 44, 56, 58, 59, 77) | Wrong line anchors. The elements exist (e.g. `incomingIdentity` at :182) |
| Z1 | WRK-SPEC `LosingMemberRecalculator.recalculate` signature vs 003 (`entityType`, `qualityScoreResult`) | The mismatch is between the spec and the task that creates the type. No step is shown using a member that its creating step lacks |
| Z1 | `MemberLeftPinDeactivatorTest (4)` lists 5 cases | Count inconsistency. It does not block execution |
| Z1 | 006 Step 4 placeholder `node <kdd-cli> …` | The task has a runnable test step (Step 2), so it is not (a). The placeholder is a verification command, not a named code element |
| Z1 | 5 knowledge violations | Excluded by rule |
| Z2 | "≥ 80 %" ACs of T001–T003 have no command | Each of those tasks has a runnable red/green test step. A missing command for an AC is not (a) |
| Z2 | Test-count inconsistencies (T002 8 vs "siete", T003 11 vs "nueve", T004 6 vs "cinco") | Description inconsistencies. They do not block execution |
| Z2 | Premise row 29 (`moveAllMembers` also closes spans) | A wrong premise or description, not a step naming something absent |
| Z2 | Row 17 (third chain copy `reSurvivorshipFromSourcesWithOverride` not covered) | Design incompleteness |
| Z2 | Row 33 line cite off by ~7 | Wrong line anchor |
| Z2 | 3 knowledge violations | Excluded by rule |
| Z3 | IT literals in 004/006 ignore the normalizers (row 67, executability (a)) | Wrong expected values. They compile and name existing elements |
| Z3 | 004 Interfaces declare `Kind { RECOMPUTED, ORPHANED }`, while 002 and 004 Step 4/tests use `UNRESOLVED` (executability (b)) | The mismatch is between an Interfaces declaration and the steps. The steps that create and use the type agree on `UNRESOLVED`, so the report shows no step naming a constant its creating step lacks. This is treated the same way as Z1's spec/task signature mismatch |
| Z3 | 004 Test Plan says 6 unit tests, Step 1 lists 8 (executability (c)) | Count inconsistency |
| Z3 | 005 cites `ConsolidationOverrideMigrator.java:116-125` for a private helper at :85-93 (row 50, executability (d)) | Wrong line anchor. The report does not say a step calls the private method; it says PSH must re-implement it |
| Z3 | Surefire flags `-Dtest=none -DfailIfNoTests=false` / `-am -Dtest=X` (executability (e)) | The report hedges this as "may need … not verified" and does not name the affected tasks. A plugin-flag concern names no nonexistent element. Not every test step of a task is shown to be unrunnable, so it is not (a). Z1's "`-Dtest=` from `src/`" is described too vaguely to apply the same check |
| Z3 | Rows 6, 40 (line drift); row 33 (data-flow order); rows 34, 35 (architecture/description) | Wrong line anchors or wrong descriptions of behaviour; row 34 was also corrected by E1 |
| Z3 | 006 has no red step | It has a runnable test command, so it is not (a) |
| Z3 | 3 knowledge violations | Excluded by rule |
| Z4 | `recompute_countsOutcome` relies on the static `Metrics.globalRegistry` | Test-isolation or flakiness risk. It compiles and names existing elements |
| Z4 | 004 red cycle compiles on `main` | Noted by the report as harmless. Not a defect |
| Z4 | Rows 3, 47 (line drift), row 33 (wrong citation), row 17 (UNVERIFIABLE JPA semantics) | Wrong line anchors or citations, and an unverifiable premise, not a step failure |
| Z4 | 6 knowledge violations | Excluded by rule |

| code | defects |
|---|---|
| Z1 | 1 |
| Z2 | 1 |
| Z3 | 0 |
| Z4 | 0 |
