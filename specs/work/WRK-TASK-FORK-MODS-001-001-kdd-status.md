---
id: WRK-TASK-FORK-MODS-001-001
type: spec
layer: work-task
scope: ephemeral
status: active
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
title: "kdd-status — the state of open KDD work as JSON"
parent: WRK-PLAN-FORK-MODS-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-FORK-MODS-001
    relation: implements
sources:
  - id: FRAG-FORK-LEDGER-001
    resource: specs/_capture/FRAG-FORK-LEDGER-001-sdd-ledger-line-forms/
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T13:30:00+02:00 }
stale_after: 2027-01-03T13:30:00+01:00
tags: [fork, mods, task, kdd-status]
---

# WRK-TASK-FORK-MODS-001-001 — kdd-status

## Objective

Deliver the deterministic half of the spec: a script that prints the state of
open work (open WRK-SPECs, their plans and tasks, ledger-derived progress,
phase, focus, pending consolidation) as JSON, reading spec data only through
`kdd-cli` and the SDD ledgers itself. The mod (tasks 002–003) only draws what
this prints.

## Implementation Notes

**Files:**
- Create: `skills/kdd-conventions/scripts/kdd-status-lib.mjs` (pure functions, no I/O)
- Create: `skills/kdd-conventions/scripts/kdd-status` (CLI, executable)
- Test: `tests/scripts/test-kdd-status.sh` (picked up by `tests/scripts/run.sh`)

