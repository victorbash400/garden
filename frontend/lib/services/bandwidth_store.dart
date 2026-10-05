import 'package:flutter/services.dart';

class BandwidthStore {
  static const _channel = MethodChannel('garden/bandwidth');

  static Future<Map<Object?, Object?>> status() async {
    final value = await _channel.invokeMapMethod<Object?, Object?>('status');
    if (value == null) throw StateError('Bandwidth settings are unavailable.');
    return value;
  }

  static Future<void> set(int upload, int download) =>
      _channel.invokeMethod('set', {'upload': upload, 'download': download});

  static Future<void> pace(int bytes, {required bool upload}) async {
    final value = await _channel.invokeMapMethod<Object?, Object?>('reserve', {
      'bytes': bytes,
      'upload': upload,
    });
    final seconds = value?['seconds'];
    if (seconds is! num || !seconds.isFinite || seconds < 0) {
      throw StateError('Transfer bandwidth service returned an invalid delay.');
    }
    if (seconds > 0) {
      await Future<void>.delayed(
        Duration(microseconds: (seconds * 1000000).ceil()),
      );
    }
  }
}
