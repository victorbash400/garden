import '../model/account_info.dart';

abstract interface class FinderFileApplications {
  Future<String> prepareFile(AccountInfo account, int driveId, int nodeId);
  Future<String> openPreparedFile(String path, {String? application});
}
