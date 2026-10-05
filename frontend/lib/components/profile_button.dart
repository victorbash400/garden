import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import 'profile_menu_item.dart';
import 'profile_help_dialog.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final account = controller.account;
    if (account == null) return const SizedBox.shrink();
    final name = account.email.split('@').first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(10),
        child: PopupMenuButton<String>(
          tooltip: 'Account menu',
          enabled: !controller.busy,
          position: PopupMenuPosition.over,
          offset: Offset(
            0,
            -(36.0 * (controller.accountWindow == null ? 5 : 6) + 16),
          ),
          borderRadius: BorderRadius.circular(10),
          constraints: const BoxConstraints(minWidth: 216, maxWidth: 300),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E2E2)),
          ),
          onSelected: (action) {
            switch (action) {
              case 'settings':
                controller.navigate(GardenPage.settings);
              case 'connections':
                controller.openConnections();
              case 'new':
                controller.newAccountWindow();
              case 'help':
                showDialog<void>(
                  context: context,
                  builder: (_) => const ProfileHelpDialog(),
                );
              case 'signOut':
                controller.signOut();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              enabled: false,
              height: 36,
              child: Text(
                account.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF737373)),
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              height: 36,
              child: ProfileMenuItem(
                icon: LucideIcons.settings,
                label: 'Settings',
              ),
            ),
            const PopupMenuItem(
              value: 'connections',
              height: 36,
              child: ProfileMenuItem(
                icon: LucideIcons.plug,
                label: 'Connections',
              ),
            ),
            if (controller.accountWindow != null)
              const PopupMenuItem(
                value: 'new',
                height: 36,
                child: ProfileMenuItem(
                  icon: LucideIcons.appWindow,
                  label: 'New account window',
                ),
              ),
            const PopupMenuItem(
              value: 'help',
              height: 36,
              child: ProfileMenuItem(
                icon: LucideIcons.circleHelp,
                label: 'Help',
              ),
            ),
            const PopupMenuItem(
              value: 'signOut',
              height: 36,
              child: ProfileMenuItem(
                icon: LucideIcons.logOut,
                label: 'Sign out',
              ),
            ),
          ],
          child: Semantics(
            button: true,
            label: 'Account menu',
            child: SizedBox(
              height: 52,
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFE0E0E0),
                      child: Text(
                        name.isEmpty
                            ? '?'
                            : name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      LucideIcons.chevronUp,
                      size: 14,
                      color: Color(0xFF737373),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
