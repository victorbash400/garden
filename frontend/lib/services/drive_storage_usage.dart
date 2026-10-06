import '../model/drive_storage_usage.dart';
import 'sharing/drive_sharing_service.dart';

Future<List<DriveStorageUsage>> readDriveStorage(
  DriveSharingService service,
  Iterable<int> driveIds,
) async {
  final ids = driveIds.toSet().toList();
  final result = <DriveStorageUsage>[];
  for (var start = 0; start < ids.length; start += 4) {
    final batch = ids.skip(start).take(4);
    result.addAll(
      await Future.wait(
        batch.map((id) async {
          final value = await service.management(id);
          return DriveStorageUsage(
            id: id,
            name: value.drive.name,
            bytes: value.logicalBytes,
            files: value.fileCount,
          );
        }),
      ),
    );
  }
  return result;
}
