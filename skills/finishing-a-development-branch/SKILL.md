---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work
---

# Finishing a Development Branch

## Overview

**Core principle:** Verify tests → Verify knowledge integrity → Detect environment → Persist the chronicle → Consolidate → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## Step 1: Verify Tests

Run the project's full test suite (`npm test` / `cargo test` / `pytest` / `go test ./...`).

**If tests fail**, report the failures and stop — the menu comes after a green suite:

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]
```

**If tests pass:** continue to Step 2.

## Step 1b: Verify Knowledge Integrity

Same standing as the tests — a red result means no menu.

**Which plan.** The WRK-PLAN being finished is the one this session
executed (named in the conversation or the ledger's first line). If it is
not already known, ask — as with the base branch. **Bounded work** (a
compact WRK-SPEC with no WRK-PLAN): skip the task/plan checks, run
validate and export-okf only, and in Step 3b write the `## Execution Log`
into the WRK-SPEC itself (rulings and capture candidates from the
session; omit the section if there are none).

```bash
<kdd-cli> --specs specs validate                       # 0 errors; no warning naming this work's artifacts
<kdd-cli> --specs specs filter --layer work-task --format json   # every task of this plan: status completed
<kdd-cli> --specs specs export-okf --out "$(mktemp -d)/okf"      # exit 0; the bundle is evidence, discard it
```

Check by reading the output: every WRK-TASK whose `parent` is this plan is
`completed`; the WRK-PLAN is `completed`; the WRK-SPEC is `active`.
Anything else is unfinished work — report it and stop:

```
Knowledge integrity failing. Must fix before completing:

- WRK-TASK-…-003 is still `active` (no completion commit)
- validate: 1 error — <message>
```

Find the CLI with `skills/using-superpowers/scripts/kdd-cli --path`.

## Step 2: Detect Environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# Capture now, while still inside the workspace — Step 5 changes directory
# before cleanup (Step 6) needs this value
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

This determines which menu to show and how cleanup works:

| State | Menu | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 3 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 3 options | Provenance-based (see Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 2 options (no merge) | Externally managed — leave in place |

## Step 3: Determine Base Branch

The base branch is whatever this work forked from — usually named in the
plan, the conversation, or the branch's upstream. If it is not already
known, ask: "This branch split from <your best guess> - is that correct?"
Confirm before merging: merging into the wrong base is expensive to undo.

## Step 3b: Persist the Chronicle

The ledger (`.kdd/sdd/<WRK-PLAN-ID>/progress.md`) is git-ignored and will
be deleted; its durable part moves into the plan. Append to the WRK-PLAN
(or the WRK-SPEC for bounded work) a section:

```markdown
## Execution Log

### Rulings
- <every `Ruling:` line, verbatim>

### Knowledge gaps
- <every `Knowledge gap:` line>

### Attacks broken and adjudicated
- <every `Attack: … — Ruling: …` line whose result was BROKEN, plus every
  BROKEN row harvested from the `## Adversarial Review` sections of the
  WRK-SPEC and the WRK-PLAN>

### Capture candidates (pending)
- <every `Capture candidate:` line and every anchored candidate from review reports>

### Parked / deferred
- <parked findings and deferred minors>
```

Then `updated: <today>`, validate, commit (`chore(<WRK-PLAN-ID>): execution log`).
`kdd:spec-consolidate` reads plan and task bodies for decision language —
this is where it finds what the run learned. With no ledger (a plan
executed without one), write the section from the commit history and say
so.

## Step 3c: Consolidate

No work closes without returning knowledge. **REQUIRED SUB-SKILL:**
`kdd:spec-consolidate <WRK-SPEC-ID>`. It reads the work tree, the
activated specs and the Execution Log, and proposes ADRs, spec deltas with
version bumps, new specs at `confidence: low`, confidence upgrades and
fragment distillation; your human partner decides what to apply.

Around it, this skill adds three things:

1. **Pending capture candidates become FRAGs first.** For each candidate
   in the Execution Log, write the fragment per
   kdd-superpowers:kdd-conventions `references/capturing-from-code.md`
   (anchors, Observed/Inferred, `frag-cite-check --strict`, `confidence: low`) so
   consolidation can cite and distill it. A candidate whose anchor no
   longer verifies is dropped with a note.
2. **Gate A6 before any promotion.** When consolidation proposes turning
   a FRAG into a DOM/ARCH (or updating one from it), dispatch
   [frag-adversary-prompt.md](frag-adversary-prompt.md) first. Only claims
   that RESISTED are distilled; BROKEN rows are ledgered in the Execution
   Log with their ruling and the FRAG stays `ingested`.
3. **Knowledge travels with the code.** Everything your human partner
   accepts (ADRs, spec bumps, `distilled` fragments, new specs) is
   committed on this branch, before the integration menu, so the merge or
   PR carries the knowledge change next to the code change
   (`chore(<WRK-SPEC-ID>): consolidate`).

If your human partner defers consolidation, say once: "After the merge
this branch's context is gone and the knowledge does not come back." Then
respect the decision: the WRK-SPEC is closed as `completed` without
archiving, and the session bootstrap will list it as *pending consolidation*
until `kdd:spec-consolidate` runs.

## Step 3d: Close the Work Artifacts

- WRK-SPEC: `status: active → completed`, `updated: <today>`; if your human
  partner confirmed the close explicitly, append `verified: - by: human:<id>`
  with `at:`.
- After consolidation was applied: WRK-SPEC, WRK-PLAN (or the WRK-SPEC for
  bounded work — already covered by the row above) and every WRK-TASK →
  `status: archived`.
- Validate; commit (`chore(<WRK-SPEC-ID>): close and consolidate`).
  `kdd-conventions/scripts/transition [--verified human:<id>] --no-commit <file> completed|archived`
  moves each artifact above; validate and commit once.

Then delete this plan's workspace (`rm -rf .kdd/sdd/<WRK-PLAN-ID>/`) — its
durable content is now in the Execution Log. Bounded work has no
WRK-PLAN and no SDD workspace: nothing to delete here.

Only now present the menu.

## Step 4: Present Options

**Normal repo and named-branch worktree — present exactly these 3 options:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)

Which option?
```

**Detached HEAD — present exactly these 2 options:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)

