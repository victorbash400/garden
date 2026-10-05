import 'package:flutter/material.dart';

import '../../state/storage_controller.dart';
import 'cache_usage_bar.dart';
import 'cache_history_graph.dart';
import 'settings_inline_button.dart';
import 'settings_issue.dart';

class CacheUsageControls extends StatelessWidget {
  const CacheUsageControls({super.key, required this.controller});
  final StorageController controller;

  @override
  Widget build(BuildContext context) {
    final usage = controller.usage;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Streaming cache'),
              const Spacer(),
              SettingsInlineButton(
                label: 'Refresh',
                onPressed: controller.busy ? null : controller.refresh,
              ),
              const SizedBox(width: 8),
              SettingsInlineButton(
                label: 'Clear cache',
                onPressed:
                    controller.busy ||
                        usage?.available != true ||
                        usage?.usedBytes == 0
                    ? null
                    : controller.clear,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (usage?.available == true)
            Column(
              children: [
                CacheUsageBar(usage: usage!),
                const SizedBox(height: 20),
                CacheHistoryGraph(samples: controller.history),
              ],
            )
          else
            Text(
              controller.busy
                  ? 'Reading cache usage…'
                  : 'Connect a Finder drive to measure cache usage.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF77777A)),
            ),
          if (controller.error != null) ...[
            const SizedBox(height: 12),
            SettingsIssue(
              message: 'Cache request failed',
              details: controller.error!,
            ),
          ],
        ],
      ),
    );
  }
}
