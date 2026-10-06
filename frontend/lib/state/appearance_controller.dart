import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/appearance/theme_presets.dart';
import '../model/appearance/theme_profile.dart';
import '../services/appearance_store.dart';
import '../utils/error_message.dart';

class AppearanceController extends ChangeNotifier {
  AppearanceController(this.store);
  final AppearanceStore store;
  ThemeMode mode = ThemeMode.light;
  ThemeProfile light = lightPresets.first;
  ThemeProfile dark = darkPresets.first;
  bool busy = false;
  String? error;

  Future<void> load() async {
    busy = true;
    notifyListeners();
    try {
      final saved = await store.read();
      if (saved != null) {
        final value = jsonDecode(saved) as Map<String, dynamic>;
        final savedMode = ThemeMode.values.byName(value['mode'] as String);
        final savedLight = ThemeProfile.fromJson(
          value['light'] as Map<String, dynamic>,
          lightPresets,
        );
        final savedDark = ThemeProfile.fromJson(
          value['dark'] as Map<String, dynamic>,
          darkPresets,
        );
        mode = savedMode;
        light = savedLight;
        dark = savedDark;
      }
      error = null;
    } catch (failure) {
      error = 'Could not load appearance: ${errorMessage(failure)}';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> update({
    ThemeMode? mode,
    ThemeProfile? light,
    ThemeProfile? dark,
  }) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    final nextMode = mode ?? this.mode;
    final nextLight = light ?? this.light;
    final nextDark = dark ?? this.dark;
    try {
      await store.write(
        jsonEncode({
          'mode': nextMode.name,
          'light': nextLight.toJson(),
          'dark': nextDark.toJson(),
        }),
      );
      this.mode = nextMode;
      this.light = nextLight;
      this.dark = nextDark;
    } catch (failure) {
      error = 'Could not save appearance: ${errorMessage(failure)}';
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
