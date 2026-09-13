import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';

class GetAttachmentsBatchParams {
  const GetAttachmentsBatchParams({
    required this.workOrderIds,
    this.since,
  });

  final List<String> workOrderIds;
  final DateTime? since;
}

@LazySingleton()
class GetAttachmentsBatchUseCase
    implements UseCase<List<AttachmentEntity>, GetAttachmentsBatchParams> {
  GetAttachmentsBatchUseCase({
    required AttachmentsRepository attachmentsRepository,
  }) : _attachmentsRepository = attachmentsRepository;

  final AttachmentsRepository _attachmentsRepository;

  @override
  FutureList<AttachmentEntity> call(GetAttachmentsBatchParams params) =>
      _attachmentsRepository.getAttachmentsByWorkOrderIds(
        params.workOrderIds,
        since: params.since,
      );
}
