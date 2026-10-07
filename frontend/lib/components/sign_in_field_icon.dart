import 'system_icon.dart';

import 'package:flutter/material.dart';

class SignInFieldIcon extends StatelessWidget {
  const SignInFieldIcon({super.key, required this.password});
  final bool password;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8, right: 10),
    child: Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: 34,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0x709CA69B),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SystemIcon(
              password ? SystemIcons.lockKeyhole : SystemIcons.mail,
              size: 18,
              color: const Color(0xFFE6ECE1),
            ),
          ),
        ),
      ),
    ),
  );
}
