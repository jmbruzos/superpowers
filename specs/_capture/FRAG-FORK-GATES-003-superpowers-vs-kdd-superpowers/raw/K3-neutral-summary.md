# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers `PersistenceStepHandler.persistMembership`'s membership-move branch: a ForceRule move, a legacy span closing onto an absorbed record, and the orphan route, whenever a source record's span on a golden record closes. Review-case resolution is excluded, since no production caller closes a span that way today. Unmerge already recomputes its record correctly and is left unchanged, only redirected to share its chained-merge algorithm. A manual-merge survivor (an active `GOLDEN_TO_GOLDEN` ForceRule pointing at it) is also recomputed: its field-level decisions live in value overrides and source pins, which the recompute continues applying.

## Recomputation mechanism

`MemberSurvivorshipChain`, a new stateless static component, is extracted from `StewardshipService.reSurvivorshipFromSources`'s private body: the first member's Silver version merges in `create` mode, each subsequent one in `update` mode over the accumulated result, via the same `MergeEngine`. `StewardshipService` delegates to it unchanged. A second, new `@Component`, `LosingMemberRecalculator`, is called directly and synchronously by `PersistenceStepHandler.persistMembership`, right after the move and key cleanup and before the source-count refresh, on a record already locked by the caller. It loads the record, returns immediately if not active, deactivates pins to the departed record, reads current members, and — if any remain — loads their Silver versions, reruns the chain, resolves freshness and the score, then writes data, lineage, score, freshness and audit fields; if none has a Silver version, the row is left untouched.

## Field lineage and `previous`

The chain starts from `create` with no existing golden data or lineage, so each field's lineage entry comes solely from remaining members' versions; neither an entry nor a competing-value list names the departed record. Backfilling a `previous` value from what was persisted before is not addressed.

## Losing the last member

If no members remain, status becomes `orphaned`, `golden_data` and `field_lineage` are emptied, `quality_score` and `latest_source_received_at` set to null, source count to zero, and blocking keys removed. If an active `SOURCE_TO_GOLDEN` ForceRule targets the record — directly, or through a chain of `GOLDEN_TO_GOLDEN` ForceRules reaching it via an absorbed record — it instead stays active and empty, logged as a warning; the pending rule can still be fulfilled later.

## Pins/overrides/ForceRules on the departed record

Active source-pin overrides pinned to the departed identity — by full identity, or id alone for a legacy pin with no recorded source — are deactivated with reason `member_left`, actor `system:pipeline`, and a deactivation event published after commit with the survivor key omitted. Pins are deactivated in every outcome except when the record was not active. Value overrides are untouched and keep applying. A manual-merge survivor's `GOLDEN_TO_GOLDEN` ForceRule is not touched: a rule-based move does not undo a manual merge.

## Locking/concurrency/retries

The recomputation runs inside the transaction that closed the span, under the row lock already held on the losing record. Any exception propagates: the transaction rolls back, so neither the span, keys, nor source count are written, and the orchestrator's retry policy applies rollback and retry up to a configured maximum. A deterministic failure that exhausts retries sends the run to a relaunchable dead-letter queue rather than apply the move with a stale record.

## Events and cache invalidation

Existing after-commit cache eviction is unchanged. In every outcome that writes the record a `PRODUCED` lineage edge from the run to it is added (`action = update`, `reason = member_left`), and `golden_record.updated` is published after commit — the only event that invalidates the record's cache on other pods. A recalculated record crossing a tier boundary also fires `GoldenRecordQualityChanged`, and each deactivated pin publishes `FieldOverrideAutoDeactivated`. A not-active record gets no write, edge, or event, though the step output still records that outcome.

## Quality score and tier

The score is recomputed by the shared resolver at an evaluation instant taken once by the handler as `Instant.now()` and passed in explicitly, matching the rule that the instant is injected rather than read inside the resolver. Its tier is compared against the previous score's tier (a mid-level default when none existed); a crossing emits the tier-change event. Orphaned and emptied outcomes compute no new score and emit no tier event — noted as an open point that no specification states what tier a null score is.

## Downstream propagation

Not addressed beyond citing the existing status definition that an orphaned record is read-only, does not participate in matching, and does not propagate downstream.

## Tests planned

Unit tests cover the chain component (empty, single-version, multi-version chaining) and the recalculator (non-active statuses, missing record, recalculation restricted to remaining members, orphaning, emptying through a chain reaching an absorbed record, members with no Silver versions, pin deactivation by full identity and legacy id, engine-failure propagation), plus the emitter's optional survivor key. Handler tests check call ordering, request fields, per-outcome tier-change and lineage-edge emission, pin-deactivation events, a not-active outcome producing nothing, exception propagation, and behavior with no recalculator configured. Integration tests cover a two-member ForceRule move (data, lineage, freshness, score and edge reflect only the remaining member and a still-applying override, cross-checked against a manual re-survivorship call), sole-member orphaning, the same move with a pending ForceRule leaving it active and empty while that rule still resolves, `not_active` assertions on two existing scenarios, and an unmerge regression. A full build, ≥80% coverage on the new package, and a knowledge-graph validation pass complete the task.

## Migrations

None: no schema change and no new migration.

## Task breakdown

Extract the shared chain into the new static component and make the existing re-survivorship method delegate to it, behavior-preserving. Build the losing-member component — pin deactivation, recomputation, orphaning/emptying, the no-Silver-data outcome, and an outcome metric — unit-tested, without publishing events itself. Wire the Persistence step handler to call it between key cleanup and the source-count refresh, adding tier comparison, the lineage edge, post-commit events, and the step-output annotation. Add integration tests for the ForceRule move, sole-member orphaning/emptying, pin deactivation, the not-active paths, and the unmerge regression, with full verification and coverage.
