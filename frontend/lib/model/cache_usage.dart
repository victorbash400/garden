class CacheUsage {
  const CacheUsage({
    required this.limitBytes,
    required this.available,
    this.usedBytes,
    this.blocks,
  });

  static const gib = 1024 * 1024 * 1024;
  final int limitBytes;
  final bool available;
  final int? usedBytes;
  final int? blocks;
  int get limitGiB => limitBytes ~/ gib;
  double get fraction => limitBytes == 0 || usedBytes == null
      ? 0
      : (usedBytes! / limitBytes).clamp(0, 1).toDouble();

  factory CacheUsage.fromMap(Map<Object?, Object?> value) {
    final limit = value['limitBytes'];
    final available = value['available'];
    final used = value['usedBytes'];
    final blocks = value['blocks'];
    if (limit is! int ||
        limit < 0 ||
        limit > 100 * gib ||
        available is! bool ||
        available &&
            (used is! int || used < 0 || blocks is! int || blocks < 0)) {
      throw const FormatException('Invalid cache usage response.');
    }
    return CacheUsage(
      limitBytes: limit,
      available: available,
      usedBytes: used as int?,
      blocks: blocks as int?,
    );
  }
}
