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
