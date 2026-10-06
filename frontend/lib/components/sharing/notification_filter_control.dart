import 'package:flutter/material.dart';

import '../../model/notification_filter.dart';
import '../../ui/garden_colors.dart';

class NotificationFilterControl extends StatelessWidget {
  const NotificationFilterControl({
    super.key,
    required this.value,
    required this.unread,
    required this.onChanged,
  });
  final NotificationFilter value;
  final int unread;
  final ValueChanged<NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 4,
    runSpacing: 4,
    children: [
      for (final filter in NotificationFilter.values)
        TextButton(
          onPressed: () => onChanged(filter),
          style: TextButton.styleFrom(
            foregroundColor: GardenColors.of(context).ink,
            backgroundColor: filter == value
                ? GardenColors.of(context).selection
                : Colors.transparent,
            shape: const StadiumBorder(),
            splashFactory: NoSplash.splashFactory,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: Theme.of(context).textTheme.labelLarge!
                .copyWith(fontSize: 12),
          ),
          child: Text(switch (filter) {
            NotificationFilter.all => 'All',
            NotificationFilter.unread =>
              unread == 0 ? 'Unread' : 'Unread ($unread)',
            NotificationFilter.trash => 'Trash',
          }),
        ),
    ],
  );
}
