import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/authentication_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/sign_up_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/verify_otp_request_entity.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/entities/device_token_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_error_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class EntityFactory {
  static DateTime _makeDateTime() {
    final dt = faker.date.dateTime();
    return DateTime.utc(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
    );
  }

  static String _makeCompanyName() => faker.company.name();
  static String _makeId() => faker.guid.guid();
  static String _makeWord() => faker.lorem.word();
  static String _makePhrase() => faker.lorem.sentence();
  static String _makeString([int? length]) =>
      faker.randomGenerator.string(length ?? 10);
  static bool _makeBool() => faker.randomGenerator.boolean();
  static int _makeInt(int max, {int min = 0}) =>
      faker.randomGenerator.integer(max, min: min);
  static double _makeDouble() => faker.randomGenerator.decimal();
  static String _makeHttps() => faker.internet.httpsUrl();
  static String _makeEmail() => faker.internet.email();
  static String _makePassword() => faker.internet.password();
  static String _makePersonName() => faker.person.name();
  static String _makeUrl() => faker.internet.httpsUrl();
  // Category
  static CategoryEntity makeCategoryEntity() {
    return CategoryEntity(
      id: _makeId(),
      companyId: _makeId(),
      name: _makeCompanyName(),
      description: _makePhrase(),
      color: _makeString(7),
      createdAt: _makeDateTime(),
      deletedAt: null,
    );
  }

  static List<CategoryEntity> makeCategoryEntityList() {
    return [makeCategoryEntity(), makeCategoryEntity(), makeCategoryEntity()];
  }

  // Location
  static LocationEntity makeLocationEntity() {
    return LocationEntity(
      id: _makeId(),
      companyId: _makeId(),
      name: _makeCompanyName(),
      address: faker.address.streetAddress(),
      city: faker.address.city(),
      state: faker.address.state(),
      isActive: _makeBool(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      complement: _makePhrase(),
      number: _makeInt(100, min: 1).toString(),
      neighborhood: _makeWord(),
      postalCode: _makeString(8),
      deletedAt: null,
    );
  }

  static List<LocationEntity> makeLocationEntityList() {
    return [makeLocationEntity(), makeLocationEntity(), makeLocationEntity()];
  }

  // Area
  static AreaEntity makeAreaEntity() {
    return AreaEntity(
      id: _makeId(),
      locationId: _makeId(),
      companyId: _makeId(),
      name: _makeCompanyName(),
      floor: _makeInt(10).toString(),
      description: _makePhrase(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      deletedAt: null,
    );
  }

  static List<AreaEntity> makeAreaEntityList() {
    return [makeAreaEntity(), makeAreaEntity(), makeAreaEntity()];
  }

  // Asset
  static AssetEntity makeAssetEntity() {
    return AssetEntity(
      id: _makeId(),
      companyId: _makeId(),
      areaId: _makeId(),
      name: _makeCompanyName(),
      code: _makeString(8),
      manufacturer: _makeCompanyName(),
      model: faker.vehicle.model(),
      serialNumber: _makeString(12),
      status: AssetStatus.active,
      criticality: AssetCriticality.medium,
      notes: _makePhrase(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      categoryId: _makeId(),
      warrantyExpiration: _makeDateTime(),
      deletedAt: null,
      installDate: _makeDateTime(),
      parentAssetId: _makeId(),
      revisionForecast: _makeDateTime(),
    );
  }

  static List<AssetEntity> makeAssetEntityList() {
    return [makeAssetEntity(), makeAssetEntity(), makeAssetEntity()];
  }

  // WorkOrder
  static WorkOrderEntity makeWorkOrderEntity() {
    return WorkOrderEntity(
      id: _makeId(),
      companyId: _makeId(),
      assetId: _makeId(),
      locationId: _makeId(),
      areaId: _makeId(),
      assignedToId: _makeId(),
      createdById: _makeId(),
      maintenancePlanId: _makeId(),
      title: _makeCompanyName(),
      description: _makePhrase(),
      priority: Priority.medium,
      status: WorkOrderStatus.open,
      type: WorkOrderType.corrective,
      scheduledDate: _makeDateTime(),
      startedAt: _makeDateTime(),
      completedAt: _makeDateTime(),
      estimatedDuration: _makeInt(120),
      actualDuration: _makeInt(90),
      laborCost: _makeDouble(),
      partsCost: _makeDouble(),
      totalCost: _makeDouble(),
      notes: _makePhrase(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      deletedAt: null,
      attachments: makeAttachmentEntityList(),
      serviceProviderCompanyId: _makeId(),
      providerProfileId: _makeId(),
      slaPolicyId: _makeId(),
      slaDeadlineAt: _makeDateTime(),
      netActiveDuration: _makeInt(60),
      completionReason: _makePhrase(),
      completionResponsibility: PauseResponsibility.shared,
      completionSectorId: _makeId(),
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
      id: _makeId(),
      workOrderId: _makeId(),
      companyId: _makeId(),
      title: _makeWord(),
      description: _makePhrase(),
      isCompleted: false,
      sortOrder: _makeInt(10),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      completedAt: null,
      completedById: null,
      deletedAt: null,
    );
  }

  static List<TaskEntity> makeTaskEntityList() {
    return [makeTaskEntity(), makeTaskEntity(), makeTaskEntity()];
  }

  // WorkOrderChangeRequest
  static WorkOrderChangeRequestEntity makeWorkOrderChangeRequestEntity() {
    return WorkOrderChangeRequestEntity(
      id: _makeId(),
      workOrderId: _makeId(),
      companyId: _makeId(),
      requestedById: _makeId(),
      changeType: WorkOrderChangeType.updateNotes,
      changeData: '{"notes": "Updated notes"}',
      status: ChangeRequestStatus.pending,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      deletedAt: null,
      rejectionReason: null,
      reviewedById: null,
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
      id: _makeId(),
      workOrderId: _makeId(),
      companyId: _makeId(),
      userId: _makeId(),
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
      id: _makeId(),
      companyId: _makeId(),
      name: _makeCompanyName(),
      description: _makePhrase(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      categoryId: null,
      deletedAt: null,
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
      id: _makeId(),
      templateId: _makeId(),
      companyId: _makeId(),
      label: _makeWord(),
      type: ChecklistItemType.boolean,
      isRequired: false,
      sortOrder: _makeInt(10),
      createdAt: _makeDateTime(),
      deletedAt: null,
      options: null,
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
      id: _makeId(),
      name: _makeCompanyName(),
      cnpj: '12345678000199',
      logoUrl: _makeHttps(),
      isActive: true,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      deletedAt: null,
    );
  }

  // UserProfile
  static UserProfileEntity makeUserProfileEntity() {
    return UserProfileEntity(
      id: _makeId(),
      companyId: _makeId(),
      name: _makePersonName(),
      email: _makeEmail(),
      phone: _makeInt(99999999, min: 10000000).toString(),
      isActive: true,
      isAdmin: false,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      avatarUrl: _makeUrl(),
      deletedAt: null,
      permissionGroupId: _makeId(),
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
      id: _makeId(),
      companyId: _makeId(),
      name: _makeWord(),
      deletedAt: null,
      permissions: const {
        ResourceType.attachments: {
          PermissionAction.create,
          PermissionAction.read,
          PermissionAction.update,
          PermissionAction.delete,
        },
      },
      workOrders: const WorkOrdersPermissionEntity.defaultTechnical(),
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
      id: _makeId(),
      companyId: _makeId(),
      title: _makePhrase(),
      description: _makePhrase(),
      frequency: Frequency.monthly,
      priority: Priority.medium,
      isActive: true,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      assetId: _makeId(),
      checklistTemplateId: _makeId(),
      assignedToId: _makeId(),
      dayOfMonth: _makeInt(30),
      dayOfWeek: _makeInt(7),
      monthOfYear: _makeInt(12),
      deletedAt: null,
      lastGeneratedAt: _makeDateTime(),
      locationId: _makeId(),
      nextDueDate: _makeDateTime(),
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
      id: _makeId(),
      workOrderId: _makeId(),
      companyId: _makeId(),
      uploadedById: _makeId(),
      fileName: '${_makeWord()}.jpg',
      fileType: FileType.image,
      localPath: _makePhrase(),
      remoteUrl: _makeUrl(),
      fileSizeBytes: _makeInt(1024),
      isCompressed: false,
      uploadStatus: UploadStatus.pending,
      createdAt: _makeDateTime(),
      deletedAt: null,
      originalPath: _makePhrase(),
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

  static User makeUser() {
    return User(
      id: _makeId(),
      appMetadata: const {},
      userMetadata: const {},
      aud: _makeString(5),
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

  static AuthUserEntity makeAuthUserEntity() {
    return AuthUserEntity(
      id: _makeId(),
      email: _makeEmail(),
      name: _makePersonName(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static AuthenticationEntity makeAuthentication() {
    return AuthenticationEntity(email: _makeEmail(), password: _makePassword());
  }

  static SignUpEntity makeSignUp() {
    return SignUpEntity(
      name: _makePersonName(),
      email: _makeEmail(),
      password: _makePassword(),
    );
  }

  static VerifyOtpRequestEntity makeVerifyOtpRequestEntity() {
    return VerifyOtpRequestEntity(tokenHash: _makeId());
  }

  static List<VerifyOtpRequestEntity> makeVerifyOtpRequestEntityList() {
    return [
      makeVerifyOtpRequestEntity(),
      makeVerifyOtpRequestEntity(),
      makeVerifyOtpRequestEntity(),
    ];
  }

  static AuthenticationRequestModel makeAuthenticationModel() {
    return AuthenticationRequestModel(
      email: _makeEmail(),
      password: _makePassword(),
    );
  }

  static SignUpRequestModel makeSignUpRequest() {
    return SignUpRequestModel(
      name: _makePersonName(),
      email: _makeEmail(),
      password: _makePassword(),
    );
  }

  static ConfigurationsEntity makeConfigurationsEntity() {
    return ConfigurationsEntity(
      pushNotificationsEnabled: _makeBool(),
      themeMode: faker.randomGenerator.element(['light', 'dark', 'system']),
      systemNotificationsEnabled: _makeBool(),
    );
  }

  // UserInvitation
  static UserInvitationEntity makeUserInvitationEntity() {
    return UserInvitationEntity(
      id: _makeId(),
      email: _makeEmail(),
      invitedAt: _makeDateTime(),
      companyId: _makeId(),
      permissionGroupId: _makeId(),
      name: _makePersonName(),
      confirmationSentAt: _makeDateTime(),
    );
  }

  static List<UserInvitationEntity> makeUserInvitationEntityList() {
    return [
      makeUserInvitationEntity(),
      makeUserInvitationEntity(),
      makeUserInvitationEntity(),
    ];
  }

  // Service Provider Company
  static ServiceProviderCompanyEntity makeServiceProviderCompanyEntity() {
    return ServiceProviderCompanyEntity(
      id: _makeId(),
      companyId: _makeId(),
      name: _makeCompanyName(),
      document: '12345678000199',
      documentType: DocumentType.values[_makeInt(DocumentType.values.length)],
      contactEmail: _makeEmail(),
      contactPhone: _makeInt(99999999, min: 10000000).toString(),
      isActive: true,
      invitationStatus: ServiceProviderInvitationStatus.accepted,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      deletedAt: null,
    );
  }

  static List<ServiceProviderCompanyEntity>
  makeServiceProviderCompanyEntityList() {
    return [
      makeServiceProviderCompanyEntity(),
      makeServiceProviderCompanyEntity(),
      makeServiceProviderCompanyEntity(),
    ];
  }

  // Service Provider Profile
  static ServiceProviderProfileEntity makeServiceProviderProfileEntity() {
    return ServiceProviderProfileEntity(
      id: _makeId(),
      authUserId: _makeId(),
      serviceProviderCompanyId: _makeId(),
      name: _makePersonName(),
      email: _makeEmail(),
      phone: _makeInt(99999999, min: 10000000).toString(),
      isActive: true,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static List<ServiceProviderProfileEntity>
  makeServiceProviderProfileEntityList() {
    return [
      makeServiceProviderProfileEntity(),
      makeServiceProviderProfileEntity(),
      makeServiceProviderProfileEntity(),
    ];
  }

  // SLA Policy
  static SlaPolicyEntity makeSlaPolicyEntity() {
    return SlaPolicyEntity(
      id: _makeId(),
      companyId: _makeId(),
      name: _makeCompanyName(),
      targetHours: _makeInt(48, min: 1),
      appliesTo: SlaAppliesTo.both,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      deletedAt: null,
    );
  }

  static List<SlaPolicyEntity> makeSlaPolicyEntityList() {
    return [
      makeSlaPolicyEntity(),
      makeSlaPolicyEntity(),
      makeSlaPolicyEntity(),
    ];
  }

  // Pause Reason
  static PauseReasonEntity makePauseReasonEntity() {
    return PauseReasonEntity(
      id: _makeId(),
      companyId: _makeId(),
      name: _makeCompanyName(),
      isActive: true,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      deletedAt: null,
    );
  }

  static List<PauseReasonEntity> makePauseReasonEntityList() {
    return [
      makePauseReasonEntity(),
      makePauseReasonEntity(),
      makePauseReasonEntity(),
    ];
  }

  // Pause Request
  static PauseRequestEntity makePauseRequestEntity() {
    return PauseRequestEntity(
      id: _makeId(),
      companyId: _makeId(),
      workOrderId: _makeId(),
      requestedById: _makeId(),
      reasonId: _makeId(),
      customReason: _makePhrase(),
      observation: _makePhrase(),
      responsibility: PauseResponsibility.provider,
      sectorId: _makeId(),
      status: PauseRequestStatus.pending,
      pausedAt: _makeDateTime(),
      affectsSla: true,
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      resumedAt: _makeDateTime(),
      resumedById: _makeId(),
      reviewObservation: _makeId(),
      reviewedById: _makeId(),
      eventType: PauseEventType.values[_makeInt(PauseEventType.values.length)],
    );
  }

  static List<PauseRequestEntity> makePauseRequestEntityList() {
    return [
      makePauseRequestEntity(),
      makePauseRequestEntity(),
      makePauseRequestEntity(),
    ];
  }

  // Work Order Observation
  static WorkOrderObservationEntity makeWorkOrderObservationEntity() {
    return WorkOrderObservationEntity(
      id: _makeId(),
      companyId: _makeId(),
      workOrderId: _makeId(),
      authorId: _makeId(),
      authorProviderProfileId: null,
      authorName: _makePhrase(),
      content: _makePhrase(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static List<WorkOrderObservationEntity> makeWorkOrderObservationEntityList() {
    return [
      makeWorkOrderObservationEntity(),
      makeWorkOrderObservationEntity(),
      makeWorkOrderObservationEntity(),
    ];
  }

  // Service Provider Invitation
  static ServiceProviderInvitationEntity makeServiceProviderInvitationEntity() {
    return ServiceProviderInvitationEntity(
      id: _makeId(),
      email: _makeEmail(),
      serviceProviderCompanyId: _makeId(),
      inviteToken: _makeString(32),
      status: ServiceProviderInvitationStatus.pending,
      createdAt: _makeDateTime(),
      expiresAt: _makeDateTime(),
      acceptedAt: _makeDateTime(),
    );
  }

  static List<ServiceProviderInvitationEntity>
  makeServiceProviderInvitationEntityList() {
    return [
      makeServiceProviderInvitationEntity(),
      makeServiceProviderInvitationEntity(),
      makeServiceProviderInvitationEntity(),
    ];
  }

  // Sector
  static SectorEntity makeSectorEntity() {
    return SectorEntity(
      id: _makeId(),
      companyId: _makeId(),
      name: _makeWord(),
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
      deletedAt: null,
    );
  }

  static List<SectorEntity> makeSectorEntityList() {
    return [makeSectorEntity(), makeSectorEntity(), makeSectorEntity()];
  }

  // Device Token
  static DeviceTokenEntity makeDeviceTokenEntity() {
    return DeviceTokenEntity(
      id: _makeId(),
      userId: _makeId(),
      deviceToken: _makeWord(),
      platform: 'android',
      createdAt: _makeDateTime(),
      updatedAt: _makeDateTime(),
    );
  }

  static List<DeviceTokenEntity> makeDeviceTokenEntityList() {
    return [
      makeDeviceTokenEntity(),
      makeDeviceTokenEntity(),
      makeDeviceTokenEntity(),
    ];
  }

  // Sync Queue Item
  static SyncQueueItemEntity makeSyncQueueItemEntity() {
    return SyncQueueItemEntity(
      id: _makeId(),
      companyId: _makeId(),
      userProfileId: _makeId(),
      entityType: SyncEntityType.workOrder,
      entityId: _makeId(),
      operation: SyncOperationType.create,
      payload: '{"title": "Test Work Order"}',
      createdAt: _makeDateTime(),
    );
  }

  static List<SyncQueueItemEntity> makeSyncQueueItemEntityList() {
    return [
      makeSyncQueueItemEntity(),
      makeSyncQueueItemEntity(),
      makeSyncQueueItemEntity(),
    ];
  }

  // Sync Error
  static SyncErrorEntity makeSyncErrorEntity() {
    return SyncErrorEntity(
      id: _makeId(),
      companyId: _makeId(),
      userId: _makeId(),
      entityType: SyncEntityType.workOrder,
      entityId: _makeId(),
      operation: SyncOperationType.create,
      payload: '{"title": "Test Work Order"}',
      errorType: 'ConstraintViolation',
      errorMessage: _makePhrase(),
      createdAt: _makeDateTime(),
    );
  }

  static List<SyncErrorEntity> makeSyncErrorEntityList() {
    return [
      makeSyncErrorEntity(),
      makeSyncErrorEntity(),
      makeSyncErrorEntity(),
    ];
  }
}
