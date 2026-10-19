# Real-task study (level 2)

The study behind FRAG-FORK-GATES-003, -004 and -005, kept here so each batch
of an upstream sync can repeat it (DOC-FORK-UPSTREAM-001 §4). It designs and
plans RFC-PIPE-039 on mdm-platform at `aacdae5`, headless, once per run, and
judges the committed spec + plan + tasks.

## Runs

```bash
export MDM_REPO=../mdm-platform            # a clean checkout that has aacdae5
source tests/claude-code/toolkit-env.sh    # pins KDD_SPEC_GRAPH / KDD_TOOLKIT_DIR
git worktree add /tmp/kdd-before kdd-superpowers--v0.6.1    # before arm
bash tests/claude-code/ab/run-one.sh B1 /tmp/kdd-before "$KDD_TOOLKIT_DIR"
bash tests/claude-code/ab/run-one.sh A1 "$PWD" "$KDD_TOOLKIT_DIR"           # after arm
```

Run arms in series and alternate them (B1 A1 B2 A2). Each run writes
`.kdd/ab/<label>/`: `result.json` (cost, turns), `run.txt` (exit, start
epoch, wall), `conditions.txt` (base, model, toolkit, Claude Code version,
plugin dirs), `transcripts/`, `commits.txt`, `artifacts/`. Pre-flight, once:
`node "$KDD_SPEC_GRAPH" --specs <mdm worktree>/specs validate`.

## Judging

`prompts/` holds the prompts the earlier fragments used, byte for byte
after their `# source:` line. They name the original bundle and summary
paths; replace those paths, and nothing else, when you reuse them.

1. **Bundle** each run: its committed WRK-SPEC, WRK-PLAN and WRK-TASKs
   concatenated, spec first, into one `.md`.
2. **Evidence judge** (`evidence-judge.txt`), one per run: claims about
   code (TRUE / FALSE / UNVERIFIABLE), knowledge violations, plan
   executability.
3. **Neutral summary** (`neutral-summary.txt`), one per run, matching the
   headings and depth of the earlier summaries.
4. **Blind pass** (`blind-pass.txt`), once over every new summary under
   shuffled codes; keep the key outside the judge's reach.

`k-task.txt` is the task prompt; `k-wait.txt` the sentence K3–K5 added
(`AB_WAIT=1`, the default).
