import 'dart:math';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as auth;
import '../generated/protocol.dart';

class Usernames {
  static String generated() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return 'garden_${List.generate(12, (_) => alphabet[random.nextInt(alphabet.length)]).join()}';
  }

  static String normalize(String value) {
    final name = value.trim().toLowerCase();
    bool letter(int c) => c >= 97 && c <= 122;
    bool digit(int c) => c >= 48 && c <= 57;
    if (name.length < 3 ||
        name.length > 40 ||
        !letter(name.codeUnitAt(0)) ||
        name.codeUnits.any(
          (c) => !letter(c) && !digit(c) && c != 45 && c != 95,
        )) {
      throw GardenException(
        message:
            'Use 3–40 letters, numbers, hyphens or underscores, starting with a letter.',
      );
    }
    return name;
  }

  static Future<AccountUsername> ensure(Session session, String userId) async {
    final known = await AccountUsername.db.findFirstRow(
      session,
      where: (row) => row.userId.equals(userId),
    );
    if (known != null) return known;
    return session.db.transaction((transaction) async {
      // Serialize creation against the existing authentication profile.
      final profile = await auth.UserProfile.db.findFirstRow(
        session,
        where: (row) => row.authUserId.equals(UuidValue.fromString(userId)),
        lockMode: LockMode.forUpdate,
        transaction: transaction,
      );
      if (profile == null) {
        throw GardenException(message: 'Account profile unavailable.');
      }
      final existing = await AccountUsername.db.findFirstRow(
        session,
        where: (row) => row.userId.equals(userId),
        transaction: transaction,
      );
      if (existing != null) return existing;
      for (var attempt = 0; attempt < 5; attempt++) {
        final savepoint = await transaction.createSavepoint();
        try {
          final identity = await AccountUsername.db.insertRow(
            session,
            AccountUsername(userId: userId, username: generated()),
            transaction: transaction,
          );
          await savepoint.release();
          return identity;
        } on DatabaseQueryException catch (error) {
          await savepoint.rollback();
          if (error.code != '23505') rethrow;
        }
      }
      throw GardenException(
        message: 'Could not assign a username. Please retry.',
      );
    });
  }

  static Future<AccountUsername> rename(
    Session session,
    String userId,
    String value,
  ) async {
    final name = normalize(value);
    final identity = await ensure(session, userId);
    if (identity.username == name) return identity;
    if (name.startsWith('garden_')) {
      throw GardenException(
        message: 'Choose a username without the reserved garden_ prefix.',
      );
    }
    try {
      identity.username = name;
      return await AccountUsername.db.updateRow(session, identity);
    } on DatabaseQueryException catch (error) {
      if (error.code != '23505') rethrow;
      throw GardenException(message: 'That username is already taken.');
    }
  }
}
