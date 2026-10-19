#!/usr/bin/env bash
# chain4.sh CAND — batch-4 measurement (pre-registration dfa6bb6, H-8): L1 scenarios 1 2 3 7 9 × {0.9.0, cand} × 1; L2 RFC-PIPE-039 B1 A1 B2 A2
R=/Users/josemanuelbruzospereiro/projects/software/superpowers; M=$R/.kdd/upstream-sync/measure; CAND="$1"
export KDD_SPEC_GRAPH="$HOME/.claude/plugins/cache/kdd/kdd/1.13.0/cli/spec-graph.mjs" KDD_TOOLKIT_DIR="$HOME/.claude/plugins/cache/kdd/kdd/1.13.0" KDD_FLOW_MODEL=opus
B=$M/arm-0.9.0; C=$M/cand-b4
[ -d $B ] || git -C $R worktree add -q --detach $B kdd-superpowers--v0.9.0
[ -d $C ] || git -C $R worktree add -q --detach $C $CAND
cp $C/tests/claude-code/{test-kdd-flow.sh,scenario8-checks.sh,toolkit-env.sh,usage-lib.sh,plan-metrics.mjs} $B/tests/claude-code/
rm -rf $B/tests/scripts/fixtures $B/tests/claude-code/fixtures; cp -R $C/tests/scripts/fixtures $B/tests/scripts/; cp -R $C/tests/claude-code/fixtures $B/tests/claude-code/
O=$M/b4-l1; mkdir -p $O
run() { echo "=== $1 start $(date +%s)"; KDD_FLOW_SCENARIOS="1 2 3 7 9" KDD_FLOW_USAGE="$O/$1" bash $2/tests/claude-code/test-kdd-flow.sh > "$O/$1.log" 2>&1; echo "=== $1 exit $? end $(date +%s)"; }
run before-r1 $B
run cand-r1 $C
export MDM_REPO=/Users/josemanuelbruzospereiro/projects/software/mdm-platform AB_OUT="$M/b4-l2" MODEL=opus
mkdir -p $AB_OUT; node "$KDD_SPEC_GRAPH" --specs "$MDM_REPO/specs" validate > "$AB_OUT/mdm-preflight.txt" 2>&1 || true
for r in 1 2; do
  echo "=== b4-l2 B$r start $(date +%s)"; bash "$C/tests/claude-code/ab/run-one.sh" B$r "$B" "$KDD_TOOLKIT_DIR"; echo "=== b4-l2 B$r exit $? end $(date +%s)"
  echo "=== b4-l2 A$r start $(date +%s)"; bash "$C/tests/claude-code/ab/run-one.sh" A$r "$C" "$KDD_TOOLKIT_DIR"; echo "=== b4-l2 A$r exit $? end $(date +%s)"
done
echo ALL-DONE
