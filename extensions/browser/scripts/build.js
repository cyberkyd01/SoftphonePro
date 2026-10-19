#!/usr/bin/env node
'use strict';
/*
 * Zero-dependency build: src/ -> dist/chrome + dist/firefox (+ zips), with manifest validation.
 *   node scripts/build.js          build + zip
 *   node scripts/build.js --lint   syntax-check sources and validate both manifests only
 * Env: EXT_VERSION overrides the package.json version for zip names (e.g. "1.2.0-dev.7");
 *      the numeric part (x.y.z) becomes the manifest version.
 */
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const { spawnSync } = require('node:child_process');

const ROOT = path.resolve(__dirname, '..');
const SRC = path.join(ROOT, 'src');
const DIST = path.join(ROOT, 'dist');
const GECKO_ID = 'clicktodial@softphonepro.app';
const ALLOWED_PERMISSIONS = ['contextMenus', 'storage', 'activeTab'];

const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, 'package.json'), 'utf8'));
const fullVersion = (process.env.EXT_VERSION || pkg.version).replace(/^v/, '');
const numeric = /^(\d+)\.(\d+)\.(\d+)/.exec(fullVersion);
if (!numeric) fail(`invalid version "${fullVersion}"`);
const manifestVersion = `${numeric[1]}.${numeric[2]}.${numeric[3]}`;

function fail(msg) { console.error('error: ' + msg); process.exit(1); }

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
    const p = path.join(dir, e.name);
    return e.isDirectory() ? walk(p) : [p];
  });
}

// ---- manifests --------------------------------------------------------------------------------
function makeManifest(target) {
  const m = JSON.parse(fs.readFileSync(path.join(SRC, 'manifest.base.json'), 'utf8'));
  m.version = manifestVersion;
  if (target === 'chrome') {
    m.minimum_chrome_version = '110';
    if (fullVersion !== manifestVersion) m.version_name = fullVersion;
    m.background = { service_worker: 'background.js' };
  } else {
    m.background = { scripts: ['phone.js', 'settings.js', 'background.js'] };
    m.browser_specific_settings = {
      gecko: {
        id: GECKO_ID,
        strict_min_version: '115.0',
        data_collection_permissions: { required: ['none'] },
      },
    };
  }
  return m;
}

function validateManifest(m, target, dir) {
  const errs = [];
  const need = (cond, msg) => { if (!cond) errs.push(msg); };
  need(m.manifest_version === 3, 'manifest_version must be 3');
  need(typeof m.name === 'string' && m.name.length > 0 && m.name.length <= 45, 'name required (<=45 chars)');
  need(typeof m.description === 'string' && m.description.length > 0 && m.description.length <= 132, 'description required (<=132 chars)');
  need(/^\d+(\.\d+){0,3}$/.test(m.version || ''), 'version must be 1-4 dot-separated integers');
  need(Array.isArray(m.permissions) && m.permissions.every((p) => ALLOWED_PERMISSIONS.includes(p)) &&
    ALLOWED_PERMISSIONS.every((p) => m.permissions.includes(p)), `permissions must be exactly ${ALLOWED_PERMISSIONS.join(', ')}`);
  need(JSON.stringify(m.host_permissions) === '["<all_urls>"]', 'host_permissions must be ["<all_urls>"]');
  need(!m.optional_permissions && !m.content_security_policy && !m.web_accessible_resources && !m.externally_connectable,
    'no optional permissions / custom CSP / web_accessible_resources / externally_connectable allowed');
  for (const s of [16, 32, 48, 128]) need(m.icons && m.icons[s], `icons.${s} missing`);
  if (target === 'chrome') {
    need(m.background && m.background.service_worker === 'background.js' && !m.background.scripts, 'chrome needs background.service_worker only');
    need(!m.browser_specific_settings, 'chrome manifest must not carry browser_specific_settings');
  } else {
    const g = m.browser_specific_settings && m.browser_specific_settings.gecko;
    need(g && /^[a-z0-9._-]+@[a-z0-9.-]+$/i.test(g.id || ''), 'firefox needs browser_specific_settings.gecko.id (email-style)');
    need(Array.isArray(m.background && m.background.scripts) && !m.background.service_worker, 'firefox needs background.scripts only');
  }
  need(Array.isArray(m.content_scripts) && m.content_scripts.length === 1, 'exactly one content_scripts entry expected');

  const files = [];
  for (const cs of m.content_scripts || []) files.push(...(cs.js || []), ...(cs.css || []));
  files.push(...Object.values(m.icons || {}), m.action && m.action.default_popup, m.options_ui && m.options_ui.page);
  files.push(...Object.values((m.action && m.action.default_icon) || {}));
  if (m.background) files.push(m.background.service_worker, ...(m.background.scripts || []));
  for (const f of files.filter(Boolean)) need(fs.existsSync(path.join(dir, f)), `referenced file missing: ${f}`);
  if (errs.length) fail(`${target} manifest invalid:\n  - ${errs.join('\n  - ')}`);
}

