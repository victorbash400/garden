import 'package:flutter/material.dart';

import '../components/garden_field.dart';
import '../components/remember_login_control.dart';
import '../components/saved_login_button.dart';
import '../components/demo_account_button.dart';
import '../components/garden_button.dart';
import '../components/account_form_links.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({
    super.key,
    required this.busy,
    required this.onSubmit,
    required this.submitLabel,
    this.onBack,
    this.onCreateAccount,
    this.showDemo = false,
    this.savedEmail,
    this.onContinueSaved,
    this.onForgetSaved,
    this.remember = false,
    this.onRememberChanged,
  });
  final String? savedEmail;
  final VoidCallback? onContinueSaved;
  final VoidCallback? onForgetSaved;
  final bool remember;
  final ValueChanged<bool>? onRememberChanged;
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
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: AutofillGroup(
        child: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.savedEmail != null) ...[
                SavedLoginButton(
                  email: widget.savedEmail!,
                  onContinue: widget.busy ? null : widget.onContinueSaved,
                  onForget: widget.busy ? null : widget.onForgetSaved,
                ),
                const SizedBox(height: 20),
              ],
              GardenField(
                label: 'Email',
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                controller: email,
                enabled: !widget.busy,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              GardenField(
                label: 'Password',
                autofillHints: [
                  widget.showDemo
                      ? AutofillHints.password
                      : AutofillHints.newPassword,
                ],
                controller: password,
                obscure: true,
                enabled: !widget.busy,
                onSubmitted: (_) => submit(),
              ),
              if (widget.showDemo || widget.onCreateAccount != null) ...[
                const SizedBox(height: 12),
                AccountFormLinks(
                  showDemo: widget.showDemo,
                  onFillDemo: widget.busy ? null : fillDemo,
                  onCreateAccount: widget.busy ? null : widget.onCreateAccount,
                  showCreateAccount: widget.onCreateAccount != null,
                ),
              ],
              if (widget.onRememberChanged != null) ...[
                const SizedBox(height: 16),
                RememberLoginControl(
                  value: widget.remember,
                  onChanged: widget.busy ? null : widget.onRememberChanged,
                ),
              ],
              const SizedBox(height: 24),
              GardenButton(
                label: widget.busy ? 'Please wait' : widget.submitLabel,
                onPressed: canSubmit ? submit : null,
              ),
              if (widget.onBack != null) ...[
                const SizedBox(height: 12),
                GardenButton(
                  label: 'Back',
                  secondary: true,
                  onPressed: widget.busy ? null : widget.onBack,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
