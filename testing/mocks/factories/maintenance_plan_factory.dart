import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';

import 'factory_helpers.dart';

abstract final class MaintenancePlanFactory {
  static MaintenancePlanEntity makeMaintenancePlanEntity() {
    return MaintenancePlanEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      title: FactoryHelpers.makePhrase(),
      description: FactoryHelpers.makePhrase(),
      frequency: Frequency.monthly,
      priority: Priority.medium,
      isActive: true,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      assetId: FactoryHelpers.makeId(),
      checklistTemplateId: FactoryHelpers.makeId(),
      assignedToId: FactoryHelpers.makeId(),
      dayOfMonth: FactoryHelpers.makeInt(30),
      dayOfWeek: FactoryHelpers.makeInt(7),
      monthOfYear: FactoryHelpers.makeInt(12),
      deletedAt: null,
      lastGeneratedAt: FactoryHelpers.makeDateTime(),
      locationId: FactoryHelpers.makeId(),
      nextDueDate: FactoryHelpers.makeDateTime(),
    );
  }

  static List<MaintenancePlanEntity> makeMaintenancePlanEntityList() {
    return [
      makeMaintenancePlanEntity(),
      makeMaintenancePlanEntity(),
      makeMaintenancePlanEntity(),
    ];
  }

  // Attachment
  static AttachmentEntity makeAttachmentEntity() {
    return AttachmentEntity(
      id: FactoryHelpers.makeId(),
      workOrderId: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      uploadedById: FactoryHelpers.makeId(),
      fileName: '${FactoryHelpers.makeWord()}.jpg',
      fileType: FileType.image,
      localPath: FactoryHelpers.makePhrase(),
      remoteUrl: FactoryHelpers.makeUrl(),
      fileSizeBytes: FactoryHelpers.makeInt(1024),
      isCompressed: false,
      uploadStatus: UploadStatus.pending,
      createdAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
      originalPath: FactoryHelpers.makePhrase(),
      lastAccessedAt: null,
    );
  }

  static List<AttachmentEntity> makeAttachmentEntityList() {
    return [
      makeAttachmentEntity(),
      makeAttachmentEntity(),
      makeAttachmentEntity(),
    ];
  }
}
