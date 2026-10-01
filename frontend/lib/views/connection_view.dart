import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../model/garden_info.dart';
import '../components/garden_button.dart';
import '../ui/garden_theme.dart';

class ConnectionView extends StatelessWidget {
  const ConnectionView({super.key, required this.garden});
  final GardenInfo garden;
  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.folderCheck,
            size: 48,
            color: GardenTheme.blue,
          ),
          const SizedBox(height: 20),
          Text(
            garden.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const Text('Connected to Garden'),
          const SizedBox(height: 8),
          const Text(
            'Finder mounting is not available yet.',
            style: TextStyle(fontSize: 12, color: GardenTheme.secondary),
          ),
          if (garden.invitationCode != null) ...[
            const SizedBox(height: 24),
            GardenButton(
              label: 'Copy invitation code',
              secondary: true,
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: garden.invitationCode!),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation code copied.')),
                  );
                }
              },
            ),
          ],
        ],
      ),
    ),
  );
}
