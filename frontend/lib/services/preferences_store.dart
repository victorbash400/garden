abstract interface class PreferencesStore {
  Future<int> readCacheLimit();
  Future<void> saveCacheLimit(int gib);
}