**Interfaces:**
- Consumes: `skills/using-superpowers/scripts/kdd-cli --specs <dir> filter --layer <layer> --format json` → JSON array of nodes with `id`, `layer`, `status`, `title`, `parent` (verified in the spec's Code Premises); exit 3 + stderr when no toolkit.
- Produces (tasks 002–003 rely on these exact keys): `kdd-status [--specs DIR] [--json]` prints one JSON object and exits 0 (exit 2 only on bad arguments):
  ```
  { root: string,
    open_work: [{ id, title, status: 'draft'|'active'|'completed',
                  phase: 'spec-review'|'planning'|'executing'|'finishing'|'consolidation-pending',
                  plans: [{ id, status, ledger: 'none'|'used'|'mismatch', done: number, total: number,
                            current: string|null,
                            tasks: [{ id, title, state: 'done'|'in-progress'|'pending' }],
                            ledger_tail: string[] }] }],
    focus: { spec: string, plan: string|null, task: string|null, done: number, total: number } | null,
    phase: 'idle' | <a phase above>,
    pending_consolidation: string[],
    error?: 'no-specs'|'toolkit-not-found'|'kdd-cli-failed', message?: string }
  ```

**Premises:** none beyond the spec's. Also checked while planning: `node --version` → `v25.8.1`; `package.json` has `"type": "module"`, so an extensionless `#!/usr/bin/env node` script is ESM (as `skills/subagent-driven-development/scripts/task-brief` already is); `spec-graph filter --layer nothing --format json` prints `[]` with exit 0; `tests/scripts/lib.sh` provides `require_cli`, `make_fixture_repo` (a git repo whose `git rev-parse --show-toplevel` it prints), `pass`, `fail`, `finish`.

- [ ] **Step 1: Write the failing test**

Create `tests/scripts/test-kdd-status.sh`:

```bash
#!/usr/bin/env bash
# kdd-status (WRK-SPEC-FORK-MODS-001): phases, ledger reading, root, errors.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
KDD_STATUS="$REPO_ROOT/skills/kdd-conventions/scripts/kdd-status"
KDD_STATUS_LIB="$REPO_ROOT/skills/kdd-conventions/scripts/kdd-status-lib.mjs"
echo "=== Test: kdd-status ==="
require_cli
export KDD_SPEC_GRAPH="$KDD_CLI"

W=specs/work
SPEC=$W/WRK-SPEC-BILL-PRORATA-001-mid-cycle-activation.md
PLAN=$W/WRK-PLAN-BILL-PRORATA-001-mid-cycle-activation.md
T1=$W/WRK-TASK-BILL-PRORATA-001-001-prorata-calculation.md
T2=$W/WRK-TASK-BILL-PRORATA-001-002-billing-api-endpoint.md
LEDGER_DIR=.kdd/sdd/WRK-PLAN-BILL-PRORATA-001
IDENTITY="# SDD ledger — plan: WRK-PLAN-BILL-PRORATA-001 ($PLAN)"
TMPS=()
trap 'rm -rf "${TMPS[@]}"' EXIT

# q EXPR — evaluate a JS expression over the JSON on stdin (d = parsed object)
q() { node -e 'const d=JSON.parse(require("fs").readFileSync(0,"utf8")); const v=(new Function("d","return "+process.argv[1]))(d); console.log(typeof v==="string"?v:JSON.stringify(v))' "$1"; }
fresh() { repo="$(make_fixture_repo)"; TMPS+=("$repo"); }
run() { out="$(cd "${1:-$repo}" && "$KDD_STATUS" --json)"; rc=$?; }
# set_status FILE STATUS — first `status:` line only (the frontmatter one)
set_status() { awk -v s="$2" '!d && /^status: /{print "status: " s; d=1; next} {print}' "$repo/$1" > "$repo/$1.tmp" && mv "$repo/$1.tmp" "$repo/$1"; }
ledger() { mkdir -p "$repo/$LEDGER_DIR"; printf '%s\n' "$@" > "$repo/$LEDGER_DIR/progress.md"; }
check() { local got; got="$(printf '%s' "$out" | q "$2")"; [[ "$got" == "$3" ]] && pass "$1" || { fail "$1"; echo "    $2 → $got (want $3)"; }; }
P='d.open_work[0].plans[0]'

# 1. active spec, active plan, two active tasks, no ledger
fresh; run
[[ "$rc" -eq 0 ]] && pass "exit 0" || fail "exit 0 (rc=$rc)"
check "no ledger: phase executing" 'd.phase' 'executing'
check "no ledger: 0/2" "$P.done+'/'+$P.total" '0/2'
check "no ledger: ledger none" "$P.ledger" 'none'
check "no ledger: no current task" 'String(d.focus.task)' 'null'
check "no ledger: focus spec/plan" "d.focus.spec+' '+d.focus.plan" 'WRK-SPEC-BILL-PRORATA-001 WRK-PLAN-BILL-PRORATA-001'
check "no ledger: nothing pending consolidation" 'd.pending_consolidation.length' '0'
check "root is the git toplevel" 'd.root' "$repo"

# 2. ledger completes task 001 by id
ledger "$IDENTITY" "Task WRK-TASK-BILL-PRORATA-001-001: complete (commits a1b2c3d..d4e5f6a, review clean)"; run
check "ledger by id: 1/2" "$P.done+'/'+$P.total" '1/2'
check "ledger by id: ledger used" "$P.ledger" 'used'
check "ledger by id: current is 002" 'd.focus.task' 'WRK-TASK-BILL-PRORATA-001-002'
check "ledger by id: task states" "$P.tasks.map(t=>t.state).join(',')" 'done,in-progress'

# 3. ledger completes task 1 by position, written as a list item
ledger "$IDENTITY" "- Task 1: complete (commits a1b2c3d..d4e5f6a, review clean)"; run
check "ledger by position: 1/2" "$P.done+'/'+$P.total" '1/2'

# 4. Task 10 is not Task 1
ledger "$IDENTITY" "Task 10: complete (commits a1b2c3d..d4e5f6a, review clean)"; run
check "Task 10 does not complete task 1" "$P.done" '0'

# 5. ledger naming another plan is ignored
ledger "# SDD ledger — plan: WRK-PLAN-OTHER-001 (specs/work/other.md)" "Task 1: complete (commits a..b, review clean)"; run
check "mismatch: flagged" "$P.ledger" 'mismatch'
check "mismatch: 0/2" "$P.done+'/'+$P.total" '0/2'
check "mismatch: no current task" 'String(d.focus.task)' 'null'

# 6. ledger tail: last 5 lines containing Ruling: or Knowledge gap:
ledger "$IDENTITY" "Ruling: r1 — a — b" "noise" "Task 1: Ruling: r2 — x" "Knowledge gap: g1" "Attack: A — Ruling: r3" "Task 2: parked — f — Ruling: r4" "Task 1: fix round 1/5 (1 addressed, 0 open; commits a..b)" "Knowledge gap: g2"; run
check "tail keeps 5 lines" "$P.ledger_tail.length" '5'
check "tail drops the oldest" "$P.ledger_tail[0]" 'Task 1: Ruling: r2 — x'
check "tail ends with the newest" "$P.ledger_tail[4]" 'Knowledge gap: g2'

# 7. draft spec → spec-review
fresh; set_status "$SPEC" draft; run
check "draft spec: spec-review" 'd.phase' 'spec-review'
check "draft spec: listed as open" 'd.open_work[0].status' 'draft'

# 8. active spec without a plan → planning
fresh; rm "$repo/$PLAN"; run
check "no plan: planning" 'd.phase' 'planning'

# 9. plan with no tasks → planning
fresh; rm "$repo/$T1" "$repo/$T2"; run
check "plan without tasks: planning" 'd.phase' 'planning'

# 10. a second, draft plan beside the active one → still executing
fresh; sed 's/^id: WRK-PLAN-BILL-PRORATA-001$/id: WRK-PLAN-BILL-PRORATA-002/' "$repo/$PLAN" > "$repo/$W/WRK-PLAN-BILL-PRORATA-002-second.md"
set_status "$W/WRK-PLAN-BILL-PRORATA-002-second.md" draft; run
check "second draft plan: two plans" 'd.open_work[0].plans.length' '2'
check "second draft plan: executing" 'd.phase' 'executing'

# 11. every task completed, spec and plan active → finishing
fresh; set_status "$T1" completed; set_status "$T2" completed; run
check "all tasks done: finishing" 'd.phase' 'finishing'
check "all tasks done: 2/2" "$P.done+'/'+$P.total" '2/2'

# 12. completed spec → consolidation pending
fresh; set_status "$SPEC" completed; set_status "$PLAN" completed; set_status "$T1" completed; set_status "$T2" completed; run
check "completed spec: phase" 'd.phase' 'consolidation-pending'
check "completed spec: pending list" 'd.pending_consolidation.join(",")' 'WRK-SPEC-BILL-PRORATA-001'

# 13. archived spec is not open
fresh; set_status "$SPEC" archived; run
check "archived spec: idle" 'd.phase' 'idle'

# 14. run from a subdirectory: root is still the toplevel
fresh; run "$repo/specs/work"
check "subdirectory: root is toplevel" 'd.root' "$repo"

# 15. outside git: root is the cwd
plain="$(mktemp -d)"; TMPS+=("$plain"); cp -R "$FIXTURE_SPECS" "$plain/specs"; run "$plain"
check "outside git: root is cwd" 'd.root' "$(cd "$plain" && pwd -P)"
check "outside git: still computed" 'd.phase' 'executing'

# 16. no specs/ → idle, exit 0
empty="$(mktemp -d)"; TMPS+=("$empty"); run "$empty"
[[ "$rc" -eq 0 ]] && pass "no specs: exit 0" || fail "no specs: exit 0 (rc=$rc)"
check "no specs: idle" 'd.phase+" "+d.open_work.length' 'idle 0'
check "no specs: says so" 'd.error+" / "+d.message' 'no-specs / no specs/ in this project'

# 17. toolkit unresolvable → error JSON, exit 0
fresh; nohome="$(mktemp -d)"; TMPS+=("$nohome")
out="$(cd "$repo" && env -u KDD_SPEC_GRAPH HOME="$nohome" "$KDD_STATUS" --json)"; rc=$?
[[ "$rc" -eq 0 ]] && pass "no toolkit: exit 0" || fail "no toolkit: exit 0 (rc=$rc)"
check "no toolkit: error" 'd.error' 'toolkit-not-found'
check "no toolkit: message from kdd-cli" 'd.message.startsWith("kdd toolkit not found")' 'true'

# 18. spec data comes through kdd-cli: a stub toolkit's spec appears
stubdir="$(mktemp -d)"; TMPS+=("$stubdir")
cat > "$stubdir/stub.mjs" <<'EOF'
const layer = process.argv[process.argv.indexOf('--layer') + 1];
console.log(JSON.stringify(layer === 'work-spec'
  ? [{ id: 'WRK-SPEC-STUB-001', layer: 'work-spec', status: 'active', title: 'stub', parent: null }]
  : []));
EOF
fresh; out="$(cd "$repo" && KDD_SPEC_GRAPH="$stubdir/stub.mjs" "$KDD_STATUS" --json)"
check "stub toolkit: its spec is the open work" 'd.open_work.map(s=>s.id).join(",")' 'WRK-SPEC-STUB-001'
check "stub toolkit: planning" 'd.phase' 'planning'

# 19. bad argument → exit 2
(cd "$repo" && "$KDD_STATUS" --bogus >/dev/null 2>&1); [[ $? -eq 2 ]] && pass "bad argument: exit 2" || fail "bad argument: exit 2"

# 20. no spec reads of its own, no toolkit path
[[ "$(grep -v '^import' "$KDD_STATUS" | grep -c 'readFileSync\|readdirSync')" == 1 ]] && pass "one file read in the CLI (the ledger)" || fail "one file read in the CLI (the ledger)"
grep -q "progress.md" "$KDD_STATUS" && pass "the read is the ledger" || fail "the read is the ledger"
! grep -q "node:fs" "$KDD_STATUS_LIB" && pass "lib does no I/O" || fail "lib does no I/O"
! grep -q "spec-graph" "$KDD_STATUS" "$KDD_STATUS_LIB" && pass "no toolkit path" || fail "no toolkit path"

finish
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/scripts/test-kdd-status.sh`
Expected: FAIL — every `check` fails because `skills/kdd-conventions/scripts/kdd-status` does not exist (`No such file or directory`).

- [ ] **Step 3: Write the library**

Create `skills/kdd-conventions/scripts/kdd-status-lib.mjs`:

```js
// kdd-status-lib — pure computation behind kdd-status (WRK-SPEC-FORK-MODS-001). No I/O.
//
// Ledger line forms (FRAG-FORK-LEDGER-001): line 1 `# SDD ledger — plan: <WRK-PLAN-ID> (<path>)`;
// a task is done on a line starting `Task <WRK-TASK-ID>: complete` or `Task <n>: complete`
// (n = position, the id's TTT suffix); rulings and gaps are lines containing `Ruling:` /
// `Knowledge gap:`. A leading list bullet (`- ` / `* `) is ignored.

const DONE = new Set(['completed', 'archived']);
const OPEN = new Set(['draft', 'active', 'completed']);
const RANK = ['executing', 'finishing', 'planning', 'spec-review', 'consolidation-pending'];
const TAIL = 5;
const byId = (a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0);

export function emptyStatus(root) {
  return { root, open_work: [], focus: null, phase: 'idle', pending_consolidation: [] };
}

export function readLedger(planId, text) {
  if (text === null || text === undefined) return { state: 'none', lines: [] };
  const lines = text.split(/\r?\n/).map(l => l.replace(/^\s*[-*]\s+/, ''));
  if (!lines[0].startsWith(`# SDD ledger — plan: ${planId} `)) return { state: 'mismatch', lines: [] };
  return { state: 'used', lines };
}

export function taskPosition(taskId) {
  const m = /-(\d{3})$/.exec(taskId);
  return m ? String(Number(m[1])) : null;
}

function completedInLedger(lines, taskId) {
  const pos = taskPosition(taskId);
  return lines.some(l => l.startsWith(`Task ${taskId}: complete`)
    || (pos !== null && l.startsWith(`Task ${pos}: complete`)));
}

export function planState(plan, tasks, ledgerText) {
  const ledger = readLedger(plan.id, ledgerText);
  const rows = tasks.map(t => ({
    id: t.id,
    title: t.title,
    done: DONE.has(t.status) || (ledger.state === 'used' && completedInLedger(ledger.lines, t.id)),
  }));
  const tracking = ledger.state === 'used' && plan.status === 'active';
  const current = tracking ? (rows.find(r => !r.done)?.id ?? null) : null;
  return {
    id: plan.id,
    status: plan.status,
    ledger: ledger.state,
    done: rows.filter(r => r.done).length,
    total: rows.length,
    current,
    tasks: rows.map(r => ({ id: r.id, title: r.title, state: r.done ? 'done' : r.id === current ? 'in-progress' : 'pending' })),
    ledger_tail: ledger.lines.filter(l => l.includes('Ruling:') || l.includes('Knowledge gap:')).slice(-TAIL),
  };
}

// First rule that applies (WRK-SPEC-FORK-MODS-001, Components → Phase).
export function phaseOf(spec, plans) {
  if (spec.status === 'completed') return 'consolidation-pending';
  if (spec.status === 'draft') return 'spec-review';
  if (plans.some(p => p.status === 'active' && p.done < p.total)) return 'executing';
  if (plans.some(p => p.status === 'draft')) return 'planning';
  if (plans.length > 0 && plans.every(p => DONE.has(p.status) || (p.total > 0 && p.done === p.total))) return 'finishing';
  return 'planning';
}

// nodes: [{ id, layer, status, title, parent }]; ledgerOf(planId) → ledger text or null.
export function computeStatus(root, nodes, ledgerOf) {
  const kids = (layer, parent) => nodes.filter(n => n.layer === layer && n.parent === parent).sort(byId);
  const open_work = nodes
    .filter(n => n.layer === 'work-spec' && OPEN.has(n.status))
    .sort(byId)
    .map(spec => {
      const plans = kids('work-plan', spec.id).map(p => planState(p, kids('work-task', p.id), ledgerOf(p.id)));
      return { id: spec.id, title: spec.title, status: spec.status, phase: phaseOf(spec, plans), plans };
    });
  if (open_work.length === 0) return emptyStatus(root);
  const top = [...open_work].sort((a, b) => RANK.indexOf(a.phase) - RANK.indexOf(b.phase) || byId(a, b))[0];
  const plan = top.plans.find(p => p.current) ?? top.plans.find(p => p.status === 'active') ?? null;
  return {
    root,
    open_work,
    focus: { spec: top.id, plan: plan?.id ?? null, task: plan?.current ?? null, done: plan?.done ?? 0, total: plan?.total ?? 0 },
    phase: top.phase,
    pending_consolidation: open_work.filter(s => s.status === 'completed').map(s => s.id),
  };
}
```

- [ ] **Step 4: Write the CLI**

Create `skills/kdd-conventions/scripts/kdd-status` and `chmod +x` it. It runs `kdd-cli` with `spawnSync` and an argv array (no shell):

```js
#!/usr/bin/env node
// kdd-status — the state of open KDD work as JSON (WRK-SPEC-FORK-MODS-001).
//
// Usage: kdd-status [--specs DIR] [--json]
// Root: `git rev-parse --show-toplevel` from the cwd, or the cwd outside git; specs default to <root>/specs.
// Spec data only through kdd-cli (`filter --layer … --format json`); the only file read here is each
// plan's SDD ledger, <root>/.kdd/sdd/<WRK-PLAN-ID>/progress.md.
// Always prints one JSON object and exits 0 (errors are `error` + `message`), except exit 2 on usage.
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { computeStatus, emptyStatus } from './kdd-status-lib.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const KDD_CLI = resolve(here, '../../using-superpowers/scripts/kdd-cli');

const args = process.argv.slice(2);
let specsArg = null;
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--json') continue;
  if (args[i] === '--specs' && args[i + 1]) { specsArg = args[++i]; continue; }
  console.error('usage: kdd-status [--specs DIR] [--json]');
  process.exit(2);
}

