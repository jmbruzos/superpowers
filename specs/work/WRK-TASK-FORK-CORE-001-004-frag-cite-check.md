---
id: WRK-TASK-FORK-CORE-001-004
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "frag-cite-check"
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

# WRK-TASK-FORK-CORE-001-004 — `frag-cite-check`

## Objective

Mechanically verify that every anchored claim in a code-derived FRAG still
points at the literal it quotes (P12 rule 4: "cite-check before writing;
one failure blocks the FRAG"; rule 1: "no anchor, no claim").

## Implementation Notes

**Anchor format** (this task fixes it; Task 009's `capturing-from-code.md`
documents it): a Markdown list item in any file listed in the FRAG's
`files[]`:

```
- `<path>:<start>-<end>@<sha7+>`: `<literal>`
```

`<path>` is repo-relative, `<start>-<end>` a 1-based inclusive line range
(a single line is `12-12`), `<sha>` the commit the range was read at, and
`<literal>` one line of code copied verbatim (backticks inside the literal
are not supported in v1). The check reads `git show <sha>:<path>` when
that object exists, otherwise the working-tree file, takes the range, and
requires the literal to occur in it as a fixed string (`grep -F`).

**Files:**
- Create: `skills/kdd-conventions/scripts/frag-cite-check`, `tests/scripts/test-frag-cite-check.sh`
- Test: `tests/scripts/test-frag-cite-check.sh`

**Interfaces:**
- Consumes: `lib.sh` helpers (Task 002).
- Produces: `frag-cite-check FRAG-DIR` (run from the repo root) → exit 0 and `verified N anchors` on stdout; exit 1 with one `FAIL <anchor>: <reason>` line per broken anchor; exit 1 with `FAIL: no anchors found` when a FRAG has none; exit 2 on usage errors. Used by `capturing-from-code.md` (009), brainstorming (011), code review (015), finishing (016) and `verification-before-completion` (017).

- [ ] **Step 1: Write the failing test**

`tests/scripts/test-frag-cite-check.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
CHECK="$REPO_ROOT/skills/kdd-conventions/scripts/frag-cite-check"
echo "=== Test: frag-cite-check ==="
repo="$(mktemp -d)"; trap 'rm -rf "$repo"' EXIT
git init -q -b main "$repo"
mkdir -p "$repo/src"
cat > "$repo/src/billing.js" <<'JS'
export function round2(amount) {
  // half-up for positive amounts
  return Math.round(amount * 100) / 100;
}
JS
( cd "$repo" && git add -A && git -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -qm init )
sha="$(cd "$repo" && git rev-parse --short=7 HEAD)"

mkfrag() { # $1 = dir name, stdin = report body
  local d="$repo/specs/_capture/$1"; mkdir -p "$d"; cat > "$d/report.md"
  local integ; integ="$(cd "$d" && sha256sum report.md | cut -d' ' -f1)"
  cat > "$d/FRAG-BILL-X-001.md" <<EOF
---
id: FRAG-BILL-X-001
type: fragment
layer: capture
status: ingested
confidence: low
version: 1.0.0
owner: t
captured_at: 2026-09-17T10:00:00+02:00
source_type: report
files:
  - report.md
integrity: "sha256:$integ"
---
# frag
EOF
  echo "$d"
}

good="$(mkfrag good <<EOF
## Observed
- \`src/billing.js:3-3@$sha\`: \`return Math.round(amount * 100) / 100;\`
- \`src/billing.js:1-4@$sha\`: \`export function round2(amount) {\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$good")"; rc=$?
[[ "$rc" -eq 0 && "$out" == "verified 2 anchors" ]] && pass "two valid anchors verify" || { fail "two valid anchors verify"; echo "    rc=$rc out=$out"; }

badlit="$(mkfrag badlit <<EOF
- \`src/billing.js:3-3@$sha\`: \`return Math.floor(amount * 100) / 100;\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$badlit" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"FAIL"*"literal not found"* ]] && pass "wrong literal fails" || { fail "wrong literal fails"; echo "    rc=$rc out=$out"; }

badrange="$(mkfrag badrange <<EOF
- \`src/billing.js:1-2@$sha\`: \`return Math.round(amount * 100) / 100;\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$badrange" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"FAIL"*"literal not found"* ]] && pass "literal outside the range fails" || { fail "literal outside the range fails"; echo "    rc=$rc out=$out"; }

badpath="$(mkfrag badpath <<EOF
- \`src/nope.js:1-1@$sha\`: \`x\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$badpath" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"FAIL"*"no such file"* ]] && pass "missing file fails" || { fail "missing file fails"; echo "    rc=$rc out=$out"; }

none="$(mkfrag none <<EOF
## Observed
Nothing anchored here.
EOF
)"
out="$(cd "$repo" && "$CHECK" "$none" 2>&1)"; rc=$?
[[ "$rc" -eq 1 && "$out" == *"no anchors found"* ]] && pass "a FRAG without anchors fails" || { fail "a FRAG without anchors fails"; echo "    rc=$rc out=$out"; }

# unknown sha falls back to the working tree (still verifies)
wt="$(mkfrag wt <<EOF
- \`src/billing.js:3-3@0000000\`: \`return Math.round(amount * 100) / 100;\`
EOF
)"
out="$(cd "$repo" && "$CHECK" "$wt" 2>&1)"; rc=$?
[[ "$rc" -eq 0 && "$out" == *"verified 1 anchors"* ]] && pass "unknown sha falls back to the working tree" || { fail "unknown sha falls back to the working tree"; echo "    rc=$rc out=$out"; }

rc=0; "$CHECK" >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 2 ]] && pass "usage error exits 2" || fail "usage error exits 2 (rc=$rc)"
finish
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/scripts/test-frag-cite-check.sh`
Expected: all FAIL (script missing).

- [ ] **Step 3: Write `frag-cite-check`**

`skills/kdd-conventions/scripts/frag-cite-check`:

```bash
#!/usr/bin/env bash
# Verify the anchors of a code-derived FRAG (WRK-SPEC-FORK-CORE-001, P12 rules 1 and 4).
#
# Usage: frag-cite-check FRAG-DIR        (run from the repository root)
# Reads every file listed under `files:` in the FRAG's frontmatter, finds anchor lines
#   - `<path>:<start>-<end>@<sha>`: `<literal>`
# and checks the literal occurs (fixed string) inside that line range of the file as it was
# at <sha> (git show), falling back to the working tree when the object is unknown.
# Exit 0: "verified N anchors". Exit 1: one "FAIL <anchor>: <reason>" per broken anchor, or
# "FAIL: no anchors found". Exit 2: usage.
set -uo pipefail

[[ $# -eq 1 && -d "$1" ]] || { echo "usage: frag-cite-check FRAG-DIR" >&2; exit 2; }
dir="$1"
fm="$(ls "$dir"/FRAG-*.md 2>/dev/null | head -1)"
[[ -n "$fm" ]] || { echo "no FRAG-*.md in $dir" >&2; exit 2; }

# files[] from the frontmatter: lines "  - name" between "files:" and the next top-level key
mapfile -t files < <(awk '/^files:/{f=1;next} f&&/^[^ ]/{f=0} f&&/^ *- /{sub(/^ *- */,"");print}' "$fm")
[[ ${#files[@]} -gt 0 ]] || files=("$(basename "$fm")")

fails=0; count=0
re='^- `([^`:]+):([0-9]+)-([0-9]+)@([0-9a-fA-F]{7,40})`: `([^`]*)`'
for f in "${files[@]}"; do
  [[ -f "$dir/$f" ]] || continue
  while IFS= read -r line; do
    [[ "$line" =~ $re ]] || continue
    path="${BASH_REMATCH[1]}"; s="${BASH_REMATCH[2]}"; e="${BASH_REMATCH[3]}"; sha="${BASH_REMATCH[4]}"; lit="${BASH_REMATCH[5]}"
    count=$((count + 1)); anchor="$path:$s-$e@$sha"
    if git cat-file -e "$sha:$path" 2>/dev/null; then
      content="$(git show "$sha:$path")"
    elif [[ -f "$path" ]]; then
      content="$(cat "$path")"
    else
      echo "FAIL $anchor: no such file (neither at $sha nor in the working tree)"; fails=$((fails + 1)); continue
    fi
    if printf '%s\n' "$content" | sed -n "${s},${e}p" | grep -qF -- "$lit"; then :; else
      echo "FAIL $anchor: literal not found in lines $s-$e"; fails=$((fails + 1))
    fi
  done < "$dir/$f"
done

if [[ "$count" -eq 0 ]]; then echo "FAIL: no anchors found (a FRAG without anchored claims is not evidence)"; exit 1; fi
if [[ "$fails" -ne 0 ]]; then echo "$fails of $count anchors failed"; exit 1; fi
echo "verified $count anchors"
```

- [ ] **Step 4: Run the test**

Run: `chmod +x skills/kdd-conventions/scripts/frag-cite-check && bash tests/scripts/test-frag-cite-check.sh`
Expected: 7 `[PASS]`, `PASS`.

- [ ] **Step 5: Run the suite and commit**

Run: `bash tests/scripts/run.sh` — Expected: all `ok`.

```bash
git add skills/kdd-conventions/scripts/frag-cite-check tests/scripts/test-frag-cite-check.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-004): frag-cite-check verifies anchored claims against git"
```

## Acceptance Criteria

- [ ] Valid anchors verify against the commit; wrong literal, wrong range, missing file and anchor-less FRAGs fail with exit 1 and a named reason.
- [ ] Unknown sha falls back to the working tree.

## Test Plan

1. `tests/scripts/test-frag-cite-check.sh` — 7 assertions on a throwaway git repo.
