---
id: WRK-TASK-FORK-MODS-001-003
type: spec
layer: work-task
scope: ephemeral
status: archived
confidence: low
version: 0.1.0
created: 2026-10-05
updated: 2026-10-05
owner: jmbruzos
title: "kdd-work mod UI — /kdd-work pane, consolidation band, /kdd-work dismiss"
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

# WRK-TASK-FORK-MODS-001-003 — kdd-work mod UI

## Objective

Draw what task 002 keeps in `$.state`: the `/kdd-work` pane (open work as a
spec → plan → tasks tree with the ledger tail, the root being read, staleness
and errors) and the band above the prompt while consolidation is pending, with
`/kdd-work dismiss` hiding the band for the session.

## Implementation Notes

**Files:**
- Modify: `mods/kdd-work/hooks/format.ts` (add `paneLines`, `bandFor`)
- Modify: `mods/kdd-work/hooks/register.tsx` (command, pane and band hooks)
- Test: `mods/kdd-work/hooks/format.test.ts` (append), `mods/kdd-work/hooks/ui.test.ts` (new)

**Interfaces:**
- Consumes (task 002): `KddStatus` and friends from `../types`; atoms `status`, `stale`, `mainRoot`, `bandDismissed` from `./state`; `bandText(status)` from `./format`.
- Produces: `paneLines(status: KddStatus | null, stale: string | null, mainRoot: string | null): PaneLine[]` with `type PaneLine = { text: string; dim?: boolean; bold?: boolean }`; `bandFor(status: KddStatus | null, dismissed: boolean): string | null`; command `/kdd-work` (no args → opens pane `kdd-work`; `dismiss` → hides the band).

**Premises:** none beyond the spec's. Read in `claude-code.d.ts` while planning: `CommandRunInput = { command, args, origin, … }` and the test call `$.command.run({ command, args? })` (:1699, :1710, `EventCalls.command.run`); `'ui.open': PaneOpenArgs = { id, title?, … }` (:6703, :7058); a `ui.render` hook on `{ component: 'Pane', requestId }` and on `{ component: 'AbovePrompt' }`, `$.ui.resolve(e)` giving `Box`, `Text` (plugin-authoring `examples/pane.tsx`, `examples/band.tsx`); `AbovePrompt` props include `hasSurvey`, `bodyColumns`, and `scroll`/`view` site objects (:9713-9720) — too heavy to mount by hand in a test, so the drawing decisions live in the pure `paneLines`/`bandFor` and the render hooks only map them to elements.

- [ ] **Step 1: Append the failing pure tests**

Append to `mods/kdd-work/hooks/format.test.ts`:

```ts
import { bandFor, paneLines } from './format'

const tree: KddStatus = {
  root: '/proj',
  phase: 'executing',
  pending_consolidation: [],
  focus: { spec: 'WRK-SPEC-A-001', plan: 'WRK-PLAN-A-001', task: 'WRK-TASK-A-001-002', done: 1, total: 3 },
  open_work: [
    {
      id: 'WRK-SPEC-A-001',
      title: 'A',
      status: 'active',
      phase: 'executing',
      plans: [
        {
          id: 'WRK-PLAN-A-001',
          status: 'active',
          ledger: 'used',
          done: 1,
          total: 3,
          current: 'WRK-TASK-A-001-002',
          tasks: [
            { id: 'WRK-TASK-A-001-001', title: 't1', state: 'done' },
            { id: 'WRK-TASK-A-001-002', title: 't2', state: 'in-progress' },
            { id: 'WRK-TASK-A-001-003', title: 't3', state: 'pending' },
          ],
          ledger_tail: ['Knowledge gap: DOM-X-001 pinned 1.0.0, file 1.1.0'],
        },
      ],
    },
    {
      id: 'WRK-SPEC-B-001',
      title: 'B',
      status: 'active',
      phase: 'planning',
      plans: [{ id: 'WRK-PLAN-B-001', status: 'active', ledger: 'mismatch', done: 0, total: 1, current: null, tasks: [{ id: 'WRK-TASK-B-001-001', title: 'u', state: 'pending' }], ledger_tail: [] }],
    },
  ],
}

test('pane: root, spec headers, marked tasks, ledger tail, mismatch', () => {
  expect(paneLines(tree, null, '/main').map(l => l.text)).toEqual([
    'reading /proj',
    'WRK-SPEC-A-001 · executing',
    '  WRK-PLAN-A-001 · 1/3',
    '    ✓ WRK-TASK-A-001-001 t1',
    '    ▶ WRK-TASK-A-001-002 t2',
    '    · WRK-TASK-A-001-003 t3',
    '    Knowledge gap: DOM-X-001 pinned 1.0.0, file 1.1.0',
    'WRK-SPEC-B-001 · planning',
    '  WRK-PLAN-B-001 · 0/1 · ledger mismatch',
    '    · WRK-TASK-B-001-001 u',
  ])
})

test('pane: stale line under the root when the last refresh failed', () => {
  expect(paneLines(tree, 'kdd-status exit 1: boom', '/main').map(l => l.text).slice(0, 2)).toEqual([
    'reading /proj',
    'stale: kdd-status exit 1: boom',
  ])
})

test('pane: errors and empty states', () => {
  expect(paneLines(null, null, null)[0].text).toBe('kdd-superpowers not found')
  expect(paneLines(null, null, '/main')[0].text).toBe('Loading…')
  expect(paneLines({ ...base, error: 'no-specs', message: 'no specs/ in this project' }, null, '/main').map(l => l.text)).toEqual([
    'reading /r',
    'no specs/ in this project',
  ])
  expect(paneLines(base, null, '/main').map(l => l.text)).toEqual(['reading /r', 'No open work.'])
})

test('band: shown while pending and not dismissed', () => {
  const pending = { ...base, pending_consolidation: ['WRK-SPEC-A-001'] }
  expect(bandFor(pending, false)).toBe('Consolidation pending: WRK-SPEC-A-001 — run kdd:spec-consolidate WRK-SPEC-A-001')
  expect(bandFor(pending, true)).toBe(null)
  expect(bandFor(base, false)).toBe(null)
})
```

