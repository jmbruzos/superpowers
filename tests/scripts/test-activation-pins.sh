#!/usr/bin/env bash
# activation_pins end to end (WRK-TASK-TOOLKIT-FEDERATION-003-009, RFC-KDD-006 Part E): a WRK-SPEC written from
# the kdd-conventions template with the block `kdd-cli pins` prints passes `validate` in a project with a
# kdd-repo.yaml; the same WRK-SPEC without the block is activation-unpinned.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
echo "=== Test: activation_pins ==="
require_cli
if ! node "$KDD_CLI" --help 2>/dev/null | grep -qE '^  pins '; then echo "SKIP: the kdd toolkit at $KDD_CLI has no pins command (CLI older than 0.13.0)"; exit 0; fi
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
git init -q -b main "$TMP"
mkdir -p "$TMP/specs/domain" "$TMP/specs/work"
printf 'descriptor_version: 1\nid: pins-test\nscope: project\nowner: t\nowns: [PINT]\n' > "$TMP/kdd-repo.yaml"
printf -- '---\nid: DOM-PINT-001\ntype: spec\nlayer: domain\nstatus: active\nconfidence: low\nversion: 1.0.0\ncreated: 2026-10-07\nupdated: 2026-10-07\nowner: t\n---\n\n# DOM-PINT-001 — Pinned rule\n' > "$TMP/specs/domain/DOM-PINT-001-pinned-rule.md"
( cd "$TMP" && git add -A && git -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -qm "fixture" )

pins="$(cd "$TMP" && "$KDD_CLI_SCRIPT" --specs specs pins DOM-PINT-001@1.0.0)"; rc=$?
[[ "$rc" -eq 0 && "$pins" == activation_pins:* && "$pins" == *"source: self@"* ]] && pass "kdd-cli pins prints an activation_pins block with a self pin" || { fail "kdd-cli pins prints an activation_pins block (rc=$rc)"; echo "    got: $pins"; }

# The full WRK-SPEC template's frontmatter, placeholders filled, its activation_pins block replaced by the CLI's output.
TEMPLATE="$REPO_ROOT/skills/kdd-conventions/references/artifact-templates.md"
write_wrk() { # $1 = activation_pins block (empty: drop the block)
  PINS="$1" node -e '
    const fs = require("fs");
    const md = fs.readFileSync(process.argv[1], "utf-8");
    const fm = md.split("## Full WRK-SPEC")[1].split("```yaml\n")[1].split("```")[0];
    let t = fm.replace(/^activation_pins:.*\n(?:  .*\n)*/m, process.env.PINS ? process.env.PINS.replace(/\n?$/, "\n") : "");
    t = t.replace(/^sources:\n(?:  .*\n)*/m, "");
    const fill = { "<WRK-SPEC-PATH-NNN>": "WRK-SPEC-PINT-PINS-001", "<date>": "2026-10-07", "<datetime +90d>": "2027-01-05T10:00:00+01:00",
      "<datetime>": "2026-10-07T10:00:00+02:00", "<team-or-person>": "t", "<full name>": "Pins end to end", "<KNOWLEDGE-ID>@<version>": "DOM-PINT-001@1.0.0",
      "<KNOWLEDGE-ID>": "DOM-PINT-001", "<model-id>": "test", "<area>, <concept>": "pint, pins" };
    for (const [k, v] of Object.entries(fill)) t = t.split(k).join(v);
    if (/<[^>]+>/.test(t)) { console.error("unfilled placeholder: " + t.match(/<[^>]+>/)[0]); process.exit(1); }
    fs.writeFileSync(process.argv[2], t + "\n# WRK-SPEC-PINT-PINS-001 — Pins end to end\n");
  ' "$TEMPLATE" "$TMP/specs/work/WRK-SPEC-PINT-PINS-001-pins.md"
}
grep -q '^activation_pins:' "$TEMPLATE" && pass "the WRK-SPEC template has an activation_pins block" || fail "the WRK-SPEC template has an activation_pins block"

write_wrk "$pins" || fail "template rendered"
out="$(cd "$TMP" && "$KDD_CLI_SCRIPT" --specs specs validate 2>&1)"
[[ "$out" != *activation-unpinned* && "$out" != *activation-pins-invalid* ]] && pass "validate accepts the WRK-SPEC written with the pins block" || { fail "validate accepts the WRK-SPEC written with the pins block"; echo "$out" | grep -E 'activation-' | sed 's/^/    /'; }

write_wrk "" || fail "template rendered without pins"
out="$(cd "$TMP" && "$KDD_CLI_SCRIPT" --specs specs validate 2>&1)"
[[ "$out" == *"[activation-unpinned]"*DOM-PINT-001* ]] && pass "without the block validate reports activation-unpinned (the check discriminates)" || { fail "without the block validate reports activation-unpinned"; echo "$out" | sed 's/^/    /' | head -10; }
finish
