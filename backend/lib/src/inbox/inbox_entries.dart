import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../sharing/recipient_identity.dart';

class InboxEntries {
  static Future<List<InboxEntry>> list(Session session, String user) async {
    final email = await RecipientIdentity.email(session);
    final private = await session.db.unsafeQuery('''
      SELECT c.id, c."gardenId", g.name, c.title, c."creatorId",
        latest.id, COALESCE(NULLIF(LEFT(latest.text, 120), ''), latest."nodeName", ''), latest."createdAt",
        (SELECT COUNT(*) FROM drive_message d WHERE d."conversationId" = c.id
          AND d.id > m."readCursor" AND d."authorId" != @user), c."createdAt",
        EXISTS (SELECT 1 FROM account_notification n WHERE n."conversationId"=c.id
          AND n."recipientEmail"=@email AND n.kind='chatAdded' AND n."readAt" IS NULL AND n."trashedAt" IS NULL)
      FROM conversation c
      JOIN conversation_member m ON m."conversationId" = c.id AND m."userId" = @user
      JOIN garden_member gm ON gm."gardenId" = c."gardenId" AND gm."userId" = @user
      JOIN garden_record g ON g.id = c."gardenId"
      LEFT JOIN LATERAL (SELECT d.id, d.text, d."nodeName", d."createdAt" FROM drive_message d
        WHERE d."conversationId" = c.id ORDER BY d.id DESC LIMIT 1) latest ON TRUE
      WHERE g.deleted = FALSE
    ''', parameters: QueryParameters.named({'user': user, 'email': email}));
    final shared = await session.db.unsafeQuery('''
      SELECT g.id, g.name, latest.id,
        COALESCE(NULLIF(LEFT(latest.text, 120), ''), latest."nodeName", ''), latest."createdAt",
        (SELECT COUNT(*) FROM drive_message d WHERE d."gardenId" = g.id
          AND d."conversationId" IS NULL AND d.id > COALESCE(r."messageId", 0) AND d."authorId" != @user)
      FROM garden_record g
      JOIN garden_member gm ON gm."gardenId" = g.id AND gm."userId" = @user
      LEFT JOIN chat_read r ON r."gardenId" = g.id AND r."userId" = @user
      LEFT JOIN LATERAL (SELECT d.id, d.text, d."nodeName", d."createdAt" FROM drive_message d
        WHERE d."gardenId" = g.id AND d."conversationId" IS NULL ORDER BY d.id DESC LIMIT 1) latest ON TRUE
      WHERE g.deleted = FALSE
    ''', parameters: QueryParameters.named({'user': user}));
    final ids = private.map((row) => row[0] as int).toSet();
    final members = ids.isEmpty
        ? <ConversationMember>[]
        : await ConversationMember.db.find(
            session,
            where: (row) => row.conversationId.inSet(ids),
          );
    final users = members.map((member) => member.userId).toSet();
    final identities = users.isEmpty
        ? <AccountUsername>[]
        : await AccountUsername.db.find(
            session,
            where: (row) => row.userId.inSet(users),
          );
    final byUser = {
      for (final identity in identities)
        identity.userId: PublicIdentity(
          userId: identity.userId,
          username: identity.username,
        ),
    };
    final byConversation = <int, List<PublicIdentity>>{};
    for (final member in members) {
      final identity = byUser[member.userId];
      if (identity != null) {
        (byConversation[member.conversationId] ??= []).add(identity);
      }
    }
    final entries = <InboxEntry>[
      for (final row in private)
        InboxEntry(
          conversationId: row[0] as int,
          gardenId: row[1] as int,
          driveName: row[2] as String,
          title: row[3] as String,
          creatorId: row[4] as String,
          createdAt: row[9] as DateTime,
          isNew: row[10] as bool,
          members: byConversation[row[0]] ?? [],
          latestText: row[6] as String,
          latestAt: row[7] as DateTime?,
          unreadCount: row[8] as int,
        ),
      for (final row in shared)
        InboxEntry(
          gardenId: row[0] as int,
          driveName: row[1] as String,
          title: '',
          members: [],
          latestText: row[3] as String,
          latestAt: row[4] as DateTime?,
          unreadCount: row[5] as int,
        ),
    ];
    return entries;
  }
}
