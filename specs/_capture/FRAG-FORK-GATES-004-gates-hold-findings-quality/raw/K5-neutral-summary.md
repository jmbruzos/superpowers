# La ficha que pierde un miembro se recalcula — neutral summary

## Scope

Covers the membership-move branch that closes a source record's span on a golden record: a ForceRule move, a legacy span onto an absorbed record, and the orphan-recovery route. Review-case resolution is excluded, since no production caller closes a span that way today. Unmerge already recomputes correctly and is left unchanged, only redirected to share the chained-survivorship algorithm through a parity test rather than a refactor. A manual-merge survivor is also recomputed, but only partially: its field-level decisions live in value overrides and source pins, which keep applying, so only fields the departed record actually won are replaced.

## Recomputation mechanism

A new, pure, stateless calculator reproduces — verified by a parity test against the unmodified original method, with no delegation between them — the same create-then-update chaining over the remaining members' Silver versions, through the injected merge-engine bean, then resolves score and freshness at an explicit evaluation instant. A new port feeds it all versions of a set of members in the original deterministic order, extended with each version's quality score. A pure applier decides what gets written: a full result (the calculator's output, previous filled only on changed fields); a partial result for the protected manual-merge survivor (only fields whose lineage names the departed record are replaced or dropped, everything else untouched); or a fallback strip, used when no member has a Silver version, removing only fields attributed to the departed record. A lineage entry matches the departed record by full identity, except a legacy entry with no source or a legacy pin, matched by id alone. Whichever caller holds the record locked — the pipeline handler or unmerge — applies the result.

## Field lineage and `previous`

The applier, not the calculator, fills `previous` with the prior value and source, only on fields whose value actually changed; a field whose value did not change gets no `previous`, even though the chain may already have produced one.

## Losing the last member

With no current members, the pipeline path sets status to orphaned and keeps every other column as a historical snapshot; unmerge's own validation already refuses to leave a record with no members, so unmerge itself never orphans one.

## Pins, overrides, and ForceRules on the departed record

Active source pins pinning the departed identity — full identity, or id alone for a legacy pin without a recorded source — are deactivated with a fixed reason and actor, and a deactivation event publishes only after commit. The spec names a new dedicated component for this, but the implementing task deviates, adding the method to an existing override-migration component instead, since a new production class outside the persistence layer may not import JPA; the deviation is recorded in the task, not reflected back into the spec. Value overrides are untouched, and a manual-merge survivor's ForceRule is left alone.

## Locking, concurrency, and retries

The recomputation runs inside the transaction that closed the span, under the row lock already held. Any exception fails the whole persistence step and the orchestrator's retry policy applies; a version conflict or a unique-constraint collision on the crossref makes any retry re-resolve membership first. Events are best-effort, published only after commit; a publish failure is logged, not propagated. A dedicated test forces a deterministic interleave between a ForceRule move and a concurrent re-ingest of a remaining member, checking neither update is lost.

## Events and cache invalidation

Existing after-commit cache eviction is unchanged. An update event fires after commit for every record recomputed or orphaned in an attempt, from both the synchronous and asynchronous emitters; the tracked list clears at the start of each retry, so a rolled-back attempt leaves no stray events. This doubles as the only cross-process cache-invalidation mechanism, which is why it still fires on orphaning even though a cited status-table rule says an orphaned record does not propagate downstream — a conflict the spec flags rather than resolves. A separate event fires on a tier crossing, via a new overload taking the id and score explicitly.

## Quality score and tier

The score comes from the shared resolver, using the evaluation instant, over the recomputed data and lineage, checked with a small tolerance against a directly invoked re-survivorship call. The previous tier defaults to a mid-level value when no prior score exists.

## Downstream propagation

Not addressed beyond citing that an orphaned record is read-only and does not participate in matching or propagate downstream — a claim the update event fired on orphaning sits in tension with.

## Tests planned

Unit tests cover the port adapter (order preserved, score passed through, no query on an empty list), the calculator (empty input, remaining members only, score from the resolver), and a parity test against the unmodified method, checking no new production file outside persistence imports JPA. The applier is tested for full, partial, and strip results, previous filled only on changed fields, and legacy/pin identity matching. The pin-deactivation method is tested for matching only the departed identity and firing its event only after commit. Integration tests cover a full ForceRule move matching a directly invoked re-survivorship call; the sole member moved away, orphaning the record; pin deactivation with a surviving override; and the protected survivor, where only departed-attributed fields change. Further coverage adds a pending-rule case, the asynchronous emitter, a concurrency interleave, and an unmerge regression.

## Migrations

None: no schema change and no new migration.

## Task breakdown

Add the version-reading port with a quality-score field; build the pure calculator with a parity test; build the pure applier producing full, partial, and fallback-strip results with previous; add member-exit pin deactivation to the existing override-migration component; wire the rule into the persistence handler with a tier-comparison overload and per-attempt tracking; emit the post-commit event from both emitters; give unmerge the fallback-strip treatment; close with the concurrency test and regression coverage.
