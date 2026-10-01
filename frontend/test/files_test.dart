import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/services/files/file_transfer.dart';
import 'package:garden_flutter/state/files_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/state/file_editor_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';

import 'files_gateway_fixture.dart';
import 'widget_test.dart' as auth;

const drive = GardenInfo(id: 1, name: 'Shared', role: 'Owner', members: 1);
void main() {
  test('snapshot buffers live changes and failed navigation keeps the current path', () async {
    final gateway = FilesFixture()..pending = Completer<DirectoryListing>();
    final controller = FilesController(gateway);
    final opening = controller.open(drive);
    await Future<void>.delayed(Duration.zero);
    final folder = await gateway.create(1, 0, 'Work', NodeKind.folder);
    gateway.pending!.complete(DirectoryListing(revision: 0, nodes: []));
    await opening;
    await Future<void>.delayed(Duration.zero);
    expect(controller.nodes.single.id, folder.id);
    gateway.pending = null;
    gateway.failList = true;
    await controller.enter(folder);
    expect(controller.path, isEmpty);
    expect(controller.error, contains('Cannot open folder'));
    await controller.close();
    await gateway.events.close();
    controller.dispose();
  });
  test('bounded transfers and failed saves preserve text', () async {
    final gateway = FilesFixture();
    final node = await gateway.create(1, 0, 'notes.txt', NodeKind.file);
    final bytes = Uint8List.fromList(
      List.generate(600000, (index) => 65 + index % 26),
    );
    final saved = await FileTransfer(gateway).upload(
      node,
      bytes.length,
      Stream.fromIterable([
        bytes.sublist(0, 19),
        bytes.sublist(19, 450000),
        bytes.sublist(450000),
      ]),
    );
    expect(gateway.chunks[saved.version]!.map((chunk) => chunk.length), [
      262144,
      262144,
      75712,
    ]);
    expect(
      await FileTransfer(gateway)
          .download(saved)
          .expand((chunk) => chunk)
          .toList(),
      bytes,
    );
    final editor = FileEditorController(gateway, saved);
    await editor.load();
    final original = editor.text;
    gateway.failSave = true;
    await editor.save('Unsaved edit');
    expect(editor.text, original);
    expect(editor.error, contains('Cannot save file'));
    editor.dispose();
    await gateway.events.close();
  });
  test('folder navigation, rename, move and delete keep the visible directory correct', () async {
    final gateway = FilesFixture();
    final controller = FilesController(gateway);
    await controller.open(drive);
    await controller.create('Work', NodeKind.folder);
    final folder = controller.selected!;
    expect(controller.folders.children(0).single.id, folder.id);
    await controller.openFolder(folder);
    await controller.create('Nested', NodeKind.folder);
    final nested = controller.selected!;
    expect(controller.folders.pathTo(nested).map((node) => node.name), [
      'Work',
      'Nested',
    ]);
    await controller.goTo(0);
    await controller.openFolder(nested);
    expect(controller.path.map((node) => node.name), ['Work', 'Nested']);
    await controller.goTo(1);
    await controller.delete(nested);
    expect(controller.folders.children(folder.id!), isEmpty);
    await controller.goTo(0);
    await controller.create('notes.txt', NodeKind.file);
    final file = controller.selected!;
    await controller.move(file, folder.id!, 'renamed.txt');
    expect(controller.nodes.map((node) => node.name), ['Work']);
    await controller.enter(folder);
    expect(controller.nodes.single.name, 'renamed.txt');
    await controller.delete(controller.nodes.single);
    expect(controller.nodes, isEmpty);
    await controller.goTo(0);
    await controller.delete(folder);
    expect(controller.nodes, isEmpty);
    await controller.close();
    expect(gateway.events.hasListener, isFalse);
    await gateway.events.close();
    controller.dispose();
  });

  testWidgets('open drive, create and edit text, then post a comment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    final controller = GardenController(
      auth.TestGateway(),
      auth.MemoryPreferences(),
      files: files,
    );
    await controller.signIn('demo@garden.local', 'garden-demo');
    await controller.connect(drive);
    await tester.pumpWidget(GardenApp(controller: controller));
    await tester.tap(find.text('Open drive'));
    await tester.pumpAndSettle();
    expect(find.text('This folder is empty'), findsOneWidget);
    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New text file…'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'notes.txt');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(files.busy, isFalse);
    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit text'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Saved from Garden');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(gateway.nodes.single.size, 17);
    await tester.tap(find.text('Comments'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ready');
    await tester.tap(find.byTooltip('Post comment'));
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    files.dispose();
    controller.dispose();
    unawaited(gateway.events.close());
    await tester.pump();
    expect(gateway.events.hasListener, isFalse);
  });
}
