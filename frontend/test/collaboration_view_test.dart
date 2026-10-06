import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/chat/share_reference_dialog.dart';
import 'package:garden_flutter/components/chat/chat_panel.dart';
import 'package:garden_flutter/components/files/directory_browser.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/state/files_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/views/files_view.dart';

import 'files_gateway_fixture.dart';
import 'chat_controller_test.dart' show FakeChat;

void main() {
  testWidgets(
    'Home, root Invite, Upload and file Share coexist with chat and empty folder navigation',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final gateway = FilesFixture();
      final files = FilesController(gateway);
      final chat = FakeChat();
      var home = false, invited = false;
      await files.open(
        const GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1),
      );
      await files.create('Empty', NodeKind.folder);
      final folder = files.selected!;
      await files.create('Document.txt', NodeKind.file);
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(
            body: FilesView(
              controller: files,
              userId: 'me',
              chatService: chat,
              onBackToDrives: () => home = true,
              onManageDrive: () => invited = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Create'), findsNothing);
      expect(find.byTooltip('Import files'), findsOneWidget);
      await tester.tap(find.byTooltip('Invite to drive'));
      expect(invited, isTrue);
      await tester.tap(find.byTooltip('Share'));
      await tester.pumpAndSettle();
      expect(find.byType(ShareReferenceDialog), findsOneWidget);
      expect(find.text('Everyone in Work'), findsOneWidget);
      await tester.tap(find.text('Share').last);
      await tester.pumpAndSettle();
      expect(find.byType(ShareReferenceDialog), findsNothing);
      expect(find.text('Shared.txt'), findsOneWidget);
      expect(find.byType(DirectoryBrowser), findsOneWidget);
      expect(tester.getSize(find.byType(ChatPanel)).width, 420);
      expect(tester.getSize(find.byType(TextField)).height, lessThan(40));
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
      await files.openFolder(folder);
      await tester.tap(find.byTooltip('Close chat'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Invite to drive'), findsNothing);
      expect(find.bySemanticsLabel('This folder is empty'), findsOneWidget);
      await tester.tap(find.text('Home'));
      expect(home, isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      files.dispose();
      unawaited(gateway.events.close());
      await chat.events.close();
    },
  );
}
