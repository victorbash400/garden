import 'package:flutter/material.dart';

import '../../services/bandwidth_store.dart';
import '../../utils/error_message.dart';
import 'bandwidth_control.dart';
import 'settings_group.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
        });
      }
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (upload != null && download != null)
        SettingsGroup(
          children: [
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
          ],
        ),
      if (upload != null)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Average payload rate across app transfers and Finder drives. Individual requests may burst.',
            style: TextStyle(fontSize: 12, color: Color(0xFF77777A)),
          ),
        ),
      if (error != null)
        Row(
          children: [
            Expanded(
              child: Text(
                error!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFB33D38)),
              ),
            ),
            TextButton(
              onPressed: busy ? null : _load,
              child: const Text('Retry'),
            ),
          ],
        ),
    ],
  );
}
