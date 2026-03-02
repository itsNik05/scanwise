import '../entities/compress_result.dart';
import '../entities/compression_level.dart';

abstract class CompressPdfRepository {
  /// Compresses the PDF at [inputPath] using the given [level].
  /// Returns a [CompressResult] with paths and size metadata.
  Future<CompressResult> compressPdf({
    required String inputPath,
    required CompressionLevel level,
  });
}