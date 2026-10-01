import '../model/account_info.dart';
import '../model/garden_info.dart';

abstract interface class GardenGateway {
  Future<AccountInfo?> restoreAccount();
  Future<AccountInfo> signIn(String email, String password);
  Future<String> beginRegistration(String email);
  Future<AccountInfo> finishRegistration(
    String requestId,
    String code,
    String password,
  );
  Future<void> signOut();
  Future<void> deleteDrive(int driveId);
  Future<List<GardenInfo>> listGardens();
  Future<GardenInfo> createGarden(String name);
  Future<GardenInfo> joinGarden(String code);
  Future<GardenInfo> connect(int gardenId);
  void dispose();
}
