'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const P = require('../src/phone.js');
const S = require('../src/settings.js');

const found = (t) => P.findPhoneNumbers(t).map((m) => m.text);
const norm = (t, cc) => {
  const f = P.findPhoneNumbers(t);
  return f.length ? P.normalizeNumber(f[0].candidate, cc) : null;
};

// ---- Positives: detection + normalisation ---------------------------------------------------
const POSITIVES = [
  ['Call +44 20 7946 0958 today', '+44 20 7946 0958', '+442079460958'],
  ['+1 (555) 123-4567', '+1 (555) 123-4567', '+15551234567'],
  ['Tel: +1-555-123-4567.', '+1-555-123-4567', '+15551234567'],
  ['+49 (0)30 123456', '+49 (0)30 123456', '+4930123456'],
  ['Phone +33 1 23 45 67 89!', '+33 1 23 45 67 89', '+33123456789'],
  ['0044 20 7946 0958', '0044 20 7946 0958', '+442079460958'],
  ['+442079460958', '+442079460958', '+442079460958'],
  ['(555) 123-4567', '(555) 123-4567', '5551234567'],
  ['555.123.4567', '555.123.4567', '5551234567'],
  ['555-1234', '555-1234', '5551234'],
  ['5551234567', '5551234567', '5551234567'],
  ['07911 123456', '07911 123456', '07911123456'],
  ['(call 020 7946 0958)', '020 7946 0958', '02079460958'],
  ['+61 412 345 678', '+61 412 345 678', '+61412345678'],
  ['Hotline: 1-800-555-0199', '1-800-555-0199', '18005550199'],
  ['01.23.45.67.89', '01.23.45.67.89', '0123456789'],
];
for (const [input, expText, expNum] of POSITIVES) {
  test(`detects ${JSON.stringify(input)}`, () => {
    assert.deepEqual(found(input), [expText]);
    assert.equal(norm(input), expNum);
  });
}

test('extension: ext. / x / extension', () => {
  const a = P.findPhoneNumbers('555-123-4567 ext. 89');
  assert.equal(a.length, 1);
  assert.equal(a[0].ext, '89');
  assert.equal(a[0].text, '555-123-4567 ext. 89');
  assert.equal(a[0].candidate, '555-123-4567');
  assert.equal(P.findPhoneNumbers('+44 20 7946 0958 x1234')[0].ext, '1234');
  assert.equal(P.findPhoneNumbers('555-123-4567, extension: 12.')[0].ext, '12');
  assert.equal(P.findPhoneNumbers('555-123-4567 extra info')[0].ext, '');
});

test('multiple numbers in one text keep order and offsets', () => {
  const t = 'Sales +44 20 7946 0958, support 0800 123 4567.';
  const r = P.findPhoneNumbers(t);
  assert.equal(r.length, 2);
  assert.equal(t.slice(r[0].start, r[0].end), '+44 20 7946 0958');
  assert.equal(t.slice(r[1].start, r[1].end), '0800 123 4567');
});

test('trailing punctuation is not part of the match', () => {
  assert.deepEqual(found('Ring 555-123-4567, then wait'), ['555-123-4567']);
  assert.deepEqual(found('Ring 555-123-4567.'), ['555-123-4567']);
  assert.deepEqual(found('(555-123-4567)'), ['555-123-4567']);
});

