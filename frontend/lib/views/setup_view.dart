import 'package:flutter/material.dart';

import '../components/garden_mark.dart';
import '../components/onboarding_footer.dart';
import '../components/setup_drive_step.dart';
import '../components/setup_finder_step.dart';
import '../state/garden_controller.dart';
import '../ui/garden_theme.dart';

class SetupView extends StatefulWidget {
  const SetupView({super.key, required this.controller});

  final GardenController controller;

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.controller.gardens.isNotEmpty &&
        !widget.controller.busy &&
        !widget.controller.finderSyncing) {
      widget.controller.checkFinder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDrive = widget.controller.gardens.isNotEmpty;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GardenMark(size: 38),
                  const SizedBox(height: 30),
                  Text(
                    hasDrive ? 'Finder' : 'Drive',
                    style: const TextStyle(
                      color: GardenTheme.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 26),
                  hasDrive
                      ? SetupFinderStep(controller: widget.controller)
                      : SetupDriveStep(controller: widget.controller),
                ],
              ),
            ),
          ),
        ),
        OnboardingFooter(
          step: hasDrive ? 2 : 1,
          totalSteps: 2,
          action: widget.controller.finderEnabledDriveIDs.isNotEmpty
              ? 'Continue in Garden'
              : 'Use Garden without Finder',
          busy: widget.controller.busy,
          onAction: hasDrive && !widget.controller.busy
              ? widget.controller.finishSetup
              : null,
        ),
      ],
    );
  }
}
