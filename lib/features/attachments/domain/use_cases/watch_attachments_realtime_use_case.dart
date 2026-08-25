import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';

@LazySingleton()
class WatchAttachmentsRealtimeUseCase {
  const WatchAttachmentsRealtimeUseCase({
    required AttachmentsRepository attachmentsRepository,
  }) : _attachmentsRepository = attachmentsRepository;

  final AttachmentsRepository _attachmentsRepository;

  Stream<RealtimeEvent<AttachmentEntity>> call({
    required String workOrderId,
  }) => _attachmentsRepository.watchAttachmentsRealtime(
    workOrderId: workOrderId,
  );
}
