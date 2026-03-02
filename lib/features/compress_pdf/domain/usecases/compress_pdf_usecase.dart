import '../entities/compress_result.dart';
import '../entities/compression_level.dart';
import '../repositories/compress_pdf_repository.dart';

class CompressPdfUsecase {
  final CompressPdfRepository _repository;

  const CompressPdfUsecase(this._repository);

  Future<CompressResult> call({
    required String inputPath,
    required CompressionLevel level,
  }) {
    return _repository.compressPdf(
      inputPath: inputPath,
      level: level,
    );
  }
}