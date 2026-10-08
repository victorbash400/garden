abstract interface class SetupStore {
  Future<bool> hasSeenSetup(String accountId);
  Future<void> markSetupSeen(String accountId);
}
