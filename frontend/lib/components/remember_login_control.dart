import 'package:flutter/material.dart';

class RememberLoginControl extends StatelessWidget {
  const RememberLoginControl({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 24,
        height: 24,
        child: Checkbox(
          value: value,
          onChanged: onChanged == null ? null : (value) => onChanged!(value!),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      const SizedBox(width: 8),
      const Text('Remember me', style: TextStyle(fontSize: 12)),
    ],
  );
}
