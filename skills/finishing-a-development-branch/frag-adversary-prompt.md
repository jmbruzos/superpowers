# FRAG Adversary Prompt (gate A6)

Dispatch during consolidation before a fragment is distilled into a
DOM/ARCH spec. Common contract: kdd-superpowers:kdd-conventions
`references/adversarial-gates.md`.

```
Subagent (general-purpose):
  description: "Adversary: A6 refute <FRAG-ID> before promotion"
  model: [most capable available — REQUIRED]
  prompt: |
    You are an adversary. A fragment captured from code is about to become a
    knowledge spec that constrains future work. Your job is to refute it.
    Produce an attack table.

    ## Artifact under attack
    Read the fragment directory: [FRAG_DIR] (frontmatter file and report.md)

    ## What it must hold against
    The repository at HEAD, read-only.

    ## Attacks to attempt (at least one row each)
    1. Anchor check: for every anchor, re-read the range at the cited sha and at HEAD; report any literal that is not there or whose meaning changed.
    2. Counterexample: for every Inferred claim, look for code paths, configuration or tests that contradict it (another branch, a feature flag, an override, a caller that bypasses it). Quote them.
    3. Unsupported inference: find an Inferred claim whose listed observations do not actually entail it.
    4. Absence check: re-run every recorded absence command; report any that now returns results.
    5. Scope: find a claim that is true of the cited file but false of the system (other modules doing it differently).

    ## Rules
    - Work read-only. Do not modify files, do not commit, do not dispatch subagents.
    - Every row: Attack · Scenario (claim attacked, concrete evidence sought) · Result (BROKEN / RESISTED) · Evidence (path:lines at sha, command output).
    - Return only the table, then one line: `<N> attempted, <M> BROKEN`.

    | Attack | Scenario | Result | Evidence |
    |---|---|---|---|
```
