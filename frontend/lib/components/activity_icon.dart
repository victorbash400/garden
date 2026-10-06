import 'system_icon.dart';

import 'package:flutter/material.dart';

class ActivityIcon extends StatelessWidget {
  const ActivityIcon({super.key});
  @override
  Widget build(BuildContext context) =>
      const SystemIcon(SystemIcons.squareActivity, size: 17);
}
