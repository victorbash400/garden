import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppearanceStore {
  Future<String?> read();
  Future<void> write(String value);
}

class LocalAppearanceStore implements AppearanceStore {
  final _storage = SharedPreferencesAsync();
  static const _key = 'garden.appearance.v1';
  @override
  Future<String?> read() => _storage.getString(_key);
  @override
  Future<void> write(String value) => _storage.setString(_key, value);
}
