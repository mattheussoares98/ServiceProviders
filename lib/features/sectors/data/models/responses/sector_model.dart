import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';

class SectorModel extends SectorEntity
    implements DataConvertible<SectorEntity> {
  const SectorModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory SectorModel.fromEntity(SectorEntity entity) => SectorModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory SectorModel.fromJson(MapDynamic json) {
    return SectorModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
  };

  @override
  SectorEntity toEntity() => SectorEntity(
    id: id,
    companyId: companyId,
    name: name,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
