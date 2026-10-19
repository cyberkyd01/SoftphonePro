import 'package:spcore_dart/spcore_dart.dart' show CallState;

import '../models/contact.dart';
import '../services/calls_controller.dart';
import '../services/caller_identity.dart';

/// Display name for a live call: contact name, remote display, or number.
String callTitle(UiCall c, List<Contact> contacts) {
  final lan = c.lan;
  if (lan != null) {
    // Transferred calls are about the original caller; other LAN calls about the device.
    if (lan.isHandoff && !lan.outgoing && lan.callerLabel.isNotEmpty) return lan.callerLabel;
    if ((lan.isHandoff && lan.outgoing) || lan.paired || lan.outgoing) {
      if (lan.peerName.isNotEmpty && !(lan.isHandoff && !lan.outgoing)) return lan.peerName;
    }
  }
  final who = CallerIdentity.of(c.info, contacts, fromNumber: c.number);
  if (who.name.isNotEmpty) return who.name;
  if (who.number.isNotEmpty) return who.number;
  if (c.number.isNotEmpty) return c.number;
  return 'Unknown caller';
}

String callStateText(UiCall c) {
  if (c.isEnded) return 'Call ended';
  if (c.transferStalled) return 'Transfer not confirmed';
  if (c.transferPending) return 'Transferring...';
  if (c.isConference) return 'Conference';
  if (c.isHeld) return 'On hold';
  if (c.remoteHeld) return 'Held by remote';
  switch (c.state) {
    case CallState.calling:
      return 'Calling...';
    case CallState.early:
      return 'Ringing...';
    case CallState.connecting:
      return 'Connecting...';
    case CallState.incoming:
      return 'Incoming call';
    case CallState.confirmed:
      return 'Connected';
    default:
      return c.info.stateReason.isEmpty ? '...' : c.info.stateReason;
  }
}
