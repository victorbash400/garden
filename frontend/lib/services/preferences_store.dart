abstract interface class PreferencesStore {
  Future<int> readCacheLimit();
  Future<void> saveCacheLimit(int gib);
  Future<bool> finderConnectionEnabled(String accountId, int driveId);
  Future<void> setFinderConnectionEnabled(
    String accountId,
    int driveId,
    bool enabled,
  );
}
