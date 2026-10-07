import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:garden_server/src/files/bounded_range_reads.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test('range responses retain binary data through the generated protocol', () {
    final bytes = [
      ByteData.sublistView(Uint8List.fromList([0, 255, 128])),
      ByteData(0),
    ];
    final encoded = SerializationManager.encode(bytes);
    final decoded = Protocol().deserialize<List<ByteData>>(jsonDecode(encoded));
    expect(decoded.map((value) => value.buffer.asUint8List()).toList(), [
      [0, 255, 128],
      [],
    ]);
  });

  test('parallel reads preserve request order, duplicates and EOF', () async {
    var active = 0;
    var maximum = 0;
    final result = await BoundedRangeReads.read(
      100,
      [50, 0, 98, 100, 50, 10],
      [3, 4, 10, 5, 3, 2],
      (offset, length) async {
        active++;
        if (active > maximum) maximum = active;
        await Future<void>.delayed(Duration(milliseconds: 100 - offset));
        active--;
        return Uint8List.fromList(List.generate(length, (i) => offset + i));
      },
    );
    expect(result.map((bytes) => bytes.buffer.asUint8List()).toList(), [
      [50, 51, 52],
      [0, 1, 2, 3],
      [98, 99],
      [],
      [50, 51, 52],
      [10, 11],
    ]);
    expect(maximum, lessThanOrEqualTo(BoundedRangeReads.concurrency));
    expect(maximum, greaterThan(1));
  });

  test('invalid batches fail before any storage reads', () async {
    var calls = 0;
    for (final input in [
      (<int>[], <int>[]),
      ([0], <int>[]),
      (List.filled(17, 0), List.filled(17, 1)),
      ([-1], [1]),
      ([101], [1]),
      ([0], [0]),
      ([0], [-1]),
      ([0], [65537]),
      ([0, -1], [1, 1]),
    ]) {
      await expectLater(
        BoundedRangeReads.read(100, input.$1, input.$2, (_, length) async {
          calls++;
          return Uint8List(length);
        }),
        throwsA(isA<GardenException>()),
      );
    }
    expect(calls, 0);
  });

  test('maximum batch returns at most one MiB', () async {
    final result = await BoundedRangeReads.read(
      65536,
      List.filled(16, 0),
      List.filled(16, 65536),
      (_, length) async => Uint8List(length),
    );
    expect(
      result.fold<int>(0, (sum, bytes) => sum + bytes.lengthInBytes),
      1048576,
    );
  });

  test('a short response fails the entire batch', () async {
    await expectLater(
      BoundedRangeReads.read(100, [0], [5], (_, _) async => Uint8List(4)),
      throwsA(isA<GardenException>()),
    );
  });

  test('failure stops new work and drains reads before returning', () async {
    final gate = Completer<void>();
    final failed = Completer<void>();
    var calls = 0;
    var active = 0;
    final error = StateError('Storage read failed');
    final operation = BoundedRangeReads.read(
      100,
      List.generate(16, (i) => i),
      List.filled(16, 1),
      (offset, length) async {
        calls++;
        if (offset == 0) {
          await Future<void>.value();
          failed.complete();
          throw error;
        }
        active++;
        await gate.future;
        active--;
        return Uint8List(length);
      },
    );
    final assertion = expectLater(operation, throwsA(same(error)));
    await failed.future;
    expect(active, 3);
    gate.complete();
    await assertion;
    expect(active, 0);
    expect(calls, 4);
  });
}
