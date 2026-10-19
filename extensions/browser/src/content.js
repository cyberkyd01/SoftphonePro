/*
 * SoftphonePro Click-to-Dial: content script.
 * Wraps phone numbers in visible text with a clickable span; optionally rewrites tel:/sip:/callto: links.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
(function () {
  'use strict';
  const P = globalThis.SPPhone;
  const S = globalThis.SPSettings;
  if (!P || !S || !document.documentElement) return;
  if (document.documentElement.namespaceURI !== 'http://www.w3.org/1999/xhtml') return; // plain XML documents
  if (globalThis.__spC2dLoaded) return;
  globalThis.__spC2dLoaded = true;

  const api = globalThis.browser || globalThis.chrome;
  const CLS = 'sp-c2d';
  const XHTML = 'http://www.w3.org/1999/xhtml';
  const SKIP_SELECTOR = [
    'script', 'style', 'noscript', 'textarea', 'input', 'select', 'option', 'code', 'pre', 'kbd', 'samp',
    'button', 'a', 'title', 'template', 'canvas', 'svg', 'math', 'iframe', 'object',
    '[contenteditable]:not([contenteditable="false"])', '[role="textbox"]', '.' + CLS,
  ].join(',');
  const QUICK = /\d[\d  ().\-‐‑–]{5,}\d/;
  const LINK_RE = /^\s*(?:tel|sips?|callto):/i;
  const THROTTLE_MS = 250;
  const BUDGET_MS = 10;

  let settings = S.sanitize(null);
  let siteOk = true;
  let observer = null;
  let detecting = false;
  let rewriting = false;
  let timer = 0;
  const rootQueue = [];
  const textQueue = [];

  // ---- helpers ----------------------------------------------------------------------------
  function isSkipped(el) {
    if (!el || el.nodeType !== 1) return true;
    if (el.namespaceURI !== XHTML) return true;
    try {
      if (el.closest(SKIP_SELECTOR)) return true;
      if (el.isContentEditable) return true;
      if (typeof el.checkVisibility === 'function' && !el.checkVisibility()) return true;
    } catch (_) { return true; }
    return false;
  }

  function isPruned(el) {
    // Cheap subtree pruning for the TreeWalker (the full check runs per candidate text node).
    const t = el.localName;
    return el.namespaceURI !== XHTML || t === 'script' || t === 'style' || t === 'noscript' || t === 'textarea' ||
      t === 'pre' || t === 'code' || t === 'svg' || t === 'a' || t === 'select' || t === 'template' || t === 'iframe' ||
      el.classList.contains(CLS) || el.getAttribute('contenteditable') === '' || el.getAttribute('contenteditable') === 'true';
  }

  // ---- detection -> spans -----------------------------------------------------------------
  function collectText(root) {
    if (root.nodeType === 3) { textQueue.push(root); return; }
    if (root.nodeType !== 1 || isPruned(root)) return;
    const walker = document.createTreeWalker(root, 1 | 4, {
      acceptNode(n) {
        if (n.nodeType === 1) return isPruned(n) ? 2 /* REJECT */ : 3 /* SKIP */;
        return n.data.length >= 7 && QUICK.test(n.data) ? 1 : 3;
      },
    });
    let n;
    while ((n = walker.nextNode())) textQueue.push(n);
  }

  function wrapText(node) {
    if (!node.isConnected) return;
    const text = node.data;
    if (text.length < 7 || !QUICK.test(text)) return;
    const matches = P.findPhoneNumbers(text);
    if (!matches.length) return;
    const parent = node.parentElement;
    if (!parent || isSkipped(parent)) return;

    const frag = document.createDocumentFragment();
    let last = 0;
    let made = 0;
    for (const m of matches) {
      const number = P.normalizeNumber(m.candidate, settings.defaultCountry);
      if (!number) continue;
      if (m.start > last) frag.appendChild(document.createTextNode(text.slice(last, m.start)));
      const span = document.createElement('span');
      span.className = CLS;
      span.setAttribute('role', 'link');
      span.tabIndex = 0;
      span.dataset.spNumber = number;
      if (m.ext) span.dataset.spExt = m.ext;
      span.title = 'Call ' + number + (m.ext ? ' ext. ' + m.ext : '') + ' with SoftphonePro';
      span.textContent = text.slice(m.start, m.end);
      frag.appendChild(span);
      last = m.end;
      made++;
    }
    if (!made) return;
    if (last < text.length) frag.appendChild(document.createTextNode(text.slice(last)));
    parent.replaceChild(frag, node);
  }

  function unwrapAll() {
    for (const s of document.querySelectorAll('span.' + CLS)) s.replaceWith(document.createTextNode(s.textContent));
  }

  // ---- anchors ----------------------------------------------------------------------------
  function rewriteAnchor(a) {
    if (a.dataset.spOrig !== undefined) return;
    const href = a.getAttribute('href');
    if (!href || !LINK_RE.test(href)) return;
    const parsed = P.parsePhoneHref(href, settings.defaultCountry);
    if (!parsed) return;
    a.dataset.spOrig = href;
    a.setAttribute('href', P.buildDialUrl(parsed.target, 'softphonepro'));
  }

  function rewriteWithin(root) {
    if (root.nodeType === 1) {
      if (root.localName === 'a') rewriteAnchor(root);
      for (const a of root.querySelectorAll('a[href]')) rewriteAnchor(a);
    }
  }

  function restoreAnchors() {
    for (const a of document.querySelectorAll('a[data-sp-orig]')) {
      a.setAttribute('href', a.dataset.spOrig);
      delete a.dataset.spOrig;
    }
  }

  // ---- scheduling / observer --------------------------------------------------------------
  function handleRecords(recs) {
    for (const r of recs) {
      if (r.type === 'characterData') {
        if (detecting && r.target.parentElement) rootQueue.push(r.target);
      } else {
        for (const n of r.addedNodes) {
          if (n.nodeType === 1 && n.classList.contains(CLS)) continue;
          if (n.nodeType === 1 || n.nodeType === 3) rootQueue.push(n);
        }
      }
    }
  }

  function schedule(delay) {
    if (timer) return;
    timer = setTimeout(run, delay === undefined ? THROTTLE_MS : delay);
  }

  function run() {
    timer = 0;
    if (!observer) return;
    handleRecords(observer.takeRecords());
    observer.disconnect(); // our own DOM changes must not retrigger us
    const t0 = performance.now();
    try {
      while (performance.now() - t0 < BUDGET_MS && (rootQueue.length || textQueue.length)) {
        if (rootQueue.length) {
          const root = rootQueue.shift();
          if (!root.isConnected) continue;
          if (rewriting) rewriteWithin(root);
          if (detecting) collectText(root);
        } else {
          wrapText(textQueue.shift());
        }
      }
    } catch (_) { /* never let the page see us fail */ }
    startObserver();
    if (rootQueue.length || textQueue.length) schedule(30);
  }

  function startObserver() {
    if (!observer || !document.body) return;
    observer.observe(document.body, { childList: true, subtree: true, characterData: true });
  }

  function ensureObserver() {
    if (observer || !document.body) return;
    observer = new MutationObserver((recs) => { handleRecords(recs); schedule(); });
    startObserver();
  }

  function releaseObserver() {
    if (observer && !detecting && !rewriting) {
      observer.disconnect();
      observer = null;
      rootQueue.length = 0;
      textQueue.length = 0;
    }
  }

  // ---- apply settings ---------------------------------------------------------------------
  function apply() {
    const wantDetect = settings.enabled && siteOk;
    const wantRewrite = settings.openAll && siteOk;
    if (!document.body) return;

    if (wantDetect !== detecting) {
      detecting = wantDetect;
      if (detecting) { ensureObserver(); rootQueue.push(document.body); }
      else unwrapAll();
    }
    if (wantRewrite !== rewriting) {
      rewriting = wantRewrite;
      if (rewriting) { ensureObserver(); rootQueue.push(document.body); }
      else restoreAnchors();
    }
    releaseObserver();
    if (rootQueue.length) schedule(0);
  }

  async function refresh() {
    try { settings = await S.load(); } catch (_) { return; }
    siteOk = P.siteAllowed(location.hostname, settings.siteMode, settings.siteList);
    // number formatting may have changed (default country): re-render spans
    if (detecting) { unwrapAll(); detecting = false; }
    if (rewriting) { restoreAnchors(); rewriting = false; }
    apply();
  }

  // ---- click handling ---------------------------------------------------------------------
  function dial(span) {
    const number = span.dataset.spNumber;
    if (!number) return;
    const url = P.buildDialUrl(number, settings.scheme, span.dataset.spExt || '');
    const a = document.createElement('a');
    a.href = url;
    a.rel = 'noreferrer noopener';
    a.style.display = 'none';
    (document.body || document.documentElement).appendChild(a);
    a.click();
    a.remove();
    S.addRecent(number).catch(() => {});
  }

  function onClick(e) {
    const span = e.target && e.target.closest ? e.target.closest('span.' + CLS) : null;
    if (!span || e.button !== 0) return;
    e.preventDefault();
    e.stopPropagation();
    dial(span);
  }

  function onKey(e) {
    if (e.key !== 'Enter' && e.key !== ' ') return;
    const span = e.target && e.target.closest ? e.target.closest('span.' + CLS) : null;
    if (!span) return;
    e.preventDefault();
    e.stopPropagation();
    dial(span);
  }

  document.addEventListener('click', onClick, true);
  document.addEventListener('keydown', onKey, true);
  api.storage.onChanged.addListener((changes, area) => {
    if (area === 'local' && changes.settings) refresh();
  });

  function boot() { refresh(); }
  if (document.body) boot();
  else document.addEventListener('DOMContentLoaded', boot, { once: true });
})();
