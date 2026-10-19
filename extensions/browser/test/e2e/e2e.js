// Manual e2e (not part of npm test). Needs: npm i puppeteer-core@24; env CHROME=<Chrome for Testing binary> EXT=<abs path to dist/chrome> OUT=<screenshot dir>.
const puppeteer = require('puppeteer-core');
const http = require('http'), fs = require('fs');
const CHROME = process.env.CHROME, EXT = process.env.EXT, OUT = process.env.OUT;
const PAGE = `<!doctype html><html><head><title>t</title></head><body>
<h1>Contacts</h1>
<p id="us">US: (415) 555-0132 and UK: 020 7946 0958, India: +91 98765 43210, Germany: +49 30 901820.</p>
<table><tr><td id="t1">+44 20 7946 0958</td><td>Fax <b><i id="nest">+1 212-555-0147</i></b></td></tr></table>
<p>Mixed <span>nest <em>+33 1 23 45 67 89</em></span> end</p>
<div id="neg">
<p>Date 2024-03-15, 15/03/2024, 03.15.2024. IP 192.168.100.200. Price $1,234,567.89 and 12.345.678 EUR. ISBN 978-3-16-148410-0. Order ID ORD-20240315-99812. Version 1.2.3.4567. Time 12:30:45. SSN 123-45-6789.</p>
<input value="415 555 0199"><textarea>415 555 0198</textarea><code>415 555 0197</code><pre>415 555 0196</pre>
<div contenteditable="true">415 555 0195</div><svg width="200" height="40"><text x="0" y="20">415 555 0194</text></svg>
<a id="telink" href="tel:+14155550100">+1 415 555 0100</a>
<a id="telink2" href="tel:+442079460000">Call us</a>
</div>
<div id="dyn"></div>
<script>setTimeout(()=>{document.getElementById('dyn').innerHTML='<p>Dynamic: <b>+1 (650) 253-0000</b></p>';},1000);
window.__dials=[];document.addEventListener('click',e=>{const a=e.target.closest&&e.target.closest('a');if(a&&a.style.display==='none'){window.__dials.push(a.href);e.preventDefault();}},false);
</script></body></html>`;
function big() {
  let s = '<!doctype html><html><body>';
  for (let i = 0; i < 5000; i++) s += `<p>Paragraph ${i} lorem ipsum dolor sit amet${i % 10 === 0 ? ' call +1 415 555 ' + String(1000 + i) : ''}</p>`;
  return s + '</body></html>';
}
const results = []; const fail = [];
const ok = (c, m) => { results.push((c ? 'PASS ' : 'FAIL ') + m); if (!c) fail.push(m); };
(async () => {
  const srv = http.createServer((q, r) => { r.setHeader('content-type', 'text/html'); r.end(q.url.startsWith('/big') ? big() : PAGE); });
  await new Promise(r => srv.listen(0, '127.0.0.1', r));
  const base = 'http://127.0.0.1:' + srv.address().port;
  const b = await puppeteer.launch({ executablePath: CHROME, headless: true, pipe: true, enableExtensions: [EXT], args: ['--no-first-run'] });
  const errors = [];
  const sw = await b.waitForTarget(t => t.type() === 'service_worker', { timeout: 15000 });
  const swW = await sw.worker();
  swW.on('console', m => { if (m.type() === 'error') errors.push('SW: ' + m.text()); });
  const id = new URL(sw.url()).host; console.log('ext id', id);
  const getSpans = (p) => p.$$eval('span.sp-c2d', els => els.map(e => ({ t: e.textContent, n: e.dataset.spNumber, x: e.dataset.spExt || '' })));
  const open = async (url) => { const p = await b.newPage(); p.on('console', m => { if (m.type() === 'error') errors.push('PAGE: ' + m.text()); }); p.on('pageerror', e => errors.push('PAGEERR: ' + e.message)); await p.goto(url, { waitUntil: 'load' }); return p; };
  const setSettings = async (s) => { const o = await b.newPage(); await o.goto(`chrome-extension://${id}/options.html`); await o.evaluate(s => chrome.storage.local.set({ settings: s }), s); await o.close(); };

  // 1. content script
  await setSettings({ enabled: true, scheme: 'tel' });
  let p = await open(base + '/');
  await new Promise(r => setTimeout(r, 2200));
  let spans = await getSpans(p);
  console.log(JSON.stringify(spans));
  const expected = ['(415) 555-0132', '020 7946 0958', '+91 98765 43210', '+49 30 901820', '+44 20 7946 0958', '+1 212-555-0147', '+33 1 23 45 67 89', '+1 (650) 253-0000'];
  ok(JSON.stringify(spans.map(s => s.t)) === JSON.stringify(expected), 'exactly expected numbers wrapped: ' + spans.length + '/' + expected.length);
  ok(spans.find(s => s.t.startsWith('+91')).n === '+919876543210', 'IN normalised');
  const orig = await p.evaluate(() => document.body.innerText);
  // compare with extension disabled
  await setSettings({ enabled: false, scheme: 'tel' });
  await new Promise(r => setTimeout(r, 600));
  ok((await getSpans(p)).length === 0, 'disabled -> spans removed live');
  const after = await p.evaluate(() => document.body.innerText);
  ok(after === orig, 'innerText identical wrapped vs unwrapped');
  const p2 = await open(base + '/'); await new Promise(r => setTimeout(r, 1500));
  ok((await getSpans(p2)).length === 0, 'disabled fresh load -> none'); await p2.close();
  ok(await p.evaluate(() => document.getElementById('telink').getAttribute('href')) === 'tel:+14155550100', 'tel link untouched');

  // dial hrefs
  for (const [scheme, exp] of [['tel', 'tel:'], ['softphonepro', 'softphonepro://call?number=']]) {
    await setSettings({ enabled: true, scheme, defaultCountry: '+44' });
    await p.reload({ waitUntil: 'load' }); await new Promise(r => setTimeout(r, 1500));
    spans = await getSpans(p);
    const uk = spans.find(s => s.t === '020 7946 0958');
    ok(uk && uk.n === '+442079460958', scheme + ': default country +44 applied -> ' + (uk && uk.n));
    await p.evaluate(() => { window.__dials.length = 0; });
    await p.click('#us .sp-c2d:nth-of-type(2)').catch(async () => { await p.evaluate(() => [...document.querySelectorAll('.sp-c2d')][1].click()); });
    await new Promise(r => setTimeout(r, 200));
    const d = await p.evaluate(() => window.__dials);
    console.log(scheme, d);
    ok(d.length === 1 && d[0].startsWith(exp), scheme + ' click href ' + d[0]);
  }
  // deny-list
  await setSettings({ enabled: true, scheme: 'tel', siteMode: 'deny', siteList: ['127.0.0.1'] });
  await p.reload({ waitUntil: 'load' }); await new Promise(r => setTimeout(r, 1500));
  ok((await getSpans(p)).length === 0, 'deny-listed host -> no spans');
  await setSettings({ enabled: true, scheme: 'tel', siteMode: 'deny', siteList: [] });
  await new Promise(r => setTimeout(r, 800));
  ok((await getSpans(p)).length > 0, 'removing deny entry re-enables live');
  // openAll
  await setSettings({ enabled: true, openAll: true });
  await new Promise(r => setTimeout(r, 800));
  ok(await p.evaluate(() => document.getElementById('telink').getAttribute('href')) === 'softphonepro://call?number=%2B14155550100', 'openAll rewrites tel link');
  await setSettings({ enabled: true, openAll: false });
  await new Promise(r => setTimeout(r, 800));
  ok(await p.evaluate(() => document.getElementById('telink').getAttribute('href')) === 'tel:+14155550100', 'openAll off restores');
  await p.close();

  // 2. screenshots
  await setSettings({ enabled: true, scheme: 'softphonepro', defaultCountry: '+44', siteMode: 'deny', siteList: ['example.com', 'intranet.corp.local'] });
  for (const dark of [false, true]) for (const pg of ['options', 'popup']) {
    const s = await b.newPage(); await s.emulateMediaFeatures([{ name: 'prefers-color-scheme', value: dark ? 'dark' : 'light' }]);
    await s.setViewport({ width: pg === 'popup' ? 360 : 900, height: pg === 'popup' ? 420 : 800 });
    s.on('pageerror', e => errors.push('UIERR: ' + e.message));
    await s.goto(`chrome-extension://${id}/${pg}.html`); await new Promise(r => setTimeout(r, 400));
    if (pg === 'popup') { await s.evaluate(() => chrome.storage.local.set({ recents: [{ number: '+442079460958', t: Date.now() - 120000 }, { number: '+14155550132', t: Date.now() - 7200000 }] })); await s.reload(); await new Promise(r => setTimeout(r, 300)); }
    await s.screenshot({ path: `${OUT}/${pg}-${dark ? 'dark' : 'light'}.png` });
    await s.close();
  }
  // options behavior
  const o = await b.newPage(); await o.goto(`chrome-extension://${id}/options.html`);
  await o.select('#scheme', 'tel'); await o.click('#cc', { clickCount: 3 }); await o.type('#cc', '+91'); await new Promise(r => setTimeout(r, 300));
  await o.evaluate(() => document.getElementById('cc').blur()); await new Promise(r => setTimeout(r, 300));
  const st = await o.evaluate(() => chrome.storage.local.get('settings'));
  ok(st.settings.scheme === 'tel' && st.settings.defaultCountry === '+91', 'options UI persists: ' + JSON.stringify(st.settings));
  await o.close();

  // 3. context menu
  const menu = await swW.evaluate(() => new Promise(res => chrome.contextMenus.create({ id: 'probe', title: 'x' }, () => res(chrome.runtime.lastError && chrome.runtime.lastError.message))));
  console.log('menu probe', menu);
  // re-create via onInstalled path: duplicates id error means registered
  const dup = await swW.evaluate(() => new Promise(res => chrome.contextMenus.create({ id: 'sp-call-selection', title: 'x' }, () => res(chrome.runtime.lastError && chrome.runtime.lastError.message))));
  ok(/duplicate|same id/i.test(dup || ''), 'menu sp-call-selection registered (dup create -> ' + dup + ')');

  // 4. performance
  await setSettings({ enabled: true, scheme: 'tel' });
  const bp = await b.newPage(); bp.on('pageerror', e => errors.push('PAGEERR ' + e.message));
  const t0 = Date.now();
  await bp.goto(base + '/big', { waitUntil: 'load' });
  await bp.evaluate(() => { window.__mut = 0; new MutationObserver(r => window.__mut += r.length).observe(document.body, { childList: true, subtree: true, characterData: true }); });
  let n = 0, tdone = 0;
  for (let i = 0; i < 60; i++) { n = (await getSpans(bp)).length; if (n === 500) { tdone = Date.now() - t0; break; } await new Promise(r => setTimeout(r, 50)); }
  console.log('big spans', n, 'ms since nav start', tdone);
  ok(n === 500, 'big page: 500 spans (' + n + ') in ' + tdone + 'ms from navigation start');
  await new Promise(r => setTimeout(r, 1500));
  const m1 = await bp.evaluate(() => window.__mut); await new Promise(r => setTimeout(r, 1500)); const m2 = await bp.evaluate(() => window.__mut);
  ok(m1 === m2, 'no self-retriggering mutations (' + m1 + ' -> ' + m2 + ')');
  const lat = await bp.evaluate(() => new Promise(res => { const t = performance.now(); setTimeout(() => res(performance.now() - t), 0); }));
  console.log('main thread latency ms', lat);
  // longtask measure on a reload
  await bp.evaluateOnNewDocument(() => { window.__lt = []; new PerformanceObserver(l => l.getEntries().forEach(e => window.__lt.push(e.duration))).observe({ entryTypes: ['longtask'] }); });
  await bp.reload({ waitUntil: 'load' }); await new Promise(r => setTimeout(r, 2500));
  const lt = await bp.evaluate(() => window.__lt);
  console.log('longtasks', lt);
  ok(Math.max(0, ...lt) < 200, 'max longtask ' + Math.max(0, ...lt) + 'ms');

  console.log(results.join('\n')); console.log('ERRORS', errors);
  ok(errors.length === 0, 'no console errors');
  await b.close(); srv.close(); process.exit(fail.length ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
