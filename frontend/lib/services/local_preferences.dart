import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/cache_usage.dart';
import 'cache_store.dart';

class LocalPreferences implements CacheStore {
  static const _channel = MethodChannel('garden/cache');
  final SharedPreferencesAsync _storage = SharedPreferencesAsync();

  @override
  Future<int> readCacheLimit() async {
    final legacy = await _storage.getInt('cacheLimitGiB');
    final limit = await _channel.invokeMethod<int>('initialize', legacy);
    if (limit == null) throw StateError('Cache settings are unavailable.');
    if (legacy != null) await _storage.remove('cacheLimitGiB');
    return limit;
  }

  @override
  Future<void> saveCacheLimit(int gib) async => setCacheLimit(gib);

  @override
  Future<CacheUsage> cacheUsage() => _request('status');

  @override
  Future<CacheUsage> setCacheLimit(int gib) => _request('setLimit', gib);

  @override
  Future<CacheUsage> clearCache() => _request('clear');

  Future<CacheUsage> _request(String method, [int? gib]) async {
    final value = await _channel.invokeMapMethod<Object?, Object?>(method, gib);
    if (value == null) throw StateError('Cache service returned no usage.');
    return CacheUsage.fromMap(value);
  }
}
