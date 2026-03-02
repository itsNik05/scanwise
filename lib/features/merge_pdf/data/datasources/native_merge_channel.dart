import 'package:flutter/services.dart';

class NativeMergeChannel {
  static const MethodChannel _channel =
  MethodChannel('scanwise.native.merge');

  Future<String> merge({
    required List<String> inputPaths,
    required String outputPath,
  }) async {
    final result = await _channel.invokeMethod<String>(
      'mergePdfs',
      {
        'inputPaths': inputPaths,
        'outputPath': outputPath,
      },
    );

    if (result == null) {
      throw Exception("Native merge failed");
    }

    return result;
  }
}