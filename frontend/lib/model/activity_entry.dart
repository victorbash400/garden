class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.account,
    required this.drive,
    required this.name,
    required this.action,
    required this.source,
    required this.time,
    this.bytes = 0,
    this.milliseconds = 0,
    this.count = 1,
    this.error,
  });
  final String id, account, name, action, source;
  final int drive, bytes, count;
  final DateTime time;
  final double milliseconds;
  final String? error;
  factory ActivityEntry.fromJson(Map<String, dynamic> value) => ActivityEntry(
    id: value['id'] as String,
    account: value['account'] as String,
    drive: value['drive'] as int,
    name: value['name'] as String,
    action: value['action'] as String,
    source: value['source'] as String,
    time: DateTime.fromMillisecondsSinceEpoch((value['time'] as num).round()),
    bytes: value['bytes'] as int,
    milliseconds: (value['milliseconds'] as num).toDouble(),
    count: value['count'] as int,
    error: value['error'] as String?,
  );
}
