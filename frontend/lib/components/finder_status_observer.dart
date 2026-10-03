import 'dart:async';

import 'package:flutter/material.dart';

import '../state/garden_controller.dart';

class FinderStatusObserver extends StatefulWidget {
  const FinderStatusObserver({
    super.key,
    required this.controller,
    required this.child,
  });

  final GardenController controller;
  final Widget child;

  @override
  State<FinderStatusObserver> createState() => _FinderStatusObserverState();
}

class _FinderStatusObserverState extends State<FinderStatusObserver>
    with WidgetsBindingObserver {
  StreamSubscription<void>? _wakeSubscription;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wakeSubscription = widget.controller.nativeSetup?.system.wakeEvents.listen(
      (_) {
        unawaited(
          widget.controller.handleSystemWake().catchError(
            widget.controller.finderUpdateError,
          ),
        );
      },
      onError: widget.controller.finderUpdateError,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wakeSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.controller.account != null &&
        !widget.controller.busy &&
        !widget.controller.finderSyncing) {
      widget.controller.checkFinder();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
