---
id: WRK-TASK-FORK-MODS-001-004
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
title: "kdd-work packaging — marketplace entry, invariants, .gitignore, release notes, README, live check"
parent: WRK-PLAN-FORK-MODS-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-FORK-MODS-001
    relation: implements
sources: []
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T13:30:00+02:00 }
stale_after: 2027-01-03T13:30:00+01:00
tags: [fork, mods, task, packaging]
---

# WRK-TASK-FORK-MODS-001-004 — kdd-work packaging

## Objective

Make `kdd-work` installable from this repository's marketplace without
disturbing the main plugin's versioning, extend the fork invariants to the new
plugin, document it, and check the whole thing live in a Claude Code session.

## Implementation Notes

**Files:**
- Modify: `.claude-plugin/marketplace.json` (append the `kdd-work` entry after `kdd-superpowers`)
- Modify: `tests/scripts/test-invariants.sh` (scan `mods/` and `*.ts`/`*.tsx`; assert `plugins[1]`)
- Modify: `.gitignore` (engine-generated mod types)
- Modify: `RELEASE-NOTES.md` (new top section)
- Modify: `README.md` (Installation, What's inside)

**Interfaces:**
- Consumes: `mods/kdd-work/.claude-plugin/plugin.json` (`name: kdd-work`, `version: 0.1.0`) from WRK-TASK-FORK-MODS-001-002; `/kdd-work`, the status line and the band from 002–003; `kdd-status` from 001.
- Produces: nothing later tasks use.

**Premises:** none beyond the spec's (`bump-version.sh` writes `plugins.0.version` only; `test-invariants.sh:40` reads `m.plugins[0].name`; the namespace grep at `test-invariants.sh:17-19` covers `skills hooks scripts tests docs README.md CLAUDE.md` with `*.md *.sh *.json *.cjs *.mjs`, the path grep at `:23` the same directories plus `.gitignore`).

- [ ] **Step 1: Write the failing invariants**

In `tests/scripts/test-invariants.sh`, change the namespace grep (lines 17-19) to:

```bash
hits=$(grep -rn --include='*.md' --include='*.sh' --include='*.json' --include='*.cjs' --include='*.mjs' --include='*.ts' --include='*.tsx' \
  -E '(^|[^-])superpowers:[a-z]' skills hooks scripts tests docs mods README.md CLAUDE.md 2>/dev/null \
  | grep -v 'tests/scripts/test-invariants.sh' || true)
```

and the path grep (line 23) to:

```bash
hits=$(grep -rn -E '(\.superpowers/|docs/superpowers/)' skills hooks scripts tests docs mods README.md CLAUDE.md .gitignore 2>/dev/null \
  | grep -v 'tests/scripts/test-invariants.sh' || true)
```

After the `# 4. identity` block's `.gitignore` check, add:

```bash
# 5. kdd-work mod (WRK-SPEC-FORK-MODS-001): second marketplace entry, versions in step
mod=$(node -e '
  const fs = require("fs");
  const m = JSON.parse(fs.readFileSync(".claude-plugin/marketplace.json", "utf8"));
  const p = JSON.parse(fs.readFileSync("mods/kdd-work/.claude-plugin/plugin.json", "utf8"));
  const e = m.plugins[1] || {};
  console.log([e.name, e.source, e.version === p.version ? "same" : `${e.version}!=${p.version}`].join(" "));
' 2>/dev/null)
[[ "$mod" == "kdd-work ./mods/kdd-work same" ]] && pass "marketplace plugins[1] is kdd-work, version matches its plugin.json" || fail "marketplace plugins[1] is kdd-work, version matches its plugin.json (got: $mod)"
grep -q '^mods/kdd-work/.claude-plugin/types/$' .gitignore && pass ".gitignore ignores the mod's generated types" || fail ".gitignore ignores the mod's generated types"
```

- [ ] **Step 2: Run it to verify the new assertions fail**

Run: `bash tests/scripts/test-invariants.sh`
Expected: `[FAIL] marketplace plugins[1] is kdd-work, version matches its plugin.json (got:  undefined!=0.1.0)` — the exact `got:` text may differ — and `[FAIL] .gitignore ignores the mod's generated types`; the namespace and path checks still behave as before (the two pre-existing failures from the untracked `docs/superpowers/` remain).

- [ ] **Step 3: Add the marketplace entry and the ignore line**

`.claude-plugin/marketplace.json` — append to `plugins` (after the `kdd-superpowers` entry, never before it: `bump-version.sh` writes `plugins.0.version`):

```json
    {
      "name": "kdd-work",
      "description": "Optional Claude Code mod for kdd-superpowers: open KDD work in a pane and the status line, and a band while consolidation is pending.",
      "version": "0.1.0",
      "source": "./mods/kdd-work",
      "author": {
        "name": "NFQ Advisory"
      }
    }
```

`.gitignore` — append:

```
# kdd-work mod: types the Claude Code engine lays when it loads the mod
mods/kdd-work/.claude-plugin/types/
```

- [ ] **Step 4: Run the invariants and the version check**

Run: `bash tests/scripts/test-invariants.sh`
Expected: both new assertions PASS; no failure beyond the two pre-existing ones.

Run: `scripts/bump-version.sh --check`
Expected: the same report as before this task (it reads `plugins.0.version` only; `kdd-work` is not listed).

- [ ] **Step 5: Release notes and README**

`RELEASE-NOTES.md` — insert under `# Release notes`, above `## 0.4.0 — gates hold their findings`:

```markdown
## Unreleased — kdd-work mod

Implements WRK-SPEC-FORK-MODS-001:
- **`kdd-status`** (`skills/kdd-conventions/scripts/`): the state of open work as
  JSON — open WRK-SPECs with their plans and tasks, progress read from the SDD
  ledger (`Task <id|n>: complete`, FRAG-FORK-LEDGER-001), the phase
  (`spec-review`, `planning`, `executing`, `finishing`,
  `consolidation-pending`), the focus and pending consolidation. Spec data only
  through `kdd-cli`.
- **`kdd-work`** (`mods/kdd-work/`, second marketplace entry, version 0.1.0): an
  optional Claude Code mod (function hooks). Status line
  `<task> · <done>/<total> · <skill>`, `/kdd-work` pane with the spec → plan →
  tasks tree and the ledger's latest rulings and knowledge gaps, and a band
  `Consolidation pending: <id> — run kdd:spec-consolidate <id>` that
  `/kdd-work dismiss` hides for the session. Needs a Claude Code build with
  function hooks; the main plugin does not depend on it.
- `test-invariants.sh` also scans `mods/` and `*.ts`/`*.tsx`, and checks the
  `kdd-work` versions match.
```

`README.md` — in `## Installation`, after the paragraph that ends with "point `KDD_SPEC_GRAPH` at a `spec-graph.mjs` checkout.", add:

```markdown
Optionally, install the `kdd-work` mod from the same marketplace
(`/plugin install kdd-work`): it shows the open work in the status line and in
a `/kdd-work` pane, and keeps a band above the prompt while a completed
WRK-SPEC waits for consolidation (`/kdd-work dismiss` hides it). It needs a
Claude Code build with function hooks. To try it from a checkout:
`claude --plugin-dir mods/kdd-work` (set `KDD_SUPERPOWERS_ROOT` to the
checkout when kdd-superpowers is not installed).
```

and in `## What's inside`, after the table, add:

```markdown
Outside `skills/`: `mods/kdd-work/` — the optional mod above, fed by
`skills/kdd-conventions/scripts/kdd-status`.
```

- [ ] **Step 6: Full deterministic suite**

Run: `bash tests/scripts/run.sh`
Expected: every file `ok` except `test-invariants.sh`, whose only failures are the two pre-existing ones (`no upstream paths` and `removed: docs/superpowers`, both from the untracked `docs/superpowers/`).

Run: `claude plugin validate mods/kdd-work && claude plugin test mods/kdd-work`
Expected: nothing refused; 20 tests PASS.

- [ ] **Step 7: Commit**

```bash
git add .claude-plugin/marketplace.json tests/scripts/test-invariants.sh .gitignore RELEASE-NOTES.md README.md
git commit -m "feat(WRK-TASK-FORK-MODS-001-004): package kdd-work — marketplace entry, invariants, docs"
```

- [ ] **Step 8: Live check on this repository**

Your human partner runs this (interactive; it cannot be done headless). Start a session in this repository with the mod loaded:

```bash
claude --plugin-dir mods/kdd-work
```

Expected, and record each observation in the ledger:
1. The status line shows this WRK-SPEC's focus — `WRK-SPEC-FORK-MODS-001 · finishing` or `… · executing`, depending on the moment — and, after a `kdd-superpowers:*` skill runs, ` · <skill>`.
2. `/kdd-work` opens a pane that starts `reading <this repo>`, lists `WRK-SPEC-FORK-CORE-001 · finishing` with 19 ✓ tasks under `WRK-PLAN-FORK-CORE-001 · 19/19`, and lists `WRK-SPEC-FORK-MODS-001`.
3. Asking Claude to run `ls specs/work` (a Bash call whose command mentions `specs/`) refreshes the status line within about a second after the call finishes.

- [ ] **Step 9: Live check of the band**

On a temporary project with a `completed` WRK-SPEC:

```bash
tmp=$(mktemp -d) && cp -R tests/scripts/fixtures/specs "$tmp/specs" && (cd "$tmp" && git init -q && \
  sed -i.bak 's/^status: active$/status: completed/' specs/work/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md && rm specs/work/*.bak && \
  KDD_SUPERPOWERS_ROOT="$OLDPWD" claude --plugin-dir "$OLDPWD/mods/kdd-work")
```

Expected: the band above the prompt reads `Consolidation pending: WRK-SPEC-BILL-PRORATA-001 — run kdd:spec-consolidate WRK-SPEC-BILL-PRORATA-001`; `/kdd-work dismiss` hides it; it stays hidden for the rest of the session.

## Acceptance Criteria

- [ ] `marketplace.json` lists `kdd-superpowers` first and `kdd-work` second; `bump-version.sh --check` reports `plugins[0]` only; `test-invariants.sh` scans `mods/` and `*.ts/*.tsx`, asserts the `kdd-work` version match and the ignore line, and shows no failure beyond the two pre-existing ones (spec AC5).
- [ ] Live: status line, pane and band behave as in Steps 8–9 (spec AC6).
- [ ] `RELEASE-NOTES.md` records the mod and `kdd-status`; README says how to install and try `kdd-work` (spec AC7).

## Test Plan

`bash tests/scripts/test-invariants.sh` red → green on the new assertions; `bash tests/scripts/run.sh`; `claude plugin validate|test mods/kdd-work`; the live checks of Steps 8–9 with your human partner.
