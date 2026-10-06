class DriveStorageUsage {
  const DriveStorageUsage({
    required this.id,
    required this.name,
    required this.bytes,
    required this.files,
  });
  final int id;
  final String name;
  final int bytes;
  final int files;
}
