import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_error_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';

class SyncErrorModel extends SyncErrorEntity
    implements DataConvertible<SyncErrorEntity> {
  const SyncErrorModel({
    required super.id,
    required super.companyId,
    required super.userId,
    required super.entityType,
    required super.entityId,
    required super.operation,
    super.payload,
    required super.errorType,
    required super.errorMessage,
    super.attempts = 1,
    required super.createdAt,
  });

  factory SyncErrorModel.fromJson(MapDynamic json) => SyncErrorModel(
    id: json['id'] as String,
    companyId: json['company_id'] as String,
    userId: json['user_id'] as String,
    entityType: SyncEntityType.fromCode(json['entity_type'] as String),
    entityId: json['entity_id'] as String,
    operation: SyncOperationType.fromCode(json['operation'] as String),
    payload: json['payload'] as String?,
    errorType: json['error_type'] as String,
    errorMessage: json['error_message'] as String,
    attempts: (json['attempts'] as num?)?.toInt() ?? 1,
    createdAt: (json['created_at'] as String?).toUtcDateTime() ?? DateTime.now(),
  );

  factory SyncErrorModel.fromEntity(SyncErrorEntity entity) => SyncErrorModel(
    id: entity.id,
    companyId: entity.companyId,
    userId: entity.userId,
    entityType: entity.entityType,
    entityId: entity.entityId,
    operation: entity.operation,
    payload: entity.payload,
    errorType: entity.errorType,
    errorMessage: entity.errorMessage,
    attempts: entity.attempts,
    createdAt: entity.createdAt,
  );

  @override
  SyncErrorEntity toEntity() => SyncErrorEntity(
    id: id,
    companyId: companyId,
    userId: userId,
    entityType: entityType,
    entityId: entityId,
    operation: operation,
    payload: payload,
    errorType: errorType,
    errorMessage: errorMessage,
    attempts: attempts,
    createdAt: createdAt,
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'user_id': userId,
    'entity_type': entityType.code,
    'entity_id': entityId,
    'operation': operation.code,
    if (payload != null) 'payload': payload,
    'error_type': errorType,
    'error_message': errorMessage,
    'attempts': attempts,
    'created_at': createdAt.toIsoUtcString(),
  };
}
