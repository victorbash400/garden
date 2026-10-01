import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DriveSectionHeader extends StatelessWidget {
  const DriveSectionHeader({
    super.key,
    required this.label,
    required this.onOpen,
    required this.actionLabel,
    required this.onAdd,
  });
  final String label;
  final String actionLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onAdd;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF858581),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              tooltip: actionLabel,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: onAdd,
              icon: const Icon(
                LucideIcons.plus,
                size: 14,
                color: Color(0xFF858581),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
