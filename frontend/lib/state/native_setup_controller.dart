import 'package:flutter/foundation.dart';

import '../native/system_setup.dart';
import '../utils/error_message.dart';

class NativeSetupController extends ChangeNotifier {
  NativeSetupController(this.system);
  final SystemSetup system;
  SystemSetupStatus? status;
  String? error;
  bool busy = false;

  bool get needsAttention =>
      error != null || status?.launchAtLogin == LoginItemState.requiresApproval;

  Future<void> refresh() => _request(() async {
    status = await system.status();
  });
  Future<void> setLaunchAtLogin(bool enabled) => _request(() async {
    status = await system.setLaunchAtLogin(enabled);
  });
  Future<void> openLoginSettings() => _request(system.openLoginSettings);

  Future<void> _request(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action().timeout(const Duration(seconds: 15));
    } catch (failure) {
      error = errorMessage(failure);
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
