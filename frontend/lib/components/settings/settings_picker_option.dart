import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsPickerOption extends StatelessWidget {
  const SettingsPickerOption({
    super.key,
    required this.selected,
    required this.onPressed,
    required this.child,
  });
  final bool selected;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => MenuItemButton(
    onPressed: onPressed,
    trailingIcon: SizedBox(
      width: 14,
      height: 14,
      child: selected ? const Icon(LucideIcons.check, size: 14) : null,
    ),
    style:
        MenuItemButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: Theme.of(context).textTheme.bodyMedium!
              .copyWith(fontSize: 13, height: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: .04);
            }
            return Colors.transparent;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
    child: child,
  );
}
