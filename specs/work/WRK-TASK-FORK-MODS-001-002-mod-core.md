---
id: WRK-TASK-FORK-MODS-001-002
type: spec
layer: work-task
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
title: "kdd-work mod core — manifest, contract, root location, refresh, status line, skill recording"
parent: WRK-PLAN-FORK-MODS-001
activates: []
equips: []
dependencies:
  - id: WRK-PLAN-FORK-MODS-001
    relation: implements
sources: []
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T13:30:00+02:00 }
stale_after: 2027-01-03T13:30:00+01:00
tags: [fork, mods, task, kdd-work]
---

# WRK-TASK-FORK-MODS-001-002 — kdd-work mod core

## Objective

Create the `kdd-work` plugin of function hooks and its non-visual half: find
the main plugin, run `kdd-status` when work may have changed (debounced, after
the tool has finished), keep the result in `$.state`, write the status line,
and record the `kdd-superpowers:*` skill the main loop is running. Task 003
draws the pane and the band from the same state.

## Implementation Notes

**Files:**
- Create: `mods/kdd-work/.claude-plugin/plugin.json`
- Create: `mods/kdd-work/hooks/hooks.json`
- Create: `mods/kdd-work/tsconfig.json`
- Create: `mods/kdd-work/types/index.d.ts` (the `$.state` contract and the `kdd-status` JSON types)
- Create: `mods/kdd-work/hooks/format.ts` (pure: status line, band text, work-path test)
- Create: `mods/kdd-work/hooks/state.ts` (the atoms, shared with task 003)
- Create: `mods/kdd-work/hooks/register.tsx` (hooks)
- Test: `mods/kdd-work/hooks/format.test.ts`, `mods/kdd-work/hooks/register.test.ts`

**Interfaces:**
- Consumes: `kdd-status --json` from WRK-TASK-FORK-MODS-001-001 — the JSON shape in that task's *Interfaces* (copied into `types/index.d.ts` below).
- Produces (task 003 relies on these exact names):
  - `types/index.d.ts`: `KddStatus`, `OpenSpec`, `PlanState`, `TaskState`, `Focus`; `PluginState['kdd-work']` = `{ status: KddStatus | null; stale: string | null; skill: string | null; mainRoot: string | null; bandDismissed: boolean }`.
  - `hooks/state.ts`: atoms `status`, `stale`, `skill`, `mainRoot`, `bandDismissed`.
  - `hooks/format.ts`: `statusLine(status: KddStatus | null, skill: string | null): string | undefined`, `bandText(status: KddStatus | null): string | null`, `touchesWork(text: string | undefined): boolean`, `SKILL_PREFIX = 'kdd-superpowers:'`.
  - `hooks/register.tsx`: `export const register: Register`; task 003 adds its hooks inside the same `register`.

**Premises:** none beyond the spec's. API names below were read from `claude-code.d.ts` (build 2.1.289) while planning: `'fs.exists': { path: string }` → `boolean` (:6751, :6944); `'fs.list'` → `FsEntry[]` with `name`, `kind: 'file' | 'dir' | 'other'` (:6745, :4743); `'session.cwd'` → `string` (:6578, :6877); `'env.get'` (:6846) — `$.env.get` takes a string literal; `'process.run': { argv, init? }` → `ProcessRunResult { exitCode, stdout, stderr, isStdoutTruncated, isStderrTruncated }` (:6831, :7694); `'ui.status': { text: string | undefined }` (:6675); `TimerCall = (ms, fn) => Timer`, `Timer = { cancel }` (:12065, :12054); `SkillPromptInput = { skill, text }` (:11337); tool-call input carries `agentId?` on subagent loops (`AgentLoop`, :196-205); `EngineInterface` is the type of `$` (:4333); `claude-code/testing` exports `test`, `expect`, `mock` (`mock.clock`, `mock.env`), a test body is `($, on)` whose `on` hooks stand for the engine (:14124-15174). If the build that runs this differs, the declaration file wins (see the plan's *Approach*).

- [ ] **Step 1: Scaffold the plugin**

`mods/kdd-work/.claude-plugin/plugin.json`:

```json
{
  "name": "kdd-work",
  "version": "0.1.0",
  "description": "Shows open KDD work (kdd-superpowers): pane, status line and a band while consolidation is pending",
  "types": "./types/index.d.ts"
}
```

`mods/kdd-work/hooks/hooks.json`:

```json
{ "modules": ["./register.tsx"] }
```

`mods/kdd-work/tsconfig.json` (extends the one the engine lays when it loads the mod):

