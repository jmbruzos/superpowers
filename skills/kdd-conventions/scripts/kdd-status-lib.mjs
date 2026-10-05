// kdd-status-lib — pure computation behind kdd-status (WRK-SPEC-FORK-MODS-001). No I/O.
//
// Ledger line forms (FRAG-FORK-LEDGER-001): line 1 `# SDD ledger — plan: <WRK-PLAN-ID> (<path>)`;
// a task is done on a line starting `Task <WRK-TASK-ID>: complete` or `Task <n>: complete`
// (n = position, the id's TTT suffix); rulings and gaps are lines containing `Ruling:` /
// `Knowledge gap:`. A leading list bullet (`- ` / `* `) is ignored.

const DONE = new Set(['completed', 'archived']);
const OPEN = new Set(['draft', 'active', 'completed']);
const RANK = ['executing', 'finishing', 'planning', 'spec-review', 'consolidation-pending'];
const TAIL = 5;
const byId = (a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0);

export function emptyStatus(root) {
  return { root, open_work: [], focus: null, phase: 'idle', pending_consolidation: [] };
}

export function readLedger(planId, text) {
  if (text === null || text === undefined) return { state: 'none', lines: [] };
  const lines = text.split(/\r?\n/).map(l => l.replace(/^\s*[-*]\s+/, ''));
  if (!lines[0].startsWith(`# SDD ledger — plan: ${planId} `)) return { state: 'mismatch', lines: [] };
  return { state: 'used', lines };
}

export function taskPosition(taskId) {
  const m = /-(\d{3})$/.exec(taskId);
  return m ? String(Number(m[1])) : null;
}

function completedInLedger(lines, taskId) {
  const pos = taskPosition(taskId);
  return lines.some(l => l.startsWith(`Task ${taskId}: complete`)
    || (pos !== null && l.startsWith(`Task ${pos}: complete`)));
}

export function planState(plan, tasks, ledgerText) {
  const ledger = readLedger(plan.id, ledgerText);
  const rows = tasks.map(t => ({
    id: t.id,
    title: t.title,
    done: DONE.has(t.status) || (ledger.state === 'used' && completedInLedger(ledger.lines, t.id)),
  }));
  const tracking = ledger.state === 'used' && plan.status === 'active';
  const current = tracking ? (rows.find(r => !r.done)?.id ?? null) : null;
  return {
    id: plan.id,
    status: plan.status,
    ledger: ledger.state,
    done: rows.filter(r => r.done).length,
    total: rows.length,
    current,
    tasks: rows.map(r => ({ id: r.id, title: r.title, state: r.done ? 'done' : r.id === current ? 'in-progress' : 'pending' })),
    ledger_tail: ledger.lines.filter(l => l.includes('Ruling:') || l.includes('Knowledge gap:')).slice(-TAIL),
  };
}

// First rule that applies (WRK-SPEC-FORK-MODS-001, Components → Phase).
export function phaseOf(spec, plans) {
  if (spec.status === 'completed') return 'consolidation-pending';
  if (spec.status === 'draft') return 'spec-review';
  if (plans.some(p => p.status === 'active' && p.done < p.total)) return 'executing';
  if (plans.some(p => p.status === 'draft')) return 'planning';
  if (plans.length > 0 && plans.every(p => DONE.has(p.status) || (p.total > 0 && p.done === p.total))) return 'finishing';
  return 'planning';
}

// nodes: [{ id, layer, status, title, parent }]; ledgerOf(planId) → ledger text or null.
export function computeStatus(root, nodes, ledgerOf) {
  const kids = (layer, parent) => nodes.filter(n => n.layer === layer && n.parent === parent).sort(byId);
  const open_work = nodes
    .filter(n => n.layer === 'work-spec' && OPEN.has(n.status))
    .sort(byId)
    .map(spec => {
      const plans = kids('work-plan', spec.id).map(p => planState(p, kids('work-task', p.id), ledgerOf(p.id)));
      return { id: spec.id, title: spec.title, status: spec.status, phase: phaseOf(spec, plans), plans };
    });
  if (open_work.length === 0) return emptyStatus(root);
  const top = [...open_work].sort((a, b) => RANK.indexOf(a.phase) - RANK.indexOf(b.phase) || byId(a, b))[0];
  const plan = top.plans.find(p => p.current) ?? top.plans.find(p => p.status === 'active') ?? null;
  return {
    root,
    open_work,
    focus: { spec: top.id, plan: plan?.id ?? null, task: plan?.current ?? null, done: plan?.done ?? 0, total: plan?.total ?? 0 },
    phase: top.phase,
    pending_consolidation: open_work.filter(s => s.status === 'completed').map(s => s.id),
  };
}
