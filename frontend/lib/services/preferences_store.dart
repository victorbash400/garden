abstract interface class PreferencesStore {
  Future<int> readCacheLimit();
  Future<void> saveCacheLimit(int gib);
  Future<bool> onboardingComplete(String accountId);
  Future<void> completeOnboarding(String accountId);
}