```json
{ "extends": "./.claude-plugin/types/tsconfig.json" }
```

`mods/kdd-work/types/index.d.ts`:

```ts
export type TaskState = { id: string; title: string; state: 'done' | 'in-progress' | 'pending' }

export type PlanState = {
  id: string
  status: string
  ledger: 'none' | 'used' | 'mismatch'
  done: number
  total: number
  current: string | null
  tasks: TaskState[]
  ledger_tail: string[]
}

export type OpenSpec = {
  id: string
  title: string
  status: 'draft' | 'active' | 'completed'
  phase: string
  plans: PlanState[]
}

export type Focus = { spec: string; plan: string | null; task: string | null; done: number; total: number }

export type KddStatus = {
  root: string
  open_work: OpenSpec[]
  focus: Focus | null
  phase: string
  pending_consolidation: string[]
  error?: string
  message?: string
}

declare module 'claude-code' {
  interface PluginState {
    'kdd-work': {
      status: KddStatus | null
      stale: string | null
      skill: string | null
      mainRoot: string | null
      bandDismissed: boolean
    }
  }
}
```

`mods/kdd-work/hooks/state.ts`:

```ts
import { atom } from 'claude-code'

export const status = atom({ plugin: 'kdd-work', key: 'status' } as const, null)
export const stale = atom({ plugin: 'kdd-work', key: 'stale' } as const, null)
export const skill = atom({ plugin: 'kdd-work', key: 'skill' } as const, null)
export const mainRoot = atom({ plugin: 'kdd-work', key: 'mainRoot' } as const, null)
export const bandDismissed = atom({ plugin: 'kdd-work', key: 'bandDismissed' } as const, false)
```

- [ ] **Step 2: Write the failing pure tests**

`mods/kdd-work/hooks/format.test.ts`:

```ts
import { expect, test } from 'claude-code/testing'

import type { KddStatus } from '../types'
import { bandText, statusLine, touchesWork } from './format'

const base: KddStatus = { root: '/r', open_work: [], focus: null, phase: 'idle', pending_consolidation: [] }
const executing: KddStatus = {
  ...base,
  phase: 'executing',
  focus: { spec: 'WRK-SPEC-A-001', plan: 'WRK-PLAN-A-001', task: 'WRK-TASK-A-001-003', done: 2, total: 7 },
}
const finishing: KddStatus = {
  ...base,
  phase: 'finishing',
  focus: { spec: 'WRK-SPEC-A-001', plan: 'WRK-PLAN-A-001', task: null, done: 7, total: 7 },
}

test('status line with a focus task', () => {
  expect(statusLine(executing, null)).toBe('WRK-TASK-A-001-003 · 2/7')
})

test('status line without a focus task shows spec and phase', () => {
  expect(statusLine(finishing, null)).toBe('WRK-SPEC-A-001 · finishing')
})

test('status line appends the kdd-superpowers skill without its prefix', () => {
  expect(statusLine(executing, 'kdd-superpowers:test-driven-development')).toBe(
    'WRK-TASK-A-001-003 · 2/7 · test-driven-development',
  )
})

test('status line ignores skills of other plugins', () => {
  expect(statusLine(executing, 'other:thing')).toBe('WRK-TASK-A-001-003 · 2/7')
})

test('no open work: the skill alone, or nothing', () => {
  expect(statusLine(base, 'kdd-superpowers:brainstorming')).toBe('brainstorming')
  expect(statusLine(base, null)).toBe(undefined)
  expect(statusLine(null, null)).toBe(undefined)
})

test('an error status shows no work', () => {
  expect(statusLine({ ...executing, error: 'toolkit-not-found' }, null)).toBe(undefined)
})

test('band text names each pending spec and kdd:spec-consolidate', () => {
  expect(bandText({ ...base, pending_consolidation: ['WRK-SPEC-A-001', 'WRK-SPEC-B-001'] })).toBe(
    'Consolidation pending: WRK-SPEC-A-001 — run kdd:spec-consolidate WRK-SPEC-A-001, ' +
      'WRK-SPEC-B-001 — run kdd:spec-consolidate WRK-SPEC-B-001',
  )
})

test('no band without pending consolidation or on error', () => {
  expect(bandText(base)).toBe(null)
  expect(bandText(null)).toBe(null)
  expect(bandText({ ...base, pending_consolidation: ['WRK-SPEC-A-001'], error: 'kdd-cli-failed' })).toBe(null)
})

test('work paths are specs/ and .kdd/', () => {
  expect(touchesWork('git add specs/work/X.md')).toBe(true)
  expect(touchesWork('/repo/.kdd/sdd/WRK-PLAN-A-001/progress.md')).toBe(true)
  expect(touchesWork('src/app.ts')).toBe(false)
  expect(touchesWork(undefined)).toBe(false)
})
```

