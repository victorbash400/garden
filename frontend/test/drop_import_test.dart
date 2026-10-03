import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/services/files/drop_import.dart';
import 'package:garden_flutter/state/file_import_controller.dart';

import 'files_gateway_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('desktop_drop');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  test(
    'dropped empty folder reports success and releases macOS access',
    () async {
      final source = await Directory.systemTemp.createTemp('garden-drop-');
      final gateway = FilesFixture();
      final imports = FileImportController(gateway, (_, _) {});
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return true;
      });
      try {
        await DropImport.run(imports, 7, 42, [
          DropItemDirectory(
            source.path,
            [],
            extraAppleBookmark: Uint8List.fromList([1]),
          ),
        ]);
        expect(gateway.nodes.single.gardenId, 7);
        expect(gateway.nodes.single.parentId, 42);
        expect(imports.result, '1 item imported');
        expect(imports.error, isNull);
        expect(calls, [
          'startAccessingSecurityScopedResource',
          'stopAccessingSecurityScopedResource',
        ]);
      } finally {
        messenger.setMockMethodCallHandler(channel, null);
        imports.dispose();
        await gateway.events.close();
        await source.delete();
      }
    },
  );

  test(
    'denied macOS access stops the drop before creating remote nodes',
    () async {
      final gateway = FilesFixture();
      final imports = FileImportController(gateway, (_, _) {});
      messenger.setMockMethodCallHandler(channel, (_) async => false);
      try {
        await expectLater(
          DropImport.run(imports, 1, 0, [
            DropItemFile(
              '/denied.txt',
              extraAppleBookmark: Uint8List.fromList([1]),
            ),
          ]),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('macOS denied access'),
            ),
          ),
        );
        expect(gateway.nodes, isEmpty);
        expect(imports.busy, isFalse);
      } finally {
        messenger.setMockMethodCallHandler(channel, null);
        imports.dispose();
        await gateway.events.close();
      }
    },
  );
}
