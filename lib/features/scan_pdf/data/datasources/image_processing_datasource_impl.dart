import 'image_processing_datasource.dart';

class ImageProcessingDatasourceImpl
    implements ImageProcessingDatasource {

  @override
  Future<String> crop({
    required String imagePath,
    required List<double> cropPoints,
  }) async {
    return imagePath;
  }

  @override
  Future<String> applyFilter({
    required String imagePath,
    required String filterType,
  }) async {
    return imagePath;
  }
}