import 'package:flutter/material.dart';

import '../state/garden_controller.dart';
import 'error_notice.dart';
import 'garden_button.dart';
import 'garden_field.dart';

Future<void> showDriveDialog(
  BuildContext context,
  GardenController controller, {
  bool join = false,
}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => DriveDialog(controller: controller, join: join),
);

class DriveDialog extends StatefulWidget {
  const DriveDialog({super.key, required this.controller, required this.join});
  final GardenController controller;
  final bool join;
  @override
  State<DriveDialog> createState() => _DriveDialogState();
}

class _DriveDialogState extends State<DriveDialog> {
  final value = TextEditingController();
  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (value.text.trim().isEmpty || widget.controller.busy) return;
    if (widget.join) {
      await widget.controller.join(value.text.trim());
    } else {
      await widget.controller.create(value.text.trim());
    }
    if (mounted && widget.controller.page == GardenPage.connected) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => PopScope(
      canPop: !widget.controller.busy,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 380,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GardenField(
                  label: widget.join ? 'Invitation code' : 'Drive name',
                  controller: value,
                  enabled: !widget.controller.busy,
                  autofocus: true,
                  onSubmitted: (_) => submit(),
                ),
                if (widget.controller.error != null) ...[
                  const SizedBox(height: 12),
                  ErrorNotice(
                    message: widget.controller.error!,
                    onDismiss: () =>
                        widget.controller.navigate(widget.controller.page),
                  ),
                ],
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    GardenButton(
                      label: 'Cancel',
                      secondary: true,
                      onPressed: widget.controller.busy
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: value,
                      builder: (_, text, _) => GardenButton(
                        label: widget.join ? 'Join drive' : 'Create drive',
                        onPressed:
                            widget.controller.busy || text.text.trim().isEmpty
                            ? null
                            : submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
