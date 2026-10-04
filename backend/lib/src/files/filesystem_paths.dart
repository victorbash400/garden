import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class FilesystemPaths {
  FilesystemPaths(this.session, this.gardenId, this.transaction);
  final Session session;
  final int gardenId;
  final Transaction transaction;

  static Never fail(FilesystemError code, String message) =>
      throw FilesystemException(code: code, message: message);

  static List<String> components(String path) {
    if (path == '/') return [];
    if (!path.startsWith('/') || utf8.encode(path).length > 1024) {
      fail(FilesystemError.invalid, 'Invalid filesystem path.');
    }
    final parts = path.substring(1).split('/');
    for (final name in parts) {
      if (name.isEmpty ||
          name == '.' ||
          name == '..' ||
          utf8.encode(name).length > 255 ||
          name.contains(':') ||
          name.codeUnits.any((unit) => unit < 32)) {
        fail(FilesystemError.invalid, 'Invalid filesystem name.');
      }
    }
    return parts;
  }

  Future<FileNode?> child(int parent, String name) => FileNode.db.findFirstRow(
    session,
    where: (row) =>
        row.gardenId.equals(gardenId) &
        row.parentId.equals(parent) &
        row.activeName.equals(name.toLowerCase()),
    transaction: transaction,
  );

  Future<({int parent, String name, FileNode? node})> address(
    String path,
  ) async {
    final parts = components(path);
    if (parts.isEmpty) {
      fail(FilesystemError.busy, 'The drive root cannot be changed.');
    }
    var parent = 0;
    for (final name in parts.take(parts.length - 1)) {
      final node = await child(parent, name);
      if (node == null) {
        fail(FilesystemError.notFound, 'Parent folder does not exist.');
      }
      if (node.kind != NodeKind.folder) {
        fail(FilesystemError.notDirectory, 'Parent is not a folder.');
      }
      parent = node.id!;
    }
    final name = parts.last;
    return (parent: parent, name: name, node: await child(parent, name));
  }

  Future<void> requireEmpty(FileNode node) async {
    final child = await FileNode.db.findFirstRow(
      session,
      where: (row) =>
          row.gardenId.equals(gardenId) &
          row.parentId.equals(node.id!) &
          row.deleted.equals(false),
      transaction: transaction,
    );
    if (child != null) fail(FilesystemError.notEmpty, 'Folder is not empty.');
  }

  Future<void> preventCycle(int source, int parent) async {
    var ancestor = parent;
    final visited = <int>{};
    while (ancestor != 0) {
      if (ancestor == source || !visited.add(ancestor)) {
        fail(
          FilesystemError.invalid,
          'A folder cannot be moved inside itself.',
        );
      }
      final node = await FileNode.db.findById(
        session,
        ancestor,
        transaction: transaction,
      );
      if (node == null || node.gardenId != gardenId || node.deleted) {
        fail(FilesystemError.notFound, 'Parent folder does not exist.');
      }
      ancestor = node.parentId;
    }
  }
}
