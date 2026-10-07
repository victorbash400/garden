import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/chat/chat_message_list.dart';
import 'package:garden_flutter/components/chat/chat_message_row.dart';
import 'package:garden_flutter/state/chat_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'chat_controller_test.dart' show FakeChat;

DriveMessage message(int id, int minute, {String author = 'other'}) =>
    DriveMessage(
      id: id,
      gardenId: 1,
      authorId: author,
      username: author,
      text: 'Message $id',
      createdAt: DateTime(2026, 10, 7, 12, minute),
    );

void main() {
  testWidgets('messages group closely and retain their elements on arrival', (
    tester,
  ) async {
    final service = FakeChat()
      ..initial = ChatSnapshot(
        messages: [message(1, 0), message(2, 1), message(3, 7)],
        identities: [],
        readCursor: 0,
        unreadCount: 0,
      );
    final chat = ChatController(service, 1, 'me');
    await chat.start();
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: ListenableBuilder(
            listenable: chat,
            builder: (_, _) =>
                ChatMessageList(controller: chat, onFile: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Finder row(int id) => find.byWidgetPredicate(
      (widget) => widget is ChatMessageRow && widget.message.id == id,
    );
    expect(tester.widget<ChatMessageRow>(row(1)).showSender, isTrue);
    expect(tester.widget<ChatMessageRow>(row(1)).groupEnd, isFalse);
    expect(tester.widget<ChatMessageRow>(row(2)).showSender, isFalse);
    expect(tester.widget<ChatMessageRow>(row(2)).groupEnd, isTrue);
    expect(tester.widget<ChatMessageRow>(row(3)).showSender, isTrue);
    final retained = tester.element(row(3));
    service.events.add(message(4, 8));
    await tester.pumpAndSettle();
    expect(tester.element(row(3)), same(retained));
    expect(tester.widget<ChatMessageRow>(row(3)).groupEnd, isFalse);
    expect(tester.widget<ChatMessageRow>(row(4)).showSender, isFalse);
    service.events.add(message(5, 8, author: 'me'));
    await tester.pumpAndSettle();
    expect(tester.widget<ChatMessageRow>(row(4)).groupEnd, isTrue);
    expect(tester.widget<ChatMessageRow>(row(5)).showSender, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    chat.dispose();
    await service.events.close();
  });
}
