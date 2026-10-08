import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';
import 'password_visibility_button.dart';
import 'sign_in_field_icon.dart';
import 'sign_in_field_surface.dart';

class GardenField extends StatefulWidget {
  const GardenField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.onDark = false,
    this.enabled = true,
    this.autofocus = false,
    this.onSubmitted,
    this.keyboardType,
    this.autofillHints,
  });
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool onDark;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
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
      if (!widget.onDark)
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            color: GardenColors.of(context).secondary,
          ),
        ),
      if (!widget.onDark) const SizedBox(height: 8),
      SignInFieldSurface(
        enabled: widget.onDark,
        child: TextField(
          controller: widget.controller,
          autofillHints: widget.autofillHints,
          obscureText: widget.obscure && !passwordVisible,
          autocorrect: !widget.obscure,
          enableSuggestions: !widget.obscure,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          onSubmitted: widget.onSubmitted,
          keyboardType: widget.keyboardType,
          style: widget.onDark
              ? const TextStyle(color: Color(0xFFF2F5EE), fontSize: 14)
              : null,
          cursorColor: widget.onDark ? const Color(0xFFE7ECE1) : null,
          decoration: InputDecoration(
            hintText: widget.onDark ? widget.label : null,
            hintStyle: widget.onDark
                ? const TextStyle(color: Color(0xFFD4DCCE), fontSize: 14)
                : null,
            prefixIcon: widget.onDark
                ? SignInFieldIcon(password: widget.obscure)
                : null,
            suffixIcon: widget.obscure
                ? PasswordVisibilityButton(
                    visible: passwordVisible,
                    color: widget.onDark
                        ? const Color(0xFFD4DCCE)
                        : GardenColors.of(context).secondary,
                    onPressed: widget.enabled
                        ? () =>
                              setState(() => passwordVisible = !passwordVisible)
                        : null,
                  )
                : null,
            isDense: true,
            filled: true,
            fillColor: widget.onDark
                ? const Color(0x506A7567)
                : GardenColors.of(context).panel,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: widget.onDark ? 19 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.onDark ? 30 : 10),
              borderSide: BorderSide(
                color: widget.onDark
                    ? const Color(0x508E9B87)
                    : GardenColors.of(context).border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.onDark ? 30 : 10),
              borderSide: BorderSide(
                color: widget.onDark
                    ? const Color(0x508E9B87)
                    : GardenColors.of(context).border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.onDark ? 30 : 10),
              borderSide: BorderSide(
                color: widget.onDark
                    ? const Color(0xFFBFCCB6)
                    : GardenColors.of(context).accent,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
