import 'dart:math';

import '../generated/protocol.dart';

class MultipartCopy {
  static List<String> ranges(
    FileVersion upload,
    FileVersion base,
    int first,
    int count,
  ) {
    final partSize = upload.partSize;
    if (upload.committed ||
        upload.aborted ||
        upload.objectPath == null ||
        upload.uploadId == null ||
        partSize == null ||
        partSize < 5 * 1024 * 1024 ||
        upload.size <= 0 ||
        upload.chunkCount != (upload.size + partSize - 1) ~/ partSize ||
        first < 1 ||
        count < 1 ||
        count > 3 ||
        first + count - 1 > upload.chunkCount) {
      throw GardenException(message: 'Invalid copy part range.');
    }
    if (base.id != upload.baseVersion ||
        base.nodeId != upload.nodeId ||
        !base.committed ||
        base.objectPath == null ||
        base.size <= 5 * 1024 * 1024) {
      throw GardenException(
        message: 'This base version cannot be range copied.',
      );
    }
    final ranges = <String>[];
    for (var number = first; number < first + count; number++) {
      final offset = (number - 1) * partSize;
      final end = min(upload.size, offset + partSize);
      if (end > base.size) {
        throw GardenException(
          message: 'The copy extends beyond the base file.',
        );
      }
      ranges.add('bytes=$offset-${end - 1}');
    }
    return ranges;
  }
}
