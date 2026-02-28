import '../entities/file_entity.dart';
import '../repositories/file_repository.dart';

class GetScannedFilesUseCase {
  final FileRepository repository;

  GetScannedFilesUseCase(this.repository);

  Future<List<FileEntity>> call() {
    return repository.getScannedFiles();
  }
}