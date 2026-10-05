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

type Write = { key: string; value: unknown }

function world(on: On, opts: { root?: string | null; fail?: boolean } = {}) {
  const clock = mock.clock(on)
  const env: Record<string, string> = { HOME: '/home/u' }
  if (opts.root !== null) env.KDD_SUPERPOWERS_ROOT = opts.root ?? '/main'
  mock.env(on, env)
  const runs: string[][] = []
  const lines: (string | undefined)[] = []
  const writes: Write[] = []
  on('state.set', { plugin: 'kdd-work' }, (_$, e, next) => {
    writes.push({ key: e.key, value: e.value })
    return next(e)
  })
  on('fs.exists', (_$, e) => ({ value: e.path === SCRIPT }))
  on('fs.list', () => ({ value: [] }))
  on('session.cwd', () => ({ value: '/proj' }))
  on('process.run', (_$, e) => {
    runs.push([...e.argv])
    return {
      value: opts.fail
        ? { exitCode: 1, stdout: '', stderr: 'boom', isStdoutTruncated: false, isStderrTruncated: false }
        : { exitCode: 0, stdout: JSON.stringify(STATUS), stderr: '', isStdoutTruncated: false, isStderrTruncated: false },
    }
  })
  on('ui.status', (_$, e) => {
    lines.push(e.text)
    return { value: undefined }
  })
  on('tool.call', () => ({ result: { text: 'ok' } }))
  return { clock, runs, lines, writes }
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
  // agentId is not in $.tool.call's declared input (AgentLoop is on the hook's `e`), but the engine carries it.
  const fromSubagent = { tool: 'Skill', skill: 'kdd-superpowers:brainstorming', agentId: 'sub-1' } as const
  await $.tool.call(fromSubagent)
  expect(w.lines.at(-1)).toBe('WRK-TASK-A-001-002 · 1/3 · test-driven-development')
  expect(w.runs.length).toBe(1)
})

test('a failed run keeps the last good status and records why', async ($, on) => {
  const w = world(on, { fail: true })
  await $.tool.call({ tool: 'Bash', command: 'cat specs/a' })
  await w.clock.advance(300)
  const stales = w.writes.filter(x => x.key === 'stale')
  expect(String(stales.at(-1)?.value)).toMatch(/kdd-status exit 1/)
  expect(w.writes.some(x => x.key === 'status')).toBe(false)
})

test('without the main plugin the status line says so and nothing runs', async ($, on) => {
  const w = world(on, { root: null })
  await $.tool.call({ tool: 'Bash', command: 'cat specs/a' })
  await w.clock.advance(300)
  expect(w.runs.length).toBe(0)
  expect(w.lines.at(-1)).toBe('kdd-work: kdd-superpowers not found')
})
