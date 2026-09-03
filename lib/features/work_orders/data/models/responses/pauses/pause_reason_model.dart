import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_reason_entity.dart';

class PauseReasonModel extends PauseReasonEntity
    implements DataConvertible<PauseReasonEntity> {
  const PauseReasonModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory PauseReasonModel.fromEntity(PauseReasonEntity entity) =>
      PauseReasonModel(
        id: entity.id,
        companyId: entity.companyId,
        name: entity.name,
        isActive: entity.isActive,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        deletedAt: entity.deletedAt,
      );

  factory PauseReasonModel.fromJson(MapDynamic json) => PauseReasonModel(
    id: json['id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? true,
    createdAt:
        (json['created_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    updatedAt:
        (json['updated_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    deletedAt: (json['deleted_at'] as String?)?.toUtcDateTime(),
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'is_active': isActive,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  PauseReasonEntity toEntity() => PauseReasonEntity(
    id: id,
    companyId: companyId,
    name: name,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
