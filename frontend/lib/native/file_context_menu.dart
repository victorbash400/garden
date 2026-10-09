import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:garden_client/garden_client.dart';

class FileContextMenu {
  static const _channel = MethodChannel('garden/file-menu');
  static bool get available =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  static Future<String?> show({
    FileNode? node,
    required bool canWrite,
    required bool canPreview,
    required bool canShare,
    required bool canOpenWith,
    required bool busy,
    required bool importing,
    required bool editableText,
    required double x,
    required double y,
  }) => _channel.invokeMethod<String>('show', {
    'x': x,
    'y': y,
    'filename': node?.name,
    'entries': [
      if (node == null) ...[
        {
          'title': 'New folder…',
          'value': 'folder',
          'enabled': canWrite && !busy,
        },
        {
          'title': 'New text file…',
          'value': 'file',
          'enabled': canWrite && !busy,
        },
        {'separator': true},
        {
          'title': 'Import files…',
          'value': 'import',
          'enabled': canWrite && !importing,
        },
      ] else ...[
        {'title': 'Open', 'value': 'open'},
        if (node.kind == NodeKind.file && canOpenWith)
          {'title': 'Open With', 'value': 'openWith'},
        if (node.kind == NodeKind.file && canPreview)
          {'title': 'Quick Look', 'value': 'preview'},
        {'separator': true},
        if (canWrite) ...[
          {'title': 'Rename…', 'value': 'rename', 'enabled': !busy},
          {'title': 'Move…', 'value': 'move', 'enabled': !busy},
          {'title': 'Delete…', 'value': 'delete', 'enabled': !busy},
          {'separator': true},
        ],
        if (node.kind == NodeKind.file) ...[
          if (canWrite && editableText)
            {'title': 'Edit text', 'value': 'edit', 'enabled': !busy},
          {'title': 'Export…', 'value': 'export'},
        ],
        if (canShare) {'title': 'Share…', 'value': 'share'},
      ],
    ],
  });
}
