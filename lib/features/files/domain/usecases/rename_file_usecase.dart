import '../repositories/file_repository.dart';

class RenameFileUseCase {
  final FileRepository repository;

  RenameFileUseCase(this.repository);

  Future<void> call(String oldPath, String newName) {
    return repository.renameFile(oldPath, newName);
  }
}