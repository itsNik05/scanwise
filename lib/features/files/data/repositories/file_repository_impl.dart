import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_repository.dart';
import '../models/file_entity_model.dart';

class FileRepositoryImpl implements FileRepository {

  @override
  Future<List<FileEntity>> getScannedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final scannedDir = Directory('${directory.path}/Scanned_Pdfs');

    if (!await scannedDir.exists()) {
      return [];
    }

    final files = scannedDir.listSync().whereType<File>().toList();

    return files.map((file) {
      final stat = file.statSync();

      return FileEntityModel.fromFile(
        file.uri.pathSegments.last,
        file.path,
        stat.size,
        stat.changed,
      );
    }).toList();
  }

  @override
  Future<void> deleteFile(String path) async {
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }
}