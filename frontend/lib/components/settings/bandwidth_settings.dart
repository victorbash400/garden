import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/bandwidth_store.dart';
import '../../utils/error_message.dart';
import 'bandwidth_control.dart';
import 'settings_group.dart';
import 'settings_issue.dart';
import 'settings_row.dart';

class BandwidthSettings extends StatefulWidget {
  const BandwidthSettings({super.key});
  @override
  State<BandwidthSettings> createState() => _BandwidthSettingsState();
}

class _BandwidthSettingsState extends State<BandwidthSettings> {
  int? upload;
  int? download;
  bool busy = false;
  String? error;
  bool restartRequired = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => busy = true);
    try {
      final value = await BandwidthStore.status();
      if (!mounted) return;
      final up = value['upload'];
      final down = value['download'];
      if (up is! int || down is! int) {
        throw StateError('Invalid bandwidth settings.');
      }
      setState(() {
        upload = up;
        download = down;
        error = null;
      });
    } catch (failure) {
      if (mounted) {
        setState(() {
          error = errorMessage(failure);
          restartRequired = failure is MissingPluginException;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _set(int up, int down) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await BandwidthStore.set(up, down);
      if (mounted) {
        setState(() {
          upload = up;
          download = down;
        });
      }
    } catch (failure) {
      if (mounted) {
        setState(() {
          error = errorMessage(failure);
          restartRequired = failure is MissingPluginException;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      if (upload != null && download != null) ...[
        BandwidthControl(
          label: 'Upload bandwidth',
          value: upload!,
          busy: busy,
          onChanged: (value) => _set(value, download!),
        ),
        BandwidthControl(
          label: 'Download bandwidth',
          value: download!,
          busy: busy,
          onChanged: (value) => _set(upload!, value),
        ),
      ] else if (error == null)
        const SettingsRow(label: 'Bandwidth', value: Text('Loading…')),
      if (error != null)
        SettingsIssue(
          message: restartRequired ? error! : 'Bandwidth unavailable',
          details: restartRequired ? null : error,
          action: restartRequired ? null : 'Retry',
          onAction: busy ? null : _load,
        ),
    ],
  );
}
