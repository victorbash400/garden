import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/chat/chat_composer.dart';
import 'package:garden_flutter/components/chat/chat_reference_picker.dart';
import 'package:garden_flutter/state/chat_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'chat_controller_test.dart' show FakeChat;
import 'files_gateway_fixture.dart';

void main() {
  testWidgets('Typing @ can mention an empty folder and send its reference', (
    tester,
  ) async {
    final gateway = FilesFixture();
    final folder = await gateway.create(1, 0, 'Assets', NodeKind.folder);
    final service = FakeChat();
    final chat = ChatController(service, 1, 'me');
    await chat.start();
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ChatComposer(
              controller: chat,
              audience: 'Review',
              onMention: () => showDialog(
                context: context,
                builder: (_) => ChatReferencePicker(
                  gateway: gateway,
                  driveId: 1,
                  driveName: 'Work',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Check @');
    await tester.pumpAndSettle();
    expect(find.text('Mention file or folder'), findsOneWidget);
    await tester.tap(find.text('Assets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mention this folder'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Check ',
    );
    expect(find.text('Assets'), findsOneWidget);
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(service.sent.single.nodeId, folder.id);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    chat.dispose();
    await service.events.close();
    await gateway.events.close();
  });
}
