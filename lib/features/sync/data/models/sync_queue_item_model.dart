import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_status.dart';

class SyncQueueItemModel extends SyncQueueItemEntity
    implements DataConvertible<SyncQueueItemEntity> {
  const SyncQueueItemModel({
    required super.id,
    required super.companyId,
    required super.userProfileId,
    required super.entityType,
    required super.entityId,
    required super.operation,
    super.payload,
    super.status = SyncStatus.pending,
    super.attempts = 0,
    super.lastError,
    required super.createdAt,
    super.syncedAt,
  });

  factory SyncQueueItemModel.fromJson(MapDynamic json) => SyncQueueItemModel(
    id: json['id'] as String,
    companyId: json['company_id'] as String,
    userProfileId: json['user_profile_id'] as String,
    entityType: SyncEntityType.fromCode(json['entity_type'] as String),
    entityId: json['entity_id'] as String,
    operation: SyncOperationType.fromCode(json['operation'] as String),
    payload: json['payload'] as String?,
    status: SyncStatus.fromCode(json['status'] as String? ?? 'pending'),
    attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    lastError: json['last_error'] as String?,
    createdAt: (json['created_at'] as String?).toUtcDateTime() ?? DateTime.now(),
    syncedAt: (json['synced_at'] as String?).toUtcDateTime(),
  );

  factory SyncQueueItemModel.fromEntity(SyncQueueItemEntity entity) =>
      SyncQueueItemModel(
        id: entity.id,
        companyId: entity.companyId,
        userProfileId: entity.userProfileId,
        entityType: entity.entityType,
        entityId: entity.entityId,
        operation: entity.operation,
        payload: entity.payload,
        status: entity.status,
        attempts: entity.attempts,
        lastError: entity.lastError,
        createdAt: entity.createdAt,
        syncedAt: entity.syncedAt,
      );

  @override
  SyncQueueItemEntity toEntity() => SyncQueueItemEntity(
    id: id,
    companyId: companyId,
    userProfileId: userProfileId,
    entityType: entityType,
    entityId: entityId,
    operation: operation,
    payload: payload,
    status: status,
    attempts: attempts,
    lastError: lastError,
    createdAt: createdAt,
    syncedAt: syncedAt,
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'user_profile_id': userProfileId,
    'entity_type': entityType.code,
    'entity_id': entityId,
    'operation': operation.code,
    'payload': payload,
    'status': status.code,
    'attempts': attempts,
    'last_error': lastError,
    'created_at': createdAt.toIsoUtcString(),
    'synced_at': syncedAt?.toIsoUtcString(),
  };
}
