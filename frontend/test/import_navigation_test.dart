import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/services/files/import_entry.dart';
import 'package:garden_flutter/state/files_controller.dart';

import 'files_gateway_fixture.dart';

const drive = GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1);

class PendingUpload extends FilesFixture {
  final started = Completer<void>();
  final resume = Completer<void>();
  @override
  Future<void> writeChunk(int versionId, int index, ByteData data) async {
    if (!started.isCompleted) started.complete();
    await resume.future;
    await super.writeChunk(versionId, index, data);
  }
}

void main() {
  test('folder imports preserve nested and empty directories', () async {
    final source = await Directory.systemTemp.createTemp('garden-import-');
    final root = await Directory('${source.path}/Project').create();
    await Directory('${root.path}/Empty').create();
    final nested = await Directory('${root.path}/Nested').create();
    await File('${nested.path}/notes.txt').writeAsString('hello');
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    try {
      await files.open(drive);
      await files.imports.import(1, 0, [await ImportEntry.fromPath(root.path)]);
      expect(files.imports.error, isNull);
      expect(files.imports.completed, 1);
      expect(files.imports.result, '4 items imported');
      final project = gateway.nodes.singleWhere((n) => n.name == 'Project');
      final folder = gateway.nodes.singleWhere((n) => n.name == 'Nested');
      final note = gateway.nodes.singleWhere((n) => n.name == 'notes.txt');
      expect(folder.parentId, project.id);
      expect(note.parentId, folder.id);
      expect(note.size, 5);
      expect(gateway.nodes.any((n) => n.name == 'Empty'), isTrue);
      await files.openFolder(folder);
      expect(files.nodes.single.name, 'notes.txt');
      await files.openFolder(
        gateway.nodes.singleWhere((n) => n.name == 'Empty'),
      );
      expect(files.nodes, isEmpty);
    } finally {
      await files.close();
      files.dispose();
      await gateway.events.close();
      await source.delete(recursive: true);
    }
  });

  test('navigation remains available during upload and cancellation removes incomplete file', () async {
    final gateway = PendingUpload();
    final files = FilesController(gateway);
    await files.open(drive);
    await Future<void>.delayed(Duration.zero);
    await files.create('Empty', NodeKind.folder);
    final folder = files.selected!;
    final upload = files.imports.import(1, 0, [
      ImportFile('large.bin', 300000, () => Stream.value(Uint8List(300000))),
    ]);
    await gateway.started.future;
    expect(files.imports.busy, isTrue);
    expect(files.busy, isFalse);
    await files.openFolder(folder);
    expect(files.parentId, folder.id);
    files.imports.cancel();
    gateway.resume.complete();
    await upload;
    expect(files.imports.result, contains('cancelled'));
    expect(
      gateway.nodes.singleWhere((n) => n.name == 'large.bin').deleted,
      isTrue,
    );
    expect(gateway.uploads.values.any((v) => v.committed), isFalse);
    expect(files.nodes, isEmpty);
    await files.close();
    files.dispose();
    await gateway.events.close();
  });

  test('returning to a drive restores its directory and replays changes without listing', () async {
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    await files.open(drive);
    await Future<void>.delayed(Duration.zero);
    await files.create('Nested', NodeKind.folder);
    final folder = files.selected!;
    await files.openFolder(folder);
    await files.open(
      const GardenInfo(id: 2, name: 'Other', role: 'Owner', members: 1),
    );
    await Future<void>.delayed(Duration.zero);
    await gateway.create(1, folder.id!, 'Remote.txt', NodeKind.file);
    final calls = gateway.listCalls;
    await files.open(drive);
    await Future<void>.delayed(Duration.zero);
    expect(files.parentId, folder.id);
    expect(files.nodes.single.name, 'Remote.txt');
    expect(gateway.listCalls, calls);
    await files.close();
    files.dispose();
    await gateway.events.close();
  });
}
