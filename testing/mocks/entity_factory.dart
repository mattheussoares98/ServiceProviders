import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/features/attachments/domain/entities/attachment_entity.dart';
import 'package:clean_architecture/features/attachments/domain/entities/file_type.dart';
import 'package:clean_architecture/features/attachments/domain/entities/upload_status.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/task_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_type.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_type.dart';
import 'package:faker/faker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class EntityFactory {
  static DateTime _makeDateTime() {
    final dt = faker.date.dateTime();
    return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
  }

  // Category
  static CategoryEntity makeCategoryEntity() {
    return CategoryEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      name: faker.company.name(),
      description: faker.lorem.sentence(),
      color: faker.randomGenerator.string(7),
      createdAt: _makeDateTime(),
    );
  }

  static List<CategoryEntity> makeCategoryEntityList() {
    return [makeCategoryEntity(), makeCategoryEntity(), makeCategoryEntity()];
  }

  // Location
  static LocationEntity makeLocationEntity() {
    return LocationEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      name: faker.company.name(),
      address: faker.address.streetAddress(),
      city: faker.address.city(),
      state: faker.address.state(),
      isActive: faker.randomGenerator.boolean(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static List<LocationEntity> makeLocationEntityList() {
    return [makeLocationEntity(), makeLocationEntity(), makeLocationEntity()];
  }

  // Area
  static AreaEntity makeAreaEntity() {
    return AreaEntity(
      id: faker.guid.guid(),
      locationId: faker.guid.guid(),
      companyId: faker.guid.guid(),
      name: faker.company.name(),
      floor: faker.randomGenerator.integer(10).toString(),
      description: faker.lorem.sentence(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static List<AreaEntity> makeAreaEntityList() {
    return [makeAreaEntity(), makeAreaEntity(), makeAreaEntity()];
  }

  // Asset
  static AssetEntity makeAssetEntity() {
    return AssetEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      areaId: faker.guid.guid(),
      name: faker.company.name(),
      code: faker.randomGenerator.string(8),
      manufacturer: faker.company.name(),
      model: faker.vehicle.model(),
      serialNumber: faker.randomGenerator.string(12),
      status: AssetStatus.active,
      criticality: AssetCriticality.medium,
      notes: faker.lorem.sentence(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static List<AssetEntity> makeAssetEntityList() {
    return [makeAssetEntity(), makeAssetEntity(), makeAssetEntity()];
  }

  // WorkOrder
  static WorkOrderEntity makeWorkOrderEntity() {
    return WorkOrderEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      assetId: faker.guid.guid(),
      locationId: faker.guid.guid(),
      assignedToId: faker.guid.guid(),
      createdById: faker.guid.guid(),
      maintenancePlanId: faker.guid.guid(),
      title: faker.company.name(),
      description: faker.lorem.sentence(),
      priority: Priority.medium,
      status: WorkOrderStatus.open,
      type: WorkOrderType.corrective,
      scheduledDate: _makeDateTime(),
      estimatedDuration: faker.randomGenerator.integer(120),
      laborCost: faker.randomGenerator.decimal(),
      partsCost: faker.randomGenerator.decimal(),
      totalCost: faker.randomGenerator.decimal(),
      notes: faker.lorem.sentence(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
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
  static TaskEntity makeTaskEntity() {
    return TaskEntity(
      id: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      companyId: faker.guid.guid(),
      title: faker.lorem.word(),
      description: faker.lorem.sentence(),
      isCompleted: false,
      sortOrder: faker.randomGenerator.integer(10),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static List<TaskEntity> makeTaskEntityList() {
    return [makeTaskEntity(), makeTaskEntity(), makeTaskEntity()];
  }

  // WorkOrderChangeRequest
  static WorkOrderChangeRequestEntity makeWorkOrderChangeRequestEntity() {
    return WorkOrderChangeRequestEntity(
      id: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      companyId: faker.guid.guid(),
      requestedById: faker.guid.guid(),
      changeType: WorkOrderChangeType.updateNotes,
      changeData: '{"notes": "Updated notes"}',
      status: ChangeRequestStatus.pending,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static List<WorkOrderChangeRequestEntity>
  makeWorkOrderChangeRequestEntityList() {
    return [
      makeWorkOrderChangeRequestEntity(),
      makeWorkOrderChangeRequestEntity(),
      makeWorkOrderChangeRequestEntity(),
    ];
  }

  // WorkOrderHistory
  static WorkOrderHistoryEntity makeWorkOrderHistoryEntity() {
    return WorkOrderHistoryEntity(
      id: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      companyId: faker.guid.guid(),
      userId: faker.guid.guid(),
      action: 'status_change',
      oldValue: 'open',
      newValue: 'in_progress',
      createdAt: _makeDateTime(),
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
  static ChecklistTemplateEntity makeChecklistTemplateEntity() {
    return ChecklistTemplateEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      name: faker.company.name(),
      description: faker.lorem.sentence(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
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
  static ChecklistItemEntity makeChecklistItemEntity() {
    return ChecklistItemEntity(
      id: faker.guid.guid(),
      templateId: faker.guid.guid(),
      companyId: faker.guid.guid(),
      label: faker.lorem.word(),
      type: ChecklistItemType.boolean,
      isRequired: false,
      sortOrder: faker.randomGenerator.integer(10),
      createdAt: _makeDateTime(),
    );
  }

  static List<ChecklistItemEntity> makeChecklistItemEntityList() {
    return [
      makeChecklistItemEntity(),
      makeChecklistItemEntity(),
      makeChecklistItemEntity(),
    ];
  }

  // Company
  static CompanyEntity makeCompanyEntity() {
    return CompanyEntity(
      id: faker.guid.guid(),
      name: faker.company.name(),
      cnpj: '12345678000199',
      logoUrl: faker.internet.httpsUrl(),
      isActive: true,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  // UserProfile
  static UserProfileEntity makeUserProfileEntity() {
    return UserProfileEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      name: faker.person.name(),
      email: faker.internet.email(),
      phone: faker.randomGenerator.integer(99999999, min: 10000000).toString(),
      isActive: true,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
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
  static PermissionGroupEntity makePermissionGroupEntity() {
    return PermissionGroupEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      name: faker.lorem.word(),
      permissions: const [
        ResourcePermissionEntity(
          resource: ResourceType.workOrders,
          actions: {PermissionAction.create, PermissionAction.update},
        ),
        ResourcePermissionEntity(
          resource: ResourceType.attachments,
          actions: {
            PermissionAction.create,
            PermissionAction.read,
            PermissionAction.update,
            PermissionAction.delete,
          },
        ),
      ],
      isDefault: false,
      createdAt: _makeDateTime(),
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
  static MaintenancePlanEntity makeMaintenancePlanEntity() {
    return MaintenancePlanEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      title: faker.lorem.sentence(),
      description: faker.lorem.sentence(),
      frequency: Frequency.monthly,
      priority: Priority.medium,
      isActive: true,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
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
      id: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      companyId: faker.guid.guid(),
      uploadedById: faker.guid.guid(),
      fileName: '${faker.lorem.word()}.jpg',
      fileType: FileType.image,
      isCompressed: false,
      uploadStatus: UploadStatus.pending,
      createdAt: _makeDateTime(),
    );
  }

  static List<AttachmentEntity> makeAttachmentEntityList() {
    return [
      makeAttachmentEntity(),
      makeAttachmentEntity(),
      makeAttachmentEntity(),
    ];
  }

  static User makeUser() {
    return User(
      id: faker.guid.guid(),
      appMetadata: const {},
      userMetadata: const {},
      aud: faker.randomGenerator.string(5),
      createdAt: _makeDateTime().toIso8601String(),
    );
  }

  static UserDataEntity makeUserDataEntity() {
    return UserDataEntity(
      user: makeUserProfileEntity(),
      accessToken: faker.jwt.valid(),
      refreshToken: faker.jwt.valid(),
    );
  }

  static AuthenticationEntity makeAuthentication() {
    return AuthenticationEntity(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }

  static SignUpEntity makeSignUp() {
    return SignUpEntity(
      name: faker.person.name(),
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }

  static AuthenticationRequestModel makeAuthenticationModel() {
    return AuthenticationRequestModel(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }

  static SignUpRequestModel makeSignUpRequest() {
    return SignUpRequestModel(
      name: faker.person.name(),
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }
}
