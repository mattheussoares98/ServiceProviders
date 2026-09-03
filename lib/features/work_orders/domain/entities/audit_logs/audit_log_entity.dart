import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_change_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_entity_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_metadata_entity.dart';

class AuditLogEntity extends Equatable {
  const AuditLogEntity({
    required this.id,
    required this.companyId,
    required this.entityType,
    required this.entityId,
    this.parentEntityType,
    this.parentEntityId,
    this.userId,
    required this.action,
    this.summary,
    this.changes = const [],
    this.metadata,
    required this.createdAt,
  });

  final String id;
  final String companyId;
  final AuditEntityType entityType;
  final String entityId;
  final AuditEntityType? parentEntityType;
  final String? parentEntityId;
  final String? userId;
  final String action;
  final String? summary;
  final List<AuditChangeEntity> changes;
  final AuditMetadataEntity? metadata;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    entityType,
    entityId,
    parentEntityType,
    parentEntityId,
    userId,
    action,
    summary,
    changes,
    metadata,
    createdAt,
  ];

  AuditLogEntity copyWith({
    String? id,
    String? companyId,
    AuditEntityType? entityType,
    String? entityId,
    AuditEntityType? parentEntityType,
    String? parentEntityId,
    String? userId,
    String? action,
    String? summary,
    List<AuditChangeEntity>? changes,
    AuditMetadataEntity? metadata,
    DateTime? createdAt,
    bool? annulParentEntityType,
    bool? annulParentEntityId,
    bool? annulUserId,
    bool? annulSummary,
    bool? annulMetadata,
  }) {
    return AuditLogEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      parentEntityType: annulParentEntityType == true
          ? null
          : parentEntityType ?? this.parentEntityType,
      parentEntityId: annulParentEntityId == true
          ? null
          : parentEntityId ?? this.parentEntityId,
      userId: annulUserId == true ? null : userId ?? this.userId,
      action: action ?? this.action,
      summary: annulSummary == true ? null : summary ?? this.summary,
      changes: changes ?? this.changes,
      metadata: annulMetadata == true ? null : metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
