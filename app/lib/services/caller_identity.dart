import 'package:spcore_dart/spcore_dart.dart' show CallInfo;

import '../core/format.dart';
import '../models/contact.dart';
import 'contacts_controller.dart';

/// Who is calling, combining the SIP From with P-Asserted-Identity /
/// Remote-Party-ID, Diversion / History-Info and Referred-By (ENGINE_API 9.5).
class CallerIdentity {
  const CallerIdentity({
    this.name = '',
    this.number = '',
    this.secondaryNumber = '',
    this.forwardedFrom = '',
    this.forwardReason = '',
    this.transferredBy = '',
  });

  /// Best name: contact, then asserted display, then From display.
  final String name;

  /// Number to show: the asserted number when present, else the From number.
  final String number;

  /// The From number when it differs from the asserted one.
  final String secondaryNumber;

  /// User part of the first diversion hop.
  final String forwardedFrom;
  final String forwardReason;

  /// User part of the Referred-By URI.
  final String transferredBy;

  bool get hasExtras =>
      secondaryNumber.isNotEmpty || forwardedFrom.isNotEmpty || transferredBy.isNotEmpty;

  String get forwardedText => forwardedFrom.isEmpty
      ? ''
      : 'Forwarded from $forwardedFrom${forwardReason.isEmpty ? '' : ' ($forwardReason)'}';

  String get transferredText => transferredBy.isEmpty ? '' : 'Transferred by $transferredBy';

  static CallerIdentity of(CallInfo i, List<Contact> contacts, {String fromNumber = ''}) {
    final from = fromNumber.isNotEmpty
        ? fromNumber
        : (i.remoteUser.isNotEmpty ? i.remoteUser : userPart(i.remoteUri));
    final pai = i.assertedIdentity;
    final paiNumber = pai?.user ?? '';
    final contact = findContact(contacts, from) ??
        (paiNumber.isNotEmpty ? findContact(contacts, paiNumber) : null);
    final name = contact?.displayName.isNotEmpty == true
        ? contact!.displayName
        : ((pai?.display ?? '').isNotEmpty ? pai!.display : i.remoteDisplay);
    final number = paiNumber.isNotEmpty ? paiNumber : from;
    final secondary = paiNumber.isNotEmpty && from.isNotEmpty && !sameNumber(paiNumber, from) ? from : '';
    final div = i.diversion.isEmpty ? null : i.diversion.first;
    final ref = i.referredBy;
    return CallerIdentity(
      name: name,
      number: number,
      secondaryNumber: secondary,
      forwardedFrom: div == null ? '' : (div.user.isNotEmpty ? div.user : userPart(div.uri)),
      forwardReason: div?.reason ?? '',
      transferredBy: ref == null || ref.isEmpty ? '' : userPart(ref),
    );
  }
}
