import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_controller.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Localisation conventions
///
/// * Widgets: `context.l10n.someKey`.
/// * Non-widget code (controllers, services, notification texts): read the
///   [l10nProvider] (`ref.read(l10nProvider)`) at the moment the text is
///   produced, so it follows the current `language` setting. Pure helpers take
///   an [AppLocalizations] parameter.
/// * Never localised: the product name, SIP tokens, codec / header names, log
///   and trace contents and raw technical identifiers.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// A language the app can be shown in: settings code, native name, locale.
class AppLanguage {
  const AppLanguage(this.code, this.nativeName, this.locale);
  final String code;
  final String nativeName;
  final Locale locale;
}

/// Languages in picker order (by native name; English first). The native names
/// are intentionally not translated so users can always find their language.
const List<AppLanguage> kAppLanguages = [
  AppLanguage('en', 'English', Locale('en')),
  AppLanguage('ar', 'العربية', Locale('ar')),
  AppLanguage('de', 'Deutsch', Locale('de')),
  AppLanguage('es', 'Español', Locale('es')),
  AppLanguage('fr', 'Français', Locale('fr')),
  AppLanguage('hi', 'हिन्दी', Locale('hi')),
  AppLanguage('it', 'Italiano', Locale('it')),
  AppLanguage('nl', 'Nederlands', Locale('nl')),
  AppLanguage('pt_BR', 'Português (Brasil)', Locale('pt', 'BR')),
  AppLanguage('ru', 'Русский', Locale('ru')),
  AppLanguage('tr', 'Türkçe', Locale('tr')),
  AppLanguage('ja', '日本語', Locale('ja')),
  AppLanguage('zh', '简体中文', Locale('zh')),
];

const String kSystemLanguage = 'system';

/// Locale for a `language` setting; null = follow the system.
Locale? localeForSetting(String code) {
  for (final l in kAppLanguages) {
    if (l.code == code) return l.locale;
  }
  return null;
}

/// Resolves the effective locale for [setting] given the system locales.
Locale resolveLocale(String setting, List<Locale> systemLocales) {
  final explicit = localeForSetting(setting);
  if (explicit != null) return explicit;
  // English first: with no match (an unsupported language, or the C/POSIX
  // locale of a minimal Linux session) the first entry is used.
  const en = Locale('en');
  final supported = [en, ...AppLocalizations.supportedLocales.where((l) => l != en)];
  return basicLocaleListResolution(systemLocales, supported);
}

/// Locale list of the platform; updated by the app root on locale changes.
class SystemLocalesNotifier extends Notifier<List<Locale>> {
  @override
  List<Locale> build() => _platformLocales();
  void refresh() => state = _platformLocales();

  /// Uses the binding's dispatcher (overridable in widget tests); falls back
  /// to the real one when no binding exists (pure-Dart tests).
  static List<Locale> _platformLocales() {
    try {
      return WidgetsBinding.instance.platformDispatcher.locales;
    } catch (_) {
      return ui.PlatformDispatcher.instance.locales;
    }
  }
}

final systemLocalesProvider = NotifierProvider<SystemLocalesNotifier, List<Locale>>(SystemLocalesNotifier.new);

/// The locale currently in effect (setting, else system, else English).
final appLocaleProvider = Provider<Locale>((ref) {
  final lang = ref.watch(settingsProvider.select((s) => s.language));
  return resolveLocale(lang, ref.watch(systemLocalesProvider));
});

/// Strings for non-widget code; follows the language setting live.
final l10nProvider = Provider<AppLocalizations>((ref) => lookupAppLocalizations(ref.watch(appLocaleProvider)));
