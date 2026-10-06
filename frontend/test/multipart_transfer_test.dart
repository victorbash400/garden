import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/services/files/direct_files_gateway.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:garden_flutter/services/files/multipart_transfer.dart';
import 'package:garden_flutter/services/files/part_checksum.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('garden/bandwidth'),
          (_) async => {'seconds': 0},
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('garden/bandwidth'),
          null,
        );
  });
  test(
    'completed upload slots refill while slower parts remain active',
    () async {
      final client = HeldUploadClient();
      final gateway = UploadedGateway(client);
      final bytes = List.generate(32, (index) => index);
      final progress = <int>[];
      await HttpOverrides.runZoned(() async {
        final operation = MultipartTransfer(gateway).upload(
          FileVersion(
            id: 1,
            nodeId: 1,
            authorId: 'test',
            baseVersion: 0,
            size: bytes.length,
            chunkCount: 8,
            partSize: 4,
            createdAt: DateTime.now(),
          ),
          Stream.value(bytes),
          onProgress: progress.add,
        );
        await client.started(3);
        expect(client.requests.keys, [1, 2, 3]);
        client.complete(1);
        await client.started(4);
        expect(client.requests[2]!.response.isCompleted, isFalse);
        expect(client.requests[3]!.response.isCompleted, isFalse);
        for (var part = 2; part <= 8; part++) {
          await client.started(part);
          client.complete(part);
        }
        expect(await operation, bytes.length);
      }, createHttpClient: (_) => client);
      expect(client.peak, 3);
      expect(client.requests.values.expand((request) => request.bytes), bytes);
      expect(progress.last, bytes.length);
      expect(gateway.checks, 2);
    },
  );

  test('a failed part stops scheduling and prevents verification', () async {
    final client = HeldUploadClient();
    final gateway = UploadedGateway(client);
    await HttpOverrides.runZoned(() async {
      final operation = MultipartTransfer(gateway).upload(
        FileVersion(
          id: 1,
          nodeId: 1,
          authorId: 'test',
          baseVersion: 0,
          size: 32,
          chunkCount: 8,
          partSize: 4,
          createdAt: DateTime.now(),
        ),
        Stream.value(List.generate(32, (index) => index)),
      );
      final failed = expectLater(operation, throwsA(isA<HttpException>()));
      await client.started(3);
      client.complete(1, status: 403);
      await failed;
      expect(client.requests.keys, [1, 2, 3]);
      expect(gateway.checks, 1);
    }, createHttpClient: (_) => client);
  });
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
      gateway.rejectVerification = false;
      gateway.duplicateVerification = true;
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

class HeldUploadClient implements HttpClient {
  final requests = <int, HeldUploadRequest>{};
  final waiting = <int, Completer<void>>{};
  var active = 0;
  var peak = 0;
  Future<void> started(int part) => requests.containsKey(part)
      ? Future.value()
      : (waiting[part] ??= Completer<void>()).future;
  void complete(int part, {int status = 200}) {
    active--;
    requests[part]!.response.complete(UploadResponse(status));
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) async {
    final part = int.parse(url.pathSegments.last);
    final request = HeldUploadRequest();
    requests[part] = request;
    active++;
    if (active > peak) peak = active;
    waiting.remove(part)?.complete();
    return request;
  }

  @override
  void close({bool force = false}) {
    for (final request in requests.values) {
      if (!request.response.isCompleted) {
        request.response.complete(UploadResponse(499));
      }
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class HeldUploadRequest implements HttpClientRequest {
  final bytes = <int>[];
  final response = Completer<HttpClientResponse>();
  @override
  void add(List<int> data) => bytes.addAll(data);
  @override
  Future<HttpClientResponse> close() => response.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class UploadResponse implements HttpClientResponse {
  UploadResponse(this.statusCode);
  @override
  final int statusCode;
  @override
  Future<E> drain<E>([E? value]) async => value as E;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class UploadedGateway extends ResumedGateway {
  UploadedGateway(this.client) : super([]);
  final HeldUploadClient client;
  @override
  Future<List<String>> uploadParts(int versionId, int first, int count) async =>
      [
        for (var part = first; part < first + count; part++)
          'https://garden-upload.test/$part',
      ];
  @override
  Future<List<UploadedPart>> uploadedParts(int versionId) async {
    checks++;
    return [
      for (final entry in client.requests.entries)
        UploadedPart(
          number: entry.key,
          size: entry.value.bytes.length,
          checksum: md5.convert(entry.value.bytes).toString(),
        ),
    ];
  }
}

class ResumedGateway implements DirectFilesGateway {
  ResumedGateway(this.parts);
  final List<UploadedPart> parts;
  var checks = 0;
  var rejectVerification = false;
  var duplicateVerification = false;
  @override
  Future<List<UploadedPart>> uploadedParts(int versionId) async {
    checks++;
    if (checks.isEven) {
      if (rejectVerification) return [];
      if (duplicateVerification) return [parts.first, parts.first, parts.last];
    }
    return parts;
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
