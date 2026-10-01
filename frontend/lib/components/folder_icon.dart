import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FolderIcon extends StatelessWidget {
  const FolderIcon({super.key, this.open = false, this.size = 24});
  final bool open;
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    open ? 'assets/folder-open.svg' : 'assets/folder-closed.svg',
    width: size,
    height: size,
  );
}
