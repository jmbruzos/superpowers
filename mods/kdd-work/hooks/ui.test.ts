import { expect, mock, test } from 'claude-code/testing'
import type { On } from 'claude-code'

// The test kit's `$.command.run` takes the whole CommandRunInput (d.ts :14343), not CommandRunArgs (:1699).
const ORIGIN = { kind: 'composer' } as const
const PRESENTATION = { isFullscreen: false, columns: 80 }

function world(on: On) {
  mock.clock(on)
  mock.env(on, { HOME: '/home/u' })
  const opened: string[] = []
  const writes: { key: string; value: unknown }[] = []
  on('state.set', { plugin: 'kdd-work' }, (_$, e, next) => {
    writes.push({ key: e.key, value: e.value })
    return next(e)
  })
  on('fs.exists', () => ({ value: false }))
  on('fs.list', () => ({ value: [] }))
  on('session.cwd', () => ({ value: '/proj' }))
  on('ui.status', () => ({ value: undefined }))
  on('ui.open', (_$, e) => {
    opened.push(e.id)
    return { value: { isPlaced: true } }
  })
  return { opened, writes }
}

test('/kdd-work opens the kdd-work pane', async ($, on) => {
  const w = world(on)
  const ran = await $.command.run({ command: 'kdd-work', args: '', origin: ORIGIN, presentation: PRESENTATION })
  expect(w.opened).toEqual(['kdd-work'])
  expect(ran.text).toBe('KDD work pane opened.')
})

test('/kdd-work dismiss hides the band for the session', async ($, on) => {
  const w = world(on)
  const ran = await $.command.run({ command: 'kdd-work', args: 'dismiss', origin: ORIGIN, presentation: PRESENTATION })
  expect(w.opened).toEqual([])
  expect(ran.text).toBe('Consolidation band hidden for this session.')
  expect(w.writes.filter(x => x.key === 'bandDismissed').at(-1)?.value).toBe(true)
})
