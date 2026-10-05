import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import '../generated/protocol.dart';
import '../files/drive_access.dart';

class RecipientIdentity {
  static String normalize(String value) {
    final email = value.trim().toLowerCase();
    final parts = email.split('@');
    if (email.length > 254 ||
        parts.length != 2 ||
        parts.any((part) => part.isEmpty) ||
        !parts.last.contains('.') ||
        email.runes.any((rune) => rune <= 32)) {
      throw GardenException(message: 'Enter a valid email address.');
    }
    return email;
  }

  static Future<String> email(Session session) async {
    final account = await EmailAccount.db.findFirstRow(
      session,
      where: (row) => row.authUserId.equals(
        UuidValue.fromString(DriveAccess.user(session)),
      ),
    );
    if (account == null) {
      throw GardenException(
        message: 'Verify your account email before accepting invitations.',
      );
    }
    return normalize(account.email);
  }
}
