import 'package:garden_client/garden_client.dart';

abstract interface class DirectFilesGateway {
  Future<FileVersion> beginMultipart(int nodeId, int baseVersion, int size);
  Future<List<String>> uploadParts(int versionId, int first, int count);
  Future<List<UploadedPart>> uploadedParts(int versionId);
  Future<ContentDownload> downloadTicket(int nodeId, int versionId);
}
