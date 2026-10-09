import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/files/file_details.dart';
import 'package:garden_flutter/components/files/file_move_dialog.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'files_gateway_fixture.dart';

class PendingReadFixture extends FilesFixture {
  final listing = Completer<DirectoryListing>();
  final history = Completer<List<FileVersion>>();
  @override
  Future<DirectoryListing> list(int gardenId, int parentId) => listing.future;
  @override
  Future<List<FileVersion>> versions(int nodeId) => history.future;
}

void main() {
  testWidgets('move browsing reports a stalled read and still permits cancel', (
    tester,
  ) async {
    final gateway = PendingReadFixture();
    final file = await gateway.create(7, 0, 'file.txt', NodeKind.file);
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: FileMoveDialog(gateway: gateway, node: file),
        ),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 45));
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('took too long'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final cancel = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Cancel'),
    );
    expect(cancel.onPressed, isNotNull);
    final move = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Move here'),
    );
    expect(move.onPressed, isNull);
    await gateway.events.close();
  });

  testWidgets('file history stops its spinner when a read stalls', (
    tester,
  ) async {
    final gateway = PendingReadFixture();
    final file = await gateway.create(7, 0, 'file.txt', NodeKind.file);
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: FileDetails(
            gateway: gateway,
            node: file,
            revision: 1,
            userId: 'account',
            onExport: (_) {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 45));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('took too long'), findsOneWidget);
    await gateway.events.close();
  });
}
