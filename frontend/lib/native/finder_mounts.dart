import '../model/account_info.dart';
import '../model/garden_info.dart';
import 'finder_status.dart';

abstract interface class FinderMounts {
  Set<int> get mountedDriveIDs;
  Future<void> sync(AccountInfo account, List<GardenInfo> drives);
  Future<FinderStatus> status(AccountInfo account, List<GardenInfo> drives);
  Future<void> open(AccountInfo account, int driveID);
  Future<void> openNode(AccountInfo account, int driveID, int nodeID);
  Future<void> openSettings();
  Future<void> signOut(AccountInfo account);
}
