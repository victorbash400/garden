import 'package:flutter/material.dart';

import '../components/garden_field.dart';
import '../components/onboarding_footer.dart';

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
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: Center(
          child: SizedBox(
            width: 340,
            child: GardenField(
              label: widget.label,
              controller: value,
              enabled: !widget.busy,
              autofocus: true,
              onSubmitted: (_) => submit(),
            ),
          ),
        ),
      ),
      OnboardingFooter(
        action: widget.action,
        busy: widget.busy,
        onBack: widget.busy ? null : widget.onBack,
        onAction: canSubmit ? submit : null,
      ),
    ],
  );
}
