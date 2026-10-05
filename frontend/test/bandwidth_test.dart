import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/bandwidth_settings.dart';
import 'package:garden_flutter/services/bandwidth_store.dart';
import 'package:garden_flutter/components/settings/settings_group.dart';

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
  testWidgets('missing native bridge has a contained restart instruction', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => throw MissingPluginException('native bridge missing'),
        );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BandwidthSettings())),
    );
    await tester.pumpAndSettle();
    final instruction = find.text(
      'Restart Garden to load the native controls.',
    );
    expect(instruction, findsOneWidget);
    expect(
      find.ancestor(of: instruction, matching: find.byType(SettingsGroup)),
      findsOneWidget,
    );
    expect(find.textContaining('MissingPluginException'), findsNothing);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets(
    'native failure details stay collapsed and retry recovers controls',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async => throw PlatformException(
              code: 'bandwidth_error',
              message: 'Background service unavailable.',
            ),
          );
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BandwidthSettings())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bandwidth unavailable'), findsOneWidget);
      expect(find.text('Background service unavailable.'), findsNothing);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text('Background service unavailable.'), findsOneWidget);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async => {'upload': 0, 'download': 0},
          );
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Unlimited'), findsNWidgets(2));
      expect(find.text('Bandwidth unavailable'), findsNothing);
    },
  );
}
