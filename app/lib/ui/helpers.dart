import 'package:spcore_dart/spcore_dart.dart' show CallState;

import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../services/calls_controller.dart';
import '../services/caller_identity.dart';

/// Display name for a live call: contact name, remote display, or number.
String callTitle(UiCall c, List<Contact> contacts, AppLocalizations l) {
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
  return l.uiUnknownCaller;
}

String callStateText(UiCall c, AppLocalizations l) {
  if (c.isEnded) return l.uiCallEnded;
  if (c.transferStalled) return l.uiCallTransferNotConfirmed;
  if (c.transferPending) return l.uiCallTransferring;
  if (c.isConference) return l.uiCallConference;
  if (c.isHeld) return l.uiCallOnHold;
  if (c.remoteHeld) return l.uiCallHeldByRemote;
  switch (c.state) {
    case CallState.calling:
      return l.uiCallCalling;
    case CallState.early:
      return l.uiCallRinging;
    case CallState.connecting:
      return l.uiCallConnecting;
    case CallState.incoming:
      return l.uiCallIncoming;
    case CallState.confirmed:
      return l.uiCallConnected;
    default:
      return c.info.stateReason.isEmpty ? '...' : c.info.stateReason;
  }
}
