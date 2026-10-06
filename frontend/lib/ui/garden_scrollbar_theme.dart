import 'package:flutter/material.dart';

ScrollbarThemeData gardenScrollbarTheme(Color ink) => ScrollbarThemeData(
  thickness: WidgetStateProperty.resolveWith(
    (states) =>
        states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.dragged)
        ? 6
        : 4.5,
  ),
  thumbColor: WidgetStateProperty.resolveWith(
    (states) => ink.withValues(
      alpha: states.contains(WidgetState.dragged)
          ? .6
          : states.contains(WidgetState.hovered)
          ? .48
          : .32,
    ),
  ),
  thumbVisibility: const WidgetStatePropertyAll(false),
  trackVisibility: const WidgetStatePropertyAll(false),
  radius: const Radius.circular(6),
  crossAxisMargin: 1,
  mainAxisMargin: 4,
  minThumbLength: 28,
  interactive: true,
);
