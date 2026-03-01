import '../repositories/folder_repository.dart';

class CreateFolderUseCase {
  final FolderRepository repository;

  CreateFolderUseCase(this.repository);

  Future<void> call(String name) {
    return repository.createFolder(name);
  }
}