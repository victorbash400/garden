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
    this.macFuseInstalled = true,
    this.finderSupported = true,
  });
  final bool finderAvailable;
  final bool macFuseInstalled;
  final bool finderSupported;
  final LoginItemState launchAtLogin;

  factory SystemSetupStatus.fromMap(Map<Object?, Object?> data) {
    final available = data['finderAvailable'];
    final login = data['launchAtLogin'];
    final installed = data['macFuseInstalled'];
    final supported = data['finderSupported'];
    if (available is! bool ||
        login is! String ||
        installed is! bool ||
        supported is! bool) {
      throw const FormatException('Invalid native setup status.');
    }
    return SystemSetupStatus(
      finderAvailable: available,
      macFuseInstalled: installed,
      finderSupported: supported,
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
