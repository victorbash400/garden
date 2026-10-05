import 'package:flutter/material.dart';

Future<bool> confirmOwnershipTransfer(
  BuildContext context,
  String name,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer ownership to $name?'),
        content: const Text('You will become a Manager.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Transfer'),
          ),
        ],
      ),
    ) ??
    false;
