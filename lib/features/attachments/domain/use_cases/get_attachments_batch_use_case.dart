import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';

@LazySingleton()
class GetAttachmentsBatchUseCase
    implements UseCase<List<AttachmentEntity>, List<String>> {
  GetAttachmentsBatchUseCase({
    required AttachmentsRepository attachmentsRepository,
  }) : _attachmentsRepository = attachmentsRepository;

  final AttachmentsRepository _attachmentsRepository;

  @override
  FutureList<AttachmentEntity> call(List<String> request) =>
      _attachmentsRepository.getAttachmentsByWorkOrderIds(request);
}
