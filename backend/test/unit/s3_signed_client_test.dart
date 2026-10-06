import 'package:garden_server/src/files/s3_signed_client.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class RecordingTransport extends http.BaseClient {
  int closes = 0;
  final requests = <http.Request>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (closes != 0) throw StateError('Transport is closed.');
    requests.add(request as http.Request);
    return http.StreamedResponse(Stream.value([1, 2, 3]), 206);
  }

  @override
  void close() => closes++;
}

void main() {
  test(
    'operation clients keep a borrowed transport available and sign each request',
    () async {
      final transport = RecordingTransport();
      for (final key in ['first', 'second']) {
        final client = S3SignedClient(
          'test-access',
          'test-secret',
          'us-east-1',
          transport: transport,
        );
        final response = await client.get(
          Uri.https('bucket.s3.amazonaws.com', '/$key'),
          headers: {'Range': 'bytes=0-2', 'Authorization': 'stale'},
        );
        expect(response.bodyBytes, [1, 2, 3]);
        client.close();
        expect(transport.closes, 0);
      }
      expect(transport.requests.map((request) => request.url.path), [
        '/first',
        '/second',
      ]);
      for (final request in transport.requests) {
        final headers = {
          for (final entry in request.headers.entries)
            entry.key.toLowerCase(): entry.value,
        };
        expect(headers['range'], 'bytes=0-2');
        expect(headers['authorization'], startsWith('AWS4-HMAC-SHA256 '));
        expect(headers['authorization'], isNot('stale'));
        expect(headers['x-amz-date'], isNotEmpty);
        expect(headers['x-amz-content-sha256'], isNotEmpty);
      }
      transport.close();
      expect(transport.closes, 1);
    },
  );

  test('a client with its own transport closes it', () async {
    final client = S3SignedClient('test-access', 'test-secret', 'us-east-1');
    client.close();
    await expectLater(
      client.transport.get(Uri.https('example.test', '/')),
      throwsA(isA<http.ClientException>()),
    );
  });
}
