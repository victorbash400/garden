import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../model/account_info.dart';
import 'window_menu_delegate.dart';
import '../model/account_window_info.dart';

class AccountWindow extends ChangeNotifier {
  List<AccountWindowInfo> windows = const [];
  static const channel = MethodChannel('garden/window');

  Future<String> initialize() async {
    final menus = WindowMenuDelegate();
    WidgetsBinding.instance.platformMenuDelegate = menus;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'windows') {
        _setWindows(call.arguments);
        return;
      }
      if (call.method != 'active' || call.arguments is! bool) {
        throw MissingPluginException(call.method);
      }
      menus.setActive(call.arguments as bool);
    });
    final state = await channel.invokeMapMethod<String, Object?>('initialize');
    if (state == null || state['id'] is! String || state['active'] is! bool) {
      throw StateError('macOS did not return the account window.');
    }
    _setWindows(state['windows']);
    menus.setActive(state['active'] as bool);
    return state['id'] as String;
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
}
