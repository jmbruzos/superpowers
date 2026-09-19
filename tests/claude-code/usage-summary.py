#!/usr/bin/env python3
"""Summarize `claude -p --output-format json` results saved by usage-lib.sh.

Usage: usage-summary.py <dir>   — one row per <dir>/*.json, then the per-model
breakdown (modelUsage) and, when <dir>/<name>.transcripts/ holds a main
session transcript, analyze-token-usage.py's per-subagent breakdown.
"""
import glob
import json
import os
import subprocess
import sys


def k(n):
    return f"{n / 1000:.1f}k"


def main(d):
    rows = sorted(glob.glob(os.path.join(d, "*.json")))
    print(f"{'scenario':16} {'turns':>5} {'cache_w':>9} {'cache_r':>9} {'out':>8} {'cost$':>7} {'dur':>6}")
    for j in rows:
        name = os.path.basename(j)[:-5]
        try:
            r = json.load(open(j))
        except (OSError, ValueError) as e:
            print(f"{name:16} (unreadable: {e})")
            continue
        u = r.get("usage", {})
        print(f"{name:16} {r.get('num_turns', 0):5} {k(u.get('cache_creation_input_tokens', 0)):>9} "
              f"{k(u.get('cache_read_input_tokens', 0)):>9} {k(u.get('output_tokens', 0)):>8} "
              f"{r.get('total_cost_usd', 0):7.2f} {r.get('duration_ms', 0) / 1000:5.0f}s")
        for model, v in r.get("modelUsage", {}).items():
            print(f"    {model:30} cache_w={k(v.get('cacheCreationInputTokens', 0))} cache_r={k(v.get('cacheReadInputTokens', 0))} "
                  f"out={k(v.get('outputTokens', 0))} cost={v.get('costUSD', 0):.2f}")
        analyzer = os.path.join(os.path.dirname(os.path.abspath(__file__)), "analyze-token-usage.py")
        main_sessions = [t for t in glob.glob(os.path.join(d, f"{name}.transcripts", "*.jsonl"))
                         if not os.path.basename(t).startswith("agent-")]
        if main_sessions and os.path.exists(analyzer):
            out = subprocess.run([sys.executable, analyzer, main_sessions[0]], capture_output=True, text=True)
            for line in out.stdout.splitlines():
                print("    " + line)
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__.strip(), file=sys.stderr)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
