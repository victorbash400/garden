import 'package:flutter/material.dart';

import '../../model/garden_info.dart';
import '../settings/settings_picker.dart';

class DrivePicker extends StatelessWidget {
  const DrivePicker({
    super.key,
    required this.drives,
    required this.selected,
    required this.onChanged,
  });
  final List<GardenInfo> drives;
  final int? selected;
  final ValueChanged<int?>? onChanged;
  @override
  Widget build(BuildContext context) => SettingsPicker<int>(
    width: 220,
    value: selected,
    items: [
      for (final drive in drives)
        DropdownMenuItem(
          value: drive.id,
          child: Text(drive.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: onChanged,
  );
}
