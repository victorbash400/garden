import 'dart:async';

import 'package:flutter/material.dart';

import '../native/account_window.dart';
import '../ui/garden_colors.dart';

class WindowAppearance extends StatefulWidget {
  const WindowAppearance({
    super.key,
    required this.window,
    required this.onError,
    required this.child,
  });

  final AccountWindow? window;
  final ValueChanged<Object> onError;
  final Widget child;

  @override
  State<WindowAppearance> createState() => _WindowAppearanceState();
}

class _WindowAppearanceState extends State<WindowAppearance> {
  Color? _color;
  Brightness? _brightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _update();
  }

  @override
  void didUpdateWidget(WindowAppearance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.window != widget.window) {
      _color = null;
      _update();
    }
  }

  void _update() {
    final window = widget.window;
    if (window == null) return;
    final color = GardenColors.of(context).surface;
    final brightness = Theme.of(context).brightness;
    if (color == _color && brightness == _brightness) return;
    _color = color;
    _brightness = brightness;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.window != window) return;
      unawaited(
        window.setAppearance(color, brightness).catchError(widget.onError),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
