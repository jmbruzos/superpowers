# Testing kdd-superpowers

```bash
export KDD_SPEC_GRAPH=/path/to/spec-graph.mjs   # e.g. ../knowledge-driven-development/apps/spec-graph/spec-graph.mjs
bash tests/scripts/run.sh
bash tests/hooks/test-session-start.sh
bash tests/claude-code/test-sdd-workspace.sh
(cd tests/brainstorm-server && npm test)
bash tests/claude-code/test-kdd-flow.sh          # headless Claude; slow
```

`tests/scripts/test-skill-content.sh` asserts the anchors prompts and scripts
depend on; when you change a skill, keep it green or update it in the same
commit. `tests/scripts/test-invariants.sh` enforces P13 and the namespace.

There is no eval harness in this repository; behavioural checks are the headless scenarios in `tests/claude-code/test-kdd-flow.sh`.
