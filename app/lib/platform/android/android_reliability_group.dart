import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../services/providers.dart';
import '../../ui/widgets/settings_tiles.dart';
import '../platform_services.dart';
import 'android_platform_services.dart';

/// "Background reliability" checklist for Android: everything that decides
/// whether incoming calls reach the phone while the app is not on screen.
class AndroidReliabilityGroup extends ConsumerStatefulWidget {
  const AndroidReliabilityGroup({super.key});
  @override
  ConsumerState<AndroidReliabilityGroup> createState() => _State();
}

class _State extends ConsumerState<AndroidReliabilityGroup> with WidgetsBindingObserver {
  AndroidStatus? _st;
  bool _wake = false;
  bool _boot = false;
  bool _oem = false;

  AndroidPlatformServices? get _p {
    final p = ref.read(platformServicesProvider);
    return p is AndroidPlatformServices ? p : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final p = _p;
    if (p == null) return;
    final st = await p.status();
    final wake = await p.idleWakeLock();
    final boot = await p.startAtBoot();
    final oem = await p.hasAutostartSettings();
    if (!mounted) return;
    setState(() {
      _st = st;
      _wake = wake;
      _boot = boot;
      _oem = oem;
    });
  }

  Widget _status(bool ok) => Icon(
    ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
    color: ok ? Colors.green : Theme.of(context).colorScheme.error,
  );

  @override
  Widget build(BuildContext context) {
    final p = _p;
    final st = _st;
    if (p == null || st == null) return const SizedBox.shrink();
    final micOk = st.microphone == PermissionStatus.granted;
    final notifOk = st.notifications == PermissionStatus.granted;
    final l = context.l10n;
    return SettingsGroup(
      title: l.reliabilityTitle,
      children: [
        ListTile(
          leading: const Icon(Icons.mic_rounded),
          title: Text(l.reliabilityMicrophone),
          subtitle: Text(micOk ? l.reliabilityAllowed : l.reliabilityMicNeeded),
          trailing: _status(micOk),
          onTap: micOk
              ? null
              : () async {
                  final r = await p.requestAll();
                  if (r.microphone != PermissionStatus.granted) await p.openAppSettings();
                  _refresh();
                },
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active_rounded),
          title: Text(l.reliabilityNotifications),
          subtitle: Text(notifOk ? l.reliabilityAllowed : l.reliabilityNotifNeeded),
          trailing: _status(notifOk),
          onTap: notifOk
              ? null
              : () async {
                  final r = await p.requestAll();
                  if (r.notifications != PermissionStatus.granted) await p.openNotificationSettings();
                  _refresh();
                },
        ),
        if (st.sdk >= 34)
          ListTile(
            leading: const Icon(Icons.fullscreen_rounded),
            title: Text(l.reliabilityFullScreen),
            subtitle: Text(st.fullScreenIntent ? l.reliabilityAllowed : l.reliabilityFullScreenNeeded),
            trailing: _status(st.fullScreenIntent),
            onTap: st.fullScreenIntent ? null : () => p.openFullScreenIntentSettings(),
          ),
        ListTile(
          leading: const Icon(Icons.battery_saver_rounded),
          title: Text(l.reliabilityBattery),
          subtitle: Text(
            st.batteryOptimizationsIgnored
                ? l.reliabilityBatteryExempt
                : l.reliabilityBatteryNeeded,
          ),
          trailing: _status(st.batteryOptimizationsIgnored),
          onTap: st.batteryOptimizationsIgnored
              ? null
              : () async {
                  await p.requestIgnoreBatteryOptimizations();
                },
        ),
        if (_oem)
          ListTile(
            leading: const Icon(Icons.rocket_launch_rounded),
            title: Text(l.reliabilityAutostart(st.manufacturer)),
            subtitle: Text(l.reliabilityAutostartHint),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => p.openAutostartSettings(),
          ),
        SwitchTile(
          icon: Icons.restart_alt_rounded,
          title: l.reliabilityBoot,
          subtitle: l.reliabilityBootHint,
          value: _boot,
          onChanged: (v) async {
            await p.setStartAtLogin(v);
            _refresh();
          },
        ),
        SwitchTile(
          icon: Icons.bolt_rounded,
          title: l.reliabilityWake,
          subtitle: l.reliabilityWakeHint,
          value: _wake,
          onChanged: (v) async {
            await p.setIdleWakeLock(v);
            _refresh();
          },
        ),
      ],
    );
  }
}
