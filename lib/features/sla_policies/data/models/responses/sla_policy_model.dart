import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';

class SlaPolicyModel extends SlaPolicyEntity
    implements DataConvertible<SlaPolicyEntity> {
  const SlaPolicyModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.targetHours,
    required super.appliesTo,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory SlaPolicyModel.fromEntity(SlaPolicyEntity entity) => SlaPolicyModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    targetHours: entity.targetHours,
    appliesTo: entity.appliesTo,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory SlaPolicyModel.fromJson(MapDynamic json) {
    return SlaPolicyModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      targetHours: json['target_hours'] as int? ?? 0,
      appliesTo: SlaAppliesTo.fromValue(json['applies_to'] as String? ?? ''),
      createdAt:
          (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      updatedAt:
          (json['updated_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'target_hours': targetHours,
    'applies_to': appliesTo.value,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  SlaPolicyEntity toEntity() => SlaPolicyEntity(
    id: id,
    companyId: companyId,
    name: name,
    targetHours: targetHours,
    appliesTo: appliesTo,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