- [ ] **Step 3: Run them to verify they fail**

Run: `claude plugin test mods/kdd-work`
Expected: FAIL — `./format` cannot be resolved.

- [ ] **Step 4: Write `hooks/format.ts`**

```ts
import type { KddStatus } from '../types'

export const SKILL_PREFIX = 'kdd-superpowers:'

function skillLabel(skill: string | null): string | null {
  return skill !== null && skill.startsWith(SKILL_PREFIX) ? skill.slice(SKILL_PREFIX.length) : null
}

// `<task> · <done>/<total>` or `<spec> · <phase>`, then ` · <skill>` (WRK-SPEC-FORK-MODS-001, Components).
export function statusLine(status: KddStatus | null, skill: string | null): string | undefined {
  const parts: string[] = []
  const focus = status !== null && status.error === undefined ? status.focus : null
  if (focus !== null) {
    parts.push(focus.task !== null ? `${focus.task} · ${focus.done}/${focus.total}` : `${focus.spec} · ${status!.phase}`)
  }
  const label = skillLabel(skill)
  if (label !== null) parts.push(label)
  return parts.length > 0 ? parts.join(' · ') : undefined
}

// Pending consolidation runs through kdd:spec-consolidate (finishing-a-development-branch/SKILL.md:146-148).
export function bandText(status: KddStatus | null): string | null {
  if (status === null || status.error !== undefined || status.pending_consolidation.length === 0) return null
  const items = status.pending_consolidation.map(id => `${id} — run kdd:spec-consolidate ${id}`)
  return `Consolidation pending: ${items.join(', ')}`
}

export function touchesWork(text: string | undefined): boolean {
  return text !== undefined && (text.includes('specs/') || text.includes('.kdd/'))
}
```

- [ ] **Step 5: Run the pure tests to verify they pass**

Run: `claude plugin test mods/kdd-work`
Expected: the 9 `format.test.ts` tests PASS.

- [ ] **Step 6: Write the failing engine tests**

`mods/kdd-work/hooks/register.test.ts` — the test's `on` stands for the engine: it answers `process.run`, `fs.exists`, `fs.list`, `session.cwd` and the tools, and observes `ui.status`.

