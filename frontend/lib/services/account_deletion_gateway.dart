abstract interface class AccountDeletionGateway {
  Future<void> deleteAccount(String email);
}
