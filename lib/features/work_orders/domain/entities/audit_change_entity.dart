import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_entity_type.dart';

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
  final AuditEntityType? entityType;
  final String? entityId;
  final AuditEntityType? parentEntityType;
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
    AuditEntityType? entityType,
    String? entityId,
    AuditEntityType? parentEntityType,
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
