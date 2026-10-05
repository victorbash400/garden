import 'dart:async';

import '../model/activity_entry.dart';

class ActivityLog {
  static final instance = ActivityLog();
  final _changes = StreamController<void>.broadcast(sync: true);
  final _entries = <ActivityEntry>[];
  String? account;
  Stream<void> get changes => _changes.stream;
  List<ActivityEntry> entries(String account) =>
      _entries.where((entry) => entry.account == account).toList();
  void record(
    int drive,
    String name,
    String action, {
    int bytes = 0,
    double milliseconds = 0,
    String? error,
  }) {
    final current = account;
    if (current == null) return;
    final now = DateTime.now();
    _entries.add(
      ActivityEntry(
        id: 'app-${now.microsecondsSinceEpoch}-${_entries.length}',
        account: current,
        drive: drive,
        name: name,
        action: action,
        source: 'Garden',
        time: now,
        bytes: bytes,
        milliseconds: milliseconds,
        error: error,
      ),
    );
    if (_entries.length > 300) _entries.removeAt(0);
    _changes.add(null);
  }

  void clear(String account) {
    _entries.removeWhere((entry) => entry.account == account);
    _changes.add(null);
  }
}
