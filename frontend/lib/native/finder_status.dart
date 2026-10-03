class FinderStatus {
  const FinderStatus({
    this.registered = const {},
    this.enabled = const {},
    this.disabled = const {},
    this.disconnected = const {},
  });
  final Set<int> registered;
  final Set<int> enabled;
  final Set<int> disabled;
  final Set<int> disconnected;

  factory FinderStatus.fromMap(Map<Object?, Object?> data) {
    Set<int> ids(String key) {
      final value = data[key];
      if (value is! List) throw FormatException('Missing Finder status: $key.');
      return value.cast<int>().toSet();
    }

    return FinderStatus(
      registered: ids('registered'),
      enabled: ids('enabled'),
      disabled: ids('disabled'),
      disconnected: ids('disconnected'),
    );
  }
}
