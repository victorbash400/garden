import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class AccountIdentity extends StatelessWidget {
  const AccountIdentity({super.key, required this.email});
  final String email;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 8, bottom: 28),
    child: Column(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: GardenColors.of(context).hover,
          child: Text(
            email.substring(0, 1).toUpperCase(),
            style: TextStyle(fontSize: 30, color: GardenColors.of(context).ink),
          ),
        ),
        SizedBox(height: 14),
        SelectableText(email, style: TextStyle(fontSize: 15)),
      ],
    ),
  );
}
