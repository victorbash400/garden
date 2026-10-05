import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../state/files_controller.dart';
import '../state/garden_controller.dart';
import 'files/file_actions.dart';

class GardenMenuBar extends StatelessWidget {
  const GardenMenuBar({
    super.key,
    required this.controller,
    required this.child,
  });
  final GardenController controller;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) return child;
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        controller.files,
        controller.accountWindow,
      ]),
      builder: (context, _) {
        final files = controller.files;
        final available =
            controller.page == GardenPage.files &&
            files?.drive != null &&
            !files!.busy;
        final actions = files == null ? null : FileActions(context, files);
        final node = available ? files.selected : null;
        PlatformMenuItem item(
          String label,
          VoidCallback? action,
          LogicalKeyboardKey key, {
          bool shift = false,
        }) => PlatformMenuItem(
          label: label,
          onSelected: action,
          shortcut: SingleActivator(key, meta: true, shift: shift),
        );
        return PlatformMenuBar(
          menus: [
            PlatformMenu(
              label: 'Garden',
              menus: [
                const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.about,
                ),
                PlatformMenuItem(
                  label: 'Settings…',
                  onSelected: controller.account == null
                      ? null
                      : () => controller.navigate(GardenPage.settings),
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.comma,
                    meta: true,
                  ),
                ),
                const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hide,
                ),
                const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit,
                ),
              ],
            ),
            PlatformMenu(
              label: 'File',
              menus: [
                item(
                  'New Account Window',
                  controller.busy ? null : controller.newAccountWindow,
                  LogicalKeyboardKey.keyN,
                ),
                item(
                  'New Folder…',
                  available ? () => actions!.create('folder') : null,
                  LogicalKeyboardKey.keyN,
                  shift: true,
                ),
                item(
                  'Import Files…',
                  available && !files.imports.busy ? actions!.import : null,
                  LogicalKeyboardKey.keyI,
                  shift: true,
                ),
                item(
                  'Open',
                  node == null ? null : () => actions!.open(node),
                  LogicalKeyboardKey.keyO,
                ),
                PlatformMenuItem(
                  label: 'Rename…',
                  onSelected: node == null
                      ? null
                      : () => actions!.perform(node, 'rename'),
                ),
                item(
                  'Delete…',
                  node == null ? null : () => actions!.perform(node, 'delete'),
                  LogicalKeyboardKey.backspace,
                ),
                item(
                  'Close Window',
                  windowManager.close,
                  LogicalKeyboardKey.keyW,
                ),
              ],
            ),
            PlatformMenu(
              label: 'Edit',
              menus: [
                PlatformMenuItem(
                  label: 'Cut',
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyX,
                    meta: true,
                  ),
                  onSelectedIntent: const CopySelectionTextIntent.cut(
                    SelectionChangedCause.keyboard,
                  ),
                ),
                PlatformMenuItem(
                  label: 'Copy',
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyC,
                    meta: true,
                  ),
                  onSelectedIntent: CopySelectionTextIntent.copy,
                ),
                PlatformMenuItem(
                  label: 'Paste',
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyV,
                    meta: true,
                  ),
                  onSelectedIntent: const PasteTextIntent(
                    SelectionChangedCause.keyboard,
                  ),
                ),
                PlatformMenuItem(
                  label: 'Select All',
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyA,
                    meta: true,
                  ),
                  onSelectedIntent: const SelectAllTextIntent(
                    SelectionChangedCause.keyboard,
                  ),
                ),
              ],
            ),
            PlatformMenu(
              label: 'View',
              menus: [
                for (final mode in FileViewMode.values)
                  item(
                    switch (mode) {
                      FileViewMode.grid => 'As Icons',
                      FileViewMode.list => 'As List',
                      FileViewMode.columns => 'As Columns',
                    },
                    available ? () => files.setViewMode(mode) : null,
                    switch (mode) {
                      FileViewMode.grid => LogicalKeyboardKey.digit1,
                      FileViewMode.list => LogicalKeyboardKey.digit2,
                      FileViewMode.columns => LogicalKeyboardKey.digit3,
                    },
                  ),
                PlatformMenuItem(
                  label: 'Parent Folder',
                  onSelected: available && files.path.isNotEmpty
                      ? () => files.goTo(files.path.length - 1)
                      : null,
                ),
              ],
            ),
            PlatformMenu(
              label: 'Window',
              menus: [
                for (final window
                    in controller.accountWindow?.windows ?? const [])
                  PlatformMenuItem(
                    label: window.title,
                    onSelected: () => controller.accountWindow!.show(window.id),
                  ),
                const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.minimizeWindow,
                ),
              ],
            ),
          ],
          child: child,
        );
      },
    );
  }
}
