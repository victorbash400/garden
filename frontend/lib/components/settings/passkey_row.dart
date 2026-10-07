import 'package:flutter/material.dart';

import 'settings_row.dart';
import 'settings_inline_button.dart';

class PasskeyRow extends StatelessWidget {
  const PasskeyRow({
    super.key,
    required this.createdAt,
    required this.onRemove,
  });
  final DateTime createdAt;
  final VoidCallback? onRemove;
  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(createdAt.toLocal());
    return SettingsRow(
      label: 'Passkey · $date',
      value: SettingsInlineButton(onPressed: onRemove, label: 'Remove'),
    );
  }
}
