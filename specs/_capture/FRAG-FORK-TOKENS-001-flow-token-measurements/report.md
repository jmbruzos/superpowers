# Token usage of the kdd-superpowers flow — two headless runs, 2026-09-19

Measurement report. Not code-derived: there are no `path:lines@sha` anchors;
every number below is read from a `claude -p --output-format json` result
(`usage`, `num_turns`, `total_cost_usd`, `duration_ms`, `modelUsage`) kept
verbatim under `raw/`, or from the session transcripts of those runs
(`~/.claude/projects/**/*.jsonl` inside the isolated `CLAUDE_CONFIG_DIR`).

## Method

- Claude Code 2.1.278, headless (`claude -p`), `--allowed-tools=all`,
  `--permission-mode bypassPermissions`, isolated `CLAUDE_CONFIG_DIR` with a
  copy of the user's credentials, `--plugin-dir` this repo and the `kdd`
  toolkit 1.3.1. Main session model Opus 5 (1M); subagent models chosen by
  the skills.
- Baseline (spike): a throwaway script running the prompts of
  `tests/claude-code/test-kdd-flow.sh` scenarios 2, 4, 5, plus a control
  (same task as scenario 2, no plugins). Plugin at commit `283aef0`.
- After: `KDD_FLOW_USAGE=<dir> bash tests/claude-code/test-kdd-flow.sh`
  at commit `101678f` (scenarios 5-6 rerun after an OAuth expiry).
  Scenario 2's JSON was lost to a harness bug (subshell counter); its
  numbers are transcribed from the summary printed at the time.
- Context per turn = `cache_read_input_tokens + cache_creation_input_tokens
  + input_tokens` of each assistant message in the transcript.

## Observed — per scenario

| Run | Scenario | Turns | Cache write | Cache read | Output | Cost | Duration |
|---|---|---|---|---|---|---|---|
| baseline | s0 control: implement + test + commit, no plugin | 8 | 27.1k | 157.3k | 5.1k | $0.48 | 62 s |
| baseline | s2 brainstorming bounded → active WRK-SPEC | 19 | 59.1k | 683.1k | 11.7k | $1.23 | 148 s |
| baseline | s4 writing-plans → plan + 2 tasks + gate A2 | 20 | 87.9k | 976.4k | 39.2k | $3.06 | 597 s |
| baseline | s5 SDD → 2 tasks, 5 subagents, final review, finishing | 26 | 93.7k | 1383.6k | 21.0k | $2.93 | 492 s |
| after | s2 brainstorming bounded | 13 | 43.1k | 382.3k | 7.1k | $0.80 | 93 s |
| after | s3 brainstorming without specs/ + FRAG capture | 24 | 57.8k | 1096.7k | 13.5k | $1.47 | 204 s |
| after | s4 writing-plans | 22 | 81.0k | 1149.1k | 41.7k | $3.24 | 665 s |
| after | s5 SDD (drew a final-review fix wave and a FRAG at consolidation) | 38 | 115.8k | 2569.8k | 30.9k | $4.03 | 647 s |
| after | s6 requesting-code-review, kdd-work mode | 8 | 37.0k | 217.2k | 8.8k | $1.16 | 182 s |

Subagent seats in baseline s5 (from `modelUsage` and transcripts): Haiku 4.5
implementers ×2 — 45 and 31 assistant messages for one-function tasks,
1.5M cached tokens, $0.14; Sonnet 5 task reviewers ×2 — $0.19; Opus 5
final reviewer ×1.

## Observed — where the context comes from (transcripts)

- First assistant turn: 16.7k tokens without plugins; 20.5k with both
  plugins. Fixed cost of the plugins per session ≈ 3.8k (session-start
  hook ~1.5k, skill listing ~1.2k, agent listing, environment).
- First `Skill` call in a session: the transcript shows a
  `prompt_snapshot` attachment of 52 KB and a `deferred_tools_delta` of
  9.7 KB following it; the turn's context grows by 11.5k (writing-plans,
  11.3 KB of prose) / 14k (brainstorming, 21.8 KB) / 19.4k (SDD, 36.1 KB).
  Consistent with ~8k of harness prompt rewrite plus skill prose at
  roughly 3 bytes per token.
- `kdd-conventions/references/artifact-templates.md` is 5.3 KB; the turn
  that read it in s4 also read `kdd-cli`, `package.json`, `.gitignore`
  and the `specs/` tree (+11k in total).
- s4 output tokens (39-42k main, 53-59k with the A2 adversary) are the
  WRK-PLAN, two WRK-TASKs with full code blocks, the adversary's attack
  table and three rewrites of the task files after adjudication.
- Baseline s5 controller: 14 Bash calls in 26 turns; status transitions
  were done by hand (`sed -i '0,/^status: active$/s//status: completed/'`)
  and grouped with other bookkeeping in the same call. After-run s5:
  every transition via `kdd-conventions/scripts/transition`; zero hand
  edits of a frontmatter in controller or subagent transcripts.

## Inferred

- Cache reads dominate token counts but not cost; output tokens and
  cache writes (each fresh subagent seat: 15-24k of system prompt) weigh
  more per token. A turn at 80k cached context is cheap; a rewrite of a
  WRK-TASK is not.
- One sample per side does not separate a skill change from the flow's own
  variance (whether a reviewer finds something, whether consolidation
  writes a FRAG). Claims about tokens need N runs per scenario.
- Splitting the template file would save ~0.8k tokens per load (~1.6k
  tokens of a 5.3 KB file, of which the caller needs about half).

## Absences

- No per-scenario repetition (`KDD_FLOW_REPS`) exists yet; searched
  `tests/claude-code/` for it: none.
- Scenario 2 after-run JSON: not present under `raw/` (overwritten before
  the counter fix in `101678f`).
