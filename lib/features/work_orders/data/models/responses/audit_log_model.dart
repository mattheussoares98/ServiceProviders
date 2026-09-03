import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/audit_change_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/audit_metadata_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_change_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_entity_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_log_entity.dart';

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
    final entityType = AuditEntityType.fromCode(json['entity_type'] as String?);
    final entityId = json['entity_id'] as String? ?? '';
    final parentEntityType = json['parent_entity_type'] != null
        ? AuditEntityType.fromCode(json['parent_entity_type'] as String?)
        : null;
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

    AuditMetadataModel? metadata;
    final metaRaw = json['metadata'];
    if (metaRaw is MapDynamic) {
      metadata = AuditMetadataModel.fromJson(metaRaw);
    } else if (metaRaw is Map) {
      metadata = AuditMetadataModel.fromJson(MapDynamic.from(metaRaw));
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
    'entity_type': entityType.code,
    'entity_id': entityId,
    'parent_entity_type': parentEntityType?.code,
    'parent_entity_id': parentEntityId,
    'user_id': userId,
    'action': action,
    'diff': {
      'summary': summary,
      'changes': changes
          .map((c) => AuditChangeModel.fromEntity(c).toJson())
          .toList(),
    },
    'metadata': metadata != null
        ? AuditMetadataModel.fromEntity(metadata!).toJson()
        : null,
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
