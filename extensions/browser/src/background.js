/*
 * SoftphonePro Click-to-Dial: background (service worker in Chrome, event page in Firefox).
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
if (typeof importScripts === 'function') importScripts('phone.js', 'settings.js');

(function () {
  'use strict';
  const api = globalThis.browser || globalThis.chrome;
  const MENU_ID = 'sp-call-selection';

  async function createMenu() {
    try { await api.contextMenus.removeAll(); } catch (_) { /* nothing to remove */ }
    api.contextMenus.create({
      id: MENU_ID,
      title: 'Call %s with SoftphonePro',
      contexts: ['selection'],
    }, () => { void (api.runtime && api.runtime.lastError); });
  }

  api.runtime.onInstalled.addListener(createMenu);

  api.contextMenus.onClicked.addListener(async (info, tab) => {
    if (info.menuItemId !== MENU_ID) return;
    try {
      const settings = await globalThis.SPSettings.load();
      const { number, ext } = globalThis.SPPhone.extractNumber(info.selectionText || '', { defaultCountry: settings.defaultCountry });
      if (!number) return;
      const url = globalThis.SPPhone.buildDialUrl(number, settings.scheme, ext);
      try {
        if (tab && tab.id !== undefined) await api.tabs.update(tab.id, { url });
        else await api.tabs.create({ url });
      } catch (_) {
        await api.tabs.create({ url });
      }
      await globalThis.SPSettings.addRecent(number);
    } catch (_) { /* nothing useful to do */ }
  });
})();