- [ ] **Step 2: Run them to verify they fail**

Run: `claude plugin test mods/kdd-work`
Expected: the 4 new tests FAIL — `paneLines` / `bandFor` are not exported.

- [ ] **Step 3: Add `paneLines` and `bandFor` to `hooks/format.ts`**

```ts
export type PaneLine = { text: string; dim?: boolean; bold?: boolean }

const MARK = { done: '✓', 'in-progress': '▶', pending: '·' } as const

export function paneLines(status: KddStatus | null, stale: string | null, mainRoot: string | null): PaneLine[] {
  if (mainRoot === null) {
    return [
      { text: 'kdd-superpowers not found', bold: true },
      { text: 'Set KDD_SUPERPOWERS_ROOT to the kdd-superpowers plugin folder, or install kdd-superpowers.', dim: true },
    ]
  }
  if (status === null) return [{ text: stale !== null ? `stale: ${stale}` : 'Loading…', dim: true }]
  const out: PaneLine[] = [{ text: `reading ${status.root}`, dim: true }]
  if (stale !== null) out.push({ text: `stale: ${stale}`, dim: true })
  if (status.error !== undefined) {
    out.push({ text: status.message ?? status.error })
    return out
  }
  if (status.open_work.length === 0) {
    out.push({ text: 'No open work.', dim: true })
    return out
  }
  for (const spec of status.open_work) {
    out.push({ text: `${spec.id} · ${spec.phase}`, bold: true })
    for (const plan of spec.plans) {
      const mismatch = plan.ledger === 'mismatch' ? ' · ledger mismatch' : ''
      out.push({ text: `  ${plan.id} · ${plan.done}/${plan.total}${mismatch}` })
      for (const task of plan.tasks) {
        out.push({ text: `    ${MARK[task.state]} ${task.id} ${task.title}`, dim: task.state === 'done' })
      }
      for (const line of plan.ledger_tail) out.push({ text: `    ${line}`, dim: true })
    }
  }
  return out
}

export function bandFor(status: KddStatus | null, dismissed: boolean): string | null {
  return dismissed ? null : bandText(status)
}
```

- [ ] **Step 4: Run the pure tests to verify they pass**

Run: `claude plugin test mods/kdd-work`
Expected: 18 tests PASS (13 format, 5 register).

- [ ] **Step 5: Write the failing command tests**

`mods/kdd-work/hooks/ui.test.ts`:

