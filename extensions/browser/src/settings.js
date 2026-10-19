/*
 * SoftphonePro Click-to-Dial: settings + recent numbers (chrome.storage.local / browser.storage.local).
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
(function (root, factory) {
  'use strict';
  const api = factory(root);
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.SPSettings = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function (root) {
  'use strict';

  const MAX_RECENTS = 20;
  const DEFAULTS = Object.freeze({
    enabled: true,
    scheme: 'tel', // 'tel' | 'softphonepro' | 'sip'
    defaultCountry: '', // e.g. '+44'
    openAll: false, // rewrite existing tel:/sip:/callto: links to softphonepro://
    siteMode: 'deny', // 'deny' | 'allow'
    siteList: [],
  });

  function ext() { return root.browser || root.chrome; }

  function phone() {
    return root.SPPhone || (typeof require === 'function' ? require('./phone.js') : null);
  }

  function sanitize(obj) {
    const o = obj && typeof obj === 'object' ? obj : {};
    const P = phone();
    return {
      enabled: o.enabled === undefined ? DEFAULTS.enabled : !!o.enabled,
      scheme: ['tel', 'softphonepro', 'sip'].includes(o.scheme) ? o.scheme : DEFAULTS.scheme,
      defaultCountry: P.normalizeCountryCode(o.defaultCountry),
      openAll: !!o.openAll,
      siteMode: o.siteMode === 'allow' ? 'allow' : 'deny',
      siteList: P.parseSiteList(o.siteList || []),
    };
  }

  async function load() {
    const r = await ext().storage.local.get('settings');
    return sanitize(r && r.settings);
  }

  async function save(s) {
    const clean = sanitize(s);
    await ext().storage.local.set({ settings: clean });
    return clean;
  }

  function pushRecent(list, number, now) {
    const arr = (Array.isArray(list) ? list : []).filter((r) => r && typeof r.number === 'string' && r.number !== number);
    arr.unshift({ number, t: now || Date.now() });
    return arr.slice(0, MAX_RECENTS);
  }

  async function getRecents() {
    const r = await ext().storage.local.get('recents');
    return Array.isArray(r && r.recents) ? r.recents.slice(0, MAX_RECENTS) : [];
  }

  async function addRecent(number) {
    if (!number) return;
    const list = pushRecent(await getRecents(), number);
    await ext().storage.local.set({ recents: list });
  }

  async function clearRecents() {
    await ext().storage.local.set({ recents: [] });
  }

  return { DEFAULTS, MAX_RECENTS, sanitize, load, save, pushRecent, getRecents, addRecent, clearRecents };
});
