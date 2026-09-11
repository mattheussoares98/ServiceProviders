import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';

class DeleteAttachmentParams {
  const DeleteAttachmentParams({
    required this.attachmentId,
    this.workOrderId,
    this.remoteUrl,
    this.localPath,
  });

  factory DeleteAttachmentParams.fromEntity({
    required AttachmentEntity attachment,
    String? workOrderId,
  }) {
    final effectiveWorkOrderId = workOrderId == null
        ? (attachment.workOrderId.isNotEmpty ? attachment.workOrderId : null)
        : (workOrderId.isNotEmpty ? workOrderId : null);
    return DeleteAttachmentParams(
      attachmentId: attachment.id,
      workOrderId: effectiveWorkOrderId,
      remoteUrl: attachment.remoteUrl,
      localPath: attachment.localPath,
    );
  }

  final String attachmentId;
  final String? workOrderId;
  final String? remoteUrl;
  final String? localPath;
}

@LazySingleton()
class DeleteAttachmentUseCase implements UseCase<bool, DeleteAttachmentParams> {
  DeleteAttachmentUseCase({
    required AttachmentsRepository attachmentsRepository,
    required ChecklistsRepository checklistsRepository,
  })  : _attachmentsRepository = attachmentsRepository,
        _checklistsRepository = checklistsRepository;

  final AttachmentsRepository _attachmentsRepository;
  final ChecklistsRepository _checklistsRepository;

  @override
  FutureBool call(DeleteAttachmentParams request) async {
    final deleteResult = await _attachmentsRepository.deleteAttachment(
      request.attachmentId,
    );

    if (deleteResult is! SuccessState<bool> || deleteResult.data != true) {
      return deleteResult;
    }

    final workOrderId = request.workOrderId;
    if (workOrderId != null && workOrderId.isNotEmpty) {
      final answersResult = await _checklistsRepository.getResponsesByWorkOrder(
        workOrderId,
      );

      if (answersResult is SuccessState && answersResult.data != null) {
        final answers = answersResult.data!;

        for (final answer in answers) {
          final photoUrl = answer.photoUrl;
          if (photoUrl != null &&
              photoUrl.isNotEmpty &&
              ((request.remoteUrl != null && photoUrl == request.remoteUrl) ||
                  (request.localPath != null &&
                      photoUrl == request.localPath))) {
            final updatedAnswer = answer.copyWith(
              annulPhotoUrl: true,
              updatedAt: DateTime.now(),
            );
            await _checklistsRepository.saveResponse(updatedAnswer);
          }
        }
      }
    }

    return const SuccessState(data: true);
  }
}
