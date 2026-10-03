import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/services/files/direct_files_gateway.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/services/files/multipart_transfer.dart';
import 'package:garden_flutter/services/files/part_checksum.dart';

void main() {
  test('large part hashing leaves the caller event loop available', () async {
    final bytes = Uint8List(8 * 1024 * 1024)..fillRange(0, 8 * 1024 * 1024, 7);
    var eventProcessed = false;
    final hash = partChecksum(bytes);
    await Future<void>(() {
      eventProcessed = true;
    });
    expect(eventProcessed, isTrue);
    expect(await hash, md5.convert(bytes).toString());
  });

  test(
    'stream segmentation preserves bytes across arbitrary input boundaries',
    () async {
      final input = [
        Uint8List.fromList([0, 1]),
        Uint8List.fromList([2, 3, 4, 5, 6]),
        Uint8List.fromList([7, 8, 9, 10]),
      ];
      final parts = await MultipartTransfer.parts(
        Stream.fromIterable(input),
        4,
      ).toList();
      expect(parts.map((part) => part.length), [4, 4, 3]);
      expect(parts.expand((part) => part), List.generate(11, (index) => index));
    },
  );
  test(
    'resume reuses matching parts and verifies all checksums before commit',
    () async {
      final bytes = List.generate(11, (index) => index);
      final records = [
        for (var offset = 0; offset < bytes.length; offset += 4)
          UploadedPart(
            number: offset ~/ 4 + 1,
            size: bytes
                .sublist(offset, (offset + 4).clamp(0, bytes.length))
                .length,
            checksum: md5
                .convert(
                  bytes.sublist(offset, (offset + 4).clamp(0, bytes.length)),
                )
                .toString(),
          ),
      ];
      final gateway = ResumedGateway(records);
      final version = FileVersion(
        id: 1,
        nodeId: 1,
        authorId: 'test',
        baseVersion: 0,
        size: 11,
        chunkCount: 3,
        partSize: 4,
        createdAt: DateTime.now(),
      );
      final progress = <int>[];
      expect(
        await MultipartTransfer(gateway)
            .upload(version, Stream.value(bytes), onProgress: progress.add),
        11,
      );
      expect(progress, [4, 8, 11]);
      expect(gateway.checks, 2);
      gateway.rejectVerification = true;
      await expectLater(
        MultipartTransfer(gateway).upload(version, Stream.value(bytes)),
        throwsStateError,
      );
    },
  );
  test('empty input does not create a spurious part', () async {
    expect(
      await MultipartTransfer.parts(const Stream.empty(), 4).toList(),
      isEmpty,
    );
  });
}

class ResumedGateway implements DirectFilesGateway {
  ResumedGateway(this.parts);
  final List<UploadedPart> parts;
  var checks = 0;
  var rejectVerification = false;
  @override
  Future<List<UploadedPart>> uploadedParts(int versionId) async {
    checks++;
    return rejectVerification && checks.isEven ? [] : parts;
  }

  @override
  Future<List<String>> uploadParts(int versionId, int first, int count) =>
      throw StateError('Verified parts must not be uploaded again.');
  @override
  Future<FileVersion> beginMultipart(int nodeId, int baseVersion, int size) =>
      throw UnimplementedError();
  @override
  Future<ContentDownload> downloadTicket(int nodeId, int versionId) =>
      throw UnimplementedError();
}
