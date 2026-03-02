enum CompressionLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case CompressionLevel.low:
        return 'Low';
      case CompressionLevel.medium:
        return 'Medium';
      case CompressionLevel.high:
        return 'High';
    }
  }

  String get description {
    switch (this) {
      case CompressionLevel.low:
        return 'Best quality, mild size reduction (~20-30%)';
      case CompressionLevel.medium:
        return 'Balanced quality & size reduction (~40-55%)';
      case CompressionLevel.high:
        return 'Maximum compression, smaller file (~60-75%)';
    }
  }

  /// JPEG quality for image compression (0–100)
  int get imageQuality {
    switch (this) {
      case CompressionLevel.low:
        return 82;
      case CompressionLevel.medium:
        return 58;
      case CompressionLevel.high:
        return 45;
    }
  }

  /// Render scale relative to original page dimensions
  double get renderScale {
    switch (this) {
      case CompressionLevel.low:
        return 1.5;
      case CompressionLevel.medium:
        return 1.2;
      case CompressionLevel.high:
        return 0.90;
    }
  }
}