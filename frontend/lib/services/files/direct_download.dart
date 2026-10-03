import 'dart:io';
import 'dart:math';

import 'package:garden_client/garden_client.dart';

import 'direct_files_gateway.dart';

class DirectDownload {
  const DirectDownload(this.gateway);
  final DirectFilesGateway gateway;

  Stream<List<int>> read(
    int nodeId,
    int versionId,
    ContentDownload ticket,
  ) async* {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      var offset = 0;
      while (offset < ticket.size) {
        if (ticket.expiresAt.difference(DateTime.now()).inSeconds < 30) {
          final refreshed = await gateway.downloadTicket(nodeId, versionId);
          if (refreshed.size != ticket.size) {
            throw StateError('File version changed during download.');
          }
          ticket = refreshed;
        }
        final url = Uri.parse(ticket.url!);
        if (url.scheme != 'https') throw StateError('Invalid download URL.');
        final end = min(offset + 4 * 1024 * 1024, ticket.size) - 1;
        final request = await client.getUrl(url);
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-$end');
        final response = await request.close();
        if (response.statusCode != HttpStatus.partialContent ||
            response.headers.value(HttpHeaders.contentRangeHeader) !=
                'bytes $offset-$end/${ticket.size}') {
          throw HttpException(
            'Invalid file range response (${response.statusCode}).',
          );
        }
        var received = 0;
        await for (final bytes in response) {
          received += bytes.length;
          if (received > end - offset + 1) {
            throw StateError('File range exceeds its expected length.');
          }
          yield bytes;
        }
        if (received != end - offset + 1) {
          throw StateError('File content is incomplete.');
        }
        offset = end + 1;
      }
    } finally {
      client.close(force: true);
    }
  }
}
