import '../entities/folder_entity.dart';
import '../repositories/folder_repository.dart';

class GetFoldersUseCase {
  final FolderRepository repository;

  GetFoldersUseCase(this.repository);

  Future<List<FolderEntity>> call() {
    return repository.getFolders();
  }
}