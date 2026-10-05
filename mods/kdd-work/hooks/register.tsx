import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, Timer } from 'claude-code'

import type { KddStatus } from '../types'
import { bandFor, paneLines, SKILL_PREFIX, statusLine, touchesWork } from './format'

const PANE = 'kdd-work'

// The engine's scan reads state references only when they are consts of this file, so the atoms
// are declared here, all five of the PluginState['kdd-work'] contract (types/index.d.ts).
const status = atom({ plugin: 'kdd-work', key: 'status' } as const, null)
const stale = atom({ plugin: 'kdd-work', key: 'stale' } as const, null)
const skill = atom({ plugin: 'kdd-work', key: 'skill' } as const, null)
const mainRoot = atom({ plugin: 'kdd-work', key: 'mainRoot' } as const, null)
// Set by `/kdd-work dismiss`, read by the band.
const bandDismissed = atom({ plugin: 'kdd-work', key: 'bandDismissed' } as const, false)

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

let pending: Timer | null = null

async function refresh($: EngineInterface): Promise<void> {
  const root = await locateMainRoot($)
  await update($, mainRoot, () => root)
  if (root === null) {
    await update($, status, () => null)
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

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'kdd-work',
      description: 'Show open KDD work in a pane; "/kdd-work dismiss" hides the consolidation band for this session',
    })
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
}
