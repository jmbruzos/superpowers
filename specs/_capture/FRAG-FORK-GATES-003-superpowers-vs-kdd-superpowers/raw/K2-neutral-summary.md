# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers only a ForceRule move handled inside the Persistence step of `PersistenceStepHandler.persistMembership`, where match resolved `FORCED` on conflict and the losing record `L` is (or was) `active`. Consolidation absorption and orphan-repair movements are excluded, since the losing record is already inactive by then. Review-case resolution is not addressed (no production caller exists yet). Unmerge is not touched behaviourally, but its internal chain is redirected to the same shared algorithm and its tests must keep passing unchanged. A record surviving a manual merge (an active `GOLDEN_TO_GOLDEN` ForceRule) is still recomputed: the filter excluding such survivors from on-demand re-survivorship is stated not to apply here.

## Recomputation mechanism

Split across two pipeline steps. The Merge step computes: a new component reads the record's current members, their Silver versions, and the active schema's survivorship config, then runs a shared chained-merge helper — first member in `create` mode, the rest in `update` over the accumulated result, using only the injected merge engine — and resolves freshness and a quality score. That result is carried in the pipeline context. The Persistence step later writes it to the locked record, guarded by expected version, status and member set, before the source-count refresh; a guard failure raises an optimistic-locking exception so the orchestrator retries from Merge. The same chained-merge helper is what `StewardshipService`'s existing re-survivorship now delegates to.

## Field lineage and `previous`

Field lineage is rebuilt from scratch by the chain (create, then updates) over the remaining members' Silver versions, so no entry can reference the departed record. Backfilling a `previous` value from the record's prior persisted lineage is not addressed.

## Losing the last member

If no members remain, the record becomes `orphaned`. Unlike the recompute branch, `golden_data` and `field_lineage` are explicitly cleared to empty, and `quality_score` and the latest-source-received-at value are set to null; `source_count` becomes 0. A quality-tier-change event is explicitly not emitted for this case.

## Pins, overrides, and ForceRules on the departed record

Not implemented here: the plan explicitly states that no task deactivates source pins on the ForceRule movement path, leaving a pin still pointing at the departed record active (the merge engine falls back to ordinary survivorship for that field). This is recorded as an open question. Manual-merge survivor records are recomputed regardless of their active `GOLDEN_TO_GOLDEN` ForceRule, since the losing-record component does not check for it.

## Locking, concurrency, and retries

The losing record is written under the row lock (`FOR UPDATE`) already taken for the move, inside the same Persistence transaction. The write increments the record's version; if a concurrent transaction already advanced it, the guard raises an optimistic-locking failure and the orchestrator falls back to Merge with a fresh read, then retries Persistence — the standard write-failure/retry path, with no separate degraded mode. Any exception during the Merge-step computation propagates and rolls back the whole persistence write.

## Events and cache invalidation

A single event type, `golden_record.updated`, is emitted after commit for every record that Persistence wrote because it lost a member — both the recomputed case and the orphaned case use it, with no `reason` field distinguishing them. In-process cache eviction for the losing record accompanies the write; the event is also what invalidates the record's cache entry on other pods.

## Quality score and tier

The quality score is computed by the shared resolver during the Merge-step calculation, using the same evaluation-instant convention as other complete recomputations. A tier crossing is detected by comparing the record's previously persisted score against the newly computed one and emits the quality-change event; this comparison is explicitly skipped when the record becomes orphaned.

## Downstream propagation

Not addressed beyond citing that an orphaned record remains queryable but does not participate in matching, per the domain's own status table.

## Tests planned

Unit tests cover the losing-record component (the three outcome rows, field disappearance, lineage no longer naming the departed record, source-count, an untouched inactive record, and the empty orphan case), the chained-merge helper (empty, single, and multi-version chaining), and the Persistence handler (a ForceRule move triggers the recompute after key cleanup and before the count refresh; absorption/orphan-repair paths don't write the inactive record). A parity test keeps the existing stewardship suite green after the delegation. Integration tests exercise the ForceRule path end to end: a member moves away and the remaining member's data survives with no lineage naming the mover, re-running re-survivorship reports zero further change, and moving a record's only member orphans it with empty data and zero source count; a separate test repeats the unmerge regression check.

## Migrations

Not addressed.

## Task breakdown

Add the member-versions port and quality-score field; build the shared chained-merge helper and delegate stewardship's existing chain to it; add the losing-record computation component and carry its result in the pipeline context, computed in the Merge step; write that result to the locked record in the Persistence step with guards for orphaning and tier changes; emit the `golden_record.updated` event for losing records in both synchronous and asynchronous ingestion; add end-to-end integration tests (ForceRule, orphaning, parity, unmerge) and a final verification pass.
