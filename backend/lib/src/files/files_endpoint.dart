import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../gardens/drive_permissions.dart';
import 'drive_access.dart';
import 'drive_journal.dart';

class FilesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<FileNode> get(Session session, int nodeId) =>
      DriveAccess.node(session, nodeId);

  Future<List<DriveEvent>> changes(
    Session session,
    int gardenId,
    int afterRevision,
  ) async {
    if (afterRevision < 0) {
      throw GardenException(message: 'Invalid revision.');
    }
    await DriveAccess.require(session, gardenId);
    return DriveEvent.db.find(
      session,
      where: (row) =>
          row.gardenId.equals(gardenId) & (row.revision > afterRevision),
      orderBy: (row) => row.revision,
      limit: 256,
    );
  }

  Future<List<FileNode>> snapshot(
    Session session,
    int gardenId,
    int afterNodeId,
  ) async {
    if (afterNodeId < 0) {
      throw GardenException(message: 'Invalid file cursor.');
    }
    await DriveAccess.require(session, gardenId);
    return FileNode.db.find(
      session,
      where: (row) =>
          row.gardenId.equals(gardenId) &
          (row.id > afterNodeId) &
          row.deleted.equals(false),
      orderBy: (row) => row.id,
      limit: 256,
    );
  }

  Future<int> revision(Session session, int gardenId) => session.db.transaction(
    (transaction) async => (await DriveAccess.lock(
      session,
      gardenId,
      transaction,
      mode: LockMode.forShare,
      capability: DriveCapability.read,
    )).revision,
  );

  Future<List<FileNode>> listPage(
    Session session,
    int gardenId,
    int parentId,
    int afterNodeId,
  ) => session.db.transaction((transaction) async {
    if (afterNodeId < 0) {
      throw GardenException(message: 'Invalid file cursor.');
    }
    await DriveAccess.lock(
      session,
      gardenId,
      transaction,
      mode: LockMode.forShare,
      capability: DriveCapability.read,
    );
    await DriveAccess.parent(session, gardenId, parentId, transaction);
    return FileNode.db.find(
      session,
      where: (row) =>
          row.gardenId.equals(gardenId) &
          row.parentId.equals(parentId) &
          row.deleted.equals(false) &
          (row.id > afterNodeId),
      orderBy: (row) => row.id,
      limit: 256,
      transaction: transaction,
    );
  });

  Future<DirectoryListing> list(Session session, int gardenId, int parentId) =>
      session.db.transaction((transaction) async {
        final drive = await DriveAccess.lock(
          session,
          gardenId,
          transaction,
          mode: LockMode.forShare,
          capability: DriveCapability.read,
        );
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
      final previousParentId = node.parentId;
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
      return DriveJournal.append(
        session,
        drive,
        transaction,
        'move',
        node,
        previousParentId: previousParentId,
      );
    });
    await DriveJournal.publish(session, event);
    return event.node!;
  }

  Future<void> delete(Session session, int nodeId) async {
    final original = await DriveAccess.node(session, nodeId);
    final events = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        original.gardenId,
        transaction,
      );
      final root = await DriveAccess.node(
        session,
        nodeId,
        transaction: transaction,
      );
      final nodes = <FileNode>[root];
      var folders = root.kind == NodeKind.folder ? [root.id!] : <int>[];
      while (folders.isNotEmpty) {
        final children = await FileNode.db.find(
          session,
          where: (row) =>
              row.gardenId.equals(root.gardenId) &
              row.parentId.inSet(folders.toSet()) &
              row.deleted.equals(false),
          transaction: transaction,
        );
        nodes.addAll(children);
        folders = children
            .where((child) => child.kind == NodeKind.folder)
            .map((child) => child.id!)
            .toList();
      }
      final deleted = await FileNode.db.updateWhere(
        session,
        columnValues: (row) => [
          row.deleted(true),
          row.activeName(null),
          row.updatedAt(DateTime.now().toUtc()),
        ],
        where: (row) => row.id.inSet(nodes.map((node) => node.id!).toSet()),
        transaction: transaction,
      );
      final events = <DriveEvent>[];
      for (final node in deleted) {
        events.add(
          await DriveJournal.append(
            session,
            drive,
            transaction,
            'delete',
            node,
          ),
        );
      }
      return events;
    });
    for (final event in events) {
      await DriveJournal.publish(session, event);
    }
  }

  Stream<DriveEvent> watch(Session session, int gardenId, int afterRevision) =>
      DriveJournal.watch(session, gardenId, afterRevision);
}
