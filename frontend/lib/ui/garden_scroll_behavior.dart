import 'package:flutter/material.dart';

class GardenScrollBehavior extends MaterialScrollBehavior {
  const GardenScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => Scrollbar(controller: details.controller, child: child);
}
