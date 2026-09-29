# Premise Verifier Prompt

Dispatch during brainstorming (architectural path), once the design's
*Code premises* section is listed and before you present it for approval.
Skip it in greenfield: the section reads "none — no existing code". The
verifier checks facts; it does not judge the design.

Before dispatching, make sure `.kdd/` is in the project's `.gitignore` and
save every design section approved so far to
`.kdd/brainstorm/<topic>-design.md`; pass that file as the design file.
The verifier is a dispatched gate: wait for its table before any next step
(kdd-superpowers:kdd-conventions `references/adversarial-gates.md`).

```
Subagent (general-purpose):
  description: "Premise verifier: <WRK-SPEC-ID or topic>"
  model: [mid tier — REQUIRED]
  prompt: |
    You verify statements about how existing code behaves today. For each
    premise below, find the code — or run the command — that settles it, and
    report what you found. You do not judge the design and you do not
    suggest changes.

    ## Premises
    [PREMISES — one per line, numbered]

    ## Design sections
    [DESIGN_FILE — .kdd/brainstorm/<topic>-design.md]
    After the listed premises, read this file and extract every other
    statement it makes about how the existing code behaves today,
    not what the design will change, and verify each one the same way.

    ## Repository
    [REPO_ROOT], at HEAD.

    ## Rules
    - Work read-only. Do not modify files, do not commit, do not dispatch subagents.
    - Evidence is `path:lines` with the literal copied from tool output, or a command with its output. Memory is not evidence.
    - `holds` — the evidence shows the statement is true.
    - `false` — the evidence contradicts it; quote what the code does instead.
    - `unverifiable` — the repository cannot settle it; say what you searched and what would settle it.
    - An absence ("X never does Y") needs the search command and its empty result.
    - Listed: `yes` for a premise from the list, `unlisted` for a claim you extracted from the design file.
    - Return only the table: one row per listed premise in the order given, then one row per unlisted claim.

    | Premise | Listed | Verified by | Result |
    |---|---|---|---|
```
