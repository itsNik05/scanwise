import '../repositories/folder_repository.dart';

class RenameFolderUseCase {
  final FolderRepository repository;

  RenameFolderUseCase(this.repository);

  Future<void> call(String oldPath, String newName) {
    return repository.renameFolder(oldPath, newName);
  }
}