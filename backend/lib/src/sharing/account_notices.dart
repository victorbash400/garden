import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class AccountNotices {
  static String channel(String email) =>
      'notifications_${sha256.convert(utf8.encode(email))}';

  static Future<void> publish(Session session, AccountNotification notice) =>
      session.messages.postMessage(channel(notice.recipientEmail), notice);

  static Future<void> invitationChanged(
    Session session,
    int invitationId,
  ) async {
    final notice = await AccountNotification.db.findFirstRow(
      session,
      where: (row) => row.invitationId.equals(invitationId),
    );
    if (notice != null) await publish(session, notice);
  }
}
