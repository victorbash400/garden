import 'package:flutter/material.dart';

import '../../model/notification_filter.dart';
import '../settings/settings_inline_button.dart';
import '../settings/settings_picker.dart';
import 'notification_filter_control.dart';

class NotificationsToolbar extends StatelessWidget {
  const NotificationsToolbar({
    super.key,
    required this.unread,
    required this.busy,
    required this.onRefresh,
    required this.filter,
    required this.sort,
    required this.onFilter,
    required this.onSort,
  });
  final int unread;
  final bool busy;
  final VoidCallback onRefresh;
  final NotificationFilter filter;
  final NotificationSort sort;
  final ValueChanged<NotificationFilter> onFilter;
  final ValueChanged<NotificationSort> onSort;

  @override
  Widget build(BuildContext context) => OverflowBar(
    alignment: MainAxisAlignment.spaceBetween,
    overflowAlignment: OverflowBarAlignment.start,
    spacing: 12,
    overflowSpacing: 12,
    children: [
      NotificationFilterControl(
        value: filter,
        unread: unread,
        onChanged: onFilter,
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SettingsPicker<NotificationSort>(
            width: 130,
            value: sort,
            items: const [
              DropdownMenuItem(
                value: NotificationSort.newest,
                child: Text('Newest first'),
              ),
              DropdownMenuItem(
                value: NotificationSort.oldest,
                child: Text('Oldest first'),
              ),
            ],
            onChanged: (value) => onSort(value!),
          ),
          SettingsInlineButton(
            label: 'Refresh',
            onPressed: busy ? null : onRefresh,
          ),
        ],
      ),
    ],
  );
}
