import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';

class CompanyRequestModel extends CompanyEntity
    implements DataConvertible<CompanyEntity> {
  const CompanyRequestModel({
    required super.id,
    required super.name,
    super.cnpj,
    super.logoUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CompanyRequestModel.fromEntity(CompanyEntity entity) =>
      CompanyRequestModel(
        id: entity.id,
        name: entity.name,
        cnpj: entity.cnpj,
        logoUrl: entity.logoUrl,
        isActive: entity.isActive,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        deletedAt: entity.deletedAt,
      );

  factory CompanyRequestModel.fromJson(MapDynamic json) => CompanyRequestModel(
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

  @override
  MapDynamic toJson() => {
    'name': name,
    'cnpj': cnpj,
    'logo_url': logoUrl,
    'is_active': isActive,
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  CompanyEntity toEntity() => CompanyEntity(
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
