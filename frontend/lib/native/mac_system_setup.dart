import 'dart:async';

import 'package:flutter/services.dart';

import 'system_setup.dart';

class MacSystemSetup implements SystemSetup {
  MacSystemSetup() {
    channel.setMethodCallHandler((call) async {
      if (call.method != 'wake') throw MissingPluginException(call.method);
      _wakeEvents.add(null);
    });
  }
  static const channel = MethodChannel('garden/setup');
  final _wakeEvents = StreamController<void>.broadcast();
  @override
  Stream<void> get wakeEvents => _wakeEvents.stream;

  Future<SystemSetupStatus> _status(String method, [Object? arguments]) async {
    final result = await channel.invokeMapMethod<Object?, Object?>(
      method,
      arguments,
    );
    if (result == null) throw StateError('macOS did not return setup status.');
    return SystemSetupStatus.fromMap(result);
  }

  @override
  Future<SystemSetupStatus> status() => _status('status');
  @override
  Future<SystemSetupStatus> setLaunchAtLogin(bool enabled) =>
      _status('setLaunchAtLogin', enabled);
  @override
  Future<void> openLoginSettings() =>
      channel.invokeMethod<void>('openLoginSettings');
  @override
  Future<void> setBackgroundActive(bool active) =>
      channel.invokeMethod<void>('setBackgroundActive', active);
}
