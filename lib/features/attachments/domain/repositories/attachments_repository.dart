import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/attachments/domain/entities/attachment_entity.dart';

abstract interface class AttachmentsRepository {
  FutureList<AttachmentEntity> getAttachmentsByWorkOrder(String workOrderId);
  FutureBool createAttachment(AttachmentEntity attachment);
  FutureBool deleteAttachment(String id);
}