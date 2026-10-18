#!/usr/bin/env bash
# Runs executing-plans' Native script tests (task-start, task-done), which live
# with the other claude-code tests, so run.sh guards them too.
set -uo pipefail
exec bash "$(dirname "$0")/../claude-code/test-executing-plans-scripts.sh" "$@"
