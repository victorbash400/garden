import '../system_icon.dart';

import 'package:flutter/material.dart';

class FileCommentInput extends StatefulWidget {
  const FileCommentInput({super.key, required this.onSubmit});
  final Future<bool> Function(String) onSubmit;
  @override
  State<FileCommentInput> createState() => _FileCommentInputState();
}

class _FileCommentInputState extends State<FileCommentInput> {
  final input = TextEditingController();
  bool busy = false;
  Future<void> submit() async {
    if (busy || input.text.trim().isEmpty) return;
    setState(() => busy = true);
    final success = await widget.onSubmit(input.text);
    if (!mounted) return;
    if (success) input.clear();
    setState(() => busy = false);
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: input,
            enabled: !busy,
            maxLength: 4000,
            decoration: const InputDecoration(
              hintText: 'Comment',
              counterText: '',
            ),
            onSubmitted: (_) => submit(),
          ),
        ),
        IconButton(
          tooltip: 'Post comment',
          onPressed: busy ? null : submit,
          icon: const SystemIcon(SystemIcons.arrowUp, size: 16),
        ),
      ],
    ),
  );
}
