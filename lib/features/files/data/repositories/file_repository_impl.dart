import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_repository.dart';
import '../models/file_entity_model.dart';

class FileRepositoryImpl implements FileRepository {

  @override
  Future<List<FileEntity>> getScannedFiles(String? folderPath) async {
    final directory = folderPath != null
        ? Directory(folderPath)
        : Directory(
      '${(await getApplicationDocumentsDirectory()).path}/Scanned_Pdfs',
    );

    if (!await directory.exists()) {
      return [];
    }

    final files =
    directory.listSync().whereType<File>().toList();

    return files.map((file) {
      final stat = file.statSync();

      return FileEntityModel.fromFile(
        file.path.split(Platform.pathSeparator).last,
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

  @override
  Future<void> moveFile(
      String sourcePath,
      String destinationFolderPath,
      ) async {
    final file = File(sourcePath);

    if (!await file.exists()) return;

    final fileName =
        sourcePath.split(Platform.pathSeparator).last;

    final newPath =
        '$destinationFolderPath${Platform.pathSeparator}$fileName';

    await file.rename(newPath);
  }
}