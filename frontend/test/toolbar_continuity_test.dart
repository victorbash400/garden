import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/files/files_toolbar.dart';
import 'package:garden_flutter/components/files/toolbar_button.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/state/files_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/views/files_view.dart';

import 'files_gateway_fixture.dart';
import 'widget_test.dart' show TestGateway, MemoryPreferences;
import 'chat_controller_test.dart' show FakeChat;

const first = GardenInfo(id: 1, name: 'First', role: 'Owner', members: 1);
const second = GardenInfo(id: 2, name: 'Second', role: 'Owner', members: 1);

class ScopedChat extends FakeChat {
  int? sentDrive;
  @override
  Future<DriveMessage> send(
    int drive,
    String text,
    int? reply,
    int? node, {
    int? conversation,
  }) {
    sentDrive = drive;
    return super.send(drive, text, reply, node, conversation: conversation);
  }
}

void main() {
  testWidgets(
    'file toolbar stays mounted through folder and drive navigation',
    (tester) async {
      final gateway = FilesFixture();
      final files = FilesController(gateway);
      await files.open(first);
      await files.create('Folder', NodeKind.folder);
      final folder = files.selected!;
      final controller =
          GardenController(TestGateway(), MemoryPreferences(), files: files)
            ..account = const AccountInfo(
              id: 'me',
              email: 'me@example.com',
              username: 'me',
            )
            ..gardens = [first, second]
            ..page = GardenPage.files;
      await tester.pumpWidget(GardenApp(controller: controller));
      await tester.pumpAndSettle();
      final bar = tester.element(find.byType(FilesToolbar));
      final button = tester.element(
        find.byWidgetPredicate(
          (widget) =>
              widget is ToolbarButton && widget.tooltip == 'Import files',
        ),
      );
      final before = tester.getRect(find.byType(FilesToolbar));
      await files.openFolder(folder);
      await tester.pump();
      expect(tester.element(find.byType(FilesToolbar)), same(bar));
      expect(
        tester.element(
          find.byWidgetPredicate(
            (widget) =>
                widget is ToolbarButton && widget.tooltip == 'Import files',
          ),
        ),
        same(button),
      );
      expect(tester.getRect(find.byType(FilesToolbar)).top, before.top);
      await tester.pumpAndSettle();
      await tester.runAsync(() => controller.openDrive(second));
      await tester.pump();
      expect(tester.element(find.byType(FilesToolbar)), same(bar));
      expect(
        tester.element(
          find.byWidgetPredicate(
            (widget) =>
                widget is ToolbarButton && widget.tooltip == 'Import files',
          ),
        ),
        same(button),
      );
      final opacity = find.ancestor(
        of: find.byType(FilesToolbar),
        matching: find.byType(FadeTransition),
      );
      expect(
        tester
            .widgetList<FadeTransition>(opacity)
            .every((fade) => fade.opacity.value == 1),
        isTrue,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await tester.runAsync(() => gateway.events.close());
    },
  );

  testWidgets('retained file page binds chat to the newly selected drive', (
    tester,
  ) async {
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    final chat = ScopedChat();
    await files.open(first);
    Widget page() => MaterialApp(
      theme: GardenTheme.light,
      home: Scaffold(
        body: FilesView(
          controller: files,
          userId: 'me',
          onBackToDrives: () {},
          chatService: chat,
        ),
      ),
    );
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    await tester.runAsync(() => files.open(second));
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Inbox'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'For the second drive');
    await tester.pump();
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(chat.sentDrive, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    files.dispose();
    await tester.runAsync(() => gateway.events.close());
    await tester.runAsync(() => chat.events.close());
  });
}
