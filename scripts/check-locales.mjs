import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { resolve, dirname } from 'node:path'
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const scripts = { en: 'Latin', hi: 'Devanagari', kn: 'Kannada', te: 'Telugu', ml: 'Malayalam', ta: 'Tamil', bn: 'Bengali', or: 'Oriya', gu: 'Gujarati', mr: 'Devanagari', pa: 'Gurmukhi' }
const read = path => JSON.parse(readFileSync(resolve(root, path), 'utf8'))
const sourceText = path => readFileSync(resolve(root, path), 'utf8')
for (const [path, pattern] of [
  ['apps/api/src/common/language.ts', /^  ([a-z]{2}): /gm],
  ['apps/web/shared/languages.ts', /code: '([a-z]{2})'/g],
  ['apps/mobile/lib/l10n/l10n.dart', /  '([a-z]{2})': /g],
]) assert.deepEqual([...sourceText(path).matchAll(pattern)].map(match => match[1]).sort(), Object.keys(scripts).sort(), `${path}: registry mismatch`)

const placeholders = text => [...text.matchAll(/\{([a-zA-Z][a-zA-Z0-9_]*)\}/g)].map(match => match[1]).sort()
for (const [folder, file] of [['apps/mobile/lib/l10n', locale => `app_${locale}.arb`], ['apps/web/i18n/locales', locale => `${locale}.json`]]) {
  const source = read(`${folder}/${file('en')}`)
  const keys = Object.keys(source).filter(key => !key.startsWith('@')).sort()
  for (const [locale, script] of Object.entries(scripts)) {
    const catalog = read(`${folder}/${file(locale)}`)
    assert.deepEqual(Object.keys(catalog).filter(key => !key.startsWith('@')).sort(), keys, `${locale}: missing/extra keys`)
    for (const key of keys) {
      const value = catalog[key], label = `${locale}.${key}`
      assert.ok(typeof value === 'string' && value.trim(), `${label}: empty`)
      assert.deepEqual(placeholders(value), placeholders(source[key]), `${label}: changed placeholders`)
      assert.equal((value.match(/\|/g) ?? []).length, (source[key].match(/\|/g) ?? []).length, `${label}: changed plural branches`)
      assert.deepEqual((value.match(/[0-9]+(?:\.[0-9]+)?/g) ?? []).sort(), (source[key].match(/[0-9]+(?:\.[0-9]+)?/g) ?? []).sort(), `${label}: changed numbers`)
      // A message made only of placeholders and punctuation has no words to translate.
      const translatableSource = source[key].replace(/\{[a-zA-Z][a-zA-Z0-9_]*\}/g, '').replace(/[\d\W]/g, '')
      if (locale !== 'en' && translatableSource) assert.ok(new RegExp(`\\p{Script=${script}}`, 'u').test(value), `${label}: missing target script`)
      assert.equal(value.includes('\uFFFD'), false, `${label}: broken Unicode`)
    }
    if (file(locale).endsWith('.arb')) {
      assert.equal(catalog['@@locale'], locale)
      for (const key of keys) if (source[`@${key}`]) assert.deepEqual(catalog[`@${key}`], source[`@${key}`], `${locale}.${key}: changed placeholder metadata`)
    }
  }
}
console.log('PASS all eleven catalogs: complete keys, placeholders, numeric literals, plural branches, Unicode scripts, ARB metadata')
