import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/ui/router.dart';

import '../harness.dart';

/// Layout-only goldens (test fonts render as boxes) for an RTL language and a
/// language with long strings, at phone size. Reviewed by eye for truncation.
void main() {
  // The comparison is only meaningful on the platform that generated them.
  final enabled = Platform.isMacOS;
  for (final lang in ['ar', 'de']) {
    for (final shot in {
      'keypad': '/keypad',
      'recents': '/recents',
      'more': '/more',
      'settings_calls': '/settings/calls',
      'settings_audio': '/settings/audio',
      'settings_appearance': '/settings/appearance',
      'in_call': '/call',
    }.entries) {
      testWidgets('golden ${shot.key} ($lang)', (t) async {
        final env = await TestEnv.create(
          profiles: [testProfile(), testProfile(id: 'acc2', user: '1002')],
          settings: AppSettings({'onboardingDone': true, 'language': lang}),
          contacts: const [
            Contact(id: 'c1', name: 'Alice Johnson', numbers: [ContactNumber(label: 'work', value: '2002')]),
          ],
        );
        t.view.physicalSize = const Size(412, 915) * 2;
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        await t.pumpWidget(env.app());
        await settle(t, env.engine);
        await waitRegistered(t, env);
        if (shot.key == 'in_call') {
          await containerOf(t).read(callsProvider.notifier).dial('2002');
          await settle(t, env.engine);
        }
        containerOf(t).read(routerProvider).go(shot.value);
        for (var i = 0; i < 4; i++) {
          await t.pump(const Duration(milliseconds: 200));
        }
        await settle(t, env.engine);
        await t.pump(const Duration(milliseconds: 300));
        if (enabled) {
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('../goldens/l10n_${lang}_${shot.key}.png'));
        }
      });
    }
  }
}
