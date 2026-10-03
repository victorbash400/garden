import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';

import '../../state/file_import_controller.dart';
import 'import_entry.dart';

class DropImport {
  static Future<void> run(
    FileImportController controller,
    int driveId,
    int parentId,
    List<DropItem> items,
  ) async {
    final access = <Uint8List>[];
    try {
      if (controller.busy) throw StateError('An import is already running.');
      final entries = <ImportEntry>[];
      for (final item in items) {
        final bookmark = item.extraAppleBookmark;
        if (bookmark != null && bookmark.isNotEmpty) {
          final granted = await DesktopDrop.instance
              .startAccessingSecurityScopedResource(bookmark: bookmark);
          if (!granted) {
            throw StateError('macOS denied access to ${item.name}.');
          }
          access.add(bookmark);
        }
        entries.add(await ImportEntry.fromPath(item.path));
      }
      await controller.import(driveId, parentId, entries);
    } finally {
      await Future.wait(
        access.reversed.map((bookmark) async {
          final released = await DesktopDrop.instance
              .stopAccessingSecurityScopedResource(bookmark: bookmark);
          if (!released) {
            throw StateError('macOS could not release dropped file access.');
          }
        }),
      );
    }
  }
}
