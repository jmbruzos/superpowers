# kdd-superpowers — Working in this repository

This is a Claude Code plugin: skills (Markdown), a session-start hook (bash),
and a handful of scripts (bash, Node ESM). It is derived from superpowers 6.3.0
and adapted to Knowledge-Driven Development (KDD). It depends on the `kdd`
toolkit plugin at runtime and never re-implements it.

## The design is a spec

`specs/work/WRK-SPEC-FORK-CORE-001-kdd-adaptation-core-flow.md` is the authority
for what this plugin does; its plan and tasks are next to it. Read the spec's
thirteen principles (P1–P13) before changing a skill. Two of them shape every
edit here:

- **P10** — keep superpowers' *how*: the voice ("your human partner"), the red-flag
  and rationalization tables, the approval gates, the subagent discipline. Add rows
  and sections; do not rewrite tuned prose.
- **P13** — no path contains `superpowers`. Runtime state lives under `.kdd/`.

## Layout

- `skills/<name>/SKILL.md` — one skill each; prompt templates and references beside it.
- `skills/kdd-conventions/` — shared conventions, templates and scripts (`next-id`, `frag-cite-check`, `brief-lib.mjs`).
- `skills/using-superpowers/scripts/kdd-cli` — the only place that knows where `spec-graph.mjs` is.
- `hooks/session-start` — injects `using-superpowers` + `<KDD-ENVIRONMENT>`.
- `tests/scripts/` — deterministic tests and the `specs/` fixture; `tests/hooks/`, `tests/claude-code/`, `tests/brainstorm-server/`.

## Testing

```bash
export KDD_SPEC_GRAPH=/path/to/spec-graph.mjs   # e.g. ../knowledge-driven-development/apps/spec-graph/spec-graph.mjs
bash tests/scripts/run.sh
bash tests/hooks/test-session-start.sh
bash tests/claude-code/test-sdd-workspace.sh
(cd tests/brainstorm-server && npm test)
bash tests/claude-code/test-kdd-flow.sh          # headless Claude; slow
KDD_FLOW_USAGE=/tmp/usage bash tests/claude-code/test-kdd-flow.sh   # same, plus a token-usage table
```

`tests/scripts/test-skill-content.sh` asserts the anchors prompts and scripts
depend on; when you change a skill, keep it green or update it in the same
commit. `tests/scripts/test-invariants.sh` enforces P13 and the namespace.

## Changing skills

Skills are behaviour-shaping prose. Use `kdd-superpowers:writing-skills` to
develop and pressure-test changes; state in the commit what behaviour the change
targets and what you observed. Keep English.

## Versioning

`scripts/bump-version.sh <version>` updates `package.json`, `.claude-plugin/plugin.json`
and `.claude-plugin/marketplace.json`. Record changes in `RELEASE-NOTES.md`.

## Language

English for everything in the repository (skills, specs, docs). Conversation
language is whatever your human partner uses.
