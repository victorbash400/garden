import 'package:flutter/widgets.dart';

/// Only the focused account window publishes the application menu.
class WindowMenuDelegate extends DefaultPlatformMenuDelegate {
  bool _active = false;
  List<PlatformMenuItem> _menus = const [];

  void setActive(bool active) {
    if (_active == active) return;
    _active = active;
    if (active) super.setMenus(_menus);
  }

  @override
  void setMenus(List<PlatformMenuItem> topLevelMenus) {
    _menus = topLevelMenus;
    if (_active) super.setMenus(topLevelMenus);
  }
}
