import 'package:flutter/foundation.dart';

/// A native (non-Dart) component that is compiled into or shipped with the
/// app. Flutter's own `LicenseRegistry` already lists the Flutter engine and
/// every pub package; these entries add the C libraries bundled in the `spcore`
/// call engine and the assets. The same list is in THIRD_PARTY_NOTICES.md.
class NativeNotice {
  const NativeNotice(this.name, this.version, this.license, this.purpose, this.url, this.text);
  final String name;
  final String version;

  /// Short licence name (SPDX style).
  final String license;
  final String purpose;
  final String url;

  /// Licence notice shown on the licence page.
  final String text;
}

const _bsdTail = '''Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

- Neither the name of the copyright holders nor the names of specific contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.''';

const _gplNote = 'Licensed under the GNU General Public License. SoftphonePro is distributed under the GNU General Public License version 3 or later, which includes this component. The complete corresponding source code is in the project repository (https://github.com/cyberkyd01/SoftphonePro), and the full licence text is in its LICENSE file.';

const kNativeNotices = <NativeNotice>[
  NativeNotice(
    'PJSIP',
    '2.17',
    'GPL-2.0-or-later',
    'SIP, media and NAT traversal stack',
    'https://www.pjsip.org/',
    'Copyright (C) 2008-2024 Teluu Inc. (http://www.teluu.com), copyright (C) 2003-2008 Benny Prijono, and contributors.\n\nPJSIP (pjproject 2.17) is free software under the GNU General Public License version 2 or later. $_gplNote\n\nPJSIP bundles these libraries: libsrtp 2.5.0 (BSD-3-Clause, Cisco Systems), Speex (BSD-3-Clause, Xiph.Org), GSM 06.10 (permissive, TU Berlin), iLBC (RFC 3951, IETF Trust), G.722.1 (ITU-T reference code, Polycom, royalty-free), libresample (LGPL-2.1+) and the WebRTC audio processing and AEC3 code (BSD-3-Clause, The WebRTC project authors).',
  ),
  NativeNotice(
    'OpenSSL',
    '3.5.9',
    'Apache-2.0',
    'TLS, SRTP key handling and cryptography',
    'https://www.openssl.org/',
    'Copyright The OpenSSL Project Authors.\n\nLicensed under the Apache License, Version 2.0 (the "License"); you may not use this software except in compliance with the License. You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.',
  ),
  NativeNotice(
    'Opus',
    '1.6.1',
    'BSD-3-Clause',
    'Opus audio codec and Ogg Opus recording',
    'https://opus-codec.org/',
    'Copyright 2001-2023 Xiph.Org, Skype Limited, Octasic, Jean-Marc Valin, Timothy B. Terriberry, CSIRO, Gregory Maxwell, Mark Borgerding, Erik de Castro Lopo, Mozilla, Amazon.\n\n$_bsdTail\n\nOpus is subject to the royalty-free patent licences specified at https://datatracker.ietf.org/ipr/1524/ (Xiph.Org), https://datatracker.ietf.org/ipr/1914/ (Microsoft) and https://datatracker.ietf.org/ipr/1526/ (Broadcom).',
  ),
  NativeNotice(
    'bcg729',
    '1.1.2',
    'GPL-3.0-or-later',
    'G.729 audio codec',
    'https://github.com/BelledonneCommunications/bcg729',
    'Copyright (c) 2011-2019 Belledonne Communications SARL.\n\nbcg729 is free software under the GNU General Public License version 3 or later. $_gplNote',
  ),
  NativeNotice(
    'RNNoise',
    '0.1.1',
    'BSD-3-Clause',
    'Voice isolation (AI noise cancellation)',
    'https://github.com/xiph/rnnoise',
    'Copyright (c) 2017, Mozilla\nCopyright (c) 2007-2017, Jean-Marc Valin\nCopyright (c) 2005-2017, Xiph.Org Foundation\nCopyright (c) 2003-2004, Mark Borgerding\n\n$_bsdTail',
  ),
  NativeNotice(
    'minimp3',
    'ea99364',
    'CC0-1.0',
    'MP3 decoding for hold music and announcements',
    'https://github.com/lieff/minimp3',
    'minimp3 is dedicated to the public domain under CC0 1.0 Universal (https://creativecommons.org/publicdomain/zero/1.0/). The author waives all copyright and related rights to the extent permitted by law.',
  ),
  NativeNotice(
    'cJSON',
    '1.7.18',
    'MIT',
    'JSON handling in the call engine',
    'https://github.com/DaveGamble/cJSON',
    'Copyright (c) 2009-2017 Dave Gamble and cJSON contributors\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
  ),
  NativeNotice(
    'Dart native API (dart_api_dl)',
    '',
    'BSD-3-Clause',
    'Bridge between the call engine and Dart',
    'https://github.com/dart-lang/sdk',
    'Copyright (c) 2020, the Dart project authors. All rights reserved.\n\n$_bsdTail',
  ),
  NativeNotice(
    'Mozilla CA certificate bundle',
    '2026-10-19',
    'MPL-2.0',
    'Trusted root certificates for TLS',
    'https://curl.se/docs/caextract.html',
    'The bundle of root certificates (as extracted by the curl project from Mozilla\'s certificate store) is licensed under the Mozilla Public License 2.0. The licence text is at https://www.mozilla.org/MPL/2.0/ and the source of the bundle is https://curl.se/ca/cacert.pem.',
  ),
  NativeNotice(
    'Inter typeface',
    '',
    'OFL-1.1',
    'App font',
    'https://github.com/rsms/inter',
    'Copyright (c) 2016 The Inter Project Authors (https://github.com/rsms/inter)\n\nThis Font Software is licensed under the SIL Open Font License, Version 1.1. The licence and FAQ are at https://openfontlicense.org. The licence text is also shipped with the app as assets/fonts/Inter-LICENSE.txt.',
  ),
];

/// The licence entries for [kNativeNotices], one per component.
List<LicenseEntry> nativeLicenseEntries() => [
  for (final n in kNativeNotices)
    LicenseEntryWithLineBreaks([n.version.isEmpty ? n.name : '${n.name} ${n.version}'], '${n.license}\n${n.url}\n\n${n.text}'),
];

bool _registered = false;

/// Adds the native components to Flutter's licence page (shown by
/// `showLicensePage`). Safe to call more than once; [force] registers again
/// (tests that reset the registry).
void registerNativeLicenses({bool force = false}) {
  if (_registered && !force) return;
  _registered = true;
  LicenseRegistry.addLicense(() => Stream<LicenseEntry>.fromIterable(nativeLicenseEntries()));
}
