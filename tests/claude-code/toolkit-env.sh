# Source it: resolve the kdd toolkit for headless runs (DOC-FORK-UPSTREAM-001 §4).
# Exports KDD_SPEC_GRAPH (the CLI) and KDD_TOOLKIT_DIR (the plugin root the runs load
# with --plugin-dir). Either one set in the environment wins; otherwise the CLI comes
# from kdd-cli (KDD_SPEC_GRAPH, project installs, then the newest installed plugin)
# and the plugin root is the directory above its cli/. Returns 1 when neither works.
_kdd_env_repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [[ -z "${KDD_SPEC_GRAPH:-}" ]]; then
  KDD_SPEC_GRAPH="$("$_kdd_env_repo/skills/using-superpowers/scripts/kdd-cli" --path 2>/dev/null)" || KDD_SPEC_GRAPH=""
fi
if [[ -z "${KDD_TOOLKIT_DIR:-}" ]]; then
  case "$KDD_SPEC_GRAPH" in
    */cli/spec-graph.mjs) KDD_TOOLKIT_DIR="${KDD_SPEC_GRAPH%/cli/spec-graph.mjs}" ;;
    *) KDD_TOOLKIT_DIR="" ;;
  esac
fi
unset _kdd_env_repo
export KDD_SPEC_GRAPH KDD_TOOLKIT_DIR
if [[ ! -f "$KDD_SPEC_GRAPH" || ! -d "$KDD_TOOLKIT_DIR/skills" ]]; then
  echo "kdd toolkit not resolved (CLI: '${KDD_SPEC_GRAPH}', plugin root: '${KDD_TOOLKIT_DIR}'): install the kdd plugin, or set KDD_SPEC_GRAPH and KDD_TOOLKIT_DIR" >&2
  return 1 2>/dev/null || exit 1
fi
