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
