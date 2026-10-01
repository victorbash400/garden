import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/garden_theme.dart';

class VerificationCodeInput extends StatefulWidget {
  const VerificationCodeInput({
    super.key,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
  });
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  final fields = List.generate(8, (_) => TextEditingController());
  final focus = List.generate(8, (_) => FocusNode());

  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    for (final node in focus) {
      node.dispose();
    }
    super.dispose();
  }

  void changed(int index, String value) {
    final characters = value
        .toLowerCase()
        .codeUnits
        .where((c) => (c >= 48 && c <= 57) || (c >= 97 && c <= 122))
        .toList();
    if (characters.isEmpty) {
      fields[index].clear();
    } else {
      final start = characters.length == 8 ? 0 : index;
      for (
        var offset = 0;
        offset < characters.length && start + offset < 8;
        offset++
      ) {
        fields[start + offset].text = String.fromCharCode(characters[offset]);
      }
      final next = (start + characters.length).clamp(0, 7);
      focus[next].requestFocus();
    }
    widget.onChanged(fields.map((field) => field.text).join());
  }

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(
      8,
      (index) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: index == 7 ? 0 : 6),
          child: Focus(
            onKeyEvent: (_, event) {
              if (widget.enabled &&
                  event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  fields[index].text.isEmpty &&
                  index > 0) {
                fields[index - 1].clear();
                focus[index - 1].requestFocus();
                widget.onChanged(fields.map((field) => field.text).join());
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: fields[index],
              focusNode: focus[index],
              enabled: widget.enabled,
              autofocus: index == 0,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: index == 0
                  ? const [AutofillHints.oneTimeCode]
                  : null,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
              onChanged: (value) => changed(index, value),
              onSubmitted: (_) => widget.onSubmitted(),
              decoration: InputDecoration(
                semanticCounterText: 'Code character ${index + 1} of 8',
                hintText: '—',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDADADD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: GardenTheme.blue),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
