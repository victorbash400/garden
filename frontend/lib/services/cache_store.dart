import '../model/cache_usage.dart';
import 'preferences_store.dart';

abstract interface class CacheStore implements PreferencesStore {
  Stream<CacheUsage> get cacheUpdates;
  Future<CacheUsage> cacheUsage();
  Future<CacheUsage> setCacheLimit(int gib);
  Future<CacheUsage> clearCache();
}
