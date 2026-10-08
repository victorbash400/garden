import 'package:shared_preferences/shared_preferences.dart';

import 'setup_store.dart';

class LocalSetupStore implements SetupStore {
  final _storage = SharedPreferencesAsync();

  @override
  Future<bool> hasSeenSetup(String accountId) async =>
      await _storage.getBool('setupSeen.$accountId') == true;

  @override
  Future<void> markSetupSeen(String accountId) =>
      _storage.setBool('setupSeen.$accountId', true);
}
