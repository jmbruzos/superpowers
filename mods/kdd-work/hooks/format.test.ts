import { expect, test } from 'claude-code/testing'

import type { KddStatus } from '../types'
import { bandFor, bandText, paneLines, statusLine, touchesWork } from './format'

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
  expect(paneLines(null, null, null)[0]?.text).toBe('kdd-superpowers not found')
  expect(paneLines(null, null, '/main')[0]?.text).toBe('Loading…')
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
