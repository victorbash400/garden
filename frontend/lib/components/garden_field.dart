import 'package:flutter/material.dart';

import '../ui/garden_theme.dart';

class GardenField extends StatelessWidget {
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: GardenTheme.secondary),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        autofocus: autofocus,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        decoration: InputDecoration(
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
