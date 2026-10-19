import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import 'providers.dart';

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(bootDataProvider).settings;

  Future<void> update(Map<String, dynamic> changes) async {
    state = state.update(changes);
    await ref.read(settingsRepoProvider).save(state);
  }

  Future<void> replaceAll(AppSettings s) async {
    state = s;
    await ref.read(settingsRepoProvider).save(state);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
