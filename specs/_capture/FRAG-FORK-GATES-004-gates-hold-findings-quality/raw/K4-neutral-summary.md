# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers `PersistenceStepHandler.persistMembership`'s branch that moves a record out of an active golden record by a ForceRule (closing a span in the membership crossref). No production code creates that kind of rule today — only rules from a manual merge exist — but legacy and migrated rules do, and related work is expected to create more; this fixes the point for both. Consolidation and orphan-recovery routes always leave the losing record not active, so nothing to recompute; review-case resolution is excluded. Unmerge already recomputes correctly and is left unchanged, protected by a regression test. A manual-merge survivor (an active ForceRule pointing at itself) is also recomputed, but only field by field: a full recomputation would rederive fields a prior consolidation or a steward decided outside the departed record's contribution, so scope is restricted to fields it actually won.

## Recomputation mechanism

The create-then-update chaining of a private re-survivorship method is extracted, unchanged, into a new shared component: the first member's Silver version merges in `create` mode, each remaining one in `update` mode over the accumulated result, through the injected merge-engine bean so active overrides still apply; the original method delegates to it. A second new component runs directly and synchronously right after the move and key cleanup, before the source-count refresh, on the record already locked. It rereads the record; if missing or not active, it is skipped. It deactivates pins on the departed record, then determines which fields are "affected": those whose lineage entry names it (by identity, id alone for a legacy entry without a source, or a competing value), plus fields of any pin just deactivated. With no members remaining, the record is orphaned. Otherwise remaining members' Silver versions are folded only if a field is affected, and the fold's result replaces just those fields, leaving the rest untouched; freshness recomputes over the remaining members. If nothing is affected and freshness did not change, nothing is written — a score that only decays with the evaluation instant is not a change.

## Field lineage and `previous`

Only affected fields are touched. A re-resolved field gets `previous` set to the prior value and source, only when the value changed; an unaffected entry is left identical, timestamp included. An earlier draft that rebuilt every field's `previous` from the chain — a placeholder, not the record's real prior value — was rejected as inconsistent with how `previous` is defined.

## Losing the last member

With no members left, status becomes orphaned; golden data and lineage are preserved as a read-only historical snapshot, and no score is recomputed. Rules or overrides pointing at the now-orphaned record are left as they are; a project rule already ignores, with a warning, one whose destination is orphaned.

## Pins, overrides, and ForceRules on the departed record

Active source pins pinning the departed identity — full identity, or id alone for a legacy pin without a recorded source — are deactivated with a fixed reason and actor, publishing a deactivation event after commit naming the destination record. Value overrides are untouched. A manual-merge survivor's active rule is not touched: a rule-based move does not undo a manual merge, and since only affected fields are re-resolved, fields the steward decided outside the departed record's contribution stay untouched.

## Locking, concurrency, and retries

The recomputation runs inside the same transaction that closed the membership span, under the row lock already held. Any exception rolls back the whole transaction — span, keys and record left as before — and the orchestrator's retry-with-backoff policy applies; a deterministic failure that exhausts retries lands in a dead-letter queue, the same contract as a merge failure.

## Events and cache invalidation

Existing after-commit cache eviction is unchanged. An update event fires after commit with version, changed fields, and previous values, only when a value changed — not when orphaned or unchanged. A separate event fires on a tier crossing, and each deactivated pin publishes its own.

## Quality score and tier

The score comes from the shared resolver at an evaluation instant taken once by the handler, over the new data; freshness resolves only over remaining members. The new tier is compared against the previous tier (a mid-level default when none existed); a crossing fires the tier-change event. Neither applies to the orphaned or unchanged outcome.

## Downstream propagation

Not addressed beyond citing that an orphaned record is read-only, does not participate in matching, and does not propagate downstream.

## Tests planned

Unit tests cover the chained-merge helper (empty, single, multi-version chaining) and the recomputer (four non-active statuses parameterized; fields affected via source/id, a legacy pin, or a competing value; a re-resolved field with `previous`; a field removed for lack of a candidate; an unaffected field identical; orphaning with no event; pin deactivation; no-write outcome; events only after commit), plus the new event payload. Handler tests check correct identities on a rule-based move, no call without one, and a failure before source-count refresh. Integration tests extend an existing scenario: a moved record's fields re-resolve, no longer named in lineage, with version and source count checked; a pin deactivates while another field's override survives; moving the sole member orphans the record with data, keys and count unchanged. A separate test checks unmerge no longer names a separated record.

## Migrations

None: no schema change and no new migration.

## Task breakdown

Extract the chained-merge component and make the existing method delegate to it, protected by an unmerge regression test; build the recomputer and event payload, unit-tested; wire it into the persistence handler between key cleanup and source-count refresh; add integration tests for the rule-based move, pin deactivation with a surviving override, and orphaning of the sole member.
