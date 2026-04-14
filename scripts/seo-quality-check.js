/**
 * SEO Quality Check
 *
 * Validates that critical SEO compliance files are present and correct:
 *   - apps/web/public/sitemap.xml: must exist, be valid XML, contain at least one <url> entry
 *   - apps/web/public/robots.txt: must exist, contain Disallow: /share/, contain Sitemap: directive
 *
 * Exits 1 with per-check failure messages if any check fails; exits 0 if all pass.
 *
 * Run via: node scripts/seo-quality-check.js (from repo root)
 * No npm install required — uses only Node.js built-ins.
 */

'use strict';

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');

let failures = 0;

function fail(message) {
  console.error(`  ❌ FAIL: ${message}`);
  failures++;
}

function pass(message) {
  console.log(`  ✅ PASS: ${message}`);
}

// ── Sitemap check ────────────────────────────────────────────────────────────

console.log('\n🔍 Checking apps/web/public/sitemap.xml...');

const sitemapPath = path.join(REPO_ROOT, 'apps', 'web', 'public', 'sitemap.xml');

if (!fs.existsSync(sitemapPath)) {
  fail('sitemap.xml not found at apps/web/public/sitemap.xml');
} else {
  const sitemap = fs.readFileSync(sitemapPath, 'utf8');

  if (!sitemap.includes('<urlset')) {
    fail('sitemap.xml missing <urlset> element — not valid XML sitemap');
  } else {
    pass('sitemap.xml contains <urlset> element');
  }

  if (!sitemap.includes('<url>')) {
    fail('sitemap.xml contains no <url> entries — sitemap is empty');
  } else {
    pass('sitemap.xml contains at least one <url> entry');
  }
}

// ── Robots.txt check ─────────────────────────────────────────────────────────

console.log('\n🔍 Checking apps/web/public/robots.txt...');

const robotsPath = path.join(REPO_ROOT, 'apps', 'web', 'public', 'robots.txt');

if (!fs.existsSync(robotsPath)) {
  fail('robots.txt not found at apps/web/public/robots.txt');
} else {
  const robots = fs.readFileSync(robotsPath, 'utf8');

  if (!robots.includes('Disallow: /share/')) {
    fail(
      'robots.txt missing "Disallow: /share/" — share routes not protected from crawlers',
    );
    console.error(
      '         💡 Add "Disallow: /share/" under User-Agent: * in robots.txt',
    );
  } else {
    pass('robots.txt contains "Disallow: /share/"');
  }

  if (!robots.includes('Sitemap:')) {
    fail(
      'robots.txt missing "Sitemap:" directive — sitemap not discoverable by crawlers',
    );
    console.error(
      '         💡 Add "Sitemap: https://doclyzer.com/sitemap.xml" to robots.txt',
    );
  } else {
    pass('robots.txt contains "Sitemap:" directive');
  }
}

// ── Result ───────────────────────────────────────────────────────────────────

if (failures === 0) {
  console.log('\n✅ SEO quality check passed — all checks clean.\n');
  process.exit(0);
} else {
  console.error(
    `\n🚫 SEO quality check FAILED — ${failures} check(s) failed.\n`,
  );
  process.exit(1);
}
