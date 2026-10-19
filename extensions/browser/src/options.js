/* SoftphonePro Click-to-Dial: options page. SPDX-License-Identifier: GPL-3.0-or-later */
(function () {
  'use strict';
  const P = globalThis.SPPhone;
  const S = globalThis.SPSettings;
  const $ = (id) => document.getElementById(id);
  let t = 0;

  function fill(s) {
    $('enabled').checked = s.enabled;
    $('scheme').value = s.scheme;
    $('cc').value = s.defaultCountry;
    $('openAll').checked = s.openAll;
    $('siteMode').value = s.siteMode;
    $('sites').value = s.siteList.join('\n');
  }

  async function save() {
    const raw = $('cc').value.trim();
    const cc = P.normalizeCountryCode(raw);
    $('ccerr').hidden = !raw || !!cc;
    if (raw && !cc) return;
    await S.save({
      enabled: $('enabled').checked,
      scheme: $('scheme').value,
      defaultCountry: cc,
      openAll: $('openAll').checked,
      siteMode: $('siteMode').value,
      siteList: $('sites').value,
    });
    $('status').textContent = 'Saved.';
    clearTimeout(t);
    t = setTimeout(() => { $('status').innerHTML = '&nbsp;'; }, 1500);
  }

  for (const id of ['enabled', 'scheme', 'openAll', 'siteMode']) $(id).addEventListener('change', save);
  $('cc').addEventListener('input', save);
  $('cc').addEventListener('blur', async () => { fill(await S.load()); });
  $('sites').addEventListener('input', () => { clearTimeout($('sites')._t); $('sites')._t = setTimeout(save, 400); });
  S.load().then(fill);
})();