```ts
import { expect, mock, test } from 'claude-code/testing'
import type { On } from 'claude-code'

import type { KddStatus } from '../types'

const SCRIPT = '/main/skills/kdd-conventions/scripts/kdd-status'
const STATUS: KddStatus = {
  root: '/proj',
  open_work: [],
  focus: { spec: 'WRK-SPEC-A-001', plan: 'WRK-PLAN-A-001', task: 'WRK-TASK-A-001-002', done: 1, total: 3 },
  phase: 'executing',
  pending_consolidation: [],
}

function world(on: On, opts: { root?: string | null; fail?: boolean } = {}) {
  const clock = mock.clock(on)
  const env: Record<string, string> = { HOME: '/home/u' }
  if (opts.root !== null) env.KDD_SUPERPOWERS_ROOT = opts.root ?? '/main'
  mock.env(on, env)
  const runs: string[][] = []
  const lines: (string | undefined)[] = []
  on('fs.exists', (_$, e) => e.path === SCRIPT)
  on('fs.list', () => [])
  on('session.cwd', () => '/proj')
  on('process.run', (_$, e) => {
    runs.push([...e.argv])
    return opts.fail
      ? { exitCode: 1, stdout: '', stderr: 'boom', isStdoutTruncated: false, isStderrTruncated: false }
      : { exitCode: 0, stdout: JSON.stringify(STATUS), stderr: '', isStdoutTruncated: false, isStderrTruncated: false }
  })
  on('ui.status', (_$, e) => {
    lines.push(e.text)
  })
  on('tool.call', () => ({ text: 'ok' }))
  return { clock, runs, lines }
}

test('a Bash call touching specs/ refreshes once after the debounce, then writes the status line', async ($, on) => {
  const w = world(on)
  await $.tool.call({ tool: 'Bash', command: 'git add specs/work/x.md' })
  await $.tool.call({ tool: 'Edit', file_path: 'specs/work/x.md', old_string: 'a', new_string: 'b' })
  expect(w.runs.length).toBe(0)
  await w.clock.advance(300)
  expect(w.runs).toEqual([['node', SCRIPT, '--json']])
  expect(w.lines.at(-1)).toBe('WRK-TASK-A-001-002 · 1/3')
})

test('a call touching neither specs/ nor .kdd/ does not refresh', async ($, on) => {
  const w = world(on)
  await $.tool.call({ tool: 'Bash', command: 'ls src' })
  await w.clock.advance(1000)
  expect(w.runs.length).toBe(0)
})

test('a main-loop kdd-superpowers Skill call is recorded; a subagent one is not', async ($, on) => {
  const w = world(on)
  await $.tool.call({ tool: 'Bash', command: 'cat specs/a' })
  await w.clock.advance(300)
  await $.tool.call({ tool: 'Skill', skill: 'kdd-superpowers:test-driven-development' })
  expect(w.lines.at(-1)).toBe('WRK-TASK-A-001-002 · 1/3 · test-driven-development')
  await $.tool.call({ tool: 'Skill', skill: 'kdd-superpowers:brainstorming', agentId: 'sub-1' })
  expect(w.lines.at(-1)).toBe('WRK-TASK-A-001-002 · 1/3 · test-driven-development')
  expect(w.runs.length).toBe(1)
})

test('a failed run keeps the last good status and records why', async ($, on) => {
  const w = world(on, { fail: true })
  await $.tool.call({ tool: 'Bash', command: 'cat specs/a' })
  await w.clock.advance(300)
  const { value } = await $.state.get({ plugin: 'kdd-work', key: 'stale' } as const)
  expect(value).toMatch(/kdd-status exit 1/)
  const last = await $.state.get({ plugin: 'kdd-work', key: 'status' } as const)
  expect(last.value ?? null).toBe(null)
})

test('without the main plugin the status line says so and nothing runs', async ($, on) => {
  const w = world(on, { root: null })
  await $.tool.call({ tool: 'Bash', command: 'cat specs/a' })
  await w.clock.advance(300)
  expect(w.runs.length).toBe(0)
  expect(w.lines.at(-1)).toBe('kdd-work: kdd-superpowers not found')
})
```

- [ ] **Step 7: Run them to verify they fail**

Run: `claude plugin test mods/kdd-work`
Expected: the 5 `register.test.ts` tests FAIL (no `register.tsx` yet: `hooks.json` names a missing module).

- [ ] **Step 8: Write `hooks/register.tsx`**

```tsx
import { read, update } from 'claude-code'
import type { EngineInterface, Register, Timer } from 'claude-code'

import type { KddStatus } from '../types'
import { SKILL_PREFIX, statusLine, touchesWork } from './format'
import { mainRoot, skill, stale, status } from './state'

const SCRIPT = 'skills/kdd-conventions/scripts/kdd-status'
const CACHE = '.claude/plugins/cache/kdd-superpowers/kdd-superpowers'
const DEBOUNCE_MS = 300
const TIMEOUT_MS = 5000

function newestFirst(a: string, b: string): number {
  const pa = a.split('.').map(Number)
  const pb = b.split('.').map(Number)
  for (let i = 0; i < 3; i++) {
    const d = (pb[i] ?? 0) - (pa[i] ?? 0)
    if (d !== 0) return d
  }
  return 0
}

// KDD_SUPERPOWERS_ROOT → the working copy (mods/kdd-work/../..) → the newest installed version.
async function locateMainRoot($: EngineInterface): Promise<string | null> {
  const fromEnv = await $.env.get('KDD_SUPERPOWERS_ROOT')
  if (fromEnv !== undefined && (await $.fs.exists(`${fromEnv}/${SCRIPT}`))) return fromEnv
  const workingCopy = `${$.plugin.root}/../..`
  if (await $.fs.exists(`${workingCopy}/${SCRIPT}`)) return workingCopy
  const home = await $.env.get('HOME')
  if (home === undefined) return null
  const cache = `${home}/${CACHE}`
  if (!(await $.fs.exists(cache))) return null
  const versions = (await $.fs.list(cache))
    .filter(entry => entry.kind === 'dir' && /^\d+\.\d+\.\d+$/.test(entry.name))
    .map(entry => entry.name)
    .sort(newestFirst)
  for (const version of versions) {
    if (await $.fs.exists(`${cache}/${version}/${SCRIPT}`)) return `${cache}/${version}`
  }
  return null
}

async function recordSkill($: EngineInterface, name: string): Promise<void> {
  if (!name.startsWith(SKILL_PREFIX)) return
  await update($, skill, () => name)
  $.ui.status(statusLine(await read($, status), name))
}

export const register: Register = on => {
  let pending: Timer | null = null

  async function refresh($: EngineInterface): Promise<void> {
    const root = await locateMainRoot($)
    await update($, mainRoot, () => root)
    if (root === null) {
      $.ui.status('kdd-work: kdd-superpowers not found')
      return
    }
    let next: KddStatus
    try {
      const ran = await $.process.run(['node', `${root}/${SCRIPT}`, '--json'], {
        cwd: await $.session.cwd(),
        timeoutMs: TIMEOUT_MS,
      })
      if (ran.exitCode !== 0) throw new Error(`kdd-status exit ${ran.exitCode}: ${ran.stderr.trim()}`)
      next = JSON.parse(ran.stdout) as KddStatus
    } catch (err) {
      await update($, stale, () => (err instanceof Error ? err.message : String(err)))
      return
    }
    await update($, status, () => next)
    await update($, stale, () => null)
    $.ui.status(statusLine(next, await read($, skill)))
  }

  function schedule($: EngineInterface): void {
    pending?.cancel()
    pending = $.clock.after(DEBOUNCE_MS, () => {
      pending = null
      void refresh($)
    })
  }

  on('session.start', async ($, e, next) => {
    schedule($)
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const done = await next(e)
    schedule($)
    return done
  })

  on('skill.prompt', async ($, e, next) => {
    await recordSkill($, e.skill)
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    if (e.tool === 'Skill') {
      if (e.agentId === undefined) await recordSkill($, e.skill)
      return next(e)
    }
    const ran = await next(e)
    const target = e.tool === 'Bash' ? e.command : e.tool === 'Write' || e.tool === 'Edit' ? e.file_path : undefined
    if (touchesWork(target)) schedule($)
    return ran
  })
}
```

