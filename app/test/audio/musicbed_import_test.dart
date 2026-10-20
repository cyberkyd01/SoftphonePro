import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/provisioning.dart';
import 'package:softphonepro/services/provisioning_import.dart';

void main() {
  test('policy: the file is forbidden, the rest follows the other audio settings', () {
    expect(classifyImportSetting('musicbedFile'), ImportClass.forbidden);
    for (final k in ['musicbedEnabled', 'musicbedVolume', 'musicbedMonitor', 'musicbedMonitorVolume']) {
      expect(classifyImportSetting(k), ImportClass.allowed, reason: k);
    }
    // Same class as the comparable hold-music settings.
    expect(classifyImportSetting('holdMusicVolume'), ImportClass.allowed);
    expect(classifyImportSetting('announceOpeningFile'), ImportClass.forbidden);
  });

  test('an untrusted import cannot set the musicbed file', () {
    final p = prepareUntrustedImport(
      const ProvisioningResult(settings: {'musicbedFile': '/etc/passwd', 'musicbedEnabled': true, 'musicbedVolume': 0.5, 'musicbedMonitor': true, 'musicbedMonitorVolume': 0.25}),
    );
    expect(p.refusedKey, isNull);
    expect(p.ignored, ['musicbedFile']);
    expect(p.safeSettings, {'musicbedEnabled': true, 'musicbedVolume': 0.5, 'musicbedMonitor': true, 'musicbedMonitorVolume': 0.25});
    final applied = const AppSettings().update(p.resolve(const ImportDecision()).settings);
    expect(applied.musicbedFile, '');
    expect(applied.musicbedEnabled, isTrue);
    expect(applied.musicbedVolume, 0.5);
    expect(applied.musicbedMonitorVolume, 0.25);
  });

  test('a library ref is not importable either', () {
    for (final v in ['lib:song.mp3', 'builtin:hold_calm', '']) {
      final p = prepareUntrustedImport(ProvisioningResult(settings: {'musicbedFile': v}));
      expect(p.safeSettings, isEmpty, reason: v);
      expect(p.ignored, ['musicbedFile'], reason: v);
    }
  });

  test('volumes outside the engine range and wrong types are ignored', () {
    final p = prepareUntrustedImport(
      const ProvisioningResult(settings: {'musicbedVolume': 3, 'musicbedMonitorVolume': -0.1, 'musicbedEnabled': 'yes', 'musicbedMonitor': 'on'}),
    );
    expect(p.ignored.toSet(), {'musicbedVolume', 'musicbedMonitorVolume', 'musicbedEnabled', 'musicbedMonitor'});
    expect(p.safeSettings, isEmpty);
    final edge = prepareUntrustedImport(const ProvisioningResult(settings: {'musicbedVolume': 2, 'musicbedMonitorVolume': 0}));
    expect(edge.safeSettings, {'musicbedVolume': 2, 'musicbedMonitorVolume': 0});
  });

  test('exports never carry the file path', () {
    expect(Provisioning.exportableSettings, isNot(contains('musicbedFile')));
    expect(Provisioning.exportableSettings, containsAll(['musicbedEnabled', 'musicbedVolume', 'musicbedMonitor', 'musicbedMonitorVolume']));
    final out = Provisioning.exportSettings({'musicbedFile': 'lib:a.mp3', 'musicbedVolume': 0.4});
    expect(out, {'musicbedVolume': 0.4});
  });

  test('AppSettings getters: defaults, values and wrong types', () {
    const d = AppSettings();
    expect([d.musicbedEnabled, d.musicbedFile, d.musicbedVolume, d.musicbedMonitor, d.musicbedMonitorVolume], [false, '', 0.3, false, 0.5]);
    final s = d.update({'musicbedEnabled': true, 'musicbedFile': 'lib:x.wav', 'musicbedVolume': 1, 'musicbedMonitor': true, 'musicbedMonitorVolume': 0.75});
    expect([s.musicbedEnabled, s.musicbedFile, s.musicbedVolume, s.musicbedMonitor, s.musicbedMonitorVolume], [true, 'lib:x.wav', 1.0, true, 0.75]);
    final j = AppSettings.fromJson(jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>);
    expect(j.musicbedFile, 'lib:x.wav');
    final bad = d.update({'musicbedEnabled': 'x', 'musicbedVolume': 'loud', 'musicbedFile': 5});
    expect([bad.musicbedEnabled, bad.musicbedVolume, bad.musicbedFile], [false, 0.3, '']);
  });
}
