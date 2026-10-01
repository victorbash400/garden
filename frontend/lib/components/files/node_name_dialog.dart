import 'package:flutter/material.dart';

class NodeNameDialog extends StatefulWidget {
  const NodeNameDialog({super.key, required this.action, this.value = ''});
  final String action;
  final String value;
  @override
  State<NodeNameDialog> createState() => _NodeNameDialogState();
}

class _NodeNameDialogState extends State<NodeNameDialog> {
  late final input = TextEditingController(text: widget.value);
  void submit() {
    if (input.text.trim().isNotEmpty) Navigator.pop(context, input.text.trim());
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: SizedBox(
      width: 320,
      child: TextField(
        controller: input,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (_) => submit(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(onPressed: submit, child: Text(widget.action)),
    ],
  );
}
