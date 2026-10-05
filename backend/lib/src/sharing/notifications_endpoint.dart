import 'dart:async';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'recipient_identity.dart';
import 'account_notices.dart';

class NotificationsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<AccountNotification>> list(Session session, int afterId) async {
    if (afterId < 0) {
      throw GardenException(message: 'Invalid notification cursor.');
    }
    final email = await RecipientIdentity.email(session);
    return _after(session, email, afterId);
  }

  Future<void> markRead(Session session, int notificationId) async {
    final email = await RecipientIdentity.email(session);
    final updated = await session.db.transaction((transaction) async {
      final notification = await AccountNotification.db.findById(
        session,
        notificationId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (notification == null || notification.recipientEmail != email) {
        throw GardenException(message: 'This notification is unavailable.');
      }
      notification.readAt ??= DateTime.now().toUtc();
      return AccountNotification.db.updateRow(
        session,
        notification,
        transaction: transaction,
      );
    });
    await AccountNotices.publish(session, updated);
  }

  Stream<AccountNotification> watch(Session session, int afterId) async* {
    if (afterId < 0) {
      throw GardenException(message: 'Invalid notification cursor.');
    }
    final email = await RecipientIdentity.email(session);
    final changes = StreamIterator(
      session.messages.createStream<AccountNotification>(
        AccountNotices.channel(email),
      ),
    );
    var cursor = afterId;
    try {
      Future<List<AccountNotification>> next() =>
          _after(session, email, cursor);
      var batch = await next();
      while (batch.isNotEmpty) {
        for (final item in batch) {
          cursor = item.id!;
          yield item;
        }
        batch = await next();
      }
      while (await changes.moveNext()) {
        final item = changes.current;
        if (item.recipientEmail != email) continue;
        if (item.id! > cursor) {
          batch = await next();
          while (batch.isNotEmpty) {
            for (final value in batch) {
              cursor = value.id!;
              yield value;
            }
            batch = await next();
          }
        } else {
          yield item;
        }
      }
    } finally {
      await changes.cancel();
    }
  }

  Future<List<AccountNotification>> _after(
    Session session,
    String email,
    int cursor,
  ) => AccountNotification.db.find(
    session,
    where: (row) => row.recipientEmail.equals(email) & (row.id > cursor),
    orderBy: (row) => row.id,
    limit: 200,
  );
}
