import '../repositories/file_repository.dart';

class MoveFileUseCase {
  final FileRepository repository;

  MoveFileUseCase(this.repository);

  Future<void> call(String sourcePath, String destinationFolderPath) {
    return repository.moveFile(sourcePath, destinationFolderPath);
  }
}