// ---- Negatives ------------------------------------------------------------------------------
const NEGATIVES = [
  ['ISO date', 'Released 2024-05-12 here'],
  ['dd/mm/yyyy', 'Due 12/05/2024'],
  ['dd-mm-yyyy', 'Due 12-05-2024'],
  ['dd.mm.yyyy', 'Due 12.05.2024'],
  ['year range', 'Years 2020-2021'],
  ['IPv4', 'Host 192.168.100.100 up'],
  ['price with symbol', 'Only $1234567 now'],
  ['price spaced symbol', 'Only € 1 234 567'],
  ['price with currency word', 'Cost 1 234 567 USD'],
  ['decimal price', 'Total 1234567.89'],
  ['ISBN-13', 'ISBN 978-3-16-148410-0'],
  ['ISBN-10', 'ISBN 0-306-40615-2'],
  ['credit card 16 digits', 'Card 4111 1111 1111 1111'],
  ['Amex-like Luhn', 'Card 3782 822463 10005'],
  ['4-4-4 groups', 'IBAN 1234 5678 9012'],
  ['long digit run', 'Serial 123456789012345678'],
  ['word-attached', 'ABC1234567'],
  ['email local part', 'john1234567@example.com'],
  ['URL path', 'see /products/12345678'],
  ['hash id', 'Order #12345678'],
  ['query id', 'id=1234567890'],
  ['SSN', 'SSN 123-45-6789'],
  ['ZIP+4', 'ZIP 12345-6789'],
  ['version string', 'Version 10.0.19045.1234'],
  ['decimal list', 'Values 1.5 2.5 3.5 4.5'],
  ['pi', 'pi = 3.14159265'],
  ['too short', 'Room 12345'],
  ['thousands commas', 'Population 1,234,567'],
  ['epoch timestamp', 'ts 1700000000'],
  ['same digits', 'Code 0000000000'],
  ['9 unseparated', 'Ref 123456789'],
  ['time', 'At 10:30:45 sharp'],
  ['percentage', 'Up 1234567%'],
];
for (const [name, input] of NEGATIVES) {
  test(`ignores ${name}`, () => assert.deepEqual(found(input), []));
}

// ---- normalizeNumber ------------------------------------------------------------------------
test('normalizeNumber: default country prefix', () => {
  assert.equal(P.normalizeNumber('020 7946 0958', '+44'), '+442079460958');
  assert.equal(P.normalizeNumber('020 7946 0958', '44'), '+442079460958');
  assert.equal(P.normalizeNumber('020 7946 0958', ''), '02079460958');
  assert.equal(P.normalizeNumber('(555) 123-4567', '+1'), '+15551234567');
  assert.equal(P.normalizeNumber('1 (555) 123-4567', '+1'), '+15551234567');
  assert.equal(P.normalizeNumber('06 12 34 56 78', '+33'), '+33612345678');
  assert.equal(P.normalizeNumber('06 1234 5678', '+39'), '+390612345678');
});
test('normalizeNumber: international numbers are never re-prefixed', () => {
  assert.equal(P.normalizeNumber('+49 (0)30 123456', '+44'), '+4930123456');
  assert.equal(P.normalizeNumber('0049 30 123456', '+44'), '+4930123456');
});
test('normalizeNumber: junk', () => {
  assert.equal(P.normalizeNumber('', '+44'), '');
  assert.equal(P.normalizeNumber('abc', '+44'), '');
  assert.equal(P.normalizeNumber(null), '');
});
test('normalizeCountryCode', () => {
  assert.equal(P.normalizeCountryCode('+44'), '+44');
  assert.equal(P.normalizeCountryCode(' 44 '), '+44');
  assert.equal(P.normalizeCountryCode('0044'), '+44');
  assert.equal(P.normalizeCountryCode('+0'), '');
  assert.equal(P.normalizeCountryCode('+12345'), '');
  assert.equal(P.normalizeCountryCode('abc'), '');
});

// ---- extractNumber (selection / popup) ------------------------------------------------------
test('extractNumber', () => {
  assert.deepEqual(P.extractNumber('  +44 20 7946 0958 ext 5 '), { number: '+442079460958', ext: '5' });
  assert.deepEqual(P.extractNumber('call me on 555-123-4567 please', { defaultCountry: '+1' }), { number: '+15551234567', ext: '' });
  assert.deepEqual(P.extractNumber('112'), { number: '112', ext: '' }); // typed short codes dial as-is
  assert.deepEqual(P.extractNumber('12345'), { number: '12345', ext: '' }); // lenient fallback for typed input
  assert.deepEqual(P.extractNumber('hello world'), { number: '', ext: '' });
  assert.deepEqual(P.extractNumber(''), { number: '', ext: '' });
});

