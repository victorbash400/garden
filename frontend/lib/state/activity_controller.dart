import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/activity_entry.dart';
import '../services/activity_log.dart';
import '../utils/error_message.dart';

class ActivityController extends ChangeNotifier {
  ActivityController(this.account) {
    _local = ActivityLog.instance.changes.listen((_) => notifyListeners());
    connect();
  }
  final String account;
  static const _events = EventChannel('garden/activity/updates');
  static const _methods = MethodChannel('garden/activity');
  StreamSubscription<dynamic>? _native;
  StreamSubscription<void>? _local;
  List<ActivityEntry> _entries = [];
  String? error;
  bool connected = false;
  List<ActivityEntry> get entries =>
      [..._entries, ...ActivityLog.instance.entries(account)]
        ..sort((a, b) => b.time.compareTo(a.time));
  void connect() {
    error = null;
    _native = _events
        .receiveBroadcastStream(account)
        .listen(
          (dynamic data) {
            try {
              final values =
                  jsonDecode(utf8.decode(data as Uint8List)) as List<dynamic>;
              _entries = values
                  .map(
                    (value) =>
                        ActivityEntry.fromJson(value as Map<String, dynamic>),
                  )
                  .toList();
              connected = true;
              error = null;
            } catch (failure) {
              error = errorMessage(failure);
            }
            notifyListeners();
          },
          onError: (Object failure) {
            connected = false;
            error = errorMessage(failure);
            notifyListeners();
          },
        );
  }

  Future<void> retry() async {
    await _native?.cancel();
    connect();
    notifyListeners();
  }

  Future<void> clear() async {
    try {
      await _methods.invokeMethod<void>('clear', account);
      ActivityLog.instance.clear(account);
    } catch (failure) {
      error = errorMessage(failure);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_native?.cancel());
    unawaited(_local?.cancel());
    super.dispose();
  }
}
