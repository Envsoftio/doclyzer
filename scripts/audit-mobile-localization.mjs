import { readdirSync, readFileSync } from 'node:fs'
import { join, relative, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = resolve(fileURLToPath(new URL('..', import.meta.url)))
const lib = join(root, 'apps/mobile/lib')
const ignored = new Set(['doclyzer', 'you@example.com', 'YYYY-MM-DD'])
const files = []

function visit(directory) {
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    if (entry.name === 'l10n') continue
    const path = join(directory, entry.name)
    if (entry.isDirectory()) visit(path)
    else if (entry.name.endsWith('.dart')) files.push(path)
  }
}

visit(lib)

// This intentionally counts direct user-facing literals only. Messages stored in
// state variables or assembled with interpolation need a separate manual review.
const directText = /\b(?:Text|SelectableText|TextSpan)\s*\(\s*(?:const\s+)?(['"])((?:\\.|(?!\1)[^\\])*?)\1/g
const uiProperty = /\b(?:labelText|hintText|helperText|errorText|tooltip|semanticLabel):\s*(['"])((?:\\.|(?!\1)[^\\])*?)\1/g
const findings = []

for (const path of files.sort()) {
  const source = readFileSync(path, 'utf8')
  for (const [kind, pattern] of [['text', directText], ['property', uiProperty]]) {
    pattern.lastIndex = 0
    for (const match of source.matchAll(pattern)) {
      const value = match[2]
      if (!value.trim() || ignored.has(value) || value.startsWith('• $')) continue
      findings.push({
        file: relative(root, path),
        line: source.slice(0, match.index).split('\n').length,
        kind,
        text: value,
      })
    }
  }
}

findings.sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line)
const byFile = new Map()
for (const finding of findings) byFile.set(finding.file, (byFile.get(finding.file) ?? 0) + 1)

if (process.argv.includes('--json')) {
  process.stdout.write(`${JSON.stringify({ total: findings.length, files: byFile.size, findings }, null, 2)}\n`)
} else {
  console.log(`${findings.length} direct user-facing literals in ${byFile.size} Dart files`)
  for (const [file, count] of byFile) console.log(`${String(count).padStart(3)} ${file}`)
  console.log('This is a lower bound; state messages and composed strings are not counted.')
}

if (process.argv.includes('--strict') && findings.length) process.exitCode = 1
