# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers every path that closes a source record's current span on a golden record L while L is active. The pipeline's ForceRule move in `PersistenceStepHandler.persistMembership` (the `kind != null` block) is the main target; the same block also handles moves out of absorbed, orphaned or deleted records, which the rule skips. Unmerge and its preview adopt the same rule; today, when no remaining member has Silver versions, unmerge leaves the separated records' data and the preview shows `{}`. Review-case resolution is excluded because no production code closes spans that way yet. Absorption (consolidation, manual merge) is exempt.

## Recomputation mechanism

`MemberSurvivorshipChain`, a new static class, is extracted from `StewardshipService.reSurvivorshipFromSources`: first version as `create`, later ones as `update` over the accumulated result (trust 1.0, version quality or 0.8), null without versions; `StewardshipService` delegates to it, callers keep their order. A new pure `@Component`, `MemberDepartureRecalculator`, takes explicit inputs (remaining members supplied by the caller, `SurvivorshipConfig`, evaluation instant, `respectManualMerge`), writes nothing, and returns an outcome. The first matching row wins:
- L missing or not active (null status counts as active) → `skipped_not_active`.
- No members remain → `orphaned`.
- L is a manual-merge survivor and the caller respects that → `pruned`.
- Remaining members have Silver versions → `recomputed`, using all of their versions read through the new `SourceRecordVersionReader.findVersionsOfMembers`.
- Remaining members have no versions → `pruned`.

Pruning removes each lineage key whose winner is a departed record, together with the matching `golden_data` key. It also filters departed `competing_values`, resetting `conflict` below two. A project rule says there are no JPA imports outside `mdm-persistence`, so the new classes read only through ports.

## Field lineage and `previous`

Recomputation builds lineage only from the remaining members' versions. Pruning never touches `previous`, because that field carries no `source_record_id`. An entry is the departed record's when id matches, source is the same, null or `"stewardship"`, and the rule is not `manual_override`. An orphaned record keeps lineage that still names the departed record.

## Losing the last member

Status becomes `orphaned`. `golden_data`, `field_lineage`, `quality_score` and `latest_source_received_at` are kept as historical read-only data. Blocking keys are removed, `source_count` becomes zero, version +1. The domain documents disagree on whether this state should be `absorbed` or `orphaned`; the design follows `orphaned`.

## Pins/overrides/ForceRules on the departed record

Active `source_pin`s that point at a departed record are hidden from the merge by a decorating `FieldOverrideProvider` inside a throwaway `DefaultMergeEngine`, so the result does not depend on when the pins are deactivated. Matching (full identity, or id alone for legacy pins) lives in the new `SourceRecordIdentity.matchesPin`, shared with `autoDeactivatePins`. In the pipeline, `ConsolidationOverrideMigrator.deactivatePinsOnDeparted` deactivates these pins with reason `auto_member_departed` and actor `system:pipeline`. `value_override`s and pins to remaining members keep applying. A manual-merge survivor's `GOLDEN_TO_GOLDEN` rule makes the pipeline prune instead of recompute. Unmerge passes `respectManualMerge = false` because it already deactivates that rule, and it now runs `autoDeactivatePins` before the recomputation.

## Locking/concurrency/retries

The recomputation runs in the same transaction as the span move, under the `FOR UPDATE` lock already held on L. L is written with `saveAndFlush` (version +1) before the native `refreshSourceCounts`, which stays the last write of `source_count`. A concurrent merge on L's old version conflicts and retries. A pessimistic-lock error in this block is turned into `OptimisticLockingFailureException`. Any exception rolls back the whole transaction. A failure that repeats exhausts the retries and sends the run to a relaunchable dead-letter queue, leaving the record unmoved.

## Events and cache invalidation

In the pipeline, these events are registered to fire after commit:
- `golden_record.updated` for L with reason `member_departure`, the outcome and the departed identities. It invalidates L2 on other pods.
- `GoldenRecordQualityChanged` when the tier changes.
- One `FieldOverrideAutoDeactivated` per deactivated pin.

A `PRODUCED` lineage edge from the run to L records the action and outcome, and the persistence step output gains `member_departure: {golden_record_id, outcome}`. Unmerge keeps its current synchronous events; the only change is that `FieldOverrideAutoDeactivated` now comes before `GoldenRecordUpdated`.

## Quality score and tier

For `recomputed` and `pruned`, freshness is resolved only over the remaining members' `received_at`, never combined with the persisted value. The score comes from `QualityScoreResolver`, using `Instant.now()` in the pipeline and the request's instant in unmerge. The tier is compared with the previous score's tier (0.5 if none). Orphaned and skipped outcomes compute no score.

## Downstream propagation

An orphaned record still emits `golden_record.updated`, as a status change and cache invalidation, even though its status definition says it does not propagate downstream. Re-survivorship excludes orphaned records; `/sources` is unchanged.

## Tests planned

- **Read-port ITs:** ordering, `qualityScore`, null data, tenant scoping, manual-merge query.
- **Unit tests:** the chain (create/update, empty input) and the recalculator (each outcome, hidden pins including legacy, overrides, pruning table).
- **Handler unit tests:** write order, after-commit events, lock conflict, missing L, tier crossing.
- **`MemberDeparturePipelineIT`:** recompute matches `/admin/re-survivorship`, pins, orphaning, non-active skip, manual-merge pruning, tenant isolation.
- **`MemberDepartureRaceIT`:** a deterministic race, rollback with a retry, and a persistent failure going to the dead-letter queue.
- **`MemberDepartureUnmergeIT`:** preview equals confirm when there are no versions, unchanged results when there are versions, legacy-pin deactivation.
- **Guard and regressions:** `MemberDepartureGuardTest` counting `move(`/`moveAllMembers(` calls per file, regression ITs, full build.

## Migrations

None: no schema change.

## Task breakdown

1. Read ports: member versions with quality score, the manual-merge-survivor query, and `matchesPin`.
2. Extract the chain and make `autoDeactivatePins` use the shared check, with no behaviour change.
3. The pure recalculator.
4. Pipeline wiring: write, pins, after-commit events, `PRODUCED` edge, step output, lock error to conflict.
5. Race and rollback ITs.
6. Unmerge and its preview moved onto the recalculator.
7. The span-closing call guard and the full suite.
