import { atom } from 'claude-code'

export const status = atom({ plugin: 'kdd-work', key: 'status' } as const, null)
export const stale = atom({ plugin: 'kdd-work', key: 'stale' } as const, null)
export const skill = atom({ plugin: 'kdd-work', key: 'skill' } as const, null)
export const mainRoot = atom({ plugin: 'kdd-work', key: 'mainRoot' } as const, null)
export const bandDismissed = atom({ plugin: 'kdd-work', key: 'bandDismissed' } as const, false)
