import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../services/accounts_controller.dart';
import '../services/engine_controller.dart';
import '../services/settings_controller.dart';

class SystemInfo {
  const SystemInfo({
    required this.appVersion,
    required this.platform,
    required this.engineState,
    required this.pjsip,
    required this.codecs,
    required this.transports,
    required this.lan,
    required this.accounts,
    required this.registered,
  });
  final String appVersion;
  final String platform;
  final String engineState;
  final String pjsip;
  final List<CodecInfo> codecs;
  final List<String> transports;
  final String lan;
  final int accounts;
  final int registered;

  List<(String, String)> get rows => [
    ('App version', appVersion),
    ('Platform', platform),
    ('Engine', engineState),
    ('pjsip', pjsip.isEmpty ? '--' : pjsip),
    ('Accounts', '$registered of $accounts registered'),
    ('LAN Link', lan),
  ];

  String toText() {
    final b = StringBuffer();
    for (final r in rows) {
      b.writeln('${r.$1}: ${r.$2}');
    }
    b.writeln('Transports: ${transports.isEmpty ? '--' : transports.join(', ')}');
    b.writeln('Codecs: ${codecs.where((c) => c.enabled).map((c) => c.id).join(', ')}');
    return b.toString();
  }
}

/// Gathers version/transport/codec information. Refreshes when re-read.
final systemInfoProvider = FutureProvider.autoDispose<SystemInfo>((ref) async {
  final es = ref.watch(engineProvider);
  final settings = ref.read(settingsProvider);
  final acc = ref.read(accountsProvider);
  var app = kAppVersion;
  try {
    final p = await PackageInfo.fromPlatform();
    app = '${p.version}+${p.buildNumber}';
  } catch (_) {}
  var pjsip = es.startResult?.pjsip ?? '';
  var codecs = <CodecInfo>[];
  final ctl = ref.read(engineProvider.notifier);
  if (ctl.hasEngine) {
    try {
      final info = await ctl.engine.info();
      if (info.pjsip.isNotEmpty) pjsip = info.pjsip;
    } catch (_) {}
    try {
      codecs = await ctl.engine.codecs();
    } catch (_) {}
  }
  final res = es.startResult;
  final lan = res?.lan;
  String os;
  try {
    os = kIsWeb ? 'web' : '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  } catch (_) {
    os = 'unknown';
  }
  return SystemInfo(
    appVersion: app,
    platform: os,
    engineState: '${es.phase.name}${es.demo ? ' (simulator)' : ''}${es.version.isEmpty ? '' : ', ${es.version}'}',
    pjsip: pjsip,
    codecs: codecs,
    transports: [
      for (final t in res?.transports ?? const <TransportInfo>[]) '${t.type.toUpperCase()} ${t.local}${t.ipv6 ? ' (IPv6)' : ''}',
    ],
    lan: !settings.lanEnabled ? 'off' : (lan == null ? 'enabled (port unknown)' : 'on, ${lan.transport} port ${lan.port}'),
    accounts: acc.profiles.length,
    registered: acc.profiles.where((p) => acc.statusOf(p.id) == AccountStatus.registered).length,
  );
});
