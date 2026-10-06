import '../model/account_info.dart';

abstract interface class FinderPreviews {
  Future<void> previewNode(AccountInfo account, int driveID, int nodeID);
}
