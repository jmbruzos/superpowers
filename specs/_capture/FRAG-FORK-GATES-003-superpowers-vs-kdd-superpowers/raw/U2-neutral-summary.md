# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers the Persistence-step handling of a membership move: a ForceRule contradicting the current span, or a merge arriving through an absorbed-into path from the winning record, while the losing record stays active. Consolidation absorption and moves toward an already-inactive record are excluded. Unmerge already recomputes its original record correctly and is not changed in behaviour, only redirected to share its algorithm. Review-case resolution is left an open question, guarded by an architecture-level test enumerating every production caller of the membership-move repository methods, failing if a new, undeclared caller appears. A record surviving a manual merge (an active `GOLDEN_TO_GOLDEN` ForceRule) is also recomputed: the discretionary-recompute protection guarding a steward's decision is judged not to apply, since membership itself changed and the stale data is wrong regardless.

## Recomputation mechanism

A new component provides two things: a static chained-merge step — identical to the body already used by stewardship's re-survivorship, first member in `create` mode and the rest in `update` mode over the accumulated result — and a read-only recompute method that gathers the record's current members, their Silver versions (via an extended port that now also carries a quality score), the active schema's survivorship configuration, and the pipeline's merge engine, then resolves freshness and score without writing anything. The Persistence step calls this after every membership move: it runs the existing key cleanup, stops if the locked losing record is not active, deactivates pins to the departed record, then applies the result — writing data, lineage, score, freshness and audit fields and saving (bumping the record's version) when members remain, or setting status to orphaned when none do. Stewardship's own re-survivorship method delegates to the same static chained-merge step without altering its signature or ordering.

## Field lineage and `previous`

Not addressed: the design describes the chained merge producing new lineage over the remaining members' versions, with no discussion of backfilling a `previous` value from what was persisted before the operation.

## Losing the last member

If no members remain, the record's status is set to orphaned and its update timestamp is refreshed, but its data is explicitly left untouched — only the status and audit fields change, so quality score is likewise not recalculated in this branch. The same update event used for a normal recompute is reused here, distinguished only by a reason value.

## Pins, overrides, and ForceRules on the departed record

A new write port deactivates active source-pin overrides on the losing record that point at the departed record (matched by full identity, or by id alone for a legacy pin with no recorded source), mirroring the matching criterion stewardship's own pin-cleanup routine already uses, and returns the deactivated pins so a deactivation event can be published after commit. Value overrides, and pins to other members, are left active and continue to apply during the recompute. A manual-merge survivor's active ForceRule is unaffected.

## Locking, concurrency, and retries

Everything happens inside Persistence's existing transaction; the losing record is already locked under `FOR UPDATE` before the membership move, and the recomputation reads current membership only after the move, so the departed record is never among the members read. Any failure during the recomputation (for example, a schema missing survivorship configuration) propagates and rolls back the entire persistence write — span, keys, staged data and the destination record together — handled by the existing retry policy. A version conflict between the losing record's save and a concurrent ingest of one of its other members is resolved by the existing fallback: the losing side rereads and re-merges over the already-recomputed data.

## Events and cache invalidation

A single event type is used for both outcomes of this rule, distinguished by a reason value: member-left when data changed, orphaned when the record lost its last member. Existing in-process cache eviction for the losing record is kept unchanged.

## Quality score and tier

The quality score is computed by the shared resolver over the recomputed data and lineage. A tier crossing on the recomputed record fires a separate quality-change event, though the comparison basis is not detailed further. The orphaning branch does not recompute the score at all.

## Downstream propagation

Addressed only as a citation of the domain's own definition: an orphaned record is read-only, does not participate in matching, and does not propagate. No further design reasoning is built on top of that citation.

## Tests planned

Unit tests cover the chained-merge helper and recompute method, and the Persistence handler's branches for an active record with data, one with no remaining members, and an inactive record left untouched. Integration tests cover the two new ports (member versions in stewardship's deterministic order with quality score, and pin deactivation with tenant isolation), an end-to-end pipeline scenario, an architecture-level guard over production callers of the move methods, and a hardening suite for concurrency (a ForceRule move racing a re-ingest of another member), rollback, and an unmerge regression. The ForceRule path moves a member owning a field to a target record and asserts the losing record's data, lineage, score, freshness and version reflect only its remaining members, with a parity check against re-survivorship reporting no further change.

## Migrations

Not addressed.

## Task breakdown

Add the member-versions port (with quality score) and the pin-deactivation port, with adapters; build the shared recompute component and make stewardship's existing method delegate to its chained-merge step; make the Persistence step recompute or orphan the losing record and handle pins and events; add concurrency, rollback, unmerge-regression, and closure-site-guard tests.