// ---- source checks ----------------------------------------------------------------------------
function checkSources() {
  const problems = [];
  for (const f of walk(SRC)) {
    const rel = path.relative(SRC, f);
    if (f.endsWith('.js')) {
      const r = spawnSync(process.execPath, ['--check', f], { encoding: 'utf8' });
      if (r.status !== 0) problems.push(`${rel}: syntax error\n${r.stderr}`);
    }
    if (/\.(js|html|css)$/.test(f)) {
      const text = fs.readFileSync(f, 'utf8');
      if (/\beval\s*\(|new\s+Function\s*\(|importScripts\(\s*['"]https?:/.test(text)) problems.push(`${rel}: dynamic code evaluation / remote script`);
      if (/<script[^>]+src=["']?(https?:)?\/\//i.test(text)) problems.push(`${rel}: remote <script>`);
      if (/<script(?![^>]*\bsrc=)[^>]*>\s*\S/i.test(text)) problems.push(`${rel}: inline <script> (violates extension CSP)`);
      if (/\b(fetch|XMLHttpRequest|WebSocket|sendBeacon)\b/.test(text) && f.endsWith('.js')) problems.push(`${rel}: network API used (extension must not make requests)`);
    }
  }
  for (const f of ['phone.js', 'settings.js']) {
    if (!fs.existsSync(path.join(SRC, f))) problems.push(`missing src/${f}`);
  }
  if (problems.length) fail(problems.join('\n'));
}

// ---- zip (store-only metadata, deflate, deterministic) ---------------------------------------------
const CRC_TABLE = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c >>> 0;
  }
  return t;
})();
function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function zipDir(dir, outFile) {
  const DOS_TIME = 0;
  const DOS_DATE = ((2020 - 1980) << 9) | (1 << 5) | 1; // 2020-01-01, keeps zips reproducible
  const files = walk(dir).map((f) => path.relative(dir, f).split(path.sep).join('/')).sort();
  const chunks = [];
  const central = [];
  let offset = 0;
  for (const name of files) {
    const data = fs.readFileSync(path.join(dir, name));
    const comp = zlib.deflateRawSync(data, { level: 9 });
    const useDeflate = comp.length < data.length;
    const body = useDeflate ? comp : data;
    const nameBuf = Buffer.from(name, 'utf8');
    const crc = crc32(data);
    const local = Buffer.alloc(30);
    local.writeUInt32LE(0x04034b50, 0);
    local.writeUInt16LE(20, 4);
    local.writeUInt16LE(0x0800, 6); // UTF-8 names
    local.writeUInt16LE(useDeflate ? 8 : 0, 8);
    local.writeUInt16LE(DOS_TIME, 10);
    local.writeUInt16LE(DOS_DATE, 12);
    local.writeUInt32LE(crc, 14);
    local.writeUInt32LE(body.length, 18);
    local.writeUInt32LE(data.length, 22);
    local.writeUInt16LE(nameBuf.length, 26);
    chunks.push(local, nameBuf, body);
    const cd = Buffer.alloc(46);
    cd.writeUInt32LE(0x02014b50, 0);
    cd.writeUInt16LE(20, 4);
    cd.writeUInt16LE(20, 6);
    cd.writeUInt16LE(0x0800, 8);
    cd.writeUInt16LE(useDeflate ? 8 : 0, 10);
    cd.writeUInt16LE(DOS_TIME, 12);
    cd.writeUInt16LE(DOS_DATE, 14);
    cd.writeUInt32LE(crc, 16);
    cd.writeUInt32LE(body.length, 20);
    cd.writeUInt32LE(data.length, 24);
    cd.writeUInt16LE(nameBuf.length, 28);
    cd.writeUInt32LE(0x81a40000, 38); // -rw-r--r--
    cd.writeUInt32LE(offset, 42);
    central.push(cd, nameBuf);
    offset += local.length + nameBuf.length + body.length;
  }
  const cdBuf = Buffer.concat(central);
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(files.length, 8);
  end.writeUInt16LE(files.length, 10);
  end.writeUInt32LE(cdBuf.length, 12);
  end.writeUInt32LE(offset, 16);
  fs.writeFileSync(outFile, Buffer.concat([...chunks, cdBuf, end]));
  return files.length;
}

// ---- main -------------------------------------------------------------------------------------
function main() {
  checkSources();
  const lintOnly = process.argv.includes('--lint');
  if (lintOnly) {
    for (const t of ['chrome', 'firefox']) validateManifest(makeManifest(t), t, SRC);
    console.log('lint ok: sources and both manifests are valid');
    return;
  }
  fs.rmSync(DIST, { recursive: true, force: true });
  fs.mkdirSync(DIST, { recursive: true });
  for (const target of ['chrome', 'firefox']) {
    const out = path.join(DIST, target);
    for (const f of walk(SRC)) {
      const rel = path.relative(SRC, f);
      if (rel === 'manifest.base.json') continue;
      fs.mkdirSync(path.dirname(path.join(out, rel)), { recursive: true });
      fs.copyFileSync(f, path.join(out, rel));
    }
    fs.copyFileSync(path.join(ROOT, '..', '..', 'LICENSE'), path.join(out, 'LICENSE'));
    const manifest = makeManifest(target);
    fs.writeFileSync(path.join(out, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n');
    validateManifest(JSON.parse(fs.readFileSync(path.join(out, 'manifest.json'), 'utf8')), target, out);
    const zip = path.join(DIST, `SoftphonePro-ClickToDial-${target}-${fullVersion}.zip`);
    const n = zipDir(out, zip);
    console.log(`${target}: ${n} files -> ${path.relative(ROOT, zip)} (${fs.statSync(zip).size} bytes)`);
  }
}
main();
