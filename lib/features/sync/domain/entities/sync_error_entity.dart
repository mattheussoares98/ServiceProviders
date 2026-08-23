import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';

class SyncErrorEntity extends Equatable {
  const SyncErrorEntity({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payload,
    required this.errorType,
    required this.errorMessage,
    this.attempts = 1,
    required this.createdAt,
  });

  final String id;
  final String companyId;
  final String userId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operation;
  final String? payload;
  final String errorType;
  final String errorMessage;
  final int attempts;
  final DateTime createdAt;

  SyncErrorEntity copyWith({
    String? id,
    String? companyId,
    String? userId,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperationType? operation,
    String? payload,
    bool? annulPayload,
    String? errorType,
    String? errorMessage,
    int? attempts,
    DateTime? createdAt,
  }) => SyncErrorEntity(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: annulPayload == true ? null : payload ?? this.payload,
    errorType: errorType ?? this.errorType,
    errorMessage: errorMessage ?? this.errorMessage,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    companyId,
    userId,
    entityType,
    entityId,
    operation,
    payload,
    errorType,
    errorMessage,
    attempts,
    createdAt,
  ];
}
