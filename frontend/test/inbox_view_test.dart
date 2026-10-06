import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/state/files_controller.dart';
import 'package:garden_flutter/state/inbox_controller.dart';
import 'package:garden_flutter/views/inbox_view.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/components/inbox/conversation_avatar.dart';

import 'chat_controller_test.dart' show FakeChat;
import 'inbox_controller_test.dart' show FakeInbox, entry;
import 'widget_test.dart' show TestGateway, MemoryPreferences;
import 'files_gateway_fixture.dart';

void main() {
  testWidgets(
    'Inbox lists incoming conversations and uses theme bubbles without avatar initials',
    (tester) async {
      tester.view.physicalSize = const Size(1040, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final messages = FakeChat()
        ..initial = ChatSnapshot(
          messages: [
            DriveMessage(
              id: 1,
              conversationId: 2,
              gardenId: 1,
              authorId: 'other',
              username: 'recipient',
              text: 'Can you review the Assets folder?',
              createdAt: DateTime.utc(2026),
            ),
            DriveMessage(
              id: 2,
              conversationId: 2,
              gardenId: 1,
              authorId: 'me',
              username: 'sender',
              text: 'Yes, I will have a look.',
              createdAt: DateTime.utc(2026),
            ),
          ],
          identities: [],
          readCursor: 0,
          unreadCount: 1,
        );
      final service = FakeInbox()..entries = [entry(2, added: true)];
      final inbox = InboxController(service, messages, 'me');
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        files: FilesController(FilesFixture()),
      )..inbox = inbox;
      await inbox.start();

      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light.copyWith(
            textTheme: GardenTheme.light.textTheme.apply(fontFamily: 'Geist'),
          ),
          home: Scaffold(
            body: ColoredBox(
              color: GardenTheme.canvas,
              child: InboxView(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Review'), findsOneWidget);
      expect(find.byType(ConversationAvatar), findsOneWidget);
      expect(find.byTooltip('New conversation'), findsOneWidget);
      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      expect(service.seenId, 2);
      expect(find.byTooltip('Conversation options'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await service.events.close();
      await messages.events.close();
    },
  );
}