Which option?
```

Present the menu exactly as written — concise, with every option coming
from the list above. Discarding the work happens only in response to your
human partner explicitly asking for it (see "If your human partner asks to
discard the work" below). Wait for their answer; the integration decision
is theirs.

## Step 5: Execute Choice

### Option 1: Merge Locally

```bash
# Get main repo root for CWD safety
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>
```

If tests fail on the merged result: stop, leave the worktree and branch in
place, and investigate — nothing has been pushed, so the merge is local
and recoverable.

Once the merged result is green: clean up the worktree (Step 6), then
delete the branch:

```bash
git branch -d <feature-branch>
```

### Option 2: Push and Create PR

```bash
git push -u origin <feature-branch>
# From a detached HEAD, name the new branch on the remote:
# git push origin HEAD:refs/heads/<new-branch>
```

Then create the pull/merge request against <base-branch> with the forge's
tooling — its CLI if one is available, or the creation URL most forges
print when you push — following the repo's PR template and conventions if
present, and report the URL to your human partner.

Keep the worktree — your human partner iterates on PR feedback there.

### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

### If your human partner asks to discard the work

This path exists only as a response to an explicit request to throw the
work away. Confirm first:

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for that exact confirmation. When it arrives:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

Then clean up the worktree (Step 6) and force-delete the branch:

```bash
git branch -D <feature-branch>
```

## Step 6: Cleanup Workspace

**Runs for Option 1 and confirmed discards.** Options 2 and 3 always
preserve the worktree. Both callers have already changed directory to the
main repo root — worktree removal must run from outside the worktree —
and use the `GIT_DIR`/`GIT_COMMON`/`WORKTREE_PATH` values captured in
Step 2, from before that directory change.

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no worktree to clean up. Done.

**If `WORKTREE_PATH` is under `.worktrees/` or `worktrees/`:** Superpowers
created this worktree — we own cleanup:

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**If removal is refused** (`contains modified or untracked files`): the
worktree holds files that exist nowhere else — uncommitted plans, notes,
or scratch work. Never `--force` on your own initiative. Show your human
partner what is at stake and ask:

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
Worktree removal refused — these files were never committed:

<file list>

1. Commit them to <branch> before cleanup
2. Move them into <main repo root>
3. Delete them (unrecoverable)

Which?
```

Carry out the choice, then remove the worktree.

**Otherwise:** The host environment owns this workspace — leave it in
place. If your platform provides a workspace-exit tool, use it.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | yes | - | - | yes |
| 2. Create PR | - | yes | yes | - |
| 3. Keep as-is | - | - | yes | - |
| Discard (explicit request only) | - | - | - | yes (force) |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tests passed earlier this session" | Run the suite on the tree you are about to integrate. A green run only proves the tree it ran on. |
| "They obviously want it merged" | Integration is your human partner's decision. Present the menu and wait. |
| "They seem done with this feature — I'll offer to discard it" | The menu is complete as written. Discard happens only when your human partner asks for it in so many words. |
| "'Yeah, get rid of it' counts as confirmation" | Only the typed word `discard` authorizes deletion. |
| "The PR is up, so the worktree is clutter now" | PR feedback gets fixed in that worktree. It stays until the work lands. |
| "This other worktree looks stale — I'll clean it too" | Clean up only worktrees under `.worktrees/` or `worktrees/`. Everything else belongs to the host. |
| "Removal refused — `--force` is just finishing the cleanup" | The refusal means files exist only in that worktree. `--force` destroys them permanently. Show your human partner and ask. |
| "The merged-result failure is probably flaky" | A failing merged result stops everything. Branch and worktree stay put while you investigate. |
| "The base branch is obviously main" | Confirm the fork point or ask. Merging into the wrong base is expensive to undo. |
| "The push was rejected — force-push will fix it" | A rejected push means the remote moved. Investigate; force-push only on your human partner's explicit request. |
| "Consolidation can wait until after the merge" | After the merge the branch context is gone and the knowledge never comes back. Now or never. |
| "Nothing was learned in this plan" | The Execution Log says otherwise: every ruling is a candidate. Read it before claiming that. |
| "The FRAG is obviously right, skip the adversary" | That DOM will constrain future work. It earns its adversary. |
| "Validate fails on a warning about someone else's spec" | Read it. If it names this work's artifacts, fix it; if not, say so out loud and rule. A graph that does not validate does not export or activate cleanly. |
