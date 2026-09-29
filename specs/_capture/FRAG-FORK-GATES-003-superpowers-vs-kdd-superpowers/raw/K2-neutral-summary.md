# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers `PersistenceStepHandler.persistMembership`'s ForceRule branch, where the losing record L is active and differs from the record F the merge writes. Consolidation and orphan-repair branches are excluded: there L is already absorbed, deleted, orphaned or otherwise not active. Review-case resolution is excluded: no production path creates it yet. Unmerge already recomputes correctly and is unchanged, only redirected to share the same algorithm. A manual-merge survivor (an active `GOLDEN_TO_GOLDEN` ForceRule) is also recomputed: the exclusion protecting an operator-triggered re-survivorship sweep on the same membership doesn't apply, since membership changed; a manual merge doesn't choose values, so absorbed members remain current members and enter the calculation.

## Recomputation mechanism

A new stateless component is extracted from `StewardshipService.reSurvivorshipFromSources`'s body (both overloads): a chained merge over ordered member versions, first `create` then `update` over the accumulated result, via the injected `MergeEngine` (null quality score defaults to 0.8). The overloads keep their signature and delegate. A new repository-port method reads all Silver versions of a record's current members in the existing order.

A second new component, invoked from the Merge step handler when membership is forced with a conflict record L different from F, reads L (fresh, uncached) and its current members minus the incoming identity, holding a result in the pipeline context: if L isn't active, nothing is produced; if members remain, it recomputes `golden_data`/`field_lineage`, freshness over those versions, and a quality score at F's merge evaluation instant; if none remain, it marks L for orphaning.

Persistence writes this after the membership move and key cleanup, before the source-count refresh, on the already-locked L: it guards that the row's version, status and member set still match what was assumed, otherwise evicts L and throws a version-conflict exception. When members remain it writes data, lineage, freshness, score and a source count equal to the remaining-member count, saving even if unchanged since the version must move; when none remain, status becomes orphaned and data/lineage emptied. Discarded alternatives: recomputing inside Persistence (mixes calculation with I/O), a flag-plus-sweep (eventual consistency, new process), and post-commit event-triggered recompute (a lost event leaves L stale).

## Field lineage and `previous`

The chain starts from `create` with no prior data or lineage, so every field's lineage comes solely from the remaining members' versions; no entry can name the departed record. Backfilling `previous` from what was persisted before is not addressed.

## Losing the last member

If no members remain, status becomes orphaned, `golden_data` and `field_lineage` are emptied, quality score and freshness timestamp set to null, source count to zero, blocking keys removed. The record stays in the table, queryable read-only as historical data, and doesn't participate in matching; a ForceRule targeting it is ignored. What an orphaned record's content and dependents should be is left an open point, not fixed by any consulted spec.

## Pins/overrides/ForceRules on the departed record

A source pin on L targeting the departed record stays active; the merge engine falls back to ordinary survivorship since the pinned source contributes no value. Whether the pin auto-deactivation applying today only to unmerge should extend here is an open question, not decided. Value overrides are untouched, and a manual-merge survivor's `GOLDEN_TO_GOLDEN` ForceRule is not touched.

## Locking/concurrency/retries

The calculation runs in Merge, outside the row lock; Persistence writes under the row lock already held on L, guarded by matching version, status and member set. A guard failure, or reaching this branch with no calculation available, rolls back the transaction, evicts L, and sends the orchestrator back to Merge to recalculate against fresh state, bounded by the retry policy. A failure inside the calculation fails Merge like any other; nothing is caught or degraded to a keys-only update.

## Events and cache invalidation

Persistence marks the records it writes in the pipeline context. After commit, both ingest paths emit the canonical update event for each, with the same source, tenant and user as for F — the event driving cache invalidation on other pods, alongside existing after-commit cache eviction. A tier-change event variant uses L's own previous score and result, not F's; the orphaned outcome emits none.

## Quality score and tier

Recomputed by the shared resolver at F's merge evaluation instant, then compared against L's own previous score to decide a tier-change event. The orphaned outcome computes no new score and emits none; what tier a null score counts as is flagged unresolved.

## Downstream propagation

Not addressed beyond the general statement that an orphaned record is read-only and doesn't participate in matching.

## Tests planned

Unit tests cover the recompute component (all outcomes, correct value replacement, no lineage naming the departed record, manual-merge survivor recomputed), the chained-merge helper (empty, single, multi-version, default score), the version-reader adapter, the Merge step handler (calculation triggered only for a forced move with L≠F), and the Persistence step handler (write ordering, the guard, orphaning, non-write branches, tier event using L's own result). Existing stewardship tests must pass unchanged. Integration tests extend an existing scenario: a two-member record with a ForceRule moving one member; the moved member as L's only member; a retry case; and an unmerge regression confirming no lineage names a separated record.

## Migrations

None: no schema change, no new migration.

## Task breakdown

Six ordered tasks: add the version-reader port method and quality-score field; extract the chained-merge helper and make the existing re-survivorship method delegate to it; build the recompute component, its context state, and its invocation from the Merge step handler; write the losing record in the Persistence step handler with the guard, orphaning and the tier-event variant; emit the update event for losing records on both ingest paths; add end-to-end integration tests plus final verification.
