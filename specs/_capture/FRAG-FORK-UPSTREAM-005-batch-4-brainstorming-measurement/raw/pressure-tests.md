# Pressure tests — after (recorded in the task commits) and the baselines run on the final review's Important 1

## brainstorming (task 001; after: commit ad8835a)

Pressure test (writing-skills, controller; one fresh Sonnet subagent reading this commit's brainstorming/SKILL.md; spec AC5; request "a small tool that reminds my team when a pull request has waited more than two days for review", no platform named):
(a) target: how it gets made — a request with no platform named gets the question, or the default stated as "my call". Observed: in the design section the choices the partner never made are stated as the agent's own: "This part is my call, because you haven't said anything about language, hosting or schedule … You can overrule any of this". PASS.
(b) target: open questions first. Observed: the first clarifying question is open ("Think of the last pull request that sat waiting too long. What happened, and what would you have wanted the tool to do at that moment?"), no menu. PASS.
(c) target: guesses marked. Observed: both guesses about what the partner meant are marked ("My guess is that 'where we already talk' means Slack … please correct me"; "I'm assuming two calendar days … That's also my guess"); what the partner said is listed separately as theirs; the unmarked sentences are design proposals, not readings of the partner. PASS.

Baseline (binding per gate A2; run after the fact on the final review's Important 1 — fresh Sonnet subagent reading 3502935's brainstorming/SKILL.md, same request and situations):
(a) how it gets made: the before text already states unmade choices as the agent's own ("How it runs is my call, and you can override it") — no change observable.
(b) open questions first: the before text's first clarifying question is a menu ("where do your pull requests live? a) GitHub b) GitLab c) Bitbucket d) Something else"); with this commit it is open ("Think of the last pull request that sat waiting too long …"). RED → GREEN.
(c) guesses marked: the before text already marks its guesses ("That is my interpretation", "That is my assumption, not something you told me") — no change observable.

## using-superpowers (task 002; after: commit e500a47)

Pressure test (writing-skills, controller; one fresh Sonnet subagent reading this commit's using-superpowers/SKILL.md as its session bootstrap; spec AC5):
(a) target: a knowledge question outside a workflow → kdd:spec-ask, never brainstorming. Observed: "What do our specs say about rounding pro-rata amounts?" → "Using kdd:spec-ask …", no brainstorming, no own grep. PASS.
(a′) target: inside a workflow discovery stays with the skill's step. Observed: mid-brainstorming, "which rules apply to rounding" → the skill's kdd:spec-context step, not spec-ask, citing the one-activation-path rule. PASS.
(b) target: browsing → kdd:spec-tui; the human runs the viewer. Observed: "Using kdd:spec-tui …", the prepared `spec-graph tui` command handed to the partner, "I never run the viewer myself". PASS.
(c) target: the `unavailable` row. Observed: every line `unavailable` → runs the absolute `…/kdd-cli --path` the toolkit line names before brainstorming acts; a path → found, anything else → NOT FOUND (install message, stop); checks `specs/` itself; open_work and okf_bundles stated once as unknown. PASS (it announces brainstorming first and probes before the skill does anything — the probe still precedes all workflow work).

Baseline (binding per gate A2; run after the fact on the final review's Important 1 — fresh Sonnet subagent reading 6c51ac2's using-superpowers/SKILL.md, same four situations):
(a) knowledge question outside a workflow: kdd:spec-ask chosen without the row ("the bootstrap never names spec-ask; I'm choosing it because it fits") — no change observable; the row credits nothing here (spec Testing anticipated it).
(a′) inside brainstorming: the skill's own discovery step, no direct spec-ask — no change observable.
(b) browsing: kdd:spec-tui, the partner runs the viewer — no change observable.
(c) all lines `unavailable`: the before text has no row; the session improvises — announces brainstorming, plans to call the plugin-relative `using-superpowers/scripts/kdd-cli` (a path that does not exist in a user's project), and does not check `specs/` ("I don't guess at specs_dir"). With this commit: it runs the absolute path the hook prints, reports the toolkit found when that prints a path (re-run 2026-10-19: "Toolkit status: FOUND"), checks `specs/` itself and states open_work/okf_bundles as unknown once. RED → GREEN.
