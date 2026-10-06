import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

import '../../state/storage_controller.dart';
import 'cache_usage_bar.dart';
import 'cache_history_graph.dart';
import 'cache_usage_actions.dart';
import 'settings_issue.dart';

class CacheUsageControls extends StatelessWidget {
  const CacheUsageControls({super.key, required this.controller});
  final StorageController controller;

  @override
  Widget build(BuildContext context) {
    final usage = controller.usage;
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            overflowAlignment: OverflowBarAlignment.start,
            spacing: 12,
            overflowSpacing: 12,
            children: [
              const Text(
                'Streaming cache',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              CacheUsageActions(controller: controller),
            ],
          ),
          SizedBox(height: 16),
          if (usage?.available == true)
            Column(
              children: [
                CacheUsageBar(usage: usage!),
                SizedBox(height: 20),
                CacheHistoryGraph(samples: controller.history),
              ],
            )
          else
            Text(
              controller.busy
                  ? 'Reading cache usage…'
                  : 'Connect a Finder drive to measure cache usage.',
              style: TextStyle(
                fontSize: 13,
                color: GardenColors.of(context).secondary,
              ),
            ),
          if (controller.error != null) ...[
            SizedBox(height: 12),
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
