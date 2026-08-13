import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity
    implements DataConvertible<CompanyEntity> {
  const CompanyModel({
    required super.id,
    required super.name,
    super.cnpj,
    super.logoUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CompanyModel.fromJson(MapDynamic json) {
    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      cnpj: json['cnpj'] as String?,
      logoUrl: json['logo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
    );
  }

  factory CompanyModel.fromEntity(CompanyEntity entity) {
    return CompanyModel(
      id: entity.id,
      name: entity.name,
      cnpj: entity.cnpj,
      logoUrl: entity.logoUrl,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'name': name,
    'cnpj': cnpj,
    'logo_url': logoUrl,
    'is_active': isActive,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  CompanyEntity toEntity() {
    return CompanyEntity(
      id: id,
      name: name,
      cnpj: cnpj,
      logoUrl: logoUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}
