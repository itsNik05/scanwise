import '../entities/file_entity.dart';

abstract class FileRepository {
  Future<List<FileEntity>> getScannedFiles();
  Future<void> deleteFile(String path);
}