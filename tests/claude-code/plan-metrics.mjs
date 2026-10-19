#!/usr/bin/env node
// plan-metrics.mjs <WRK-PLAN file> — one JSON line: implementation-code share, proportion
// against the WRK-SPEC, Review Focus form. Deterministic; no dependencies.
import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';

function split(text) {
  const lines = text.split('\n');
  if (lines[lines.length - 1] === '') lines.pop();
  if (lines[0] !== '---') return { fm: {}, body: lines, has: false };
  const end = lines.indexOf('---', 1);
  if (end < 0) return { fm: {}, body: lines, has: false };
  const fm = {};
  for (const l of lines.slice(1, end)) {
    const m = /^([A-Za-z_][\w-]*):\s*(.*)$/.exec(l);
    if (m) fm[m[1]] = m[2].trim().replace(/^["']|["']$/g, '');
  }
  return { fm, body: lines.slice(end + 1), has: true };
}

const stepRe = /^\s*- \[[ xX]\] \*\*Step\b(.*)$/;
const fenceRe = /^\s*(```|~~~)/;

function implCodeLines(body) {
  let impl = false, inFence = false, n = 0;
  for (const l of body) {
    const s = stepRe.exec(l);
    if (s && !inFence) {
      const title = s[1].split('**')[0].toLowerCase();
      impl = title.includes('implement') && !title.includes('test');
      continue;
    }
    if (fenceRe.test(l)) { inFence = !inFence; if (impl) n++; continue; }
    if (impl && inFence) n++;
  }
  return n;
}

function reviewFocus(body) {
  const i = body.findIndex((l) => /^## Review Focus\s*$/.test(l));
  if (i < 0) return 'absent';
  const sec = [];
  for (const l of body.slice(i + 1)) { if (/^## /.test(l)) break; sec.push(l); }
  const lines = sec.filter((l) => l.trim() !== '');
  const bullets = lines.filter((l) => /^\s*(?:- |\d+[.)] )/.test(l)).length;   // "- " bullets or "1." / "1)" items
  const first = lines[0] ?? '';
  if (/^none — every input class/.test(first) && bullets >= 1) return `none-per-class:${bullets}`;
  if (/^none/.test(first)) return 'none-bare';
  return `lines:${bullets}`;
}

const file = process.argv[2];
if (!file || process.argv.length > 3) { console.error('usage: plan-metrics.mjs <WRK-PLAN file>'); process.exit(2); }
const plan = split(readFileSync(file, 'utf8'));
if (!plan.has || plan.fm.layer !== 'work-plan') { console.error(`not a WRK-PLAN: ${file}`); process.exit(3); }

const dir = dirname(file);
const docs = readdirSync(dir).filter((f) => f.endsWith('.md')).sort().map((f) => split(readFileSync(join(dir, f), 'utf8')));
const tasks = docs.filter((d) => d.fm.parent === plan.fm.id);
const spec = docs.find((d) => d.fm.id === plan.fm.parent);

const shares = tasks.map((t) => (t.body.length ? implCodeLines(t.body) / t.body.length : 0));
const share = shares.length ? shares.reduce((a, b) => a + b, 0) / shares.length : 0;
const total = plan.body.length + tasks.reduce((a, t) => a + t.body.length, 0);
const proportion = spec && spec.body.length ? total / spec.body.length : 0;

console.log(JSON.stringify({
  plan: plan.fm.id,
  tasks: tasks.length,
  impl_code_share: Number(share.toFixed(3)),
  proportion: Number(proportion.toFixed(2)),
  review_focus: reviewFocus(plan.body),
}));
