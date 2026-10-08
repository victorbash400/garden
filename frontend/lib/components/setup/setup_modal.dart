import 'package:flutter/material.dart';

import '../../state/garden_controller.dart';
import '../../ui/garden_colors.dart';
import '../settings/setup_checklist.dart';
import 'finder_permission_step.dart';
import 'installation_step.dart';
import 'setup_navigation.dart';

class SetupModal extends StatefulWidget {
  const SetupModal({super.key, required this.controller});
  final GardenController controller;

  @override
  State<SetupModal> createState() => _SetupModalState();
}

class _SetupModalState extends State<SetupModal> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final colors = GardenColors.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: .18),
      child: Center(
        child: Dialog(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            key: const ValueKey('setup-surface'),
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          const [
                            'Install Garden',
                            'Enable Finder drives',
                            'Set up your drive',
                          ][step],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${step + 1} of 3',
                        style: TextStyle(color: colors.secondary),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: AnimatedSwitcher(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      child: KeyedSubtree(
                        key: ValueKey(step),
                        child: switch (step) {
                          0 => InstallationStep(controller: controller),
                          1 => FinderPermissionStep(controller: controller),
                          _ => SetupChecklist(controller: controller),
                        },
                      ),
                    ),
                  ),
                ),
                SetupNavigation(
                  onLater: controller.closeSetup,
                  onBack: step > 0 ? () => setState(() => step--) : null,
                  lastStep: step == 2,
                  onContinue: step == 2
                      ? controller.closeSetup
                      : () => setState(() => step++),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
