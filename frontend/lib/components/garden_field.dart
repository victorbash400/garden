import 'package:flutter/material.dart';

import '../ui/garden_theme.dart';
import 'password_visibility_button.dart';

class GardenField extends StatefulWidget {
  const GardenField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.enabled = true,
    this.autofocus = false,
    this.onSubmitted,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  @override
  State<GardenField> createState() => _GardenFieldState();
}

class _GardenFieldState extends State<GardenField> {
  bool passwordVisible = false;

  @override
  void didUpdateWidget(covariant GardenField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscure != widget.obscure ||
        oldWidget.controller != widget.controller) {
      passwordVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.label,
        style: const TextStyle(fontSize: 12, color: GardenTheme.secondary),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: widget.controller,
        obscureText: widget.obscure && !passwordVisible,
        autocorrect: !widget.obscure,
        enableSuggestions: !widget.obscure,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        onSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          suffixIcon: widget.obscure
              ? PasswordVisibilityButton(
                  visible: passwordVisible,
                  onPressed: widget.enabled
                      ? () => setState(() => passwordVisible = !passwordVisible)
                      : null,
                )
              : null,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDADADD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDADADD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: GardenTheme.blue),
          ),
        ),
      ),
    ],
  );
}
