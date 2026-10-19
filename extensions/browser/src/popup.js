/* SoftphonePro Click-to-Dial: toolbar popup. SPDX-License-Identifier: GPL-3.0-or-later */
(function () {
  'use strict';
  const api = globalThis.browser || globalThis.chrome;
  const P = globalThis.SPPhone;
  const S = globalThis.SPSettings;
  const $ = (id) => document.getElementById(id);

  function rel(t) {
    const m = Math.round((Date.now() - t) / 60000);
    if (m < 1) return 'just now';
    if (m < 60) return m + ' min ago';
    const h = Math.round(m / 60);
    if (h < 24) return h + ' h ago';
    return Math.round(h / 24) + ' d ago';
  }

  async function dialNumber(number, ext) {
    const s = await S.load();
    const a = document.createElement('a');
    a.href = P.buildDialUrl(number, s.scheme, ext || '');
    a.style.display = 'none';
    document.body.appendChild(a);
    a.click();
    a.remove();
    await S.addRecent(number);
    window.close();
  }

  async function renderRecents() {
    const list = await S.getRecents();
    const ul = $('recents');
    ul.textContent = '';
    $('empty').hidden = list.length > 0;
    $('clear').hidden = list.length === 0;
    for (const r of list) {
      const li = document.createElement('li');
      const b = document.createElement('button');
      b.type = 'button';
      const n = document.createElement('span');
      n.textContent = r.number;
      const w = document.createElement('span');
      w.className = 'when';
      w.textContent = rel(r.t);
      b.append(n, w);
      b.addEventListener('click', () => dialNumber(r.number));
      li.appendChild(b);
      ul.appendChild(li);
    }
  }

  $('dial').addEventListener('submit', async (e) => {
    e.preventDefault();
    const s = await S.load();
    const { number, ext } = P.extractNumber($('num').value, { defaultCountry: s.defaultCountry });
    if (!number) { $('msg').textContent = 'That does not look like a phone number.'; return; }
    $('msg').textContent = '';
    dialNumber(number, ext);
  });
  $('clear').addEventListener('click', async () => { await S.clearRecents(); renderRecents(); });
  $('options').addEventListener('click', (e) => { e.preventDefault(); api.runtime.openOptionsPage(); window.close(); });
  renderRecents();
})();
