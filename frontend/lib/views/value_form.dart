import 'package:flutter/material.dart';

import '../components/garden_field.dart';
import '../components/garden_button.dart';

class ValueForm extends StatefulWidget {
  const ValueForm({
    super.key,
    required this.label,
    required this.action,
    required this.busy,
    required this.onSubmit,
    required this.onBack,
  });
  final String label;
  final String action;
  final bool busy;
  final ValueChanged<String> onSubmit;
  final VoidCallback onBack;
  @override
  State<ValueForm> createState() => _ValueFormState();
}

class _ValueFormState extends State<ValueForm> {
  final value = TextEditingController();
  @override
  void initState() {
    super.initState();
    value.addListener(_changed);
  }

  void _changed() => setState(() {});
  bool get canSubmit => !widget.busy && value.text.trim().isNotEmpty;
  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  void submit() {
    if (canSubmit) widget.onSubmit(value.text);
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GardenField(
              label: widget.label,
              controller: value,
              enabled: !widget.busy,
              autofocus: true,
              onSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 24),
            GardenButton(
              label: widget.action,
              onPressed: canSubmit ? submit : null,
            ),
            const SizedBox(height: 12),
            GardenButton(
              label: 'Back',
              secondary: true,
              onPressed: widget.busy ? null : widget.onBack,
            ),
          ],
        ),
      ),
    ),
  );
}
