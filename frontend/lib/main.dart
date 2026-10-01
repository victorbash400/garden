import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'services/local_preferences.dart';
import 'services/serverpod_gateway.dart';
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
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'http://localhost:8080/',
  );
  final controller = GardenController(
    ServerpodGateway(serverUrl),
    LocalPreferences(),
  );
  runApp(GardenApp(controller: controller));
  unawaited(controller.initialize());
}
