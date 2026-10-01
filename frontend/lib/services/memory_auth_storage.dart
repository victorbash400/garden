import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? _value;

  @override
  Future<AuthSuccess?> get() async => _value;

  @override
  Future<void> set(AuthSuccess? value) async {
    _value = value;
  }
}
