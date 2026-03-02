import '../../domain/entities/compression_level.dart';

abstract class CompressPdfDatasource {
  /// Returns the path of the newly saved compressed PDF.
  Future<String> compressAndSave({
    required String inputPath,
    required CompressionLevel level,
    required void Function(int current, int total) onProgress,
  });
}