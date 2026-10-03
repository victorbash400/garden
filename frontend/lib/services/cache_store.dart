import '../model/cache_usage.dart';
import 'preferences_store.dart';

abstract interface class CacheStore implements PreferencesStore {
  Future<CacheUsage> cacheUsage();
  Future<CacheUsage> setCacheLimit(int gib);
  Future<CacheUsage> clearCache();
}
