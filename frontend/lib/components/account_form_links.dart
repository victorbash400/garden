import 'package:flutter/material.dart';

import 'demo_account_button.dart';

class AccountFormLinks extends StatelessWidget {
  const AccountFormLinks({
    super.key,
    required this.showDemo,
    required this.showCreateAccount,
    this.onFillDemo,
    this.onDark = false,
    this.onCreateAccount,
  });

  final bool showDemo;
  final bool onDark;
  final bool showCreateAccount;
  final VoidCallback? onFillDemo;
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    spacing: 12,
    runSpacing: 8,
    children: [
      if (showDemo) DemoAccountButton(onFill: onFillDemo, onDark: onDark),
      if (showCreateAccount)
        TextButton(
          onPressed: onCreateAccount,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge!
                .copyWith(fontSize: 12),
          ),
          child: const Text('Create account'),
        ),
    ],
  );
}
