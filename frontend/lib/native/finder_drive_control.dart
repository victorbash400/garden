import '../model/account_info.dart';

abstract interface class FinderDriveControl {
  Future<void> setMounted(AccountInfo account, int driveId, bool mounted);
}