const git = spawnSync('git', ['rev-parse', '--show-toplevel'], { encoding: 'utf8' });
const root = git.status === 0 ? git.stdout.trim() : process.cwd();
const specs = specsArg ? resolve(specsArg) : join(root, 'specs');
const emit = value => { process.stdout.write(JSON.stringify(value, null, 2) + '\n'); process.exit(0); };

if (!existsSync(specs)) emit({ ...emptyStatus(root), error: 'no-specs', message: 'no specs/ in this project' });

const nodes = [];
for (const layer of ['work-spec', 'work-plan', 'work-task']) {
  const r = spawnSync(KDD_CLI, ['--specs', specs, 'filter', '--layer', layer, '--format', 'json'],
    { encoding: 'utf8', cwd: root, maxBuffer: 256 * 1024 * 1024 });
  if (r.status === 3) emit({ ...emptyStatus(root), error: 'toolkit-not-found', message: (r.stderr || '').trim() });
  let list;
  try { if (r.status !== 0) throw new Error(`exit ${r.status}`); list = JSON.parse(r.stdout); }
  catch (err) { emit({ ...emptyStatus(root), error: 'kdd-cli-failed', message: ((r.stderr || '').trim() || String(err.message)) }); }
  for (const n of list) nodes.push({ id: n.id, layer: n.layer, status: n.status, title: n.title, parent: n.parent ?? null });
}

