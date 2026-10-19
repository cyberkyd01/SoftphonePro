/*
 * SoftphonePro Click-to-Dial: phone number detection + normalisation (pure, no DOM, no browser APIs).
 * Loaded as a classic script in the content script / popup / background, and via require() in tests.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
(function (root, factory) {
  'use strict';
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.SPPhone = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';

  // One separator between digit groups: space, dot, hyphen/dash, or parentheses (with optional space/dash).
  const SEP = '(?:[ \\u00a0]?\\(|\\)[ \\u00a0.\\-]?|[ \\u00a0.\\-\\u2010\\u2011\\u2013])';
  const CANDIDATE_SRC = '\\+?\\(?\\d+(?:' + SEP + '\\d+)*';
  const EXT_RE = /^[ \u00a0]?,?[ \u00a0]?(?:ext(?:ension|n)?\.?|x|#)[ \u00a0.:]{0,2}(\d{1,6})(?!\w)/i;
  const CURRENCY_AFTER_RE = /^[ \u00a0]?(?:€|\$|£|¥|%|USD|EUR|GBP|SEK|NOK|DKK|CHF|JPY|CAD|AUD|kr\b|dollars?\b|euros?\b|pounds?\b)/i;
  const CURRENCY_BEFORE_RE = /[$€£¥][ \u00a0]?$/;
  const ISBN_BEFORE_RE = /ISBN(?:[- ]?1[03])?[\s:]*$/i;

  /** '+44' / '44' / '0044' / ' +44 ' -> '+44'; anything invalid -> ''. */
  function normalizeCountryCode(v) {
    let s = String(v == null ? '' : v).trim().replace(/[^\d+]/g, '');
    if (s.startsWith('00')) s = '+' + s.slice(2);
    s = s.replace(/^\+/, '');
    return /^[1-9]\d{0,3}$/.test(s) ? '+' + s : '';
  }

  /**
   * Turn a raw phone string into a dialable number: '+<digits>' for international, otherwise digits only.
   * defaultCountry (e.g. '+44') is prefixed to national numbers (and their single trunk '0' dropped).
   * Returns '' when there are no digits.
   */
  function normalizeNumber(raw, defaultCountry) {
    let s = String(raw == null ? '' : raw).trim();
    const plus = s.startsWith('+');
    if (plus) s = s.replace(/\(\s*0\s*\)/g, ''); // "+44 (0)20 ..." trunk zero
    let d = s.replace(/\D/g, '');
    if (!d) return '';
    if (plus) return '+' + d;
    if (d.startsWith('00')) return '+' + d.slice(2);
    const cc = normalizeCountryCode(defaultCountry);
    if (!cc) return d;
    if (cc === '+1') {
      if (d.length === 11 && d[0] === '1') return '+' + d; // already includes the NANP country code
      return cc + d;
    }
    if (d.startsWith('0') && cc !== '+39') d = d.slice(1); // Italy keeps the leading 0
    return cc + d;
  }

  function luhn(digits) {
    let sum = 0;
    let dbl = false;
    for (let i = digits.length - 1; i >= 0; i--) {
      let n = digits.charCodeAt(i) - 48;
      if (dbl) { n *= 2; if (n > 9) n -= 9; }
      sum += n;
      dbl = !dbl;
    }
    return sum % 10 === 0;
  }

  /** Decide whether a candidate (no extension) is a plausible phone number. */
  function plausible(cand) {
    const hasPlus = cand.startsWith('+');
    let c = cand;
    if (hasPlus) c = c.replace(/\(\s*0\s*\)/g, '');
    const digits = c.replace(/\D/g, '');
    const len = digits.length;
    const groups = c.split(/\D+/).filter(Boolean);
    const intl00 = !hasPlus && digits.startsWith('00');
    const trunk0 = !hasPlus && !intl00 && digits.startsWith('0');

    if (len < 7) return false;
    if (/^(\d)\1+$/.test(digits)) return false;
    if (hasPlus) { if (len > 15) return false; }
    else if (intl00) { if (len > 17) return false; }
    else if (trunk0) { if (len > 13) return false; }
    else if (len > 12) return false;

    if (groups.length === 1) {
      if (hasPlus) return true;
      if (intl00) return len >= 10;
      if (trunk0) return len >= 8;
      if (len === 10 && digits[0] === '1') return false; // epoch-like, invalid NANP area code
      return len === 10 || len === 11;
    }

    // Separated numbers: need at least two groups of 2+ digits ("1.5 2.5 3.5 4.5" is not a phone).
    if (groups.filter((g) => g.length >= 2).length < 2) return false;
    const plain = c.replace(/[()]/g, '');
    if (/^\d{4}[-. ]\d{1,2}[-. ]\d{1,2}$/.test(plain)) return false; // ISO-ish date
    if (/^\d{1,2}[-. ]\d{1,2}[-. ]\d{2,4}$/.test(plain)) return false; // dd-mm-yyyy
    if (/^(19|20)\d\d[ \-\u2010\u2011\u2013](19|20)\d\d$/.test(plain)) return false; // year range
    if (/^\d{3}-\d{2}-\d{4}$/.test(plain)) return false; // SSN
    if (/^\d{5}-\d{4}$/.test(plain)) return false; // ZIP+4
    if (/^\d{1,3}(\.\d{1,3}){3}$/.test(plain)) return false; // IPv4
    if (/^\d{1,5}-\d{1,7}-\d{1,7}-\d$/.test(plain)) return false; // ISBN-10
    if (!hasPlus && len === 13 && /^97[89]/.test(digits)) return false; // ISBN-13
    if (/^[\d.]+$/.test(plain) && (groups.length === 2 || groups.some((g) => g.length === 1))) return false; // decimals / versions
    if (!hasPlus && !intl00 && !trunk0) {
      if (groups.length >= 3 && groups.every((g) => g.length === 4)) return false; // card / IBAN-like
      if (/^\d{1,3}( \d{3}){2,}$/.test(plain)) return false; // "1 234 567" thousands
    }
    if (!hasPlus && len >= 13 && luhn(digits)) return false; // credit-card-like
    return true;
  }

  /**
   * Find phone numbers in plain text.
   * Returns [{start, end, text, candidate, ext}] where text = text.slice(start, end) (includes any extension),
   * candidate = the number part only (feed it to normalizeNumber).
   */
  function findPhoneNumbers(text) {
    const out = [];
    if (typeof text !== 'string' || text.length < 7) return out;
    const re = new RegExp(CANDIDATE_SRC, 'g');
    let m;
    while ((m = re.exec(text))) {
      let start = m.index;
      const candEnd = start + m[0].length;
      let cand = m[0];
      if (cand[0] === '(' && !cand.includes(')')) { cand = cand.slice(1); start += 1; } // unbalanced "(" is prose
      const before = text.slice(Math.max(0, start - 24), start);
      const prev = start > 0 ? text[start - 1] : '';

      if (/[A-Za-z0-9_@\/$€£¥%#=\\]/.test(prev)) continue;
      if ((prev === '-' || prev === '\u2013' || prev === '.') && start > 1 && /\w/.test(text[start - 2])) continue;
      if (CURRENCY_BEFORE_RE.test(before)) continue;
      if (ISBN_BEFORE_RE.test(before)) continue;

      let end = candEnd;
      let ext = '';
      const em = EXT_RE.exec(text.slice(candEnd, candEnd + 24));
      if (em) { ext = em[1]; end = candEnd + em[0].length; }

      const next = end < text.length ? text[end] : '';
      const after = text.slice(end, end + 14);
      if (/[A-Za-z0-9_@%\/]/.test(next)) continue;
      if (/^[:.,]\d/.test(after)) continue; // times, decimals
      if (CURRENCY_AFTER_RE.test(after)) continue;
      if (!plausible(cand)) continue;

      // "(+44) 20 7946 0958": keep the opening parenthesis inside the match so the markup stays balanced.
      let from = start;
      if (cand[0] === '+' && prev === '(' && cand.includes(')')) from = start - 1;
      out.push({ start: from, end, text: text.slice(from, end), candidate: cand, ext });
      re.lastIndex = end;
    }
    return out;
  }

  /**
   * Best dialable number for a user selection / typed text, or '' if none.
   * Tries strict detection first, then falls back to a lenient "looks like a phone number" check.
   */
  function extractNumber(text, opts) {
    const cc = opts && opts.defaultCountry;
    const s = String(text == null ? '' : text).trim();
    if (!s) return { number: '', ext: '' };
    const found = findPhoneNumbers(s);
    if (found.length) return { number: normalizeNumber(found[0].candidate, cc), ext: found[0].ext };
    if (/^[+\d\s().\-\u2010\u2011\u2013*#]{3,32}$/.test(s) && /\d{3,}/.test(s.replace(/\D/g, ''))) {
      return { number: normalizeNumber(s.replace(/[*#]/g, ''), cc), ext: '' };
    }
    return { number: '', ext: '' };
  }

  /** Build the URL that hands a number to the dialer. scheme: 'tel' | 'sip' | 'softphonepro'. */
  function buildDialUrl(number, scheme, ext) {
    const n = String(number == null ? '' : number).trim();
    if (scheme === 'softphonepro') return 'softphonepro://call?number=' + encodeURIComponent(n);
    if (scheme === 'sip') return 'sip:' + encodeURI(n);
    return 'tel:' + encodeURI(n) + (ext ? ';ext=' + encodeURIComponent(ext) : '');
  }

  /**
   * Parse an existing tel:/sip:/sips:/callto: href. Returns {target, ext} or null.
   * target is a normalised number, or user@host for non-numeric SIP addresses.
   */
  function parsePhoneHref(href, defaultCountry) {
    const m = /^(tel|sips?|callto):(.*)$/is.exec(String(href == null ? '' : href).trim());
    if (!m) return null;
    const scheme = m[1].toLowerCase();
    let rest = m[2].replace(/^\/\//, '').split('?')[0];
    let ext = '';
    const em = /;ext=(\d{1,6})/i.exec(rest);
    if (em) ext = em[1];
    rest = rest.split(';')[0];
    try { rest = decodeURIComponent(rest); } catch (_) { /* keep raw */ }
    rest = rest.trim();
    if (!rest) return null;
    const user = scheme === 'tel' ? rest : rest.split('@')[0];
    if (/^[+\d\s().\-]+$/.test(user) && /\d/.test(user)) {
      const digits = user.replace(/\D/g, '');
      const n = digits.length >= 7 ? normalizeNumber(user, defaultCountry) : normalizeNumber(user, '');
      return n ? { target: n, ext } : null;
    }
    if (scheme === 'tel') return null;
    return /^[^\s@]+(@[^\s@]+)?$/.test(rest) ? { target: rest, ext } : null;
  }

  function normalizeSiteEntry(entry) {
    let s = String(entry == null ? '' : entry).trim().toLowerCase();
    if (!s || s.startsWith('#')) return '';
    s = s.replace(/^[a-z][a-z0-9+.-]*:\/\//, '').replace(/^\*\./, '').replace(/^www\./, '');
    s = s.split(/[\/?#]/)[0].replace(/:\d+$/, '').replace(/\.$/, '');
    return /^[a-z0-9.-]+$/.test(s) ? s : '';
  }

  /** Textarea / array -> de-duplicated list of bare hostnames. */
  function parseSiteList(input) {
    const lines = Array.isArray(input) ? input : String(input == null ? '' : input).split(/[\n,;]+/).filter((l) => !l.trim().startsWith('#'));
    const out = [];
    for (const l of lines) {
      const s = normalizeSiteEntry(l);
      if (s && !out.includes(s)) out.push(s);
    }
    return out;
  }

  /** mode 'deny' = run everywhere except the list; 'allow' = run only on the list. */
  function siteAllowed(hostname, mode, list) {
    const host = String(hostname || '').toLowerCase().replace(/^www\./, '');
    const entries = parseSiteList(list || []);
    const hit = entries.some((e) => host === e || host.endsWith('.' + e));
    return mode === 'allow' ? hit : !hit;
  }

  return { normalizeCountryCode, normalizeNumber, findPhoneNumbers, extractNumber, buildDialUrl, parsePhoneHref, parseSiteList, siteAllowed };
});
