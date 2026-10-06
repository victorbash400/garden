import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/settings/drive_storage_usage.dart';
import 'package:garden_flutter/services/drive_storage_usage.dart';
import 'package:garden_flutter/services/sharing/drive_sharing_service.dart';
import 'package:garden_flutter/services/files/file_type.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

class UsageService extends DriveSharingService {
  UsageService() : super(Client('http://localhost:8080/'));
  final calls = <int>[];
  bool fail = false;
  @override
  Future<DriveManagement> management(int drive) async {
    calls.add(drive);
    if (fail) throw StateError('Access denied');
    return DriveManagement(
      drive: GardenSummary(
        id: drive,
        name: 'Drive $drive',
        role: 'Owner',
        members: 1,
      ),
      logicalBytes: drive * 1024,
      fileCount: drive,
      folderCount: 0,
      members: [],
      invitations: [],
    );
  }
}

void main() {
  test('file types support uppercase names and compound filenames', () {
    expect(fileType('portrait.HEIC'), FileType.image);
    expect(fileType('sample.live.WAV'), FileType.audio);
    expect(fileType('movie.WEBM'), FileType.video);
    expect(fileType('notes.md'), FileType.document);
    expect(fileType('data.json'), FileType.code);
    expect(fileType('backup.tar.gz'), FileType.archive);
    expect(fileType('extensionless'), FileType.other);
  });
  test(
    'drive usage deduplicates drives and does not hide failed requests',
    () async {
      final service = UsageService();
      final usage = await readDriveStorage(service, [1, 2, 1]);
      expect(usage.fold<int>(0, (sum, drive) => sum + drive.bytes), 3072);
      expect(service.calls, [1, 2]);
      service.fail = true;
      await expectLater(readDriveStorage(service, [1]), throwsStateError);
      service.client.close();
    },
  );
  testWidgets('usage loads once and refreshes explicitly', (tester) async {
    final service = UsageService();
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: DriveStorageUsageControls(
            service: service,
            driveIds: const [1, 2],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3.0 KiB'), findsOneWidget);
    expect(find.text('1.0 KiB · 1 file'), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    expect(service.calls, [1, 2]);
    await tester.tap(find.byTooltip('Refresh storage usage'));
    await tester.pumpAndSettle();
    expect(service.calls, [1, 2, 1, 2]);
    service.client.close();
  });
}
