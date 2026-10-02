import '../model/account_info.dart';
import '../model/garden_info.dart';

abstract interface class FinderMounts {
  Set<int> get mountedDriveIDs;
  Future<void> sync(AccountInfo account, List<GardenInfo> drives);
  Future<Set<int>> enabled(AccountInfo account, List<GardenInfo> drives);
  Future<void> open(AccountInfo account, int driveID);
  Future<void> openSettings();
  Future<void> signOut(AccountInfo account);
  Future<void> signal(AccountInfo account, int driveID, List<int> parentIDs);
}
