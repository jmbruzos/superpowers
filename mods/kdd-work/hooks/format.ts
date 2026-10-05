import type { KddStatus } from '../types'

export const SKILL_PREFIX = 'kdd-superpowers:'

function skillLabel(skill: string | null): string | null {
  return skill !== null && skill.startsWith(SKILL_PREFIX) ? skill.slice(SKILL_PREFIX.length) : null
}

// `<task> · <done>/<total>` or `<spec> · <phase>`, then ` · <skill>` (WRK-SPEC-FORK-MODS-001, Components).
export function statusLine(status: KddStatus | null, skill: string | null): string | undefined {
  if (status !== null && status.error !== undefined) return undefined
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

export function touchesWork(text: string | undefined): boolean {
  return text !== undefined && (text.includes('specs/') || text.includes('.kdd/'))
}
