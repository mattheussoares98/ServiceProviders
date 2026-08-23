import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_status.dart';

class SyncQueueItemEntity extends Equatable {
  const SyncQueueItemEntity({
    required this.id,
    required this.companyId,
    required this.userProfileId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payload,
    this.status = SyncStatus.pending,
    this.attempts = 0,
    this.lastError,
    required this.createdAt,
    this.syncedAt,
  });

  final String id;
  final String companyId;
  final String userProfileId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operation;
  final String? payload;
  final SyncStatus status;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? syncedAt;

  SyncQueueItemEntity copyWith({
    String? id,
    String? companyId,
    String? userProfileId,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperationType? operation,
    String? payload,
    bool? annulPayload,
    SyncStatus? status,
    int? attempts,
    String? lastError,
    bool? annulLastError,
    DateTime? createdAt,
    DateTime? syncedAt,
    bool? annulSyncedAt,
  }) => SyncQueueItemEntity(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    userProfileId: userProfileId ?? this.userProfileId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: annulPayload == true ? null : payload ?? this.payload,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    lastError: annulLastError == true ? null : lastError ?? this.lastError,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: annulSyncedAt == true ? null : syncedAt ?? this.syncedAt,
  );

  @override
  List<Object?> get props => [
    id,
    companyId,
    userProfileId,
    entityType,
    entityId,
    operation,
    payload,
    status,
    attempts,
    lastError,
    createdAt,
    syncedAt,
  ];
}
