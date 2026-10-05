import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'settings_picker_option.dart';

class SettingsPicker<T> extends StatelessWidget {
  const SettingsPicker({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 180,
  });
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = value == null
        ? null
        : items.singleWhere((item) => item.value == value);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        alignment: Alignment.bottomLeft,
        backgroundColor: WidgetStatePropertyAll(colors.surfaceContainer),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(1),
        shadowColor: WidgetStatePropertyAll(
          colors.onSurface.withValues(alpha: .14),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
        minimumSize: WidgetStatePropertyAll(Size(width, 0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.outline),
          ),
        ),
      ),
      menuChildren: [
        for (final item in items)
          SettingsPickerOption(
            selected: item.value == value,
            onPressed: onChanged == null || !item.enabled
                ? null
                : () => onChanged!(item.value),
            child: item.child,
          ),
      ],
      builder: (context, controller, child) => SizedBox(
        width: width,
        height: 32,
        child: TextButton(
          onPressed: onChanged == null
              ? null
              : () =>
                    controller.isOpen ? controller.close() : controller.open(),
          style:
              TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                foregroundColor: colors.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: Theme.of(context).textTheme.bodyMedium!
                    .copyWith(fontSize: 13, height: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: colors.outline),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return colors.onSurface.withValues(alpha: .08);
                  }
                  if (states.contains(WidgetState.focused)) {
                    return colors.primary.withValues(alpha: .12);
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return colors.onSurface.withValues(alpha: .04);
                  }
                  return Colors.transparent;
                }),
              ),
          child: Row(
            children: [
              Expanded(child: selected?.child ?? const SizedBox.shrink()),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronDown, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
