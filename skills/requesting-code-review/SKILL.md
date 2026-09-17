---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main, or the task's recorded BASE
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Build the knowledge brief — pick the mode that matches what exists:**

| Mode | When | The third layer of authority |
|---|---|---|
| **1. KDD work** | a WRK-SPEC (and usually a WRK-PLAN) exists for this change | `scripts/review-brief <WRK-SPEC-or-WRK-PLAN file>` (this skill's directory) writes one file: acceptance criteria, constraints, the plan's Architecture Impact, every activated spec in full with pin check, the cited FRAGs. Pass the printed path. |
| **2. Knowledge base, no WRK-SPEC** | an external PR, a hotfix, legacy code under review in a project with `specs/` | invoke `kdd:spec-context "<one-line description of the change>"`, confirm with your human partner which surfaced specs apply, and write their paths plus the requirements into a scratch brief file under `.kdd/review/`. Remind them once that a change of their own should have a compact WRK-SPEC (kdd-superpowers:brainstorming, bounded path). |
| **3. Pure brownfield** | no `specs/` at all | the brief is the requirements you were given, in a scratch file. Capture is mandatory: the reviewer must list the rules the code embodies and the change touches. |

The reviewer receives a path, never pasted spec text.

**3. Dispatch code reviewer subagent:**

Dispatch a `general-purpose` subagent, filling the template at [code-reviewer.md](code-reviewer.md)

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{KNOWLEDGE_BRIEF}` - path of the brief from step 2 (mode 1: the review-brief file; modes 2–3: the scratch brief)
- `{MODE}` - `kdd-work`, `knowledge-no-spec` or `brownfield`
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{BEFORE_MERGE}` - `yes` when this review gates a merge or PR (enables gate A5), else `no`

**4. Act on feedback:**
- Fix Critical issues immediately — a violated activated rule is always Critical
- Fix Important issues before proceeding
- Note Minor issues for later
- **Capture candidates:** offer your human partner to write them as FRAGs with kdd-superpowers:kdd-conventions `references/capturing-from-code.md` (cite-check included); inside SDD, ledger them as `Capture candidate:` lines instead
- **Knowledge findings:** ledger as `Knowledge gap:` (SDD) or note them for consolidation
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  KNOWLEDGE_BRIEF: .kdd/sdd/WRK-PLAN-DEPLOY-VERIFY-001/review-brief.md
  MODE: kdd-work
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'll just review the diff myself instead of dispatching a reviewer" | You're the coordinator — reviewing the diff inline burns the context window you need to keep driving the work. Dispatch a reviewer subagent: the diff and the evaluation live in its context, and only the findings come back to you. |
| "The reviewer needs my whole session history to understand the change" | Hand it precisely crafted context, never your session's history. That keeps the reviewer on the work product, not your thought process. |
| "There's no spec for this repo, so the reviewer can only check style" | The code embodies rules. Mode 3 makes the reviewer surface them as anchored capture candidates — that review *creates* the first knowledge. |
| "The DOM says X but the reviewer says Y is better" | The activated rule wins in this review. If the rule is wrong, that is a Knowledge gap for consolidation, not a silent override. |

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: [code-reviewer.md](code-reviewer.md)
