import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';

class PickAttachmentParams extends Equatable {
  const PickAttachmentParams({
    required this.source,
    required this.workOrderId,
    required this.companyId,
    required this.uploadedById,
  });

  final AttachmentSource source;
  final String workOrderId;
  final String companyId;
  final String uploadedById;

  @override
  List<Object?> get props => [source, workOrderId, companyId, uploadedById];
}

@LazySingleton()
class PickAttachmentUseCase implements UseCase<List<AttachmentEntity>, PickAttachmentParams> {
  PickAttachmentUseCase({required AttachmentsRepository attachmentsRepository})
      : _attachmentsRepository = attachmentsRepository;

  final AttachmentsRepository _attachmentsRepository;

  @override
  FutureList<AttachmentEntity> call(PickAttachmentParams request) =>
      _attachmentsRepository.pickAndPrepareAttachment(
        source: request.source,
        workOrderId: request.workOrderId,
        companyId: request.companyId,
        uploadedById: request.uploadedById,
      );
}
