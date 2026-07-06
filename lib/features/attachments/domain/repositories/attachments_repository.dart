import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';

abstract interface class AttachmentsRepository {
  FutureList<AttachmentEntity> getAttachmentsByWorkOrder(String workOrderId);
  FutureBool createAttachment(AttachmentEntity attachment);
  FutureBool deleteAttachment(String id);
}
