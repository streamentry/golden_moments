#!/usr/bin/env node
// Checks that a translated dictionary mirrors its English source:
// same keys and array lengths, same {placeholders}, same HTML tags and hrefs.
//   node scripts/check-translation.mjs src/i18n/ui/en.json src/i18n/ui/vi.json
import { readFileSync } from 'node:fs';

const [srcPath, dstPath] = process.argv.slice(2);
const src = JSON.parse(readFileSync(srcPath, 'utf8'));
const dst = JSON.parse(readFileSync(dstPath, 'utf8'));
const errors = [];
const sorted = (re, s) => [...s.matchAll(re)].map((m) => m[0]).sort().join(' ');
const PLACEHOLDER = /\{\w+\}/g;
const TAG = /<\/?[a-z][a-z0-9]*/gi;
const HREF = /href="[^"]*"/g;

function walk(a, b, path) {
  if (typeof a === 'string') {
    if (typeof b !== 'string') return errors.push(`${path}: expected text`);
    if (path.endsWith('.href') || path.endsWith('.icon') || path.endsWith('.id')) {
      if (a !== b) errors.push(`${path}: must stay "${a}"`);
      return;
    }
    for (const [name, re] of [['placeholders', PLACEHOLDER], ['tags', TAG], ['links', HREF]]) {
      if (sorted(re, a) !== sorted(re, b)) errors.push(`${path}: ${name} differ (${sorted(re, a)} vs ${sorted(re, b)})`);
    }
    if (a.trim() && !b.trim()) errors.push(`${path}: empty`);
    return;
  }
  if (Array.isArray(a)) {
    if (!Array.isArray(b)) return errors.push(`${path}: expected a list`);
    if (a.length !== b.length) errors.push(`${path}: ${b.length} items, English has ${a.length}`);
    a.forEach((v, i) => walk(v, b[i], `${path}[${i}]`));
    return;
  }
  if (a && typeof a === 'object') {
    if (!b || typeof b !== 'object' || Array.isArray(b)) return errors.push(`${path}: expected an object`);
    for (const key of Object.keys(a)) {
      if (key.startsWith('_')) continue;
      if (!(key in b)) errors.push(`${path}.${key}: missing`);
      else walk(a[key], b[key], `${path}.${key}`);
    }
    for (const key of Object.keys(b)) if (!(key in a)) errors.push(`${path}.${key}: not in English`);
  }
}
walk(src, dst, '');
if (errors.length) {
  console.error(errors.join('\n'));
  console.error(`${errors.length} problems in ${dstPath}`);
  process.exit(1);
}
console.log(`${dstPath}: OK`);
