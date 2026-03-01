import '../repositories/folder_repository.dart';

class DeleteFolderUseCase {
  final FolderRepository repository;

  DeleteFolderUseCase(this.repository);

  Future<void> call(String folderPath) {
    return repository.deleteFolder(folderPath);
  }
}