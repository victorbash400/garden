import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'drive_journal.dart';
import 'filesystem_paths.dart';
import 'filesystem_attributes.dart';

class FilesystemMutations {
  FilesystemMutations(this.session, this.drive, this.transaction)
    : paths = FilesystemPaths(session, drive.id!, transaction);
  final Session session;
  final GardenRecord drive;
  final Transaction transaction;
  final FilesystemPaths paths;

  Future<List<DriveEvent>> apply(FilesystemRequest request) async {
    final source = await paths.address(request.path);
    final node = source.node;
    switch (request.operation) {
      case FilesystemOperation.createFile:
      case FilesystemOperation.createFolder:
        if (node != null) {
          FilesystemPaths.fail(
            FilesystemError.alreadyExists,
            'File or folder already exists.',
          );
        }
        final created = await FileNode.db.insertRow(
          session,
          FileNode(
            gardenId: drive.id!,
            parentId: source.parent,
            name: source.name,
            activeName: source.name.toLowerCase(),
            kind: request.operation == FilesystemOperation.createFolder
                ? NodeKind.folder
                : NodeKind.file,
            updatedAt: DateTime.now().toUtc(),
            createdAt: DateTime.now().toUtc(),
          ),
          transaction: transaction,
        );
        return [await event('create', created)];
      case FilesystemOperation.setAttributes:
      case FilesystemOperation.setExtendedAttribute:
      case FilesystemOperation.removeExtendedAttribute:
        if (node == null) {
          FilesystemPaths.fail(
            FilesystemError.notFound,
            'File or folder does not exist.',
          );
        }
        if (!FilesystemAttributes.apply(node, request)) return [];
        await FileNode.db.updateRow(session, node, transaction: transaction);
        return [await event('update', node)];
      case FilesystemOperation.unlink:
      case FilesystemOperation.rmdir:
        if (node == null) {
          FilesystemPaths.fail(
            FilesystemError.notFound,
            'File or folder does not exist.',
          );
        }
        if (request.operation == FilesystemOperation.unlink &&
            node.kind == NodeKind.folder) {
          FilesystemPaths.fail(
            FilesystemError.isDirectory,
            'Use folder removal for a folder.',
          );
        }
        if (request.operation == FilesystemOperation.rmdir) {
          if (node.kind != NodeKind.folder) {
            FilesystemPaths.fail(
              FilesystemError.notDirectory,
              'Item is not a folder.',
            );
          }
          await paths.requireEmpty(node);
        }
        return [await remove(node)];
      case FilesystemOperation.rename:
        if (node == null) {
          FilesystemPaths.fail(
            FilesystemError.notFound,
            'File or folder does not exist.',
          );
        }
        final destination = request.destination;
        if (destination == null) {
          FilesystemPaths.fail(
            FilesystemError.invalid,
            'Missing rename destination.',
          );
        }
        final target = await paths.address(destination);
        if (node.kind == NodeKind.folder) {
          await paths.preventCycle(node.id!, target.parent);
        }
        final replaced = target.node;
        final events = <DriveEvent>[];
        if (replaced != null && replaced.id != node.id) {
          if (request.noReplace) {
            FilesystemPaths.fail(
              FilesystemError.alreadyExists,
              'Destination already exists.',
            );
          }
          if (node.kind != replaced.kind) {
            FilesystemPaths.fail(
              replaced.kind == NodeKind.folder
                  ? FilesystemError.isDirectory
                  : FilesystemError.notDirectory,
              'Source and destination have different types.',
            );
          }
          if (replaced.kind == NodeKind.folder) {
            await paths.requireEmpty(replaced);
          }
          events.add(await remove(replaced));
        }
        if (node.parentId == target.parent && node.name == target.name) {
          return events;
        }
        final previous = node.parentId;
        node.parentId = target.parent;
        node.name = target.name;
        node.activeName = target.name.toLowerCase();
        node.updatedAt = DateTime.now().toUtc();
        await FileNode.db.updateRow(session, node, transaction: transaction);
        events.add(
          await DriveJournal.append(
            session,
            drive,
            transaction,
            'move',
            node,
            previousParentId: previous,
          ),
        );
        return events;
    }
  }

  Future<DriveEvent> event(String operation, FileNode node) =>
      DriveJournal.append(session, drive, transaction, operation, node);

  Future<DriveEvent> remove(FileNode node) async {
    node.deleted = true;
    node.activeName = null;
    node.updatedAt = DateTime.now().toUtc();
    await FileNode.db.updateRow(session, node, transaction: transaction);
    return event('delete', node);
  }
}
