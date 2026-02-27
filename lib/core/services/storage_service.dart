/// ------------------------------------------------------------
/// StorageService
/// ------------------------------------------------------------
/// Responsible for:
/// - Creating ScanWise storage folder
/// - Providing path for scanned PDFs
/// - Handling file saving logic
/// ------------------------------------------------------------

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<Directory> getScanDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final scanDir = Directory('${baseDir.path}/Scanned_Pdfs');

    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    return scanDir;
  }

  Future<String> createEmptyPdf(String fileName) async {
    final directory = await getScanDirectory();
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes([]); // empty file for now

    return file.path;
  }
}