import 'package:spcore_dart/spcore_dart.dart' show CallState;

import '../models/contact.dart';
import '../services/calls_controller.dart';
import '../services/contacts_controller.dart';

/// Display name for a live call: contact name, remote display, or number.
String callTitle(UiCall c, List<Contact> contacts) {
  final byContact = findContact(contacts, c.number)?.displayName;
  if (byContact != null && byContact.isNotEmpty) return byContact;
  if (c.info.remoteDisplay.isNotEmpty) return c.info.remoteDisplay;
  if (c.number.isNotEmpty) return c.number;
  return 'Unknown caller';
}

String callStateText(UiCall c) {
  if (c.isEnded) return 'Call ended';
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
