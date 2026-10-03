import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/files/directory_column.dart';
import 'package:garden_flutter/components/files/node_drag_surface.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/state/files_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/views/files_view.dart';

import 'files_gateway_fixture.dart';
import 'widget_test.dart' show TestFinder, TestGateway, MemoryPreferences;

void main() {
  test(
    'drive trees and loaded folders survive switching before ready',
    () async {
      final gateway = FilesFixture();
      final files = FilesController(gateway);
      const first = GardenInfo(id: 1, name: 'First', role: 'Owner', members: 1);
      const second = GardenInfo(
        id: 2,
        name: 'Second',
        role: 'Owner',
        members: 1,
      );
      await files.open(first);
      await files.create('Folder', NodeKind.folder);
      final folder = files.selected!;
      files.folders.expanded.add(folder.id!);
      final index = files.folders;
      await files.open(second);
      final calls = gateway.listCalls;
      expect(files.folderIndex(1), same(index));
      expect(index.directory(0).single.name, 'Folder');
      await files.open(first);
      await files.openFolder(folder);
      expect(gateway.listCalls, calls);
      expect(files.folders.expanded, contains(folder.id));
      await files.close();
      files.dispose();
      await gateway.events.close();
    },
  );

  testWidgets('drag moves a file into a folder without uploading content', (
    tester,
  ) async {
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    await files.open(
      const GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1),
    );
    await files.create('Destination', NodeKind.folder);
    final folder = files.selected!;
    await files.create('Document.txt', NodeKind.file);
    final file = files.selected!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilesView(
            controller: files,
            userId: 'account',
            onBackToDrives: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final calls = gateway.listCalls;
    final source = find.byWidgetPredicate(
      (widget) =>
          widget is Draggable<NodeDrag> && widget.data?.node.id == file.id,
    );
    final target = find.text('Destination');
    final gesture = await tester.startGesture(tester.getCenter(source));
    await gesture.moveBy(const Offset(10, 0));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(file.parentId, folder.id);
    expect(files.nodes.map((node) => node.name), ['Destination']);
    expect(files.folders.directory(folder.id!).single.id, file.id);
    expect(gateway.uploads, isEmpty);
    expect(gateway.listCalls, calls);
    await expectLater(
      files.moveWithin(1, folder, folder.id!),
      throwsStateError,
    );
    await tester.pumpWidget(const SizedBox());
    files.dispose();
    unawaited(gateway.events.close());
    await tester.pump();
  });

  test('ancestor column actions keep their destination and deletion repairs the path', () async {
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    await files.open(
      const GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1),
    );
    await Future<void>.delayed(Duration.zero);
    await files.create('Parent', NodeKind.folder);
    final parent = files.selected!;
    await files.openFolder(parent);
    await files.create('Sibling', NodeKind.folder, parentId: 0);
    expect(files.nodes, isEmpty);
    expect(files.folders.directory(0).length, 2);
    await files.delete(parent);
    expect(files.parentId, 0);
    expect(files.nodes.single.name, 'Sibling');
    await files.close();
    files.dispose();
    await gateway.events.close();
  });
  testWidgets('views share selection and cached empty-folder navigation', (
    tester,
  ) async {
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    await files.open(
      const GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1),
    );
    await files.create('Empty', NodeKind.folder);
    final folder = files.selected!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            child: FilesView(
              controller: files,
              userId: 'account',
              onBackToDrives: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final calls = gateway.listCalls;
    await tester.tap(find.byTooltip('Grid view'));
    await tester.pumpAndSettle();
    expect(files.viewMode, FileViewMode.grid);
    expect(files.selected?.id, folder.id);
    expect(gateway.listCalls, calls);
    await tester.tap(find.text('Empty').last);
    await tester.pumpAndSettle();
    expect(files.parentId, 0);
    await tester.tap(find.text('Empty').last, buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();
    expect(find.text('Delete…'), findsOneWidget);
    await tester.tap(find.text('Delete…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(gateway.nodes.single.deleted, isFalse);
    await files.openFolder(folder);
    await tester.tap(find.byTooltip('Column view'));
    await tester.pumpAndSettle();
    expect(find.byType(DirectoryColumn), findsNWidgets(2));
    expect(
      tester.getSize(find.byType(DirectoryColumn).first).width,
      tester.getSize(find.byType(DirectoryColumn).last).width,
    );
    expect(files.nodes, isEmpty);
    expect(gateway.listCalls, calls);
    await files.goTo(0);
    await tester.pumpAndSettle();
    expect(find.byType(DirectoryColumn), findsOneWidget);
    expect(
      tester.getSize(find.byType(DirectoryColumn)).width,
      greaterThan(240),
    );
    await tester.tap(find.byTooltip('List view'));
    await tester.pumpAndSettle();
    expect(files.nodes.single.id, folder.id);
    await tester.tap(find.text('Empty').last, buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(gateway.nodes.single.deleted, isTrue);
    expect(files.nodes, isEmpty);
    await tester.pumpWidget(const SizedBox());
    files.dispose();
    unawaited(gateway.events.close());
    await tester.pump();
  });

  test(
    'hosted file opening uses the account and native provider item',
    () async {
      final gateway = FilesFixture();
      final files = FilesController(gateway);
      final finder = TestFinder();
      final garden = GardenController(
        TestGateway(),
        MemoryPreferences(),
        files: files,
        finder: finder,
      );
      garden.account = const AccountInfo(
        id: 'account',
        email: 'test@example.com',
      );
      final node = await gateway.create(7, 0, 'movie.mp4', NodeKind.file);
      await files.openFile!(node);
      expect(finder.openedID, 7);
      expect(finder.openedNodeID, node.id);
      garden.dispose();
      await files.close();
      files.dispose();
      unawaited(gateway.events.close());
      await Future<void>.delayed(Duration.zero);
    },
  );
}
