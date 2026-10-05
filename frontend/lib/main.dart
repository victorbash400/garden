import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'services/local_preferences.dart';
import 'services/serverpod_gateway.dart';
import 'services/files/serverpod_files_gateway.dart';
import 'native/mac_finder_mounts.dart';
import 'native/mac_finder_updates.dart';
import 'native/mac_system_setup.dart';
import 'native/garden_window_lifecycle.dart';
import 'native/account_window.dart';
import 'state/native_setup_controller.dart';
import 'state/files_controller.dart';
import 'state/account_security_controller.dart';
import 'state/garden_controller.dart';
import 'ui/garden_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    size: Size(1100, 740),
    minimumSize: Size(900, 640),
    center: true,
    title: 'Garden',
  );
  const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'https://garden.api.serverpod.space/',
  );
  final accountWindow = AccountWindow();
  final windowId = await accountWindow.initialize();
  final gateway = ServerpodGateway(serverUrl, windowId: windowId);
  final system = MacSystemSetup();
  final finder = MacFinderMounts(gateway, serverUrl);
  final filesGateway = ServerpodFilesGateway(gateway.client);
  late final GardenController controller;
  final finderUpdates = MacFinderUpdates();
  controller = GardenController(
    gateway,
    LocalPreferences(),
    accountWindow: accountWindow,
    security: AccountSecurityController(gateway),
    finder: finder,
    finderUpdates: finderUpdates,
    nativeSetup: NativeSetupController(system),
    localServer: const [
      'localhost',
      '127.0.0.1',
      '::1',
    ].contains(Uri.parse(serverUrl).host),
    files: FilesController(filesGateway),
  );
  await GardenWindowLifecycle(controller.finderUpdateError).install();
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(GardenApp(controller: controller));
  unawaited(controller.initialize());
}
