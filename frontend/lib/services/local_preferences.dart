import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_store.dart';

class LocalPreferences implements PreferencesStore {
  final SharedPreferencesAsync _storage = SharedPreferencesAsync();
  @override
  Future<int> readCacheLimit() async =>
      await _storage.getInt('cacheLimitGiB') ?? 20;
  @override
  Future<void> saveCacheLimit(int gib) => _storage.setInt('cacheLimitGiB', gib);
  @override
  Future<bool> onboardingComplete(String accountId) async =>
      await _storage.getBool('onboarding.$accountId') ?? false;
  @override
  Future<void> completeOnboarding(String accountId) =>
      _storage.setBool('onboarding.$accountId', true);
}
