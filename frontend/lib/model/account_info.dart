class AccountInfo {
  const AccountInfo({
    required this.id,
    required this.email,
    this.username = 'garden-user',
  });
  final String id;
  final String email;
  final String username;
}
