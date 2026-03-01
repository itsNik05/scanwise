abstract class ImageProcessingDatasource {
  Future<String> crop({
    required String imagePath,
    required List<double> cropPoints,
  });

  Future<String> applyFilter({
    required String imagePath,
    required String filterType,
  });
}