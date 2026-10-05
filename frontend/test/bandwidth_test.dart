import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/bandwidth_settings.dart';
import 'package:garden_flutter/services/bandwidth_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('garden/bandwidth');
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'status') return {'upload': 0, 'download': 0};
          if (call.method == 'reserve') return {'seconds': 0.0};
          return <String, Object>{};
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  testWidgets('settings send independent upload and download limits', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BandwidthSettings())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unlimited'), findsNWidgets(2));
    await tester.tap(find.byType(DropdownButton<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 MiB/s').last);
    await tester.pumpAndSettle();
    final saved = calls.lastWhere((call) => call.method == 'set');
    expect(saved.arguments, {'upload': 5 * 1024 * 1024, 'download': 0});
    expect(find.text('5 MiB/s'), findsOneWidget);
  });

  test(
    'transfer service reserves exact bytes and rejects malformed replies',
    () async {
      await BandwidthStore.pace(65536, upload: false);
      expect(calls.single.arguments, {'bytes': 65536, 'upload': false});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => {'seconds': -1});
      await expectLater(BandwidthStore.pace(1, upload: true), throwsStateError);
    },
  );
}