```ts
import { expect, mock, test } from 'claude-code/testing'
import type { On } from 'claude-code'

function world(on: On) {
  mock.clock(on)
  mock.env(on, { HOME: '/home/u' })
  const opened: string[] = []
  on('fs.exists', () => false)
  on('fs.list', () => [])
  on('session.cwd', () => '/proj')
  on('ui.status', () => {})
  on('ui.open', (_$, e) => {
    opened.push(e.id)
    return { isOpen: true } as never
  })
  return { opened }
}

test('/kdd-work opens the kdd-work pane', async ($, on) => {
  const w = world(on)
  const ran = await $.command.run({ command: 'kdd-work' })
  expect(w.opened).toEqual(['kdd-work'])
  expect(ran.text).toBe('KDD work pane opened.')
})

test('/kdd-work dismiss hides the band for the session', async ($, on) => {
  const w = world(on)
  const ran = await $.command.run({ command: 'kdd-work', args: 'dismiss' })
  expect(w.opened).toEqual([])
  expect(ran.text).toBe('Consolidation band hidden for this session.')
  const { value } = await $.state.get({ plugin: 'kdd-work', key: 'bandDismissed' } as const)
  expect(value).toBe(true)
})
```

(`{ isOpen: true } as never` stands for the engine's `UiOpenResult`; if `tsc` names its fields, return them instead.)

- [ ] **Step 6: Run them to verify they fail**

Run: `claude plugin test mods/kdd-work`
Expected: the 2 `ui.test.ts` tests FAIL — no `command.run` hook answers `kdd-work`.

- [ ] **Step 7: Add the UI hooks to `hooks/register.tsx`**

Change the imports at the top:

```tsx
import { read, update } from 'claude-code'
import type { EngineInterface, Register, Timer } from 'claude-code'

import type { KddStatus } from '../types'
import { bandFor, paneLines, SKILL_PREFIX, statusLine, touchesWork } from './format'
import { bandDismissed, mainRoot, skill, stale, status } from './state'

const PANE = 'kdd-work'
```

Replace the `session.start` hook with:

```tsx
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'kdd-work',
      description: 'Show open KDD work in a pane; "/kdd-work dismiss" hides the consolidation band for this session',
    })
    schedule($)
    return next(e)
  })
```

Add, at the end of `register` (after the `tool.call` hook):

```tsx
  on('command.run', { command: 'kdd-work' }, async ($, e) => {
    if (e.args.trim() === 'dismiss') {
      await update($, bandDismissed, () => true)
      return { text: 'Consolidation band hidden for this session.' }
    }
    await $.ui.open({ id: PANE, title: 'KDD work' })
    return { text: 'KDD work pane opened.' }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const lines = paneLines(await read($, status), await read($, stale), await read($, mainRoot))
    return (
      <Box flexDirection="column">
        {lines.map(line => (
          <Text dimColor={line.dim === true} bold={line.bold === true}>
            {line.text}
          </Text>
        ))}
      </Box>
    )
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const text = bandFor(await read($, status), await read($, bandDismissed))
    if (text === null || e.props.hasSurvey) return next(e)
    const { Box, Text } = $.ui.resolve(e)
    return (
      <Box>
        <Text bold>{text}</Text>
      </Box>
    )
  })
```

- [ ] **Step 8: Validate, type-check, test**

Run: `claude plugin validate mods/kdd-work`
Expected: also reports `command.run` and the two `ui.render` hooks; nothing refused.

Run: `claude plugin test mods/kdd-work`
Expected: 20 tests PASS (13 format, 5 register, 2 ui).

Type-check as in WRK-TASK-FORK-MODS-001-002 Step 9 (throwaway tsconfig, or `npx -y -p typescript tsc -p mods/kdd-work` once the engine has loaded the mod). Expected: exit 0.

- [ ] **Step 9: Commit**

```bash
git add mods/kdd-work
git commit -m "feat(WRK-TASK-FORK-MODS-001-003): kdd-work pane, consolidation band, /kdd-work dismiss"
```

## Acceptance Criteria

- [ ] Pane shows the root, each open WRK-SPEC with its phase, each plan with `done/total` and `ledger mismatch` when flagged, tasks marked ✓ / ▶ / ·, the ledger tail, a `stale:` line, and the error/empty texts of the spec's *Error handling* (`no specs/ in this project`, `kdd-superpowers not found`) — `format.test.ts`.
- [ ] Band text is `Consolidation pending: <id> — run kdd:spec-consolidate <id>` while pending and not dismissed; `/kdd-work dismiss` sets `bandDismissed` — `format.test.ts`, `ui.test.ts` (spec AC4).
- [ ] `/kdd-work` opens pane `kdd-work` — `ui.test.ts`.
- [ ] Validate and type-check clean.

## Test Plan

`claude plugin test mods/kdd-work` (20 tests), `claude plugin validate mods/kdd-work`, type-check. The drawn pane and band are checked live in task 004.
