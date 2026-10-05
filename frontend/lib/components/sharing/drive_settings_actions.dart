import 'package:flutter/material.dart';

import '../settings/settings_row.dart';
import '../settings/settings_inline_button.dart';
import '../files/node_name_dialog.dart';

class DriveSettingsActions extends StatelessWidget {
  const DriveSettingsActions({
    super.key,
    required this.name,
    required this.owner,
    required this.busy,
    required this.onRename,
    required this.onRemove,
  });
  final String name;
  final bool owner, busy;
  final Future<void> Function(String) onRename;
  final Future<void> Function() onRemove;

  Future<void> rename(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => NodeNameDialog(action: 'Rename', value: name),
    );
    if (value != null) await onRename(value);
  }

  Future<void> remove(BuildContext context) async {
    final action = owner ? 'Delete drive' : 'Leave drive';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action "$name"?'),
        content: Text(
          owner
              ? 'This removes the drive for all members.'
              : 'You will lose access to this drive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed == true) await onRemove();
  }

  @override
  Widget build(BuildContext context) => SettingsRow(
    label: 'Drive',
    value: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (owner) ...[
          SettingsInlineButton(
            label: 'Rename…',
            onPressed: busy ? null : () => rename(context),
          ),
          const SizedBox(width: 8),
        ],
        SettingsInlineButton(
          label: owner ? 'Delete…' : 'Leave…',
          onPressed: busy ? null : () => remove(context),
        ),
      ],
    ),
  );
}
