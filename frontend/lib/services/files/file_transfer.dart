import 'dart:typed_data';

import '../activity_log.dart';

import 'package:garden_client/garden_client.dart';

import 'files_gateway.dart';
import '../bandwidth_store.dart';
import 'direct_files_gateway.dart';
import 'direct_download.dart';
import 'multipart_transfer.dart';
import 'transfer_cancellation.dart';

class FileTransfer {
  const FileTransfer(this.gateway);
  static const chunkSize = 256 * 1024;
  final FilesGateway gateway;

  Future<FileNode> upload(
    FileNode node,
    int size,
    Stream<List<int>> input, {
    void Function(int)? onProgress,
    TransferCancellation? cancellation,
    void Function()? onCommit,
  }) async {
    final watch = Stopwatch()..start();
    try {
      final saved = await _upload(
        node,
        size,
        input,
        onProgress: onProgress,
        cancellation: cancellation,
        onCommit: onCommit,
      );
      ActivityLog.instance.record(
        node.gardenId,
        node.name,
        'Upload',
        bytes: size,
        milliseconds: watch.elapsedMicroseconds / 1000,
      );
      return saved;
    } catch (failure) {
      ActivityLog.instance.record(
        node.gardenId,
        node.name,
        'Upload failed',
        milliseconds: watch.elapsedMicroseconds / 1000,
        error: failure.toString(),
      );
      rethrow;
    }
  }

  Future<FileNode> _upload(
    FileNode node,
    int size,
    Stream<List<int>> input, {
    void Function(int)? onProgress,
    TransferCancellation? cancellation,
    void Function()? onCommit,
  }) async {
    cancellation?.check();
    if (gateway is DirectFilesGateway && size > chunkSize) {
      final direct = gateway as DirectFilesGateway;
      final version = await direct.beginMultipart(node.id!, node.version, size);
      await MultipartTransfer(direct).upload(
        version,
        input,
        onProgress: onProgress,
        cancellation: cancellation,
      );
      cancellation?.check();
      onCommit?.call();
      return gateway.finish(version.id!);
    }
    final version = await gateway.begin(node.id!, node.version, size);
    var buffer = BytesBuilder(copy: false);
    var index = 0;
    var sent = 0;
    await for (final bytes in input) {
      cancellation?.check();
      var offset = 0;
      while (offset < bytes.length) {
        final remaining = chunkSize - buffer.length;
        final end = (offset + remaining).clamp(0, bytes.length);
        buffer.add(bytes.sublist(offset, end));
        offset = end;
        if (buffer.length == chunkSize) {
          cancellation?.check();
          final data = buffer.takeBytes();
          await BandwidthStore.pace(data.length, upload: true);
          cancellation?.check();
          await gateway.writeChunk(
            version.id!,
            index++,
            ByteData.sublistView(data),
          );
          sent += data.length;
          onProgress?.call(sent);
        }
      }
    }
    if (buffer.isNotEmpty) {
      cancellation?.check();
      final data = buffer.takeBytes();
      await BandwidthStore.pace(data.length, upload: true);
      cancellation?.check();
      await gateway.writeChunk(
        version.id!,
        index++,
        ByteData.sublistView(data),
      );
      sent += data.length;
      onProgress?.call(sent);
    }
    if (sent != size) throw StateError('The file changed during upload.');
    cancellation?.check();
    onCommit?.call();
    return gateway.finish(version.id!);
  }

  Stream<List<int>> download(FileNode node, {FileVersion? version}) async* {
    final size = version?.size ?? node.size;
    final id = version?.id ?? node.version;
    if (gateway is DirectFilesGateway && size > 0) {
      final direct = gateway as DirectFilesGateway;
      final ticket = await direct.downloadTicket(node.id!, id);
      if (ticket.size != size) {
        throw StateError('File version size does not match.');
      }
      if (ticket.url != null) {
        yield* DirectDownload(direct).read(node.id!, id, ticket);
        return;
      }
    }
    var offset = 0;
    while (offset < size) {
      final length = (size - offset).clamp(0, chunkSize);
      await BandwidthStore.pace(length, upload: false);
      final data = await gateway.read(node.id!, id, offset, length);
      if (data.lengthInBytes != length) {
        throw StateError('File content is incomplete.');
      }
      offset += data.lengthInBytes;
      yield data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
  }
}
