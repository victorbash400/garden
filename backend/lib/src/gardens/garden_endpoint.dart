import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';

class GardenEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  String _user(Session session) => session.authenticated!.userIdentifier;
  String _hash(String code) => sha256.convert(utf8.encode(code)).toString();

  Future<AccountDetails> account(Session session) async {
    final id = _user(session);
    final profile = await AuthServices.instance.userProfiles
        .findUserProfileByUserId(session, UuidValue.fromString(id));
    final email = profile.email;
    if (email == null) {
      throw GardenException(message: 'The account has no email address.');
    }
    return AccountDetails(id: id, email: email);
  }

  Future<List<GardenSummary>> list(Session session) async {
    final memberships = await GardenMember.db.find(
      session,
      where: (row) => row.userId.equals(_user(session)),
    );
    final result = <GardenSummary>[];
    for (final membership in memberships) {
      final record = await GardenRecord.db.findById(
        session,
        membership.gardenId,
      );
      if (record == null) {
        throw GardenException(message: 'A drive membership is invalid.');
      }
      result.add(await _summary(session, record, membership.role));
    }
    return result;
  }

  Future<GardenSummary> create(Session session, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 80) {
      throw GardenException(
        message: 'Use a drive name between 1 and 80 characters.',
      );
    }
    final random = Random.secure();
    final code = base64Url.encode(
      List<int>.generate(24, (_) => random.nextInt(256)),
    );
    final user = _user(session);
    return session.db.transaction((transaction) async {
      final record = await GardenRecord.db.insertRow(
        session,
        GardenRecord(
          name: trimmed,
          ownerId: user,
          invitationHash: _hash(code),
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
      await GardenMember.db.insertRow(
        session,
        GardenMember(gardenId: record.id!, userId: user, role: 'Owner'),
        transaction: transaction,
      );
      return GardenSummary(
        id: record.id!,
        name: record.name,
        role: 'Owner',
        members: 1,
        invitationCode: code,
      );
    });
  }

  Future<GardenSummary> join(Session session, String invitationCode) async {
    final record = await GardenRecord.db.findFirstRow(
      session,
      where: (row) => row.invitationHash.equals(_hash(invitationCode.trim())),
    );
    if (record == null) {
      throw GardenException(message: 'The invitation code is invalid.');
    }
    await session.db.transaction((transaction) async {
      final existing = await GardenMember.db.findFirstRow(
        session,
        where: (row) =>
            row.gardenId.equals(record.id!) & row.userId.equals(_user(session)),
        transaction: transaction,
      );
      if (existing == null) {
        await GardenMember.db.insertRow(
          session,
          GardenMember(
            gardenId: record.id!,
            userId: _user(session),
            role: 'Member',
          ),
          transaction: transaction,
        );
      }
    });
    return connect(session, record.id!);
  }

  Future<GardenSummary> connect(Session session, int gardenId) async {
    final membership = await GardenMember.db.findFirstRow(
      session,
      where: (row) =>
          row.gardenId.equals(gardenId) & row.userId.equals(_user(session)),
    );
    if (membership == null) {
      throw GardenException(message: 'You do not have access to this drive.');
    }
    final record = await GardenRecord.db.findById(session, gardenId);
    if (record == null) {
      throw GardenException(message: 'This drive no longer exists.');
    }
    return _summary(session, record, membership.role);
  }

  Future<GardenSummary> _summary(
    Session session,
    GardenRecord record,
    String role,
  ) async => GardenSummary(
    id: record.id!,
    name: record.name,
    role: role,
    members: await GardenMember.db.count(
      session,
      where: (row) => row.gardenId.equals(record.id!),
    ),
  );
}
