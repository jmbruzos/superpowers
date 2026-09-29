# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers the ForceRule move handled by `PersistenceStepHandler.persistMembership`, the one production path that today closes a membership span on an active golden record without recalculating it. Consolidation, orphan-repair, and non-existent/deleted targets are excluded, since the losing record is no longer active. Review-case resolution is out of scope, since no production caller closes spans that way yet; future operations closing a span on an active record are expected to invoke the same component. Unmerge already behaves correctly and is left unchanged, only regression-tested. A record surviving a manual merge (an active `GOLDEN_TO_GOLDEN` ForceRule) is also recomputed: the exclusion protecting discretionary re-survivorship doesn't apply, since membership itself changed.

## Recomputation mechanism

A chained-merge helper is extracted from `StewardshipService`'s existing re-survivorship method into a shared component: the first member's Silver version is merged in `create` mode, the rest in `update` mode over the accumulated result, using the merge engine bean so active field overrides and pins still apply; `StewardshipService` delegates to it without altering its own behaviour. A second, new component is invoked directly and synchronously from the Persistence step, in place of the former keys-only cleanup routine, right after the membership move: it loads the locked record, reads its current members, and — if any remain — reruns the chained merge over their Silver versions, then writes the resulting data, lineage, freshness, and quality score, and recomputes the source count. If none of the remaining members have Silver rows, the record's data is left untouched (only keys, pins, and source count still update) and a warning is logged.

## Field lineage and `previous`

The chain starts from `create` with no prior lineage, so each field's `previous` reflects a value contributed earlier in the same chain by a still-current member, not the value that was persisted before the operation. This was checked deliberately: no lineage entry can reference the departed record.

## Losing the last member

If no members remain, the record's status becomes `orphaned`, its source count drops to zero, and its blocking keys are removed, but `golden_data` and `field_lineage` are explicitly preserved unchanged as a read-only historical snapshot — the same treatment given to merged records. The quality score is not recalculated in this case.

## Pins, overrides, and ForceRules on the departed record

Active source-pin overrides on the losing record that pin the departed record (matched by full identity, or by id alone for a legacy pin with no recorded source) are deactivated with a dedicated reason, and a deactivation event is published after commit, mirroring how unmerge already deactivates pins on separated records. Value overrides are left untouched. A manual-merge survivor's active ForceRule is unaffected by this recomputation.

## Locking, concurrency, and retries

The recomputation runs inside the same transaction that closed the membership span, under the row lock already held on the losing record. Writing the recomputed record increments its version; a concurrent pipeline run that had already computed a merge against the old version collides with the version guard and retries from the merge step. The source-count refresh that follows is idempotent because the recomputation already set the same value.

## Events and cache invalidation

Cache eviction for the losing record happens after commit in every outcome. When the record is recomputed with remaining data, an update event (reason: member left) fires after commit if the data or score changed, and a separate quality-tier-change event fires if the score crosses a tier boundary, using the same guard the rest of the pipeline uses. When the record is orphaned, the same update-event type fires instead, carrying both the member-left reason and an orphaned status.

## Quality score and tier

The quality score is recomputed from the merged result at the evaluation instant using the shared resolver; freshness is resolved only over the remaining members' versions. Neither the score nor a tier-change event applies to the orphaned outcome.

## Downstream propagation

Not addressed beyond the general status-table statement that an orphaned record is read-only and does not participate in matching.

## Tests planned

Unit tests cover the chained-merge helper (empty, single, and multi-version chaining) and the losing-record component (inactive record, orphaning, a field disappearing when its only contributor leaves, pin deactivation including the legacy case, events, score/tier, no-Silver-data). A handler-level test checks a ForceRule move invokes the recomputation with the correct departed identity, and a run without a move does not. Integration tests extend an existing ForceRule scenario: a member moving away leaves no lineage naming it; moving a record's only member orphans it with no keys or spans and deactivates its pin; a manual-merge survivor is recomputed while its ForceRule stays active; tenant isolation with identical data in two tenants; a concurrency case ingesting another member during the move. A separate test checks unmerge no longer leaves lineage naming a separated record.

## Migrations

None: no schema change and no new migration.

## Task breakdown

Extract the shared chained-merge helper and make stewardship's existing method delegate to it as a behaviour-preserving refactor; build the losing-record recomputation component and its event, unit-tested; wire the Persistence step to invoke it in place of the old keys-only cleanup, with integration tests for the ForceRule path, orphaning, pins, and a manual-merge survivor; add integration tests for concurrency, tenant isolation, and an unmerge regression.
