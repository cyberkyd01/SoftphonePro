import 'dart:async';

/// A SoftphonePro device discovered on the LAN.
class LanDevice {
  const LanDevice({
    required this.id,
    required this.name,
    this.platform = '',
    this.online = true,
    this.busy = false,
    this.paired = true,
  });
  final String id;
  final String name;
  final String platform;
  final bool online;
  final bool busy;
  final bool paired;
}

enum HandoffMode { blind, attended }

/// Seam to the LAN Link feature (implemented by another agent). The UI only
/// talks to this interface; [NoopLanHandoff] is the default.
abstract class LanHandoff {
  /// False when LAN Link is not available/enabled.
  bool get available;

  List<LanDevice> get devices;
  Stream<List<LanDevice>> get devicesStream;

  /// Hands the external call [cid] to [device]. Throws on failure.
  Future<void> handoff({
    required int cid,
    required LanDevice device,
    HandoffMode mode = HandoffMode.blind,
  });

  /// Offers the ringing call [cid] to [device] instead of answering here.
  Future<void> forwardIncoming({required int cid, required LanDevice device});
}

class NoopLanHandoff implements LanHandoff {
  @override
  bool get available => false;
  @override
  List<LanDevice> get devices => const [];
  @override
  Stream<List<LanDevice>> get devicesStream => const Stream.empty();
  @override
  Future<void> handoff({
    required int cid,
    required LanDevice device,
    HandoffMode mode = HandoffMode.blind,
  }) async => throw UnsupportedError('LAN Link is not available yet');
  @override
  Future<void> forwardIncoming({
    required int cid,
    required LanDevice device,
  }) async => throw UnsupportedError('LAN Link is not available yet');
}
