import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/recordings/recording_formats.dart';
import 'package:softphonepro/recordings/recording_rules.dart';
import 'package:spcore_dart/spcore_dart.dart';
import 'package:softphonepro/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;

final _l = lookupAppLocalizations(const Locale('en'));

AccountProfile acc(String autoRecord) => AccountProfile(
  id: 'a',
  config: const AccountConfig(uid: 'a', username: '1', password: 'p', domain: 'd'),
  autoRecord: autoRecord,
);

void main() {
  bool rec(
    String rule, {
    String account = 'inherit',
    bool contact = false,
    CallDirection dir = CallDirection.incoming,
    Map<String, dynamic> extra = const {},
  }) => shouldAutoRecord(
    settings: AppSettings({'recordRule': rule, ...extra}),
    profile: acc(account),
    contact: contact ? const Contact(id: 'c', name: 'C', autoRecord: true) : null,
    direction: dir,
  );

  test('global rule: off / all / incoming / outgoing', () {
    expect(rec('off'), isFalse);
    expect(rec('all'), isTrue);
    expect(rec('incoming'), isTrue);
    expect(rec('incoming', dir: CallDirection.outgoing), isFalse);
    expect(rec('outgoing', dir: CallDirection.outgoing), isTrue);
    expect(rec('outgoing'), isFalse);
  });

  test('legacy autoRecord switch still means "all calls"', () {
    expect(const AppSettings({'autoRecord': true}).recordRule, 'all');
    expect(const AppSettings().recordRule, 'off');
    expect(const AppSettings({'autoRecord': true, 'recordRule': 'incoming'}).recordRule, 'incoming');
  });

  test('per-account override beats the global rule; never wins over everything but the contact', () {
    expect(rec('off', account: 'always'), isTrue);
    expect(rec('all', account: 'never'), isFalse);
    expect(rec('off', account: 'outgoing', dir: CallDirection.outgoing), isTrue);
    expect(rec('off', account: 'outgoing'), isFalse);
    expect(rec('all', account: 'incoming', dir: CallDirection.outgoing), isFalse);
  });

  test('per-contact "always record" overrides everything', () {
    expect(rec('off', contact: true), isTrue);
    expect(rec('all', account: 'never', contact: true), isTrue);
  });

  test('formats: labels, extensions, playability per platform', () {
    expect(recordFormatLabel(_l, RecordFormat.wav), 'Standard (WAV)');
    expect(recordFormatLabel(_l, RecordFormat.wavStereo), contains('separate channels'));
    expect(recordFormatLabel(_l, RecordFormat.opus), 'Compressed (Opus)');
    expect(recordFormatExtension(RecordFormat.opus), 'ogg');
    expect(recordFormatExtension(RecordFormat.wavStereo), 'wav');
    expect(recordFormatBadge('opus'), 'Opus');
    expect(recordFormatBadge('wavStereo'), 'WAV stereo');
    for (final p in TargetPlatform.values) {
      expect(canPlayInApp('wav', p), isTrue);
      expect(canPlayInApp('wavStereo', p), isTrue);
    }
    expect(canPlayInApp('opus', TargetPlatform.android), isTrue);
    expect(canPlayInApp('opus', TargetPlatform.linux), isTrue);
    expect(canPlayInApp('opus', TargetPlatform.iOS), isFalse);
    expect(canPlayInApp('opus', TargetPlatform.macOS), isFalse);
    expect(canPlayInApp('opus', TargetPlatform.windows), isFalse);
    expect(formatBytes(0), '0 B');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(5 * 1024 * 1024), '5.0 MB');
  });
}
