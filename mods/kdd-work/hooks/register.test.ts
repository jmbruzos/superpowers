import { expect, mock, test } from 'claude-code/testing'
import type { FsEntry, On } from 'claude-code'

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

type Opts = {
  root?: string | null
  fail?: boolean
  exists?: (path: string) => boolean
  list?: Pick<FsEntry, 'name' | 'kind'>[]
  toolCall?: () => Promise<{ result: { text: string } }>
}

function world(on: On, opts: Opts = {}) {
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
  on('fs.exists', (_$, e) => ({ value: (opts.exists ?? (p => p === SCRIPT))(e.path) }))
  on('fs.list', () => ({ value: (opts.list ?? []).map(entry => ({ size: 0, mtimeMs: 0, isLink: false, ...entry })) }))
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
  on('tool.call', opts.toolCall ?? (() => ({ result: { text: 'ok' } })))
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
  expect(w.writes.filter(x => x.key === 'status').at(-1)).toEqual({ key: 'status', value: null })
})

test('refresh is scheduled only after the tool resolved', async ($, on) => {
  let resolved = false
  const slow = async () => {
    await w.clock.advance(1000)
    resolved = true
    return { result: { text: 'ok' } }
  }
  const w = world(on, { toolCall: slow })
  await $.tool.call({ tool: 'Bash', command: 'cat specs/work/x.md' })
  expect(resolved).toBe(true)
  expect(w.runs.length).toBe(0)
  await w.clock.advance(299)
  expect(w.runs.length).toBe(0)
  await w.clock.advance(1)
  expect(w.runs.length).toBe(1)
})

const SUFFIX = 'skills/kdd-conventions/scripts/kdd-status'

test('working copy: no env root, the script two levels above the plugin root', async ($, on) => {
  const probed: string[] = []
  const w = world(on, {
    root: null,
    exists: p => {
      probed.push(p)
      return p.endsWith(`/${SUFFIX}`) && !p.startsWith('/home/u')
    },
  })
  await $.tool.call({ tool: 'Bash', command: 'cat specs/a' })
  await w.clock.advance(300)
  // fs.exists sees the path normalised (the repo root); process.run gets `<plugin root>/../../<script>` as written.
  expect(probed[0]).toMatch(new RegExp(`/${SUFFIX}$`))
  expect(probed[0]).not.toContain('/mods/')
  expect(w.runs.length).toBe(1)
  expect(w.runs[0]?.[1]).toMatch(new RegExp(`/mods/kdd-work/\\.\\./\\.\\./${SUFFIX}$`))
  expect(w.lines.at(-1)).toBe('WRK-TASK-A-001-002 · 1/3')
})

test('cache: the newest installed version wins by number, not by text', async ($, on) => {
  const cache = '/home/u/.claude/plugins/cache/kdd-superpowers/kdd-superpowers'
  const w = world(on, {
    root: null,
    exists: p => p === cache || p === `${cache}/1.9.0/${SUFFIX}` || p === `${cache}/1.10.0/${SUFFIX}`,
    list: [
      { name: '1.9.0', kind: 'dir' },
      { name: '1.10.0', kind: 'dir' },
      { name: 'latest', kind: 'dir' },
      { name: '2.0.0', kind: 'file' },
    ],
  })
  await $.tool.call({ tool: 'Bash', command: 'cat specs/a' })
  await w.clock.advance(300)
  expect(w.runs).toEqual([['node', `${cache}/1.10.0/${SUFFIX}`, '--json']])
})

test('a skill.prompt for a kdd-superpowers skill is recorded; another plugin is not', async ($, on) => {
  const w = world(on)
  on('skill.prompt', () => ({ text: 'prompt' }))
  await $.tool.call({ tool: 'Bash', command: 'cat specs/a' })
  await w.clock.advance(300)
  await $.skill.prompt({ skill: 'kdd-superpowers:brainstorming', text: 'x' })
  expect(w.lines.at(-1)).toBe('WRK-TASK-A-001-002 · 1/3 · brainstorming')
  await $.skill.prompt({ skill: 'other:thing', text: 'x' })
  expect(w.lines.at(-1)).toBe('WRK-TASK-A-001-002 · 1/3 · brainstorming')
})
