---
id: WRK-TASK-FORK-CORE-001-003
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "next-id allocator"
parent: WRK-PLAN-FORK-CORE-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-FORK-CORE-001
    relation: implements
sources:
  - id: WRK-SPEC-FORK-CORE-001
    resource: specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-17T00:00:00+02:00
stale_after: 2026-12-16T00:00:00+01:00
tags: [kdd, fork, task, tooling]
---

# WRK-TASK-FORK-CORE-001-003 — `next-id` allocator

## Objective

Allocate the next free `TYPE-PATH-NNN` identifier by scanning a specs
directory, enforcing the semantic-path grammar (spec *Identifiers*: number
last, `[A-Z0-9]+` segments, numbering per path; a plan may *prefer* its
spec's number).

## Implementation Notes

**Files:**
- Create: `skills/kdd-conventions/scripts/next-id`, `tests/scripts/test-next-id.sh`
- Test: `tests/scripts/test-next-id.sh`

**Interfaces:**
- Consumes: fixture from Task 002 (`WRK-SPEC-BILL-PRORATA-001`, `WRK-PLAN-BILL-PRORATA-001`, `WRK-TASK-BILL-PRORATA-001-001/002`, `FRAG-BILL-ROUNDING-001`).
- Produces: `next-id [--specs DIR] [--prefer NNN] TYPE-PATH` → prints `TYPE-PATH-NNN`; exit 2 on bad grammar. Used by brainstorming (011), writing-plans (012), capture (009 reference) and finishing (016) skill text.

- [ ] **Step 1: Write the failing test**

`tests/scripts/test-next-id.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
NEXT_ID="$REPO_ROOT/skills/kdd-conventions/scripts/next-id"
echo "=== Test: next-id ==="
check() { local want="$1"; shift; local got; got="$("$@" 2>/dev/null)"; [[ "$got" == "$want" ]] && pass "$* → $want" || { fail "$* → $want"; echo "    got: $got"; }; }
check "WRK-SPEC-BILL-PRORATA-002" "$NEXT_ID" --specs "$FIXTURE_SPECS" WRK-SPEC-BILL-PRORATA
check "WRK-SPEC-BILL-NEW-001"     "$NEXT_ID" --specs "$FIXTURE_SPECS" WRK-SPEC-BILL-NEW
check "WRK-TASK-BILL-PRORATA-001-003" "$NEXT_ID" --specs "$FIXTURE_SPECS" WRK-TASK-BILL-PRORATA-001
check "FRAG-BILL-ROUNDING-002"    "$NEXT_ID" --specs "$FIXTURE_SPECS" FRAG-BILL-ROUNDING
check "WRK-PLAN-BILL-PRORATA-002" "$NEXT_ID" --specs "$FIXTURE_SPECS" --prefer 001 WRK-PLAN-BILL-PRORATA
check "WRK-PLAN-BILL-OTHER-007"   "$NEXT_ID" --specs "$FIXTURE_SPECS" --prefer 007 WRK-PLAN-BILL-OTHER
# default --specs is ./specs
tmp="$(mktemp -d)"; mkdir -p "$tmp/specs"; cp -R "$FIXTURE_SPECS/." "$tmp/specs/"
check "DOM-BILL-PRORATA-002" bash -c "cd '$tmp' && '$NEXT_ID' DOM-BILL-PRORATA"
rm -rf "$tmp"
# grammar
for bad in "wrk-spec-x" "WRK-SPEC" "WRK-SPEC-BILL-001" "WRK-SPEC-BILL_X" "WRK-SPEC-BILL-"; do
  rc=0; "$NEXT_ID" --specs "$FIXTURE_SPECS" "$bad" >/dev/null 2>&1 || rc=$?
  [[ "$rc" -eq 2 ]] && pass "rejects '$bad' with exit 2" || fail "rejects '$bad' with exit 2 (rc=$rc)"
done
finish
```

Note on the grammar cases: `WRK-SPEC` alone has no semantic segment; `WRK-SPEC-BILL-001` already ends in a number (the caller must pass the path, not an ID) — *but* `WRK-TASK-BILL-PRORATA-001` is valid input because its last segment is the plan number and the task number is still to be allocated. The rule that distinguishes them: a trailing `-\d{3}` is rejected only when the prefix is not `WRK-TASK`.

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/scripts/test-next-id.sh`
Expected: every check FAILs (script missing).

- [ ] **Step 3: Write `next-id`**

`skills/kdd-conventions/scripts/next-id`:

```bash
#!/usr/bin/env bash
# Allocate the next free KDD identifier for a semantic path.
#
# Usage: next-id [--specs DIR] [--prefer NNN] TYPE-PATH
#   TYPE-PATH  e.g. WRK-SPEC-RISK-VAR-ENGINE, DOM-RISK-VAR, WRK-TASK-RISK-VAR-ENGINE-001
#   --specs    directory to scan for `id:` lines (default ./specs)
#   --prefer   use NNN if it is free (a plan prefers its spec's number), else the next free
# Prints TYPE-PATH-NNN. Exit 2 on a malformed path.
#
# Grammar (WRK-SPEC-FORK-CORE-001, Identifiers): uppercase segments [A-Z0-9]+ joined by '-',
# at least one semantic segment after the type prefix, number LAST — so the path must not
# already end in -NNN, except for WRK-TASK paths, whose last segment is the parent plan number.
set -euo pipefail

specs="./specs"; prefer=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --specs) specs="$2"; shift 2 ;;
    --prefer) prefer="$2"; shift 2 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) break ;;
  esac
