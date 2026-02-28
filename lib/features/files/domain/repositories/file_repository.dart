import '../entities/file_entity.dart';

abstract class FileRepository {
  Future<List<FileEntity>> getScannedFiles(String? folderPath);
  Future<void> deleteFile(String path);
  Future<void> moveFile(String sourcePath, String destinationFolderPath);
}