const ledgerOf = planId => {
  const file = join(root, '.kdd', 'sdd', planId, 'progress.md');
  return existsSync(file) ? readFileSync(file, 'utf8') : null;
};

emit(computeStatus(root, nodes, ledgerOf));
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `chmod +x skills/kdd-conventions/scripts/kdd-status && bash tests/scripts/test-kdd-status.sh`
Expected: every line `[PASS]`, last line `PASS`.

- [ ] **Step 6: Run the whole deterministic suite**

Run: `bash tests/scripts/run.sh`
Expected: `### test-kdd-status.sh: ok`; no file fails that did not fail before this task (today `test-invariants.sh` fails 2 assertions because of the untracked `docs/superpowers/` — that stays as it is).

- [ ] **Step 7: Run it on this repository**

Run: `skills/kdd-conventions/scripts/kdd-status --json | node -e 'const d=JSON.parse(require("fs").readFileSync(0,"utf8")); console.log(d.phase, d.open_work.map(s=>s.id+":"+s.phase).join(" "))'`
Expected: `WRK-SPEC-FORK-CORE-001:finishing` and `WRK-SPEC-FORK-MODS-001:executing` are listed; `phase` is `executing`.

- [ ] **Step 8: Commit**

```bash
git add skills/kdd-conventions/scripts/kdd-status skills/kdd-conventions/scripts/kdd-status-lib.mjs tests/scripts/test-kdd-status.sh
git commit -m "feat(WRK-TASK-FORK-MODS-001-001): kdd-status — open KDD work as JSON"
```

## Acceptance Criteria

- [ ] `tests/scripts/test-kdd-status.sh` passes under `run.sh`, covering every fixture variant of the spec's *Testing* (spec AC1).
- [ ] Exit 0 with `error: toolkit-not-found` when `kdd-cli` exits 3; `phase: idle`, empty lists and `error: no-specs` (message `no specs/ in this project`) without `specs/` (spec AC2).
- [ ] A stub toolkit's spec appears in the output, the lib does no I/O, the CLI's only file read is the ledger, and no toolkit path is named (spec AC3).
- [ ] Ledger handling follows FRAG-FORK-LEDGER-001: identity line, completion by prefix with id or position, tail by containment.

## Test Plan

`bash tests/scripts/test-kdd-status.sh` (20 groups above), then `bash tests/scripts/run.sh` for regressions, then the run against this repository (Step 7).
