import 'package:flutter/foundation.dart';

import '../model/cache_usage.dart';
import '../services/cache_store.dart';
import '../utils/error_message.dart';

class StorageController extends ChangeNotifier {
  StorageController(this.store);
  final CacheStore store;
  CacheUsage? usage;
  String? error;
  bool busy = false;

  Future<void> refresh() => _run(store.cacheUsage);
  Future<void> setLimit(int gib) => _run(() => store.setCacheLimit(gib));
  Future<void> clear() => _run(store.clearCache);

  Future<void> _run(Future<CacheUsage> Function() operation) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      usage = await operation();
    } catch (failure) {
      error = errorMessage(failure);
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
