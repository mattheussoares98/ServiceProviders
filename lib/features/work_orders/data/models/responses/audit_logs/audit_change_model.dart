import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_change_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_entity_type.dart';

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
    AuditEntityType? defaultEntityType,
    String? defaultEntityId,
    AuditEntityType? defaultParentEntityType,
    String? defaultParentEntityId,
  }) {
    final rawEntityType = json['entity_type'] as String?;
    final resolvedEntityType = rawEntityType != null
        ? AuditEntityType.fromCode(rawEntityType)
        : defaultEntityType;

    final rawParentEntityType = json['parent_entity_type'] as String?;
    final resolvedParentEntityType = rawParentEntityType != null
        ? AuditEntityType.fromCode(rawParentEntityType)
        : defaultParentEntityType;

    return AuditChangeModel(
      field: json['field'] as String? ?? '',
      label: json['label'] as String?,
      oldValue: json['old_value']?.toString(),
      newValue: json['new_value']?.toString(),
      oldDisplay: json['old_display']?.toString(),
      newDisplay: json['new_display']?.toString(),
      entityType: resolvedEntityType,
      entityId: (json['entity_id'] as String?) ?? defaultEntityId,
      parentEntityType: resolvedParentEntityType,
      parentEntityId:
          (json['parent_entity_id'] as String?) ?? defaultParentEntityId,
    );
  }

  @override
  MapDynamic toJson() => {
    'field': field,
    'label': label,
    'old_value': oldValue,
    'new_value': newValue,
    'old_display': oldDisplay,
    'new_display': newDisplay,
    'entity_type': entityType?.code,
    'entity_id': entityId,
    'parent_entity_type': parentEntityType?.code,
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
