#!/usr/bin/env bash
# chain3.sh CAND — batch-3 level 1 (pre-registration a4eae76): scenario 8 × {inline-old@0.8.0, native, sdd} × 2; scenarios 4,5 × {0.8.0, cand} × 2
R=/Users/josemanuelbruzospereiro/projects/software/superpowers; M=$R/.kdd/upstream-sync/measure; CAND="$1"
export KDD_SPEC_GRAPH="$HOME/.claude/plugins/cache/kdd/kdd/1.13.0/cli/spec-graph.mjs" KDD_TOOLKIT_DIR="$HOME/.claude/plugins/cache/kdd/kdd/1.13.0" KDD_FLOW_MODEL=opus
B=$M/arm-0.8.0; C=$M/cand-b3
[ -d $B ] || git -C $R worktree add -q --detach $B kdd-superpowers--v0.8.0
[ -d $C ] || git -C $R worktree add -q --detach $C $CAND
for a in $B; do
  cp $C/tests/claude-code/{test-kdd-flow.sh,scenario8-checks.sh,toolkit-env.sh,usage-lib.sh,plan-metrics.mjs} $a/tests/claude-code/
  rm -rf $a/tests/scripts/fixtures $a/tests/claude-code/fixtures; cp -R $C/tests/scripts/fixtures $a/tests/scripts/; cp -R $C/tests/claude-code/fixtures $a/tests/claude-code/
done
O=$M/b3-l1; mkdir -p $O
run() { # label arm-dir scenarios [arm8]
  echo "=== $1 start $(date +%s)"; KDD_FLOW_SCENARIOS="$3" KDD_FLOW_ARM8="${4:-native}" KDD_FLOW_USAGE="$O/$1" bash $2/tests/claude-code/test-kdd-flow.sh > "$O/$1.log" 2>&1; echo "=== $1 exit $? end $(date +%s)"; }
for r in 1 2; do
  run s8-inline-old-r$r $B 8 inline-old
  run s8-native-r$r $C 8 native
  run s8-sdd-r$r $C 8 sdd
  run s45-before-r$r $B "4 5"
  run s45-cand-r$r $C "4 5"
done
echo ALL-DONE
