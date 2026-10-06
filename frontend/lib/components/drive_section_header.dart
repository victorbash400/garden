import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

class DriveSectionHeader extends StatelessWidget {
  const DriveSectionHeader({
    super.key,
    required this.label,
    required this.onOpen,
  });
  final String label;
  final VoidCallback? onOpen;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
    child: SizedBox(
      height: 31,
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onOpen,
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                overlayColor: Colors.transparent,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: GardenColors.of(context).secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