done
[[ $# -eq 1 ]] || { echo "usage: next-id [--specs DIR] [--prefer NNN] TYPE-PATH" >&2; exit 2; }
path="$1"

[[ "$path" =~ ^[A-Z]+(-[A-Z0-9]+)+$ ]] || { echo "malformed path: $path (expected UPPER segments, e.g. WRK-SPEC-AREA-CONCEPT)" >&2; exit 2; }
if [[ "$path" =~ -[0-9]{3}$ && ! "$path" =~ ^WRK-TASK- ]]; then
  echo "path already ends in a number: $path (pass the semantic path, not an ID)" >&2; exit 2
fi
# WRK-SPEC-X: the prefix is two segments; require at least one semantic segment after it.
case "$path" in
  WRK-SPEC|WRK-PLAN|WRK-TASK) echo "missing semantic segment: $path" >&2; exit 2 ;;
esac

max=0
if [[ -d "$specs" ]]; then
  while IFS= read -r n; do
    n=$((10#$n)); (( n > max )) && max=$n
  done < <(grep -rhoE "^id:[[:space:]]*${path}-[0-9]{3}[[:space:]]*$" "$specs" --include='*.md' 2>/dev/null \
           | sed -E 's/.*-([0-9]{3})[[:space:]]*$/\1/')
fi

taken() { grep -rqE "^id:[[:space:]]*${path}-$(printf '%03d' "$1")[[:space:]]*$" "$specs" --include='*.md' 2>/dev/null; }

if [[ -n "$prefer" ]]; then
  p=$((10#$prefer))
  if ! taken "$p"; then printf '%s-%03d\n' "$path" "$p"; exit 0; fi
fi
printf '%s-%03d\n' "$path" "$((max + 1))"
```

- [ ] **Step 4: Run the test**

Run: `chmod +x skills/kdd-conventions/scripts/next-id && bash tests/scripts/test-next-id.sh`
Expected: 12 `[PASS]`, `PASS`.

- [ ] **Step 5: Run the suite and commit**

Run: `bash tests/scripts/run.sh` — Expected: all `ok`.

```bash
git add skills/kdd-conventions/scripts/next-id tests/scripts/test-next-id.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-003): next-id allocator with semantic-path grammar"
```

## Acceptance Criteria

- [ ] Allocates per path (`…-PRORATA-002`, `…-NEW-001`), handles task paths ending in the plan number, honours `--prefer` when free.
- [ ] Rejects lowercase, missing segment, trailing number (non-task), underscores, trailing hyphen with exit 2.

## Test Plan

1. `tests/scripts/test-next-id.sh` — 7 allocation checks + 5 grammar rejections.
