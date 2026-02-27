import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/files/data/repositories/file_repository_impl.dart';
import '../../features/files/domain/repositories/file_repository.dart';
import '../../features/files/domain/usecases/get_scanned_files_usecase.dart';
import '../../features/files/domain/usecases/delete_file_usecase.dart';

final fileRepositoryProvider = Provider<FileRepository>(
      (ref) => FileRepositoryImpl(),
);

final getScannedFilesUseCaseProvider = Provider<GetScannedFilesUseCase>(
      (ref) => GetScannedFilesUseCase(ref.read(fileRepositoryProvider)),
);

final deleteFileUseCaseProvider = Provider<DeleteFileUseCase>(
      (ref) => DeleteFileUseCase(ref.read(fileRepositoryProvider)),
);