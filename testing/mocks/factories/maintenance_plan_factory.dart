import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';

import 'factory_helpers.dart';

abstract final class MaintenancePlanFactory {
  static MaintenancePlanEntity makeMaintenancePlanEntity() {
    return MaintenancePlanEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      locationId: FactoryHelpers.makeId(),
      assetId: FactoryHelpers.makeId(),
      areaId: FactoryHelpers.makeId(),
      assignedToId: FactoryHelpers.makeId(),
      serviceProviderCompanyId: FactoryHelpers.makeId(),
      checklistTemplateId: FactoryHelpers.makeId(),
      title:
          'Plano ${FactoryHelpers.makeWord()} ${FactoryHelpers.makeInt(9999)}',
      description: FactoryHelpers.makePhrase(),
      priority: Priority.medium,
      price: 150,
      currency: 'BRL',
      intervalValue: 1,
      intervalUnit: IntervalUnit.months,
      leadTimeDays: 2,
      durationHours: 8,
      dayOfWeek: 1,
      dayOfMonth: 15,
      monthOfYear: 6,
      isActive: true,
      lastGeneratedAt: FactoryHelpers.makeDateTime(),
      lastGeneratedWorkOrderId: FactoryHelpers.makeId(),
      lastError: null,
      nextDueDate: FactoryHelpers.makeDateTime(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
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
