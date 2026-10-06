import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/files/node_menu_items.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/native/finder_previews.dart';
import 'package:garden_flutter/state/files_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';

import 'files_gateway_fixture.dart';
import 'widget_test.dart' show TestFinder, TestGateway, MemoryPreferences;

class PreviewFinder extends TestFinder implements FinderPreviews {
  String? previewedAccount;
  int? previewedNode;
  @override
  Future<void> previewNode(AccountInfo account, int driveID, int nodeID) async {
    previewedAccount = account.id;
    previewedNode = nodeID;
  }
}

void main() {
  test('preview uses current account and rejects signed-out access', () async {
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    final finder = PreviewFinder();
    final garden = GardenController(
      TestGateway(),
      MemoryPreferences(),
      files: files,
      finder: finder,
    );
    final node = await gateway.create(7, 0, 'image.png', NodeKind.file);
    garden.account = const AccountInfo(id: 'first', email: 'first@example.com');
    await files.previewFile!(node);
    expect(finder.previewedNode, node.id);
    expect(finder.previewedAccount, 'first');
    garden.account = const AccountInfo(
      id: 'second',
      email: 'second@example.com',
    );
    await files.previewFile!(node);
    expect(finder.previewedAccount, 'second');
    garden.account = null;
    await expectLater(files.previewFile!(node), throwsStateError);
    garden.dispose();
    files.dispose();
    await gateway.events.close();
  });

  test(
    'Quick Look supports read-only files and requires a preview provider',
    () async {
      final gateway = FilesFixture();
      final file = await gateway.create(7, 0, 'sound.wav', NodeKind.file);
      final folder = await gateway.create(7, 0, 'Folder', NodeKind.folder);
      List<String?> values(FileNode node, bool available) => nodeMenuItems(
        node,
        canWrite: false,
        canPreview: available,
      ).whereType<PopupMenuItem<String>>().map((item) => item.value).toList();
      expect(values(file, true), contains('preview'));
      expect(values(file, false), isNot(contains('preview')));
      expect(values(folder, true), isNot(contains('preview')));
      await gateway.events.close();
    },
  );
}
