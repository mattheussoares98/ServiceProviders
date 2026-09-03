import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_log_entity.dart';

class AuditChangeModel extends AuditChangeEntity
    implements DataConvertible<AuditChangeEntity> {
  const AuditChangeModel({
    required super.field,
    super.label,
    super.oldValue,
    super.newValue,
    super.oldDisplay,
    super.newDisplay,
    super.entityType,
    super.entityId,
    super.parentEntityType,
    super.parentEntityId,
  });

  factory AuditChangeModel.fromEntity(AuditChangeEntity entity) =>
      AuditChangeModel(
        field: entity.field,
        label: entity.label,
        oldValue: entity.oldValue,
        newValue: entity.newValue,
        oldDisplay: entity.oldDisplay,
        newDisplay: entity.newDisplay,
        entityType: entity.entityType,
        entityId: entity.entityId,
        parentEntityType: entity.parentEntityType,
        parentEntityId: entity.parentEntityId,
      );

  factory AuditChangeModel.fromJson(
    MapDynamic json, {
    String? defaultEntityType,
    String? defaultEntityId,
    String? defaultParentEntityType,
    String? defaultParentEntityId,
  }) => AuditChangeModel(
    field: json['field'] as String? ?? '',
    label: json['label'] as String?,
    oldValue: json['old_value']?.toString(),
    newValue: json['new_value']?.toString(),
    oldDisplay: json['old_display']?.toString(),
    newDisplay: json['new_display']?.toString(),
    entityType: (json['entity_type'] as String?) ?? defaultEntityType,
    entityId: (json['entity_id'] as String?) ?? defaultEntityId,
    parentEntityType:
        (json['parent_entity_type'] as String?) ?? defaultParentEntityType,
    parentEntityId:
        (json['parent_entity_id'] as String?) ?? defaultParentEntityId,
  );

  @override
  MapDynamic toJson() => {
    'field': field,
    'label': label,
    'old_value': oldValue,
    'new_value': newValue,
    'old_display': oldDisplay,
    'new_display': newDisplay,
    'entity_type': entityType,
    'entity_id': entityId,
    'parent_entity_type': parentEntityType,
    'parent_entity_id': parentEntityId,
  };

  @override
  AuditChangeEntity toEntity() => AuditChangeEntity(
    field: field,
    label: label,
    oldValue: oldValue,
    newValue: newValue,
    oldDisplay: oldDisplay,
    newDisplay: newDisplay,
    entityType: entityType,
    entityId: entityId,
    parentEntityType: parentEntityType,
    parentEntityId: parentEntityId,
  );
}

class AuditLogModel extends AuditLogEntity
    implements DataConvertible<AuditLogEntity> {
  const AuditLogModel({
    required super.id,
    required super.companyId,
    required super.entityType,
    required super.entityId,
    super.parentEntityType,
    super.parentEntityId,
    super.userId,
    required super.action,
    super.summary,
    super.changes = const [],
    super.metadata,
    required super.createdAt,
  });

  factory AuditLogModel.fromEntity(AuditLogEntity entity) => AuditLogModel(
    id: entity.id,
    companyId: entity.companyId,
    entityType: entity.entityType,
    entityId: entity.entityId,
    parentEntityType: entity.parentEntityType,
    parentEntityId: entity.parentEntityId,
    userId: entity.userId,
    action: entity.action,
    summary: entity.summary,
    changes: entity.changes,
    metadata: entity.metadata,
    createdAt: entity.createdAt,
  );

  factory AuditLogModel.fromJson(MapDynamic json) {
    final entityType = json['entity_type'] as String? ?? '';
    final entityId = json['entity_id'] as String? ?? '';
    final parentEntityType = json['parent_entity_type'] as String?;
    final parentEntityId = json['parent_entity_id'] as String?;

    String? summary;
    final changes = <AuditChangeEntity>[];

    final diffRaw = json['diff'];
    if (diffRaw is MapDynamic) {
      summary = diffRaw['summary'] as String?;
      final changesList = diffRaw['changes'];
      if (changesList is List) {
        for (final item in changesList) {
          if (item is MapDynamic) {
            changes.add(
              AuditChangeModel.fromJson(
                item,
                defaultEntityType: entityType,
                defaultEntityId: entityId,
                defaultParentEntityType: parentEntityType,
                defaultParentEntityId: parentEntityId,
              ),
            );
          } else if (item is Map) {
            changes.add(
              AuditChangeModel.fromJson(
                MapDynamic.from(item),
                defaultEntityType: entityType,
                defaultEntityId: entityId,
                defaultParentEntityType: parentEntityType,
                defaultParentEntityId: parentEntityId,
              ),
            );
          }
        }
      }
    }

    MapDynamic? metadata;
    final metaRaw = json['metadata'];
    if (metaRaw is MapDynamic) {
      metadata = metaRaw;
    } else if (metaRaw is Map) {
      metadata = MapDynamic.from(metaRaw);
    }

    return AuditLogModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      entityType: entityType,
      entityId: entityId,
      parentEntityType: parentEntityType,
      parentEntityId: parentEntityId,
      userId: json['user_id'] as String?,
      action: json['action'] as String? ?? '',
      summary: summary,
      changes: changes,
      metadata: metadata,
      createdAt: (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'entity_type': entityType,
    'entity_id': entityId,
    'parent_entity_type': parentEntityType,
    'parent_entity_id': parentEntityId,
    'user_id': userId,
    'action': action,
    'diff': {
      'summary': summary,
      'changes': changes
          .map((c) => AuditChangeModel.fromEntity(c).toJson())
          .toList(),
    },
    'metadata': metadata,
    'created_at': createdAt.toIsoUtcString(),
  };

  @override
  AuditLogEntity toEntity() => AuditLogEntity(
    id: id,
    companyId: companyId,
    entityType: entityType,
    entityId: entityId,
    parentEntityType: parentEntityType,
    parentEntityId: parentEntityId,
    userId: userId,
    action: action,
    summary: summary,
    changes: changes,
    metadata: metadata,
    createdAt: createdAt,
  );
}
