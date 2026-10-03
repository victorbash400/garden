enum LoginItemState {
  enabled,
  disabled,
  requiresApproval,
  notFound,
  unsupported,
  unknown,
}

class SystemSetupStatus {
  const SystemSetupStatus({
    required this.finderAvailable,
    required this.launchAtLogin,
  });
  final bool finderAvailable;
  final LoginItemState launchAtLogin;

  factory SystemSetupStatus.fromMap(Map<Object?, Object?> data) {
    final available = data['finderAvailable'];
    final login = data['launchAtLogin'];
    if (available is! bool || login is! String) {
      throw const FormatException('Invalid native setup status.');
    }
    return SystemSetupStatus(
      finderAvailable: available,
      launchAtLogin: LoginItemState.values.byName(login),
    );
  }
}

abstract interface class SystemSetup {
  Stream<void> get wakeEvents;
  Future<SystemSetupStatus> status();
  Future<SystemSetupStatus> setLaunchAtLogin(bool enabled);
  Future<void> openLoginSettings();
  Future<void> setBackgroundActive(bool active);
}