// ---- buildDialUrl ---------------------------------------------------------------------------
test('buildDialUrl', () => {
  assert.equal(P.buildDialUrl('+442079460958', 'tel'), 'tel:+442079460958');
  assert.equal(P.buildDialUrl('+442079460958', 'tel', '12'), 'tel:+442079460958;ext=12');
  assert.equal(P.buildDialUrl('+442079460958', 'sip'), 'sip:+442079460958');
  assert.equal(P.buildDialUrl('+442079460958', 'softphonepro'), 'softphonepro://call?number=%2B442079460958');
  assert.equal(P.buildDialUrl('5551234', 'bogus'), 'tel:5551234');
});

// ---- parsePhoneHref -------------------------------------------------------------------------
test('parsePhoneHref', () => {
  assert.deepEqual(P.parsePhoneHref('tel:+44-20-7946-0958'), { target: '+442079460958', ext: '' });
  assert.deepEqual(P.parsePhoneHref('tel:+442079460958;ext=7'), { target: '+442079460958', ext: '7' });
  assert.deepEqual(P.parsePhoneHref('tel:020%207946%200958', '+44'), { target: '+442079460958', ext: '' });
  assert.deepEqual(P.parsePhoneHref('sip:+15551234567@pbx.example.com'), { target: '+15551234567', ext: '' });
  assert.deepEqual(P.parsePhoneHref('sips:alice@example.com'), { target: 'alice@example.com', ext: '' });
  assert.deepEqual(P.parsePhoneHref('callto:+15551234567'), { target: '+15551234567', ext: '' });
  assert.deepEqual(P.parsePhoneHref('tel:100', '+44'), { target: '100', ext: '' }); // short codes are untouched
  assert.equal(P.parsePhoneHref('https://example.com'), null);
  assert.equal(P.parsePhoneHref('tel:'), null);
  assert.equal(P.parsePhoneHref('tel:abc'), null);
});

// ---- site allow / deny ----------------------------------------------------------------------
test('parseSiteList', () => {
  assert.deepEqual(P.parseSiteList('Example.com\nhttps://www.foo.org/path\n*.bar.net, example.com\n# note\n\n'), ['example.com', 'foo.org', 'bar.net']);
  assert.deepEqual(P.parseSiteList(['a.com:8080', 'bad host!']), ['a.com']);
});
test('siteAllowed deny mode', () => {
  assert.equal(P.siteAllowed('example.com', 'deny', ['bank.com']), true);
  assert.equal(P.siteAllowed('www.bank.com', 'deny', ['bank.com']), false);
  assert.equal(P.siteAllowed('login.bank.com', 'deny', ['bank.com']), false);
  assert.equal(P.siteAllowed('notbank.com', 'deny', ['bank.com']), true);
});
test('siteAllowed allow mode', () => {
  assert.equal(P.siteAllowed('crm.example.com', 'allow', ['example.com']), true);
  assert.equal(P.siteAllowed('other.com', 'allow', ['example.com']), false);
  assert.equal(P.siteAllowed('other.com', 'allow', []), false);
});

// ---- settings -------------------------------------------------------------------------------
test('settings.sanitize', () => {
  assert.deepEqual(S.sanitize(undefined), { enabled: true, scheme: 'tel', defaultCountry: '', openAll: false, siteMode: 'deny', siteList: [] });
  const s = S.sanitize({ enabled: false, scheme: 'evil', defaultCountry: '44', openAll: 1, siteMode: 'allow', siteList: 'a.com\nb.com' });
  assert.deepEqual(s, { enabled: false, scheme: 'tel', defaultCountry: '+44', openAll: true, siteMode: 'allow', siteList: ['a.com', 'b.com'] });
});
test('settings.pushRecent: dedupe, newest first, max 20', () => {
  let l = [];
  for (let i = 0; i < 25; i++) l = S.pushRecent(l, '+4400000' + String(i).padStart(2, '0'), i);
  assert.equal(l.length, 20);
  assert.equal(l[0].number, '+440000024');
  l = S.pushRecent(l, '+440000010', 99);
  assert.equal(l[0].number, '+440000010');
  assert.equal(l.filter((r) => r.number === '+440000010').length, 1);
  assert.equal(l.length, 20);
});
