import 'package:garden_server/src/files/multipart_copy.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  const part = 8 * 1024 * 1024;
  final base = FileVersion(
    id: 10,
    nodeId: 1,
    authorId: 'owner',
    baseVersion: 0,
    size: 3 * part,
    chunkCount: 3,
    partSize: part,
    objectPath: 'objects/10/content',
    committed: true,
    createdAt: DateTime.utc(2026),
  );
  final upload = base.copyWith(
    id: 11,
    baseVersion: 10,
    objectPath: 'objects/11/content',
    uploadId: 'pending',
    committed: false,
  );

  test('unchanged ranges use exact inclusive multipart boundaries', () {
    expect(MultipartCopy.ranges(upload, base, 2, 2), [
      'bytes=$part-${2 * part - 1}',
      'bytes=${2 * part}-${3 * part - 1}',
    ]);
    expect(
      MultipartCopy.ranges(upload.copyWith(size: 2 * part + 17), base, 3, 1),
      ['bytes=${2 * part}-${2 * part + 16}'],
    );
  });

  test('copy cannot disclose another file or uncommitted data', () {
    for (final invalid in [
      base.copyWith(nodeId: 2),
      base.copyWith(id: 9),
      base.copyWith(committed: false),
      base.copyWith(objectPath: null),
      base.copyWith(size: 5 * 1024 * 1024),
    ]) {
      expect(
        () => MultipartCopy.ranges(upload, invalid, 1, 1),
        throwsA(isA<GardenException>()),
      );
    }
  });

  test('invalid and extended ranges fail before any S3 operation', () {
    for (final range in [(0, 1), (1, 0), (1, 4), (3, 2)]) {
      expect(
        () => MultipartCopy.ranges(upload, base, range.$1, range.$2),
        throwsA(isA<GardenException>()),
      );
    }
    for (final invalid in [
      upload.copyWith(size: 3 * part + 1, chunkCount: 4),
      upload.copyWith(committed: true),
      upload.copyWith(aborted: true),
      upload.copyWith(uploadId: null),
      upload.copyWith(partSize: 1),
      upload.copyWith(chunkCount: 2),
    ]) {
      expect(
        () => MultipartCopy.ranges(invalid, base, invalid.chunkCount, 1),
        throwsA(isA<GardenException>()),
      );
    }
  });
}
