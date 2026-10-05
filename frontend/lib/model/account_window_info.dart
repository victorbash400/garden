class AccountWindowInfo {
  const AccountWindowInfo({required this.id, required this.title});
  final String id;
  final String title;

  factory AccountWindowInfo.fromMap(Map<Object?, Object?> value) {
    if (value['id'] is! String || value['title'] is! String) {
      throw StateError('Invalid account window.');
    }
    return AccountWindowInfo(
      id: value['id'] as String,
      title: value['title'] as String,
    );
  }
}
