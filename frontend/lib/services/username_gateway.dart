import '../model/account_info.dart';

abstract interface class UsernameGateway {
  Future<AccountInfo> setUsername(String username);
}
