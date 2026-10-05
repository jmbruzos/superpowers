export type TaskState = { id: string; title: string; state: 'done' | 'in-progress' | 'pending' }

export type PlanState = {
  id: string
  status: string
  ledger: 'none' | 'used' | 'mismatch'
  done: number
  total: number
  current: string | null
  tasks: TaskState[]
  ledger_tail: string[]
}

export type OpenSpec = {
  id: string
  title: string
  status: 'draft' | 'active' | 'completed'
  phase: string
  plans: PlanState[]
}

export type Focus = { spec: string; plan: string | null; task: string | null; done: number; total: number }

export type KddStatus = {
  root: string
  open_work: OpenSpec[]
  focus: Focus | null
  phase: string
  pending_consolidation: string[]
  error?: string
  message?: string
}

declare module 'claude-code' {
  interface PluginState {
    'kdd-work': {
      status: KddStatus | null
      stale: string | null
      skill: string | null
      mainRoot: string | null
      bandDismissed: boolean
    }
  }
}
