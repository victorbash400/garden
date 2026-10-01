import 'dart:async';
import 'dart:typed_data';

import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/services/files/files_gateway.dart';

class FilesFixture implements FilesGateway {
  final events = StreamController<DriveEvent>.broadcast();
  final nodes = <FileNode>[];
  final journal = <DriveEvent>[];
  final uploads = <int, FileVersion>{};
  final chunks = <int, List<Uint8List>>{};
  final notes = <FileComment>[];
  int revision = 0;
  int next = 1;
  bool failList = false;
  bool failSave = false;
  Completer<DirectoryListing>? pending;
  void publish(FileNode node, String operation) {
    final event = DriveEvent(
      gardenId: 1,
      revision: ++revision,
      operation: operation,
      authorId: 'account',
      node: node,
      createdAt: DateTime.now(),
    );
    journal.add(event);
    events.add(event);
  }

  @override
  Future<String> invite(int driveId) async => 'invitation';
  @override
  Future<DirectoryListing> list(int driveId, int parentId) async {
    if (failList) throw StateError('Cannot open folder.');
    if (pending != null) return pending!.future;
    return DirectoryListing(
      revision: revision,
      nodes: nodes
          .where((node) => node.parentId == parentId && !node.deleted)
          .toList(),
    );
  }

  @override
  Stream<DriveEvent> watch(int driveId, int revision) {
    final output = StreamController<DriveEvent>();
    final subscription = events.stream.listen(output.add);
    output.onListen = () {
      for (final event in journal.where((event) => event.revision > revision)) {
        output.add(event);
      }
      output.add(
        DriveEvent(
          gardenId: driveId,
          revision: this.revision,
          operation: 'ready',
          authorId: 'account',
          createdAt: DateTime.now(),
        ),
      );
    };
    output.onCancel = subscription.cancel;
    return output.stream;
  }

  @override
  Future<FileNode> create(
    int driveId,
    int parentId,
    String name,
    NodeKind kind,
  ) async {
    final node = FileNode(
      id: next++,
      gardenId: driveId,
      parentId: parentId,
      name: name,
      activeName: name.toLowerCase(),
      kind: kind,
      updatedAt: DateTime.now(),
    );
    nodes.add(node);
    publish(node, 'create');
    return node;
  }

  @override
  Future<FileNode> move(int nodeId, int parentId, String name) async {
    final node = nodes.firstWhere((node) => node.id == nodeId);
    node.parentId = parentId;
    node.name = name;
    publish(node, 'move');
    return node;
  }

  @override
  Future<void> delete(int nodeId) async {
    final node = nodes.firstWhere((node) => node.id == nodeId);
    node.deleted = true;
    publish(node, 'delete');
  }

  @override
  Future<FileVersion> begin(int nodeId, int baseVersion, int size) async {
    final version = FileVersion(
      id: next++,
      nodeId: nodeId,
      authorId: 'account',
      baseVersion: baseVersion,
      size: size,
      chunkCount: (size + 262143) ~/ 262144,
      createdAt: DateTime.now(),
    );
    uploads[version.id!] = version;
    chunks[version.id!] = [];
    return version;
  }

  @override
  Future<void> writeChunk(int versionId, int index, ByteData data) async {
    chunks[versionId]!.add(
      Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ),
    );
  }

  @override
  Future<FileNode> finish(int versionId) async {
    if (failSave) throw StateError('Cannot save file.');
    final version = uploads[versionId]!;
    version.committed = true;
    final node = nodes.firstWhere((node) => node.id == version.nodeId);
    node.version = versionId;
    node.size = version.size;
    publish(node, 'write');
    return node;
  }

  @override
  Future<ByteData> read(
    int nodeId,
    int versionId,
    int offset,
    int length,
  ) async {
    final bytes = Uint8List.fromList(
      chunks[versionId]?.expand((chunk) => chunk).toList() ?? [],
    );
    return ByteData.sublistView(
      bytes,
      offset,
      (offset + length).clamp(0, bytes.length),
    );
  }

  @override
  Future<List<FileVersion>> versions(int nodeId) async => uploads.values
      .where((version) => version.nodeId == nodeId && version.committed)
      .toList();
  @override
  Future<List<FileComment>> comments(int nodeId) async =>
      notes.where((note) => note.nodeId == nodeId).toList();
  @override
  Future<FileComment> comment(int nodeId, String text) async {
    final note = FileComment(
      nodeId: nodeId,
      authorId: 'account',
      text: text,
      createdAt: DateTime.now(),
    );
    notes.add(note);
    publish(nodes.firstWhere((node) => node.id == nodeId), 'comment');
    return note;
  }

  @override
  Future<FileLease> acquire(int nodeId) async => FileLease(
    nodeId: nodeId,
    holderId: 'account',
    token: 'lease',
    expiresAt: DateTime.now().add(const Duration(minutes: 2)),
  );
  @override
  Future<void> release(int nodeId, String token) async {}
}
