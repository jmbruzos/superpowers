# Exploration report — kdd-work mod: engine constraints and focus rule (kdd-superpowers, 988dfe7)

## Scope
What the kdd-work mod's code embodies about the Claude Code function-hook API (early access, build 2.1.289)
and the focus rule of kdd-status, as surfaced by the reviews of WRK-PLAN-FORK-MODS-001 (Execution Log,
*Capture candidates*). Needed to distil DOC-FORK-MODS-001. Only what that work touched.

## Observed
- `mods/kdd-work/hooks/register.tsx:9-9@988dfe7`: `// The engine's scan reads state references only when they are consts of this file, so the atoms`
- `mods/kdd-work/hooks/register.tsx:11-11@988dfe7`: `const status = atom({ plugin: 'kdd-work', key: 'status' } as const, null)`
- `mods/kdd-work/hooks/register.tsx:61-61@988dfe7`: `async function refresh($: EngineInterface): Promise<void> {`
- `mods/kdd-work/hooks/register.tsx:86-86@988dfe7`: `function schedule($: EngineInterface): void {`
- `mods/kdd-work/hooks/register.tsx:104-104@988dfe7`: `  on('turn.complete', async ($, e, next) => {`
- `mods/kdd-work/hooks/register.tsx:117-117@988dfe7`: `      if (e.agentId === undefined) await recordSkill($, e.skill)`
- `mods/kdd-work/hooks/register.test.ts:79-79@988dfe7`: `  // agentId is not in $.tool.call's declared input (AgentLoop is on the hook's`
- `mods/kdd-work/hooks/register.test.ts:39-39@988dfe7`: `  on('session.cwd', () => ({ value: '/proj' }))`
- `mods/kdd-work/hooks/ui.test.ts:4-4@988dfe7`: `// The test kit's `
- `mods/kdd-work/hooks/ui.test.ts:4-4@988dfe7`: `takes the whole CommandRunInput (d.ts :14343), not CommandRunArgs (:1699).`
- `mods/kdd-work/hooks/ui.test.ts:23-23@988dfe7`: `    return { value: { isPlaced: true } }`
- `skills/kdd-conventions/scripts/kdd-status-lib.mjs:10-10@988dfe7`: `const RANK = ['executing', 'finishing', 'planning', 'spec-review', 'consolidation-pending'];`
- `skills/kdd-conventions/scripts/kdd-status-lib.mjs:78-78@988dfe7`: `  const top = [...open_work].sort((a, b) => RANK.indexOf(a.phase) - RANK.indexOf(b.phase) || byId(a, b))[0];`

## Inferred
- State atoms of a mod are declared as consts in the module that reads/writes them; a shared atoms module is not read by the engine's scan (rests on: register.tsx:9, 11; task 002 report: `claude plugin validate` refused the imported atoms — that output is not in the repository).
- Functions that receive `$` are top-level declarations, not closures inside `register` (rests on: register.tsx:61, 86; task 002 report: validate refused closures receiving `$` — not in the repository).
- In `claude plugin test`, the test's `on` answers engine operations with `{ value }` (and `tool.call` with `{ result }`), and `$.command.run` takes the full CommandRunInput (rests on: register.test.ts:39, ui.test.ts:4, 23).
- `agentId` is present on a hook's `e` for subagent loops (main loop: absent) but not part of `$.tool.call`'s declared input (rests on: register.tsx:117, register.test.ts:79; claude-code.d.ts 2.1.289 :194-205, outside the repository).
- `turn.complete` also fires for each subagent loop, carrying its `agentId` (rests on: claude-code.d.ts 2.1.289 :362-363 "its answer is its own `turn.complete`, carrying this `agentId`", outside the repository); the mod's `turn.complete` hook does not filter on it (register.tsx:104).
- Focus among open WRK-SPECs is the best-ranked phase, ties broken by id (lexicographic) — so with two specs in `finishing` the lower id wins (rests on: kdd-status-lib.mjs:10, 78).

## Absences
- `grep -rn "agentId" mods/kdd-work/hooks/register.tsx` → only line 117; the `turn.complete` hook does not read it.
