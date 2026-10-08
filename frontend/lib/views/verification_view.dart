import 'package:flutter/material.dart';

import '../components/account_card.dart';
import '../components/garden_button.dart';
import '../components/verification_code_input.dart';
import '../state/garden_controller.dart';
import '../ui/garden_theme.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key, required this.controller});
  final GardenController controller;
  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  String code = '';
  String? resendStatus;
  int revision = 0;
  bool get ready => !widget.controller.busy && code.length == 8;
  void submit() {
    if (ready) widget.controller.verify(code);
  }

  Future<void> resend() async {
    setState(() => resendStatus = null);
    await widget.controller.resendVerification();
    if (!mounted || widget.controller.error != null) return;
    setState(() {
      resendStatus = widget.controller.localServer
          ? 'A new code is available in the backend output.'
          : 'A new verification email was requested.';
      code = '';
      revision++;
    });
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 436),
        child: AccountCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Email verification code',
                style: TextStyle(fontSize: 12, color: GardenTheme.secondary),
              ),
              const SizedBox(height: 8),
              Text(
                widget.controller.localServer
                    ? 'Local server: find the code in the backend output.'
                    : 'Verification email requested for ${widget.controller.registrationEmail}. Check your inbox and spam folder.',
                style: const TextStyle(
                  fontSize: 12,
                  color: GardenTheme.secondary,
                ),
              ),
              const SizedBox(height: 20),
              VerificationCodeInput(
                key: ValueKey(revision),
                enabled: !widget.controller.busy,
                onChanged: (value) => setState(() => code = value),
                onSubmitted: submit,
              ),
              const SizedBox(height: 24),
              GardenButton(label: 'Verify', onPressed: ready ? submit : null),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.controller.busy ? null : resend,
                    child: const Text('Resend code'),
                  ),
                  TextButton(
                    onPressed: widget.controller.busy
                        ? null
                        : widget.controller.back,
                    child: const Text('Change email'),
                  ),
                ],
              ),
              if (resendStatus != null)
                Text(
                  resendStatus!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: GardenTheme.secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
