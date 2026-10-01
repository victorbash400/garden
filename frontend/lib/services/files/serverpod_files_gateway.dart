import 'dart:typed_data';

import 'package:garden_client/garden_client.dart';

import 'files_gateway.dart';

class ServerpodFilesGateway implements FilesGateway {
  const ServerpodFilesGateway(this.client);
  final Client client;
  @override
  Future<String> invite(int driveId) => client.garden.invite(driveId);
  @override
  Future<DirectoryListing> list(int driveId, int parentId) =>
      client.files.list(driveId, parentId);
  @override
  Stream<DriveEvent> watch(int driveId, int revision) =>
      client.files.watch(driveId, revision);
  @override
  Future<FileNode> create(
    int driveId,
    int parentId,
    String name,
    NodeKind kind,
  ) => client.files.create(driveId, parentId, name, kind);
  @override
  Future<FileNode> move(int nodeId, int parentId, String name) =>
      client.files.move(nodeId, parentId, name);
  @override
  Future<void> delete(int nodeId) => client.files.delete(nodeId);
  @override
  Future<FileVersion> begin(int nodeId, int baseVersion, int size) =>
      client.content.begin(nodeId, baseVersion, size);
  @override
  Future<void> writeChunk(int versionId, int index, ByteData data) =>
      client.content.writeChunk(versionId, index, data);
  @override
  Future<FileNode> finish(int versionId) => client.content.finish(versionId);
  @override
  Future<ByteData> read(int nodeId, int versionId, int offset, int length) =>
      client.content.read(nodeId, versionId, offset, length);
  @override
  Future<List<FileVersion>> versions(int nodeId) =>
      client.content.versions(nodeId);
  @override
  Future<List<FileComment>> comments(int nodeId) =>
      client.collaboration.comments(nodeId);
  @override
  Future<FileComment> comment(int nodeId, String text) =>
      client.collaboration.comment(nodeId, text);
  @override
  Future<FileLease> acquire(int nodeId) => client.collaboration.acquire(nodeId);
  @override
  Future<void> release(int nodeId, String token) =>
      client.collaboration.release(nodeId, token);
}
