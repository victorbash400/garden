import 'package:flutter/material.dart';

import '../components/garden_field.dart';
import '../components/demo_account_button.dart';
import '../components/onboarding_footer.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({
    super.key,
    required this.busy,
    required this.onSubmit,
    required this.submitLabel,
    this.onBack,
    this.onCreateAccount,
    this.showDemo = false,
  });
  final bool busy;
  final bool showDemo;
  final String submitLabel;
  final void Function(String email, String password) onSubmit;
  final VoidCallback? onBack;
  final VoidCallback? onCreateAccount;
  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  void initState() {
    super.initState();
    email.addListener(_changed);
    password.addListener(_changed);
  }

  void _changed() => setState(() {});
  bool get canSubmit =>
      !widget.busy && email.text.trim().isNotEmpty && password.text.isNotEmpty;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void fillDemo() {
    email.text = DemoAccountButton.email;
    password.text = DemoAccountButton.password;
  }

  void submit() {
    if (canSubmit) widget.onSubmit(email.text, password.text);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: Center(
          child: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GardenField(
                  label: 'Email',
                  controller: email,
                  enabled: !widget.busy,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                GardenField(
                  label: 'Password',
                  controller: password,
                  obscure: true,
                  enabled: !widget.busy,
                  onSubmitted: (_) => submit(),
                ),
                if (widget.showDemo)
                  DemoAccountButton(onFill: widget.busy ? null : fillDemo),
                if (widget.onCreateAccount != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: widget.busy ? null : widget.onCreateAccount,
                      child: const Text('Create account'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      OnboardingFooter(
        action: widget.submitLabel,
        busy: widget.busy,
        onBack: widget.busy ? null : widget.onBack,
        onAction: canSubmit ? submit : null,
      ),
    ],
  );
}
