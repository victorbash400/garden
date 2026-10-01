import 'dart:typed_data';

import 'package:garden_client/garden_client.dart';

abstract interface class FilesGateway {
  Future<String> invite(int driveId);
  Future<DirectoryListing> list(int driveId, int parentId);
  Stream<DriveEvent> watch(int driveId, int revision);
  Future<FileNode> create(
    int driveId,
    int parentId,
    String name,
    NodeKind kind,
  );
  Future<FileNode> move(int nodeId, int parentId, String name);
  Future<void> delete(int nodeId);
  Future<FileVersion> begin(int nodeId, int baseVersion, int size);
  Future<void> writeChunk(int versionId, int index, ByteData data);
  Future<FileNode> finish(int versionId);
  Future<ByteData> read(int nodeId, int versionId, int offset, int length);
  Future<List<FileVersion>> versions(int nodeId);
  Future<List<FileComment>> comments(int nodeId);
  Future<FileComment> comment(int nodeId, String text);
  Future<FileLease> acquire(int nodeId);
  Future<void> release(int nodeId, String token);
}
