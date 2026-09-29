# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers only membership-span closures performed by the pipeline's Persistence step (`PersistenceStepHandler.persistMembership`), the single production path that today leaves an active losing record un-recalculated. Consolidation absorption, manual-merge absorption, and moves toward a non-existent/deleted/orphaned target are excluded, since the losing record is no longer active. Unmerge already recomputes the original record correctly and is left unchanged. Review-case resolution is explicitly out of scope, deferred to a future spec expected to reuse the same component. A record surviving a manual merge (an active `GOLDEN_TO_GOLDEN` ForceRule) is also recomputed: the filter excluding such survivors from on-demand re-survivorship is judged to apply only to a steward-triggered recompute, not to a membership change. A dedicated architecture-level guard enumerates every production caller of the membership-move repository methods and requires each to declare how it treats the losing record, so an undeclared new caller breaks the build.

## Recomputation mechanism

A new component, invoked from the Persistence step after the span closes and while the losing record is still locked, applies a state-based rule: an active record with at least one remaining member that has a Silver version gets a full recompute — chained merge (first member `create`, rest `update` over the accumulated result) over all Silver versions of its current members, replacing data, lineage, quality score and freshness, and deactivating stale pins, then saved (bumping its version). An active record whose remaining members have no Silver version is left unwritten, its pins still deactivated, and a warning logged. An active record with no remaining members becomes orphaned; any other status is a no-op. The chained-merge algorithm mirrors stewardship's existing re-survivorship, but stewardship's own code is not changed to share it — the two implementations are kept in sync only by a dedicated equivalence test.

## Field lineage and `previous`

For each field whose value changes relative to what was already persisted, the field's lineage `previous` slot is explicitly backfilled with the value and source taken from the record's persisted lineage before the operation, together with the operation's timestamp and run identifier — distinct from letting the chain's own internal accumulation stand in for `previous`.

## Losing the last member

If no members remain, the record becomes orphaned; its data, lineage, and quality score are preserved as a read-only historical snapshot, not cleared. A dedicated event type is emitted for this transition instead of the ordinary update event, on the reasoning that an orphaned record no longer propagates updates and should not be mistaken for one that does.

## Pins, overrides, and ForceRules on the departed record

Active source-pin overrides on the losing record that point at the departed record (matched by full identity, or by id alone for a legacy pin with no recorded source) are deactivated with a dedicated reason and actor, and a deactivation event is published after commit, using the same matching criterion already used for pin cleanup elsewhere. Value overrides stay active and continue to apply during the recompute; on an orphaned record they become inert only because the record no longer participates in merging. A manual-merge survivor's active ForceRule is unaffected.

## Locking, concurrency, and retries

The recomputation runs in the same transaction that closed the span, under the row lock it already holds on the losing record, and writing it increments its version. A version-mismatch failure rolls back the whole Persistence attempt and falls back to a fresh recompute from the merge step, then retries — the same policy any other write failure follows, with no partial state and no "mark for later" fallback; exhausted retries route to a relaunchable dead-letter queue. Event registration is scoped per attempt, cleared before a retry, so a rolled-back attempt leaves no trace.

## Events and cache invalidation

A recomputed record fires the ordinary update event after commit, and a separate quality-tier-change event if its tier crosses a boundary. An orphaned record fires a distinct, dedicated event instead of the ordinary update event; the cache-invalidation listener is extended to also evict on that new event type, alongside the existing in-process eviction.

## Quality score and tier

The quality score is recomputed by the shared resolver, and freshness is resolved only over the versions of members that remain linked. The tier-change event compares the record's previously persisted tier (with a documented default when no score existed) against the newly computed tier; an orphaned record gets neither its score recalculated nor a tier-change event.

## Downstream propagation

Addressed explicitly: an orphaned record is defined as not propagating updates, the stated reason a distinct event is introduced for that transition instead of reusing the ordinary update event.

## Tests planned

Unit tests cover the recomputation component (chain, `previous` backfill, freshness, score, and the edge outcomes for no-remaining-members and no-Silver-version cases) and the Persistence handler (all four state-table rows, pin deactivation, per-attempt event registration). Integration tests cover the acceptance criteria against a fixture with two members and a competing ForceRule: the moved member owned a field a remaining member does not, the orphaning case, pin deactivation, a rollback/retry scenario, an unmerge regression, and a parity check that the new component and unmerge produce identical output for the same members.

## Migrations

None: the schema already supports the needed pin-deactivation columns and the orphaned status, so no migration is required.

## Task breakdown

Add two read/write ports (member Silver versions with quality score; source-pin deactivation) with adapters and integration tests; build the recomputation component (chain, lineage backfill, freshness, score, edge outcomes); add the dedicated orphaned event and wire it into cache invalidation; make the Persistence step apply the rule to the losing record; add end-to-end tests for the ForceRule path, orphaning, pins, rollback/retry, unmerge regression, and parity.