- [ ] **Step 9: Validate, type-check, test**

Run: `claude plugin validate mods/kdd-work`
Expected: reports the hooks (`session.start`, `turn.complete`, `skill.prompt`, `tool.call`) and nothing refused.

Run: `claude plugin test mods/kdd-work`
Expected: 14 tests PASS (9 format, 5 register).

Type-check. Where the engine has not loaded the mod yet, write a throwaway tsconfig outside the mod, per the header of the types file:

```bash
TYPES=/private/tmp/claude-501/bundled-skills/2.1.289/b0610be21fa2b284bc6b23b836f226b9/plugin-authoring/types/claude-code.d.ts
mkdir -p "$TMPDIR/kdd-work-tsc" && cat > "$TMPDIR/kdd-work-tsc/tsconfig.json" <<EOF
{ "compilerOptions": { "target": "es2023", "lib": ["es2023"], "types": [], "module": "esnext",
    "moduleResolution": "bundler", "strict": true, "noUncheckedIndexedAccess": true, "noEmit": true,
    "skipLibCheck": true, "jsx": "react", "jsxFactory": "h", "jsxFragmentFactory": "Fragment" },
  "include": ["$TYPES", "$PWD/mods/kdd-work/hooks", "$PWD/mods/kdd-work/types"] }
EOF
npx -y -p typescript tsc -p "$TMPDIR/kdd-work-tsc"
```
Expected: exit 0, no output. (After the engine has loaded the mod: `npx -y -p typescript tsc -p mods/kdd-work`.)

- [ ] **Step 10: Commit**

```bash
git add mods/kdd-work
git commit -m "feat(WRK-TASK-FORK-MODS-001-002): kdd-work mod core — refresh, status line, skill recording"
```

## Acceptance Criteria

- [ ] `claude plugin validate mods/kdd-work` reports nothing refused; type-check exits 0 (spec AC4, first half).
- [ ] Status line matches the spec's format with and without a focus task, appends only `kdd-superpowers:*` skills recorded from the main loop (`Skill` without `agentId`, and `skill.prompt`) — `format.test.ts`, `register.test.ts` (spec AC4).
- [ ] Refresh runs only after the tool resolved, only for `specs/` or `.kdd/`, coalesced by a 300 ms debounce; a failure keeps the last good state and records `stale` (spec *Data flow*, *Error handling*).
- [ ] Main plugin located by `KDD_SUPERPOWERS_ROOT`, working copy, or newest cached version; not found → `kdd-work: kdd-superpowers not found`.

## Test Plan

`claude plugin test mods/kdd-work` (14 tests), `claude plugin validate mods/kdd-work`, type-check. `session.start` and `turn.complete` triggers are exercised in task 004's manual check.
