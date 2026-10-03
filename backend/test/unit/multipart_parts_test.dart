import 'package:aws_client/s3.dart' as aws;
import 'package:garden_server/src/files/multipart_object_store.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  test('part sizes stay within S3 limits through the file size limit', () {
    for (final size in [1, 256 * 1024, 3 * 1024 * 1024 * 1024, 1 << 40]) {
      final part = MultipartObjectStore.partSizeFor(size);
      expect(part, greaterThanOrEqualTo(5 * 1024 * 1024));
      expect((size + part - 1) ~/ part, lessThanOrEqualTo(10000));
    }
  });
  test('completion requires exact ordered parts and byte count', () {
    const partSize = 8 * 1024 * 1024;
    final version = FileVersion(
      nodeId: 1,
      authorId: 'owner',
      baseVersion: 0,
      size: partSize + 12,
      chunkCount: 2,
      partSize: partSize,
      createdAt: DateTime.utc(2026),
    );
    final parts = [
      aws.Part(partNumber: 1, size: partSize, eTag: 'first'),
      aws.Part(partNumber: 2, size: 12, eTag: 'last'),
    ];
    MultipartObjectStore.validateParts(version, parts);
    for (final invalid in [
      parts.reversed.toList(),
      parts.take(1).toList(),
      [parts.first, aws.Part(partNumber: 2, size: 13, eTag: 'wrong')],
      [parts.first, aws.Part(partNumber: 2, size: 12)],
    ]) {
      expect(
        () => MultipartObjectStore.validateParts(version, invalid),
        throwsA(isA<GardenException>()),
      );
    }
  });
}
