import '../entities/folder_entity.dart';

abstract class FolderRepository {
  Future<List<FolderEntity>> getFolders();
  Future<void> createFolder(String name);
  Future<void> renameFolder(String oldPath, String newName);
  Future<void> deleteFolder(String folderPath);
}