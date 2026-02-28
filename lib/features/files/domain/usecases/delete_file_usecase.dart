import '../repositories/file_repository.dart';

class DeleteFileUseCase {
  final FileRepository repository;

  DeleteFileUseCase(this.repository);

  Future<void> call(String path) {
    return repository.deleteFile(path);
  }
}