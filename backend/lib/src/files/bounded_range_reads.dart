import 'dart:math';
import 'dart:typed_data';

import '../generated/protocol.dart';

class BoundedRangeReads {
  static const maximumRanges = 16;
  static const maximumLength = 64 * 1024;
  static const concurrency = 4;

  static Future<List<ByteData>> read(
    int size,
    List<int> offsets,
    List<int> lengths,
    Future<Uint8List> Function(int offset, int length) fetch,
  ) async {
    if (size < 0 ||
        offsets.isEmpty ||
        offsets.length > maximumRanges ||
        offsets.length != lengths.length) {
      throw GardenException(message: 'Invalid metadata read ranges.');
    }
    for (var index = 0; index < offsets.length; index++) {
      if (offsets[index] < 0 ||
          offsets[index] > size ||
          lengths[index] < 1 ||
          lengths[index] > maximumLength) {
        throw GardenException(message: 'Invalid metadata read range.');
      }
    }
    final result = List<ByteData?>.filled(offsets.length, null);
    var next = 0;
    var failed = false;
    Future<void> worker() async {
      while (!failed && next < offsets.length) {
        final index = next++;
        final offset = offsets[index];
        final length = min(lengths[index], size - offset);
        try {
          final bytes = length == 0
              ? Uint8List(0)
              : await fetch(offset, length);
          if (bytes.length != length) {
            throw GardenException(message: 'Incomplete metadata read range.');
          }
          result[index] = ByteData.sublistView(bytes);
        } catch (_) {
          failed = true;
          rethrow;
        }
      }
    }

    await Future.wait(
      List.generate(min(concurrency, offsets.length), (_) => worker()),
    );
    return result.map((bytes) => bytes!).toList();
  }
}
