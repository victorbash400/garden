import 'package:flutter/services.dart';

enum SetupLink { approval, macFuse }

class SetupLinks {
  static const _channel = MethodChannel('garden/setup');

  static Future<void> open(SetupLink link) =>
      _channel.invokeMethod<void>('openHelp', link.name);
}
