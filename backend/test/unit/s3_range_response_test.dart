import 'dart:typed_data';

import 'package:aws_client/s3.dart' as aws;
import 'package:garden_server/src/files/multipart_object_store.dart';
import 'package:test/test.dart';

void main() {
  test('S3 range bytes require exact position and file size', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final response = aws.GetObjectOutput(
      body: bytes,
      contentRange: 'bytes 5-7/8',
    );
    expect(MultipartObjectStore.validateRead(response, 5, 3, 8), same(bytes));
    for (final range in [null, 'bytes 0-2/8', 'bytes 5-7/9', 'bytes 5-8/8']) {
      expect(
        () => MultipartObjectStore.validateRead(
          aws.GetObjectOutput(body: bytes, contentRange: range),
          5,
          3,
          8,
        ),
        throwsStateError,
      );
    }
  });

  test('missing, short and oversized S3 bodies fail explicitly', () {
    for (final body in [null, Uint8List(2), Uint8List(4)]) {
      expect(
        () => MultipartObjectStore.validateRead(
          aws.GetObjectOutput(body: body, contentRange: 'bytes 5-7/8'),
          5,
          3,
          8,
        ),
        throwsStateError,
      );
    }
  });
}
