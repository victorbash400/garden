import '../model/account_info.dart';

abstract interface class RelaunchSessionGateway {
  Map<String, Object?> exportSession(AccountInfo? account);
  Future<AccountInfo?> restoreRelaunch();
}
