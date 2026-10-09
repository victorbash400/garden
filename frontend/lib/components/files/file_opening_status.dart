import 'package:flutter/material.dart';

import '../../state/file_opening_controller.dart';
import '../../ui/garden_colors.dart';
import 'file_opening_popup.dart';

class FileOpeningStatus extends StatefulWidget {
  const FileOpeningStatus({super.key, required this.controller});
  final FileOpeningController controller;

  @override
  State<FileOpeningStatus> createState() => _FileOpeningStatusState();
}

class _FileOpeningStatusState extends State<FileOpeningStatus> {
  DialogRoute<void>? _route;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    _changed();
  }

  void _changed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.controller.node == null) {
        _route?.navigator?.removeRoute(_route!);
        _route = null;
        _shown = false;
      } else if (!_shown) {
        _shown = true;
        final route = DialogRoute<void>(
          context: context,
          builder: (_) => FileOpeningPopup(controller: widget.controller),
        );
        _route = route;
        Navigator.of(context, rootNavigator: true).push(route).then((_) {
          if (_route == route) _route = null;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    final route = _route;
    if (route != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => route.navigator?.removeRoute(route),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final node = widget.controller.node;
      if (node == null) return const SizedBox.shrink();
      return Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: GardenColors.of(context).ink,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Opening ${node.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
