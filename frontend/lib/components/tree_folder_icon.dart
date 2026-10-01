import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TreeFolderIcon extends StatelessWidget {
  const TreeFolderIcon({super.key, this.connected = false});
  final bool connected;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 22,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset('assets/testbed-folder.svg', width: 22, height: 17),
        if (connected)
          const Positioned(
            right: 0,
            bottom: 0,
            child: Tooltip(
              message: 'Connected drive',
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: Icon(
                    LucideIcons.link,
                    size: 9,
                    color: Color(0xFF5C8FC4),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
