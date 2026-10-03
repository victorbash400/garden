import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/cache_sample.dart';
import '../model/cache_usage.dart';
import '../services/cache_store.dart';
import '../utils/error_message.dart';

class StorageController extends ChangeNotifier {
  StorageController(this.store);
  final CacheStore store;
  CacheUsage? usage;
  String? error;
  bool busy = false;
  final List<CacheSample> history = [];
  StreamSubscription<CacheUsage>? _subscription;

  void watch() {
    _subscription ??= store.cacheUpdates.listen(
      (value) {
        _record(value);
        error = null;
        notifyListeners();
      },
      onError: (Object failure) {
        error = errorMessage(failure);
        notifyListeners();
      },
    );
  }

  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _record(CacheUsage value) {
    usage = value;
    if (!value.available) return;
    final now = DateTime.now();
    final sample = CacheSample(time: now, bytes: value.usedBytes!);
    if (history.isNotEmpty &&
        now.millisecondsSinceEpoch ~/ 1250 ==
            history.last.time.millisecondsSinceEpoch ~/ 1250) {
      history[history.length - 1] = sample;
    } else {
      history.add(sample);
    }
    history.removeWhere((sample) => now.difference(sample.time).inMinutes >= 5);
    if (history.length > 240) history.removeRange(0, history.length - 240);
  }

  @override
  void dispose() {
    stopWatching();
    super.dispose();
  }

  Future<void> refresh() => _run(store.cacheUsage);
  Future<void> setLimit(int gib) => _run(() => store.setCacheLimit(gib));
  Future<void> clear() => _run(store.clearCache);

  Future<void> _run(Future<CacheUsage> Function() operation) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      _record(await operation());
    } catch (failure) {
      error = errorMessage(failure);
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
