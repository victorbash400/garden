import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/chat/chat_panel.dart';
import 'package:garden_flutter/components/chat/chat_history.dart';
import 'package:garden_flutter/state/chat_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'chat_controller_test.dart' show FakeChat;
import 'files_gateway_fixture.dart';

void main() {
  testWidgets(
    'drive chat centers its composer, starts saved conversations and mentions files without changing scope',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = FakeChat();
      final chat = ChatController(service, 1, 'me');
      await chat.start();
      final files = FilesFixture();
      final node = await files.create(1, 0, 'Reference.txt', NodeKind.file);
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(
            body: ListenableBuilder(
              listenable: chat,
              builder: (_, _) => ChatPanel(
                controller: chat,
                driveName: 'Work',
                onFile: (_) {},
                onMention: () async => node,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final inputRect = tester.getRect(find.byType(TextField));
      expect(inputRect.center.dx, closeTo(550, 4));
      expect(inputRect.width, lessThan(760));
      await tester.tap(find.byTooltip('Conversations'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New conversation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('member').last);
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(find.text('Open conversation'));
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      expect(chat.conversation, isNotNull);
      expect(find.text('member'), findsWidgets);
      await tester.tap(find.byTooltip('Mention file or folder'));
      await tester.pumpAndSettle();
      expect(find.text('Reference.txt'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Review this file');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(service.sent.single.gardenId, 1);
      expect(service.sent.single.replyToId, isNull);
      expect(service.sent.single.nodeId, node.id);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), 'A reply');
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(service.sent.last.replyToId, isNull);
      expect(
        service.sent.last.conversationId,
        chat.conversation!.conversation.id,
      );
      await tester.tap(find.byTooltip('Conversations'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatHistory), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(
          find.descendant(
            of: find.byType(ChatHistory),
            matching: find.text('member'),
          ),
        );
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      expect(find.byType(ChatHistory), findsNothing);
      expect(find.text('A reply'), findsOneWidget);
      expect(find.text('Shared.txt'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      chat.dispose();
      await service.events.close();
      await files.events.close();
    },
  );

  testWidgets(
    'failed send keeps text and the file mention; file Viewer can chat',
    (tester) async {
      final service = FakeChat()..failSend = true;
      final chat = ChatController(service, 1, 'me');
      await chat.start();
      final files = FilesFixture();
      final node = await files.create(1, 0, 'Reference.txt', NodeKind.file);
      Widget app() => MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: ListenableBuilder(
            listenable: chat,
            builder: (_, _) => ChatPanel(
              controller: chat,
              driveName: 'Work',
              onFile: (_) {},
              onMention: () async => node,
            ),
          ),
        ),
      );
      await tester.pumpWidget(app());
      await tester.tap(find.byTooltip('Mention file or folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Keep this draft');
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Keep this draft',
      );
      expect(find.text('Reference.txt'), findsOneWidget);
      expect(find.text('Message could not be sent.'), findsOneWidget);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
      await tester.pumpWidget(const SizedBox());
      chat.dispose();
      await service.events.close();
      await files.events.close();
    },
  );
}
