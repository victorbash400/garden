import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'drive_access.dart';
import 'drive_journal.dart';

class FilesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<DirectoryListing> list(Session session, int gardenId, int parentId) =>
      session.db.transaction((transaction) async {
        final drive = await DriveAccess.lock(session, gardenId, transaction);
        await DriveAccess.parent(session, gardenId, parentId, transaction);
        final nodes = await FileNode.db.find(
          session,
          where: (row) =>
              row.gardenId.equals(gardenId) &
              row.parentId.equals(parentId) &
              row.deleted.equals(false),
          orderBy: (row) => row.name,
          transaction: transaction,
        );
        return DirectoryListing(revision: drive.revision, nodes: nodes);
      });

  Future<FileNode> create(
    Session session,
    int gardenId,
    int parentId,
    String name,
    NodeKind kind,
  ) async {
    final clean = DriveAccess.name(name);
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(session, gardenId, transaction);
      await DriveAccess.parent(session, gardenId, parentId, transaction);
      await DriveAccess.available(
        session,
        gardenId,
        parentId,
        clean,
        transaction,
      );
      final node = await FileNode.db.insertRow(
        session,
        FileNode(
          gardenId: gardenId,
          parentId: parentId,
          name: clean,
          activeName: clean.toLowerCase(),
          kind: kind,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
      return DriveJournal.append(session, drive, transaction, 'create', node);
    });
    await DriveJournal.publish(session, event);
    return event.node!;
  }

  Future<FileNode> move(
    Session session,
    int nodeId,
    int parentId,
    String name,
  ) async {
    final original = await DriveAccess.node(session, nodeId);
    final clean = DriveAccess.name(name);
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        original.gardenId,
        transaction,
      );
      final node = await DriveAccess.node(
        session,
        nodeId,
        transaction: transaction,
      );
      await DriveAccess.parent(session, node.gardenId, parentId, transaction);
      await DriveAccess.available(
        session,
        node.gardenId,
        parentId,
        clean,
        transaction,
        except: node.id,
      );
      var ancestor = parentId;
      while (ancestor != 0) {
        if (ancestor == node.id) {
          throw GardenException(
            message: 'A folder cannot be moved inside itself.',
          );
        }
        ancestor = (await DriveAccess.node(
          session,
          ancestor,
          transaction: transaction,
        )).parentId;
      }
      node.parentId = parentId;
      node.name = clean;
      node.activeName = clean.toLowerCase();
      node.updatedAt = DateTime.now().toUtc();
      await FileNode.db.updateRow(session, node, transaction: transaction);
      return DriveJournal.append(session, drive, transaction, 'move', node);
    });
    await DriveJournal.publish(session, event);
    return event.node!;
  }

  Future<void> delete(Session session, int nodeId) async {
    final original = await DriveAccess.node(session, nodeId);
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        original.gardenId,
        transaction,
      );
      final node = await DriveAccess.node(
        session,
        nodeId,
        transaction: transaction,
      );
      final children = await FileNode.db.count(
        session,
        where: (row) => row.parentId.equals(nodeId) & row.deleted.equals(false),
        transaction: transaction,
      );
      if (children != 0) {
        throw GardenException(message: 'Empty this folder before deleting it.');
      }
      node.deleted = true;
      node.activeName = null;
      node.updatedAt = DateTime.now().toUtc();
      await FileNode.db.updateRow(session, node, transaction: transaction);
      return DriveJournal.append(session, drive, transaction, 'delete', node);
    });
    await DriveJournal.publish(session, event);
  }

  Stream<DriveEvent> watch(Session session, int gardenId, int afterRevision) =>
      DriveJournal.watch(session, gardenId, afterRevision);
}
