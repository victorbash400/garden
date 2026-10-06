import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:garden_client/garden_client.dart';

import 'direct_files_gateway.dart';
import '../bandwidth_store.dart';
import 'part_checksum.dart';
import 'transfer_cancellation.dart';

class MultipartTransfer {
  const MultipartTransfer(this.gateway);
  final DirectFilesGateway gateway;

  Future<int> upload(
    FileVersion version,
    Stream<List<int>> input, {
    void Function(int)? onProgress,
    TransferCancellation? cancellation,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    client.maxConnectionsPerHost = 3;
    final completed = {
      for (final part in await gateway.uploadedParts(version.id!))
        part.number: part,
    };
    final expected = <int, (int, String)>{};
    var sent = 0;
    var part = 1;
    var first = 0;
    var urls = <String>[];
    final pending = <Future<void>>{};
    (Object, StackTrace)? failure;
    try {
      await for (final bytes in parts(input, version.partSize!)) {
        if (failure case final error?) {
          Error.throwWithStackTrace(error.$1, error.$2);
        }
        cancellation?.check();
        final checksum = await partChecksum(bytes);
        cancellation?.check();
        expected[part] = (bytes.length, checksum);
        final previous = completed[part];
        if (previous != null &&
            previous.size == bytes.length &&
            previous.checksum == checksum) {
          sent += bytes.length;
          onProgress?.call(sent);
          part++;
          continue;
        }
        if (part >= first + urls.length) {
          first = part;
          urls = await gateway.uploadParts(
            version.id!,
            first,
            min(32, version.chunkCount - first + 1),
          );
        }
        final url = Uri.parse(urls[part - first]);
        late final Future<void> operation;
        operation = _put(client, url, bytes, cancellation)
            .then(
              (_) {
                sent += bytes.length;
                onProgress?.call(sent);
              },
              onError: (Object error, StackTrace stack) {
                failure ??= (error, stack);
              },
            )
            .whenComplete(() => pending.remove(operation));
        pending.add(operation);
        part++;
        if (pending.length == 3) {
          await Future.any(pending);
          if (failure case final error?) {
            Error.throwWithStackTrace(error.$1, error.$2);
          }
        }
      }
      await Future.wait(pending, eagerError: false);
      if (failure case final error?) {
        Error.throwWithStackTrace(error.$1, error.$2);
      }
      if (sent != version.size) {
        throw StateError('The file changed during upload.');
      }
      final verified = await gateway.uploadedParts(version.id!);
      if (verified.length != expected.length ||
          verified.map((part) => part.number).toSet().length !=
              expected.length ||
          verified.any((part) {
            final value = expected[part.number];
            return value == null ||
                value.$1 != part.size ||
                value.$2 != part.checksum;
          })) {
        throw StateError('Uploaded file checksums do not match.');
      }
      return sent;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _put(
    HttpClient client,
    Uri url,
    Uint8List bytes,
    TransferCancellation? cancellation,
  ) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _send(client, url, bytes, cancellation);
        return;
      } on SocketException {
        if (attempt == 2) rethrow;
      } on TimeoutException {
        if (attempt == 2) rethrow;
      }
      await Future<void>.delayed(Duration(milliseconds: 250 * (attempt + 1)));
    }
  }

  Future<void> _send(
    HttpClient client,
    Uri url,
    Uint8List bytes,
    TransferCancellation? cancellation,
  ) async {
    if (url.scheme != 'https') throw StateError('Invalid upload URL.');
    cancellation?.check();
    await BandwidthStore.pace(bytes.length, upload: true);
    cancellation?.check();
    final request = await client.putUrl(url);
    request.contentLength = bytes.length;
    request.add(bytes);
    final response = await request.close().timeout(const Duration(minutes: 2));
    await response.drain<void>();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('File part upload failed (${response.statusCode}).');
    }
    cancellation?.check();
  }

  static Stream<Uint8List> parts(Stream<List<int>> input, int size) async* {
    if (size <= 0) throw ArgumentError.value(size, 'size');
    var buffer = BytesBuilder(copy: false);
    await for (final bytes in input) {
      var offset = 0;
      while (offset < bytes.length) {
        final end = min(bytes.length, offset + size - buffer.length);
        buffer.add(bytes.sublist(offset, end));
        offset = end;
        if (buffer.length == size) yield buffer.takeBytes();
      }
    }
    if (buffer.isNotEmpty) yield buffer.takeBytes();
  }
}
