import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

@LazySingleton()
class GetVideoThumbnailUseCase implements UseCase<String, String> {
  const GetVideoThumbnailUseCase({required FileService fileService})
      : _fileService = fileService;

  final FileService _fileService;

  @override
  FutureString call(String videoPath) =>
      _fileService.getOrCreateVideoThumbnail(videoPath);
}
