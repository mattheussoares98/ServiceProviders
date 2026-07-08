import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';

@LazySingleton()
class OpenAttachmentUseCase implements UseCase<void, AttachmentEntity> {
  OpenAttachmentUseCase({required FileService fileService})
      : _fileService = fileService;

  final FileService _fileService;

  @override
  FutureVoid call(AttachmentEntity request) async {
    final path = request.localPath ?? request.remoteUrl;
    if (path == null || path.isEmpty) {
      return FailureState(
        message: 'Nenhum caminho ou link disponível para abrir.'.hardcoded,
      );
    }
    return _fileService.openFile(path);
  }
}
