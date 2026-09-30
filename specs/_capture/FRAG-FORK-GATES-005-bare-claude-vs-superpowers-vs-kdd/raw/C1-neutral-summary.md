# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers the ForceRule move in `PersistenceStepHandler.persistMembership` (`kind = FORCE_RULE`) when the record losing the member is still active under the lock. Non-active or missing records only get the existing key cleanup. Review-case resolution is out of scope (it closes no spans today); future operations are expected to reuse the same components. Unmerge keeps its recalculation and pins-after-recompute order, now sharing the algorithm. Consolidation and manual merges are unchanged. Also covered: `valueOverride`, `sourcePin`, `removeOverride` and `manualMerge` lock records `FOR UPDATE` before reading, and re-survivorship's write criterion is widened for repairs.

## Recomputation mechanism

`SurvivorshipReplay`, a new pure static class, takes the `create`/`update` chain out of `StewardshipService.reSurvivorshipFromSources` (trust 1.0; version quality or 0.8; always the caller's `MergeEngine`). Stewardship, including `reSurvivorshipFromSourcesWithOverride`, delegates to it. `SourceRecordVersionReader` gains `findVersionsOfMembers`, and `SourceRecordVersion` gains `qualityScore`. `MemberLossRecalculator`, a new `@Component` built on ports only, picks a mode and computes without writing:
- `recalculated`: replay every Silver version of the remaining members through the Spring `MergeEngine`, so active value overrides apply. Fields attributed to a remaining member with no Silver versions are then carried forward.
- `stripped`: used for a manual-merge survivor or when no remaining member has Silver versions. The current data is kept, minus fields whose lineage is attributed to the departed record.
- `absorbed`: used when zero members remain.

`PersistenceStepHandler` calls `applyMemberLoss` in place of the old key-only cleanup and writes the record with a single `saveAndFlush`.

## Field lineage and `previous`

In `recalculated` and `stripped`, no field stays attributed to the departed record. A lineage entry is attributed to it when its `source_record_id` matches and its source matches, is null, or is a legacy pin (`stewardship` with rule `source_pin`). An entry without an id is never attributed. A `_norm` field follows its own lineage entry, or its base field if it has none. Lineage is compared ignoring `resolved_at` and `previous`. What `previous` should contain is not addressed.

## Losing the last member

The record becomes `absorbed` into the target, not `orphaned`. A project rule on the specific move case says `absorbed`, and a lifecycle rule says `orphaned`. The spec follows the first, so concurrent ingests, ForceRules and absorption chains pointing at the record redirect to the target through `ABSORBED_INTO`. An `ABSORBED_INTO` edge is written with reason `member_moved`, run id, ForceRule id and timestamp. Active overrides migrate to the target through `ConsolidationOverrideMigrator`. `golden_data`, `field_lineage`, score and freshness stay unchanged, source count drops to zero, and blocking keys are removed.

## Pins/overrides/ForceRules on the departed record

Before recomputation, the new `SourcePinRepository.deactivatePinsTo` deactivates active source pins that point at the departed record. It matches on full identity, or on id alone for legacy pins, and sets reason `member_moved` and actor `system:pipeline`. It flushes, so the engine no longer sees those pins. `FieldOverrideAutoDeactivated` is published after commit, with the target as survivor. Value overrides and pins pointing at other members are left alone. A manual-merge survivor, detected by the new `StewardshipRuleProvider.isManualMergeSurvivor`, goes through `stripped`, and its `GOLDEN_TO_GOLDEN` ForceRule stays active.

## Locking/concurrency/retries

Everything runs in the transaction that closed the span, under the `FOR UPDATE` lock already held on the losing record, before `refreshSourceCounts`. No expected version is added for this record. Its `@Version` increments, so a concurrent merge that read it earlier fails the version guard and retries. Pessimistic lock or deadlock errors inside the block become `OptimisticLockingFailureException`, so the orchestrator retries. Stewardship locks the record before override rows, and `manualMerge` locks records in ascending id order. After-commit callbacks catch their own exceptions so a committed run is never retried.

## Events and cache invalidation

Everything is published after commit; nothing on rollback. `golden_record.updated` carries `reason: member_left`, `result` and `status` in all three modes, through a new `IngestEventEmitter.emitGoldenRecordUpdated` overload. The existing after-commit cache eviction is unchanged. `FieldOverrideAutoDeactivated` fires for each deactivated pin, and in `absorbed` also for each override deactivated by a conflict during migration. A `PRODUCED` edge (run → record, `action = member_left`, `result`) is added.

## Quality score and tier

In `recalculated` and `stripped`, `QualityScoreResolver` recomputes the score at the current instant. Freshness is resolved only over the remaining members' versions and may be null. `GoldenRecordQualityChanged` fires after commit when the tier changes (a missing previous score is treated as 0.5). The in-transaction tier-change helper is not used. `absorbed` computes no score and sends no tier event.

## Downstream propagation

Not addressed.

## Tests planned

- **Unit:** replay chaining and parity against a literal copy of the old loop; recalculator modes, carry-forward, attribution edge cases, tenant on every port call; handler ordering, non-active record, commit/rollback events, tier, lock errors, failing callback, per-entry lineage conversion, metric, absorption; stewardship lock ordering and `lineageAttributionChanged`.
- **Integration:** ports with two tenants; a two-member move cross-checked with a zero-change re-survivorship; pins and overrides; a stripped manual-merge survivor; tenant isolation; absorption; a race proving no dead letter; an override-lock race that returns 400; two repair cases; extended concurrency and unmerge assertions.
- **Suite:** existing stewardship suites stay green with unchanged assertions.

## Migrations

No schema change is stated. Existing damaged records are repaired by a deployment runbook that runs `POST /admin/re-survivorship/batch` per tenant. It now also writes when lineage attribution changes, without counting it as `changed` or emitting an event. Manual-merge survivors and active records with zero members stay unrepaired.

## Task breakdown

1. Member-versions port with quality.
2. Shared `SurvivorshipReplay` with parity.
3. Manual-merge-survivor and source-pin ports.
4. `MemberLossRecalculator`.
5. Persistence applies pins, `recalculated`/`stripped`, `PRODUCED`, after-commit events, output `member_left`, the `mdm_member_loss_recalc_seconds` timer and lock-error translation.
6. The `absorbed` branch and its race test.
7. Stewardship locking and the lineage-aware write criterion.
8. Full-suite verification, AC-to-test traceability and the runbook.

No contradictions between plan/tasks and spec were found.
