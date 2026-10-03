import 'package:window_manager/window_manager.dart';

class GardenWindowLifecycle with WindowListener {
  GardenWindowLifecycle(this.onError);
  final void Function(Object) onError;

  Future<void> install() async {
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    try {
      await windowManager.hide();
    } catch (failure) {
      onError(failure);
    }
  }
}
