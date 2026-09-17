---
id: WRK-TASK-FORK-CORE-001-006
type: spec
layer: work-task
scope: ephemeral
status: draft
confidence: low
version: 0.1.0
created: 2026-09-17
updated: 2026-09-17
owner: jmbruzos
title: "brief-lib.mjs and task-brief"
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

# WRK-TASK-FORK-CORE-001-006 — `brief-lib.mjs` and `task-brief`

## Objective

Build the deterministic task brief (spec Skill 4 *Deterministic brief*,
P4, P5): one file per WRK-TASK containing the task, the plan's
*Architecture Impact*, every activated/equipped spec in full with a
**PIN DRIFT** header when the pinned version differs from the file, and the
FRAGs cited in `sources`. No LLM, no npm dependencies; the only external
call is `spec-graph filter --format json` through `kdd-cli`.

## Implementation Notes

**Files:**
- Create: `skills/kdd-conventions/scripts/brief-lib.mjs`, `tests/scripts/test-task-brief.sh`
- Replace: `skills/subagent-driven-development/scripts/task-brief` (the awk-based upstream script)
- Modify: `tests/claude-code/test-sdd-workspace.sh` (task-brief assertion)
- Test: `tests/scripts/test-task-brief.sh`

**Interfaces:**
- Consumes: `kdd-cli --path` (002), `sdd-workspace PLAN_FILE` (005), fixture facts (002).
- Produces:
  - `brief-lib.mjs` exports: `parseFrontmatter(text) → {fm: string, body: string}`; `listField(fm, key) → string[]` (block or inline YAML lists of scalars); `scalarField(fm, key) → string|null`; `sourceIds(fm) → string[]` (the `id:` of each `sources` entry); `splitPin(ref) → {id, version|null}`; `loadNodes(cliPath, specsDir) → node[]` (runs `node <cli> --specs <dir> filter --format json`); `findNode(nodes, id) → node|null`; `sectionOf(body, heading) → string` (text under `## <heading>` up to the next `## `); `renderSpecBlock(node, pin) → string`; `renderFragBlock(node) → string`; `buildTaskBrief({nodes, taskNode, planNode, taskText}) → string`.
  - `task-brief TASK_FILE [OUTFILE]` → writes `<sdd-workspace of parent plan>/<TASK-ID>-brief.md`, prints `wrote <path>: <N> lines`. Exit 2 usage, 3 toolkit missing, 4 parent plan not found.
  - Brief layout (headings are the contract Task 013's prompts rely on): `# Task brief — <TASK-ID>`, `## 1. Task`, `## 2. Architecture Impact (WRK-PLAN …)`, `## 3. Activated knowledge` (+ `### <ID> @<pin>` sub-blocks, `## 3b. Equipped capabilities` when `equips` is non-empty), `## 4. Evidence (fragments cited in sources)`. A drifted pin renders the line `**PIN DRIFT:** pinned <pin>, file is <version> — read the current text, report the drift to the controller.`

- [ ] **Step 1: Write the failing test**

`tests/scripts/test-task-brief.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$0")/lib.sh"
TASK_BRIEF="$REPO_ROOT/skills/subagent-driven-development/scripts/task-brief"
echo "=== Test: task-brief ==="
require_cli
repo="$(make_fixture_repo)"; trap 'rm -rf "$repo"' EXIT
export KDD_SPEC_GRAPH="$KDD_CLI"

out="$(cd "$repo" && "$TASK_BRIEF" specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md)"; rc=$?
path="$(printf '%s\n' "$out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
[[ "$rc" -eq 0 && "$path" == "$repo/.kdd/sdd/WRK-PLAN-BILL-PRORATA-001/WRK-TASK-BILL-PRORATA-001-001-brief.md" ]] \
  && pass "writes <workspace of parent plan>/<TASK-ID>-brief.md" || { fail "writes <workspace of parent plan>/<TASK-ID>-brief.md"; echo "    rc=$rc out=$out"; }
b="$(cat "$path" 2>/dev/null)"
for h in "# Task brief — WRK-TASK-BILL-PRORATA-001-001" "## 1. Task" "## 2. Architecture Impact (WRK-PLAN-BILL-PRORATA-001)" "## 3. Activated knowledge" "### DOM-BILL-PRORATA-001 @1.0.0" "## 4. Evidence (fragments cited in sources)" "### FRAG-BILL-ROUNDING-001"; do
  [[ "$b" == *"$h"* ]] && pass "contains '$h'" || fail "contains '$h'"
done
[[ "$b" == *"Implement \`prorata(fee, day, daysInMonth)\`"* ]] && pass "task text is inlined" || fail "task text is inlined"
[[ "$b" == *"Round to 2 decimal places, half-up"* ]] && pass "activated DOM body is inlined" || fail "activated DOM body is inlined"
[[ "$b" == *"| Round to 2 decimal places, half-up | DOM-BILL-PRORATA-001 |"* ]] && pass "plan Architecture Impact row is inlined" || fail "plan Architecture Impact row is inlined"
[[ "$b" == *"Math.round(amount * 100) / 100"* ]] && pass "FRAG report.md is inlined" || fail "FRAG report.md is inlined"
[[ "$b" != *"PIN DRIFT"* ]] && pass "no PIN DRIFT when pin matches" || fail "no PIN DRIFT when pin matches"
[[ "$b" != *"## 3b. Equipped capabilities"* ]] && pass "no equips section when equips is empty" || fail "no equips section when equips is empty"

out2="$(cd "$repo" && "$TASK_BRIEF" specs/work/WRK-TASK-BILL-PRORATA-001-002-billing-api-endpoint.md)"
path2="$(printf '%s\n' "$out2" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
b2="$(cat "$path2" 2>/dev/null)"
[[ "$b2" == *"**PIN DRIFT:** pinned 0.9.0, file is 1.0.0"* ]] && pass "PIN DRIFT header on version mismatch" || { fail "PIN DRIFT header on version mismatch"; }

# explicit OUTFILE
out3="$(cd "$repo" && "$TASK_BRIEF" specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md "$repo/explicit-brief.md")"
[[ -s "$repo/explicit-brief.md" && "$out3" == *"$repo/explicit-brief.md"* ]] && pass "honours explicit OUTFILE" || fail "honours explicit OUTFILE"

rc=0; (cd "$repo" && "$TASK_BRIEF" >/dev/null 2>&1) || rc=$?
[[ "$rc" -eq 2 ]] && pass "usage error exits 2" || fail "usage error exits 2 (rc=$rc)"
finish
```

- [ ] **Step 2: Run it to verify it fails**

Run: `export KDD_SPEC_GRAPH="$(cd .. && pwd)/knowledge-driven-development/apps/spec-graph/spec-graph.mjs"; bash tests/scripts/test-task-brief.sh`
Expected: FAIL on the first assertion (the old awk script rejects a file without `Task N` headings) and everything after.

- [ ] **Step 3: Write `brief-lib.mjs`**

`skills/kdd-conventions/scripts/brief-lib.mjs`:

```js
// brief-lib.mjs — build deterministic briefs from KDD work artifacts.
// Pure functions plus one process call (spec-graph filter --format json).
// No npm dependencies: the frontmatter subset we need is parsed by hand.
import { execFileSync } from 'node:child_process';
import { readFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';

/** Split a spec file into its YAML frontmatter text and Markdown body. */
export function parseFrontmatter(text) {
  const m = /^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/.exec(text);
  return m ? { fm: m[1], body: m[2] } : { fm: '', body: text };
}

/** A scalar `key: value` at the top level of the frontmatter, unquoted. */
export function scalarField(fm, key) {
  const m = new RegExp(`^${key}:[ \\t]*(.*?)[ \\t]*$`, 'm').exec(fm);
  if (!m) return null;
  return m[1].replace(/^["']|["']$/g, '') || null;
}

/** A top-level list of scalars, either inline `key: [a, b]` or block `key:\n  - a`. */
export function listField(fm, key) {
  const inline = new RegExp(`^${key}:[ \\t]*\\[([^\\]]*)\\][ \\t]*$`, 'm').exec(fm);
  if (inline) return inline[1].split(',').map((s) => s.trim().replace(/^["']|["']$/g, '')).filter(Boolean);
  const block = new RegExp(`^${key}:[ \\t]*\\r?\\n((?:[ \\t]+-[^\\n]*\\r?\\n?)+)`, 'm').exec(fm);
  if (!block) return [];
  return block[1].split(/\r?\n/).map((l) => l.replace(/^[ \t]+-[ \t]*/, '').trim().replace(/^["']|["']$/g, '')).filter(Boolean);
}

/** The `id:` of every entry under `sources:` (a block list of mappings). */
export function sourceIds(fm) {
  const block = /^sources:[ \t]*\r?\n((?:[ \t]+[^\n]*\r?\n?)+)/m.exec(fm);
  if (!block) return [];
  return [...block[1].matchAll(/^[ \t]+-[ \t]+id:[ \t]*([^\s]+)/gm)].map((m) => m[1]);
}

/** `ID@version` → {id, version}; a bare ID has version null. */
export function splitPin(ref) {
  const at = ref.indexOf('@');
  return at === -1 ? { id: ref, version: null } : { id: ref.slice(0, at), version: ref.slice(at + 1) };
}

/** All specs of a directory as spec-graph nodes (id, layer, version, file, body, files, …). */
export function loadNodes(cliPath, specsDir) {
  const out = execFileSync('node', [cliPath, '--specs', specsDir, 'filter', '--format', 'json'], { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  return JSON.parse(out);
}

export function findNode(nodes, id) {
  return nodes.find((n) => n.id === id) || null;
}

/** Text under `## <heading>` (exact, case-sensitive) up to the next `## `. */
export function sectionOf(body, heading) {
  const lines = body.split(/\r?\n/);
  const start = lines.findIndex((l) => l.trim() === `## ${heading}`);
  if (start === -1) return '';
  let end = lines.length;
  for (let i = start + 1; i < lines.length; i++) if (/^## /.test(lines[i])) { end = i; break; }
  return lines.slice(start + 1, end).join('\n').trim();
}

/** One activated/equipped spec: header with pin check, then the full body. */
export function renderSpecBlock(node, pin) {
  const head = `### ${node.id} @${pin ?? node.version} (${node.layer}, file version ${node.version}) — ${node.file}`;
  const drift = pin && pin !== node.version
    ? `\n**PIN DRIFT:** pinned ${pin}, file is ${node.version} — read the current text, report the drift to the controller.\n`
    : '';
  return `${head}\n${drift}\n${(node.body || '').trim()}\n`;
}

/** One fragment: its body plus the raw files it lists (report.md, tests…). */
export function renderFragBlock(node) {
  let out = `### ${node.id} (${node.source_type || 'fragment'}, captured ${node.captured_at || 'n/a'}) — ${node.file}\n\n${(node.body || '').trim()}\n`;
  const dir = dirname(node.file);
  for (const f of node.files || []) {
    const p = join(dir, f);
    if (existsSync(p)) out += `\n#### ${f}\n\n${readFileSync(p, 'utf8').trim()}\n`;
    else out += `\n#### ${f}\n\n_(missing on disk)_\n`;
  }
  return out;
}

function missing(id, what) { return `### ${id}\n\n_(${what} not found in the graph — report this to the controller)_\n`; }

/** The task brief. `taskText` is the raw task file (frontmatter included). */
export function buildTaskBrief({ nodes, taskNode, planNode, taskText }) {
  const { fm } = parseFrontmatter(taskText);
  const activates = listField(fm, 'activates').map(splitPin);
  const equips = listField(fm, 'equips').map(splitPin);
  const frags = sourceIds(fm).filter((id) => /^FRAG-/.test(id));
  const parts = [];
  parts.push(`# Task brief — ${taskNode.id}\n`);
  parts.push(`Generated by task-brief from \`${taskNode.file}\` (plan ${planNode ? planNode.id : 'unknown'}). Read this first — it is your requirements, with the exact values to use verbatim. Sections 2–4 are the knowledge that binds this task: their rules are requirements, not optional context.\n`);
  parts.push(`## 1. Task\n\n${taskText.trim()}\n`);
  parts.push(`## 2. Architecture Impact (${planNode ? planNode.id : 'no plan'})\n\n${planNode ? (sectionOf(planNode.body || '', 'Architecture Impact') || '_(the plan has no Architecture Impact section)_') : '_(parent plan not found)_'}\n`);
  parts.push(`## 3. Activated knowledge\n\n${activates.length ? activates.map(({ id, version }) => { const n = findNode(nodes, id); return n ? renderSpecBlock(n, version) : missing(id, 'activated spec'); }).join('\n') : '_(this task activates no knowledge — activates: [])_\n'}`);
  if (equips.length) parts.push(`## 3b. Equipped capabilities\n\n${equips.map(({ id, version }) => { const n = findNode(nodes, id); return n ? renderSpecBlock(n, version) : missing(id, 'equipped artifact'); }).join('\n')}`);
  parts.push(`## 4. Evidence (fragments cited in sources)\n\n${frags.length ? frags.map((id) => { const n = findNode(nodes, id); return n ? renderFragBlock(n) : missing(id, 'fragment'); }).join('\n') : '_(no fragments cited)_\n'}`);
  return parts.join('\n');
}
```

- [ ] **Step 4: Replace `task-brief`**

`skills/subagent-driven-development/scripts/task-brief` (Node ESM; the shebang is `#!/usr/bin/env node`):

```js
#!/usr/bin/env node
// task-brief — write one WRK-TASK's deterministic brief into its plan's SDD workspace.
//
// Usage: task-brief TASK_FILE [OUTFILE]
// Default OUTFILE: <sdd-workspace of the parent WRK-PLAN>/<TASK-ID>-brief.md
// Prints: wrote <path>: <N> lines
// Exit 2 usage · 3 kdd toolkit not found · 4 parent plan not found in the graph
import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseFrontmatter, scalarField, loadNodes, findNode, buildTaskBrief } from '../../kdd-conventions/scripts/brief-lib.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const [taskArg, outArg] = process.argv.slice(2);
if (!taskArg || process.argv.length > 4) { console.error('usage: task-brief TASK_FILE [OUTFILE]'); process.exit(2); }

let taskText;
try { taskText = readFileSync(taskArg, 'utf8'); } catch { console.error(`no such task file: ${taskArg}`); process.exit(2); }
const { fm } = parseFrontmatter(taskText);
const taskId = scalarField(fm, 'id');
const parentId = scalarField(fm, 'parent');
if (!taskId) { console.error(`no frontmatter id in ${taskArg}`); process.exit(2); }

// specs dir = the nearest ancestor directory of the task file named `specs`, else its parent dir
const abs = resolve(taskArg);
let specsDir = dirname(abs);
for (let d = dirname(abs); d !== dirname(d); d = dirname(d)) if (d.endsWith('/specs')) { specsDir = d; break; }

let cli;
try { cli = execFileSync(join(here, '../../using-superpowers/scripts/kdd-cli'), ['--path'], { encoding: 'utf8' }).trim(); }
catch { console.error('kdd toolkit not found: install the kdd plugin or set KDD_SPEC_GRAPH'); process.exit(3); }

const nodes = loadNodes(cli, specsDir);
const taskNode = findNode(nodes, taskId) || { id: taskId, file: taskArg, body: '' };
const planNode = parentId ? findNode(nodes, parentId) : null;
if (parentId && !planNode) { console.error(`parent plan ${parentId} not found under ${specsDir}`); process.exit(4); }

let outPath;
if (outArg) outPath = resolve(outArg);
else {
  const ws = execFileSync(join(here, 'sdd-workspace'), [planNode ? planNode.file : taskArg], { encoding: 'utf8' }).trim();
  outPath = join(ws, `${taskId}-brief.md`);
}
mkdirSync(dirname(outPath), { recursive: true });
const brief = buildTaskBrief({ nodes, taskNode, planNode, taskText });
writeFileSync(outPath, brief);
console.log(`wrote ${outPath}: ${brief.split('\n').length} lines`);
```

Note: `node.file` paths returned by `spec-graph filter` are relative to
the current working directory when `--specs` is relative; `task-brief` is
run from the repo root (as SDD does), so the plan file path is usable as
is. `chmod +x` the script.

- [ ] **Step 5: Run the test**

Run: `chmod +x skills/subagent-driven-development/scripts/task-brief && bash tests/scripts/test-task-brief.sh`
Expected: 16 `[PASS]`, `PASS`.

- [ ] **Step 6: Update the task-brief assertion in `tests/claude-code/test-sdd-workspace.sh`**

Replace the block `# --- task-brief lands in its plan's directory ---` (three commands and the if/else) with:

```bash
    # --- task-brief lands in its plan's directory (needs the kdd CLI; skipped otherwise) ---
    if KDD_SPEC_GRAPH_RESOLVED="$("$REPO_ROOT/skills/using-superpowers/scripts/kdd-cli" --path 2>/dev/null)"; then
        cp "$REPO_ROOT"/tests/scripts/fixtures/specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md "$repo/specs/work/"
        mkdir -p "$repo/specs/domain" && cp "$REPO_ROOT"/tests/scripts/fixtures/specs/domain/*.md "$repo/specs/domain/"
        local brief_out brief_path
        brief_out="$(cd "$repo" && KDD_SPEC_GRAPH="$KDD_SPEC_GRAPH_RESOLVED" "$SDD_SCRIPTS/task-brief" specs/work/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md)"
        brief_path="$(printf '%s\n' "$brief_out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
        if [[ "$brief_path" == "$repo/.kdd/sdd/WRK-PLAN-BILL-PRORATA-001/WRK-TASK-BILL-PRORATA-001-001-brief.md" ]]; then
            pass "task-brief writes its brief under the parent plan's workspace"
        else
            fail "task-brief writes its brief under the parent plan's workspace"
            echo "    got: $brief_path"
        fi
    else
        echo "  [SKIP] task-brief placement (kdd toolkit not found)"
    fi
```

Run: `bash tests/claude-code/test-sdd-workspace.sh` — Expected: PASS.

- [ ] **Step 7: Run the suite and commit**

Run: `bash tests/scripts/run.sh` — Expected: all ok.

```bash
git add skills/kdd-conventions/scripts/brief-lib.mjs skills/subagent-driven-development/scripts/task-brief tests/scripts/test-task-brief.sh tests/claude-code/test-sdd-workspace.sh
git commit -m "feat(WRK-TASK-FORK-CORE-001-006): deterministic task-brief with activated specs, PIN DRIFT and cited fragments"
```

## Acceptance Criteria

- [ ] Brief has the four sections, inlines task, plan constraints, activated spec bodies and FRAG files (spec AC 7).
- [ ] PIN DRIFT appears exactly when the pin differs from the file version.
- [ ] Output lands in `.kdd/sdd/<parent plan id>/<TASK-ID>-brief.md`.

## Test Plan

1. `tests/scripts/test-task-brief.sh` — 16 assertions on the fixture repo.
2. `tests/claude-code/test-sdd-workspace.sh` — placement assertion (skips without CLI).
