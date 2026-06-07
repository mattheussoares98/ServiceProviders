import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/task_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_type.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_type.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:clean_architecture/features/attachments/domain/entities/attachment_entity.dart';
import 'package:clean_architecture/features/attachments/domain/entities/file_type.dart';
import 'package:clean_architecture/features/attachments/domain/entities/upload_status.dart';
import 'package:faker/faker.dart';

abstract final class EntityFactory {
  // Category
  static CategoryEntity makeCategoryEntity({
    String? id,
    String? companyId,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return CategoryEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.company.name(),
      description: description ?? faker.lorem.sentence(),
      color: color ?? faker.randomGenerator.string(7),
      createdAt: createdAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<CategoryEntity> makeCategoryEntityList() {
    return [
      makeCategoryEntity(),
      makeCategoryEntity(),
      makeCategoryEntity(),
    ];
  }

  // Location
  static LocationEntity makeLocationEntity({
    String? id,
    String? companyId,
    String? name,
    String? address,
    String? city,
    String? state,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return LocationEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.company.name(),
      address: address ?? faker.address.streetAddress(),
      city: city ?? faker.address.city(),
      state: state ?? faker.address.state(),
      isActive: isActive ?? faker.randomGenerator.boolean(),
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<LocationEntity> makeLocationEntityList() {
    return [
      makeLocationEntity(),
      makeLocationEntity(),
      makeLocationEntity(),
    ];
  }

  // Area
  static AreaEntity makeAreaEntity({
    String? id,
    String? locationId,
    String? companyId,
    String? name,
    String? floor,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AreaEntity(
      id: id ?? faker.guid.guid(),
      locationId: locationId ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.company.name(),
      floor: floor ?? faker.randomGenerator.integer(10).toString(),
      description: description ?? faker.lorem.sentence(),
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<AreaEntity> makeAreaEntityList() {
    return [
      makeAreaEntity(),
      makeAreaEntity(),
      makeAreaEntity(),
    ];
  }

  // Asset
  static AssetEntity makeAssetEntity({
    String? id,
    String? companyId,
    String? areaId,
    String? categoryId,
    String? parentAssetId,
    String? name,
    String? code,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? installDate,
    DateTime? warrantyExpiration,
    DateTime? revisionForecast,
    AssetStatus? status,
    AssetCriticality? criticality,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AssetEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      areaId: areaId ?? faker.guid.guid(),
      categoryId: categoryId,
      parentAssetId: parentAssetId,
      name: name ?? faker.company.name(),
      code: code ?? faker.randomGenerator.string(8),
      manufacturer: manufacturer ?? faker.company.name(),
      model: model ?? faker.vehicle.model(),
      serialNumber: serialNumber ?? faker.randomGenerator.string(12),
      installDate: installDate ?? faker.date.dateTime(),
      warrantyExpiration: warrantyExpiration ?? faker.date.dateTime(),
      revisionForecast: revisionForecast ?? faker.date.dateTime(),
      status: status ?? AssetStatus.active,
      criticality: criticality ?? AssetCriticality.medium,
      notes: notes ?? faker.lorem.sentence(),
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<AssetEntity> makeAssetEntityList() {
    return [
      makeAssetEntity(),
      makeAssetEntity(),
      makeAssetEntity(),
    ];
  }

  // WorkOrder
  static WorkOrderEntity makeWorkOrderEntity({
    String? id,
    String? companyId,
    String? assetId,
    String? locationId,
    String? assignedToId,
    String? createdById,
    String? maintenancePlanId,
    String? title,
    String? description,
    Priority? priority,
    WorkOrderStatus? status,
    WorkOrderType? type,
    DateTime? scheduledDate,
    DateTime? startedAt,
    DateTime? completedAt,
    int? estimatedDuration,
    int? actualDuration,
    double? laborCost,
    double? partsCost,
    double? totalCost,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return WorkOrderEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      assetId: assetId ?? faker.guid.guid(),
      locationId: locationId ?? faker.guid.guid(),
      assignedToId: assignedToId ?? faker.guid.guid(),
      createdById: createdById ?? faker.guid.guid(),
      maintenancePlanId: maintenancePlanId ?? faker.guid.guid(),
      title: title ?? faker.company.name(),
      description: description ?? faker.lorem.sentence(),
      priority: priority ?? Priority.medium,
      status: status ?? WorkOrderStatus.open,
      type: type ?? WorkOrderType.corrective,
      scheduledDate: scheduledDate ?? faker.date.dateTime(),
      startedAt: startedAt,
      completedAt: completedAt,
      estimatedDuration: estimatedDuration ?? faker.randomGenerator.integer(120),
      actualDuration: actualDuration,
      laborCost: laborCost ?? faker.randomGenerator.decimal(),
      partsCost: partsCost ?? faker.randomGenerator.decimal(),
      totalCost: totalCost ?? faker.randomGenerator.decimal(),
      notes: notes ?? faker.lorem.sentence(),
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<WorkOrderEntity> makeWorkOrderEntityList() {
    return [
      makeWorkOrderEntity(),
      makeWorkOrderEntity(),
      makeWorkOrderEntity(),
    ];
  }

  // Task
  static TaskEntity makeTaskEntity({
    String? id,
    String? workOrderId,
    String? companyId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    String? completedById,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaskEntity(
      id: id ?? faker.guid.guid(),
      workOrderId: workOrderId ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      title: title ?? faker.lorem.word(),
      description: description ?? faker.lorem.sentence(),
      isCompleted: isCompleted ?? false,
      completedAt: completedAt,
      completedById: completedById,
      sortOrder: sortOrder ?? faker.randomGenerator.integer(10),
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<TaskEntity> makeTaskEntityList() {
    return [
      makeTaskEntity(),
      makeTaskEntity(),
      makeTaskEntity(),
    ];
  }

  // WorkOrderChangeRequest
  static WorkOrderChangeRequestEntity makeWorkOrderChangeRequestEntity({
    String? id,
    String? workOrderId,
    String? companyId,
    String? requestedById,
    WorkOrderChangeType? changeType,
    String? changeData,
    ChangeRequestStatus? status,
    String? reviewedById,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return WorkOrderChangeRequestEntity(
      id: id ?? faker.guid.guid(),
      workOrderId: workOrderId ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      requestedById: requestedById ?? faker.guid.guid(),
      changeType: changeType ?? WorkOrderChangeType.updateNotes,
      changeData: changeData ?? '{"notes": "Updated notes"}',
      status: status ?? ChangeRequestStatus.pending,
      reviewedById: reviewedById,
      rejectionReason: rejectionReason,
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<WorkOrderChangeRequestEntity> makeWorkOrderChangeRequestEntityList() {
    return [
      makeWorkOrderChangeRequestEntity(),
      makeWorkOrderChangeRequestEntity(),
      makeWorkOrderChangeRequestEntity(),
    ];
  }

  // WorkOrderHistory
  static WorkOrderHistoryEntity makeWorkOrderHistoryEntity({
    String? id,
    String? workOrderId,
    String? companyId,
    String? userId,
    String? action,
    String? oldValue,
    String? newValue,
    DateTime? createdAt,
  }) {
    return WorkOrderHistoryEntity(
      id: id ?? faker.guid.guid(),
      workOrderId: workOrderId ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      userId: userId ?? faker.guid.guid(),
      action: action ?? 'status_change',
      oldValue: oldValue ?? 'open',
      newValue: newValue ?? 'in_progress',
      createdAt: createdAt ?? faker.date.dateTime(),
    );
  }

  static List<WorkOrderHistoryEntity> makeWorkOrderHistoryEntityList() {
    return [
      makeWorkOrderHistoryEntity(),
      makeWorkOrderHistoryEntity(),
      makeWorkOrderHistoryEntity(),
    ];
  }

  // ChecklistTemplate
  static ChecklistTemplateEntity makeChecklistTemplateEntity({
    String? id,
    String? companyId,
    String? name,
    String? description,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ChecklistTemplateEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.company.name(),
      description: description ?? faker.lorem.sentence(),
      categoryId: categoryId,
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<ChecklistTemplateEntity> makeChecklistTemplateEntityList() {
    return [
      makeChecklistTemplateEntity(),
      makeChecklistTemplateEntity(),
      makeChecklistTemplateEntity(),
    ];
  }

  // ChecklistItem
  static ChecklistItemEntity makeChecklistItemEntity({
    String? id,
    String? templateId,
    String? companyId,
    String? label,
    ChecklistItemType? type,
    bool? isRequired,
    List<String>? options,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return ChecklistItemEntity(
      id: id ?? faker.guid.guid(),
      templateId: templateId ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      label: label ?? faker.lorem.word(),
      type: type ?? ChecklistItemType.boolean,
      isRequired: isRequired ?? false,
      options: options ?? (type == ChecklistItemType.selection ? ['Sim', 'Não'] : null),
      sortOrder: sortOrder ?? faker.randomGenerator.integer(10),
      createdAt: createdAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<ChecklistItemEntity> makeChecklistItemEntityList() {
    return [
      makeChecklistItemEntity(),
      makeChecklistItemEntity(),
      makeChecklistItemEntity(),
    ];
  }

  // UserProfile
  static UserProfileEntity makeUserProfileEntity({
    String? id,
    String? companyId,
    String? name,
    String? email,
    String? phone,
    String? permissionGroupId,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserProfileEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.person.name(),
      email: email ?? faker.internet.email(),
      phone: phone ?? faker.phoneNumber.random(),
      permissionGroupId: permissionGroupId,
      avatarUrl: avatarUrl ?? faker.internet.httpsUrl(),
      isActive: isActive ?? true,
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<UserProfileEntity> makeUserProfileEntityList() {
    return [
      makeUserProfileEntity(),
      makeUserProfileEntity(),
      makeUserProfileEntity(),
    ];
  }

  // PermissionGroup
  static PermissionGroupEntity makePermissionGroupEntity({
    String? id,
    String? companyId,
    String? name,
    List<Permission>? permissions,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return PermissionGroupEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.lorem.word(),
      permissions: permissions ?? [
        Permission.workOrdersViewAssigned,
        Permission.workOrdersUpdateStatus,
        Permission.attachmentsAll,
      ],
      isDefault: isDefault ?? false,
      createdAt: createdAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<PermissionGroupEntity> makePermissionGroupEntityList() {
    return [
      makePermissionGroupEntity(),
      makePermissionGroupEntity(),
      makePermissionGroupEntity(),
    ];
  }

  // MaintenancePlan
  static MaintenancePlanEntity makeMaintenancePlanEntity({
    String? id,
    String? companyId,
    String? assetId,
    String? locationId,
    String? title,
    String? description,
    Frequency? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    int? monthOfYear,
    String? checklistTemplateId,
    String? assignedToId,
    Priority? priority,
    bool? isActive,
    DateTime? lastGeneratedAt,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return MaintenancePlanEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      assetId: assetId,
      locationId: locationId,
      title: title ?? faker.lorem.sentence(),
      description: description ?? faker.lorem.paragraph(),
      frequency: frequency ?? Frequency.monthly,
      dayOfWeek: dayOfWeek,
      dayOfMonth: dayOfMonth,
      monthOfYear: monthOfYear,
      checklistTemplateId: checklistTemplateId,
      assignedToId: assignedToId,
      priority: priority ?? Priority.medium,
      isActive: isActive ?? true,
      lastGeneratedAt: lastGeneratedAt,
      nextDueDate: nextDueDate,
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
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
  static AttachmentEntity makeAttachmentEntity({
    String? id,
    String? workOrderId,
    String? companyId,
    String? uploadedById,
    String? fileName,
    FileType? fileType,
    String? localPath,
    String? remoteUrl,
    int? fileSizeBytes,
    bool? isCompressed,
    UploadStatus? uploadStatus,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return AttachmentEntity(
      id: id ?? faker.guid.guid(),
      workOrderId: workOrderId ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      uploadedById: uploadedById ?? faker.guid.guid(),
      fileName: fileName ?? faker.file.fileName(),
      fileType: fileType ?? FileType.image,
      localPath: localPath,
      remoteUrl: remoteUrl,
      fileSizeBytes: fileSizeBytes ?? faker.randomGenerator.integer(1000000),
      isCompressed: isCompressed ?? false,
      uploadStatus: uploadStatus ?? UploadStatus.pending,
      createdAt: createdAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
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
