# SoftphonePro Click-to-Dial (browser extension)

Turns phone numbers on web pages into click-to-dial links that open in the **SoftphonePro** softphone.
One Manifest V3 codebase for **Chrome, Edge, Brave** (service worker) and **Firefox 115+** (event page);
`npm run build` emits a separate manifest for each. GPL-3.0-or-later, no dependencies, no analytics, no remote code.

## Features

- Detects phone numbers in visible page text: international (`+44 20 7946 0958`, `+1 (555) 123-4567`, `0044 ...`),
  national formats with 7+ digits, trunk zero `(0)`, extensions (`ext. 12`, `x12`).
  Ignores dates, IPs, prices, ISBNs, card-like digit runs, versions, SSN/ZIP+4 and similar.
- Never touches input, textarea, code, pre, script, style, svg, `contenteditable` content or text that is already inside a link.
- Matches get a dotted underline and a small phone icon on hover/focus (no layout shift; transitions disabled under `prefers-reduced-motion`).
  Handles dynamic pages with a throttled `MutationObserver`.
- Right-click selected text: **Call "<selection>" with SoftphonePro**.
- Toolbar popup: quick dial box + last 20 numbers.
- Options: on/off, link scheme (`tel:` / `softphonepro://call?number=` / `sip:`), default country code for national numbers
  (e.g. `+44`: `020 7946 0958` becomes `+442079460958`), site allow/deny list,
  and **Open all phone links with SoftphonePro** (rewrites existing `tel:`, `sip:`, `sips:`, `callto:` links to `softphonepro://call?number=...`).

## How numbers reach SoftphonePro

The extension never talks to the app directly. It only asks the browser to open a URL, and the OS hands it to whichever
app owns that scheme. The SoftphonePro desktop and mobile apps register `tel:`, `sip:`, `sips:`, `callto:` and `softphonepro:`.
If another app owns `tel:` on your machine, pick `softphonepro://call?number=<n>` in the options.
The browser will ask once whether to allow opening SoftphonePro. Extensions are sent with `;ext=` only on `tel:` links;
`sip:` and `softphonepro://` links carry just the main number.

## Install (development)

```sh
cd extensions/browser
npm test          # node --test, no dependencies
npm run build     # -> dist/chrome, dist/firefox, dist/*.zip
```

- **Chrome / Edge / Brave:** open `chrome://extensions` (or `edge://extensions`), enable *Developer mode*, *Load unpacked*, choose `dist/chrome`.
- **Firefox:** open `about:debugging#/runtime/this-firefox`, *Load Temporary Add-on...*, choose `dist/firefox/manifest.json`
  (temporary add-ons vanish on restart). Firefox MV3 treats site access as user-granted: if numbers are not detected, allow
  "Access your data for all websites" for the add-on in `about:addons` > Permissions.
- Store submission later: upload `SoftphonePro-ClickToDial-chrome-<version>.zip` (Chrome Web Store / Edge Add-ons) and
  `SoftphonePro-ClickToDial-firefox-<version>.zip` (addons.mozilla.org). Gecko ID: `clicktodial@softphonepro.app`.

`EXT_VERSION=1.2.0-dev.7 npm run build` sets the zip name; the manifest gets the numeric `1.2.0` (Chrome also gets `version_name`).
`npm run icons` regenerates the PNG icons from `app/assets/branding/icon.svg` with `rsvg-convert`.

## Permissions (and why)

| Permission | Reason |
|---|---|
| `contextMenus` | the "Call selection" menu item |
| `storage` | your options and the last 20 dialled numbers (local to this browser profile) |
| `activeTab` | open the dial link in the tab where you used the context menu |
| host `<all_urls>` | **only** so the content script can run on pages and wrap phone numbers; page content is processed locally and never leaves the page. Use the site list to restrict it. |

No `tabs`, `history`, `cookies`, `webRequest` or network permissions. The build fails if the manifest asks for anything else.

## Privacy

No analytics, telemetry, tracking, accounts or remote code. The extension makes **no network requests**.
Page text is scanned locally in the page. Settings and recent numbers are stored in `storage.local` (never synced) and
only leave your browser when you click a number, in the form of a `tel:` / `sip:` / `softphonepro:` URL handled by your OS.

## Known limitations

- Numbers split across several elements (`<b>+44</b> 20 ...`) are not detected.
- Pages that fully re-render their own text with a framework can occasionally conflict with inserted spans; add such sites to the deny list.
- If the context-menu click cannot navigate the current tab (e.g. `chrome://` pages), the link opens in a new tab.
## Layout

```
src/phone.js      pure detection + normalisation (unit tested)
src/settings.js   settings + recents storage
src/content.js    DOM scanning, spans, link rewriting
src/background.js context menu
src/popup.*       toolbar popup           src/options.*  options page
scripts/build.js  build, manifest validation, zip (zero deps)
test/             node --test
```
