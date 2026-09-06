import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_action.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/create_access_log_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/get_access_logs_request_entity.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/entities/device_token_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_error_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';

import 'factory_helpers.dart';

abstract final class SystemFactory {
  static SlaPolicyEntity makeSlaPolicyEntity() {
    return SlaPolicyEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      targetHours: FactoryHelpers.makeInt(48, min: 1),
      appliesTo: SlaAppliesTo.both,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
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
  static SectorEntity makeSectorEntity() {
    return SectorEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeWord(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
    );
  }

  static List<SectorEntity> makeSectorEntityList() {
    return [makeSectorEntity(), makeSectorEntity(), makeSectorEntity()];
  }

  // Device Token
  static DeviceTokenEntity makeDeviceTokenEntity() {
    return DeviceTokenEntity(
      id: FactoryHelpers.makeId(),
      userId: FactoryHelpers.makeId(),
      deviceToken: FactoryHelpers.makeWord(),
      platform: 'android',
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
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
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      userProfileId: FactoryHelpers.makeId(),
      entityType: SyncEntityType.workOrder,
      entityId: FactoryHelpers.makeId(),
      operation: SyncOperationType.create,
      payload: '{"title": "Test Work Order"}',
      createdAt: FactoryHelpers.makeDateTime(),
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
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      userId: FactoryHelpers.makeId(),
      entityType: SyncEntityType.workOrder,
      entityId: FactoryHelpers.makeId(),
      operation: SyncOperationType.create,
      payload: '{"title": "Test Work Order"}',
      errorType: 'ConstraintViolation',
      errorMessage: FactoryHelpers.makePhrase(),
      createdAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<SyncErrorEntity> makeSyncErrorEntityList() {
    return [
      makeSyncErrorEntity(),
      makeSyncErrorEntity(),
      makeSyncErrorEntity(),
    ];
  }

  // Access Log
  static AccessLogEntity makeAccessLogEntity() {
    return AccessLogEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      userId: FactoryHelpers.makeId(),
      userName: FactoryHelpers.makePersonName(),
      userEmail: FactoryHelpers.makeEmail(),
      action: AccessLogAction.login,
      ipAddress: '192.168.1.1',
      deviceInfo: 'Flutter (macOS)',
      createdAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<AccessLogEntity> makeAccessLogEntityList() {
    return [
      makeAccessLogEntity(),
      makeAccessLogEntity(),
      makeAccessLogEntity(),
    ];
  }

  static GetAccessLogsRequestEntity makeGetAccessLogsRequestEntity() {
    return GetAccessLogsRequestEntity(
      companyId: FactoryHelpers.makeId(),
      startDate: FactoryHelpers.makeDateTime(),
      endDate: FactoryHelpers.makeDateTime(),
      userId: FactoryHelpers.makeId(),
    );
  }

  static CreateAccessLogRequestEntity makeCreateAccessLogRequestEntity() {
    return CreateAccessLogRequestEntity(
      companyId: FactoryHelpers.makeId(),
      userId: FactoryHelpers.makeId(),
      action: AccessLogAction.login,
      ipAddress: '192.168.1.1',
      deviceInfo: 'Flutter (macOS)',
    );
  }

  // Generic Realtime Event
  static RealtimeEvent<T> makeRealtimeEvent<T>({T? entity}) {
    return RealtimeEvent<T>(
      eventType: RealtimeEventType.update,
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      entity: entity,
    );
  }

  static List<RealtimeEvent<T>> makeRealtimeEventList<T>({T? entity}) {
    return [
      makeRealtimeEvent<T>(entity: entity),
      makeRealtimeEvent<T>(entity: entity),
      makeRealtimeEvent<T>(entity: entity),
    ];
  }
}
