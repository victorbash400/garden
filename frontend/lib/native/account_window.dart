import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../model/account_info.dart';
import 'window_menu_delegate.dart';
import '../model/account_window_info.dart';

class AccountWindow extends ChangeNotifier {
  final _focusEvents = StreamController<void>.broadcast();
  Stream<void> get focusEvents => _focusEvents.stream;
  List<AccountWindowInfo> windows = const [];
  Map<String, Object?>? relaunchSession;
  Map<String, Object?> Function()? exportSession;
  String? sessionError;
  bool updateReady = false;
  bool updateDismissed = false;
  bool restarting = false;
  String? updateError;
  String? Function()? prepareRelaunch;
  VoidCallback? cancelRelaunch;
  static const channel = MethodChannel('garden/window');

  Future<String> initialize() async {
    final menus = WindowMenuDelegate();
    WidgetsBinding.instance.platformMenuDelegate = menus;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'build') {
        _setBuild(call.arguments);
        return null;
      }
      if (call.method == 'prepareRelaunch') {
        if (prepareRelaunch == null) {
          return 'An account window is still starting.';
        }
        final error = prepareRelaunch!();
        if (error != null) return error;
        return exportSession?.call() ?? <String, Object?>{};
      }
      if (call.method == 'cancelRelaunch') {
        cancelRelaunch?.call();
        return null;
      }
      if (call.method == 'windows') {
        _setWindows(call.arguments);
        return null;
      }
      if (call.method != 'active' || call.arguments is! bool) {
        throw MissingPluginException(call.method);
      }
      menus.setActive(call.arguments as bool);
      if (call.arguments == true) _focusEvents.add(null);
    });
    final state = await channel.invokeMapMethod<String, Object?>('initialize');
    if (state == null || state['id'] is! String || state['active'] is! bool) {
      throw StateError('macOS did not return the account window.');
    }
    _setWindows(state['windows']);
    _setBuild(state['build']);
    final session = state['session'];
    if (session is Map) relaunchSession = Map<String, Object?>.from(session);
    sessionError = state['sessionError'] as String?;
    menus.setActive(state['active'] as bool);
    return state['id'] as String;
  }

  Future<void> ready() => channel.invokeMethod<void>('ready');

  Future<void> relaunch() async {
    try {
      await channel.invokeMethod<void>('relaunch');
    } catch (_) {
      updateError = 'Could not relaunch Garden. Try again.';
      notifyListeners();
    }
  }

  void dismissUpdate() {
    updateDismissed = true;
    notifyListeners();
  }

  void _setBuild(Object? value) {
    if (value is! Map ||
        value['ready'] is! bool ||
        value['restarting'] is! bool) {
      throw StateError('Invalid build status.');
    }
    if (value['ready'] == true && !updateReady) updateDismissed = false;
    updateReady = value['ready'] as bool;
    restarting = value['restarting'] as bool;
    updateError = value['error'] as String?;
    notifyListeners();
  }

  void _setWindows(Object? value) {
    if (value is! List) throw StateError('Invalid account window list.');
    windows = value
        .map(
          (entry) => AccountWindowInfo.fromMap(
            Map<Object?, Object?>.from(entry as Map),
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> show(String id) => channel.invokeMethod<void>('show', id);
  Future<void> open() => channel.invokeMethod<void>('new');
  Future<void> setAccount(AccountInfo account) => channel.invokeMethod<void>(
    'account',
    {'id': account.id, 'email': account.email},
  );

  Future<bool> releaseAccount() async {
    final lastWindow = await channel.invokeMethod<bool>('release');
    if (lastWindow == null) {
      throw StateError('macOS did not release the account window.');
    }
    return lastWindow;
  }

  @override
  void dispose() {
    _focusEvents.close();
    super.dispose();
  }
}
