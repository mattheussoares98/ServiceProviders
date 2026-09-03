import 'package:equatable/equatable.dart';

class AuditChangeEntity extends Equatable {
  const AuditChangeEntity({
    required this.field,
    this.label,
    this.oldValue,
    this.newValue,
    this.oldDisplay,
    this.newDisplay,
    this.entityType,
    this.entityId,
    this.parentEntityType,
    this.parentEntityId,
  });

  final String field;
  final String? label;
  final String? oldValue;
  final String? newValue;
  final String? oldDisplay;
  final String? newDisplay;
  final String? entityType;
  final String? entityId;
  final String? parentEntityType;
  final String? parentEntityId;

  String get effectiveLabel => label ?? field;
  String? get effectiveOldValue => oldDisplay ?? oldValue;
  String? get effectiveNewValue => newDisplay ?? newValue;

  @override
  List<Object?> get props => [
    field,
    label,
    oldValue,
    newValue,
    oldDisplay,
    newDisplay,
    entityType,
    entityId,
    parentEntityType,
    parentEntityId,
  ];

  AuditChangeEntity copyWith({
    String? field,
    String? label,
    String? oldValue,
    String? newValue,
    String? oldDisplay,
    String? newDisplay,
    String? entityType,
    String? entityId,
    String? parentEntityType,
    String? parentEntityId,
    bool? annulOldValue,
    bool? annulNewValue,
    bool? annulOldDisplay,
    bool? annulNewDisplay,
    bool? annulEntityType,
    bool? annulEntityId,
    bool? annulParentEntityType,
    bool? annulParentEntityId,
  }) {
    return AuditChangeEntity(
      field: field ?? this.field,
      label: label ?? this.label,
      oldValue: annulOldValue == true ? null : oldValue ?? this.oldValue,
      newValue: annulNewValue == true ? null : newValue ?? this.newValue,
      oldDisplay:
          annulOldDisplay == true ? null : oldDisplay ?? this.oldDisplay,
      newDisplay:
          annulNewDisplay == true ? null : newDisplay ?? this.newDisplay,
      entityType: annulEntityType == true
          ? null
          : entityType ?? this.entityType,
      entityId: annulEntityId == true ? null : entityId ?? this.entityId,
      parentEntityType: annulParentEntityType == true
          ? null
          : parentEntityType ?? this.parentEntityType,
      parentEntityId: annulParentEntityId == true
          ? null
          : parentEntityId ?? this.parentEntityId,
    );
  }
}

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
  final String entityType;
  final String entityId;
  final String? parentEntityType;
  final String? parentEntityId;
  final String? userId;
  final String action;
  final String? summary;
  final List<AuditChangeEntity> changes;
  final Map<String, dynamic>? metadata;
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
    String? entityType,
    String? entityId,
    String? parentEntityType,
    String? parentEntityId,
    String? userId,
    String? action,
    String? summary,
    List<AuditChangeEntity>? changes,
    Map<String, dynamic>? metadata,
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
