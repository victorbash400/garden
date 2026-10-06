import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class SettingsCategory extends StatelessWidget {
  const SettingsCategory({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final Widget icon;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
    child: Material(
      color: selected ? GardenColors.of(context).selection : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 34,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                    size: 17,
                    color: GardenColors.of(context).secondary,
                  ),
                  child: icon,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
