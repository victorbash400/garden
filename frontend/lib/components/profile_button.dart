import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

import '../state/garden_controller.dart';
import 'profile_menu_item.dart';
import 'profile_help_dialog.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final account = controller.account;
    if (account == null) return SizedBox.shrink();
    final name = account.email.split('@').first;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: GardenColors.of(context).hover,
        borderRadius: BorderRadius.circular(20),
        child: PopupMenuButton<String>(
          tooltip: 'Account menu',
          popUpAnimationStyle: AnimationStyle.noAnimation,
          enabled: !controller.busy,
          position: PopupMenuPosition.over,
          offset: Offset(
            0,
            -(36.0 * (controller.accountWindow == null ? 5 : 6) + 16),
          ),
          borderRadius: BorderRadius.circular(20),
          constraints: BoxConstraints(minWidth: 216, maxWidth: 300),
          color: GardenColors.of(context).panel,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shadowColor: GardenColors.of(context).ink.withValues(alpha: .14),
          menuPadding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: GardenColors.of(context).border),
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
                  builder: (_) => ProfileHelpDialog(),
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
                style: TextStyle(
                  fontSize: 12,
                  color: GardenColors.of(context).secondary,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              height: 36,
              child: ProfileMenuItem(
                icon: SystemIcons.settings,
                label: 'Settings',
              ),
            ),
            PopupMenuItem(
              value: 'connections',
              height: 36,
              child: ProfileMenuItem(
                icon: SystemIcons.plug,
                label: 'Connections',
              ),
            ),
            if (controller.accountWindow != null)
              PopupMenuItem(
                value: 'new',
                height: 36,
                child: ProfileMenuItem(
                  icon: SystemIcons.appWindow,
                  label: 'New account window',
                ),
              ),
            PopupMenuItem(
              value: 'help',
              height: 36,
              child: ProfileMenuItem(
                icon: SystemIcons.circleHelp,
                label: 'Help',
              ),
            ),
            PopupMenuItem(
              value: 'signOut',
              height: 36,
              child: ProfileMenuItem(
                icon: SystemIcons.logOut,
                label: 'Sign out',
              ),
            ),
          ],
          child: Semantics(
            button: true,
            label: 'Account menu',
            child: SizedBox(
              height: 40,
              child: Ink(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: GardenColors.of(context).hover,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: GardenColors.of(context).hover,
                      child: Text(
                        name.isEmpty
                            ? '?'
                            : name.characters.first.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: GardenColors.of(context).ink,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
