import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';

class CompanyResponseModel extends CompanyEntity
    implements DataConvertible<CompanyEntity> {
  const CompanyResponseModel({
    required super.id,
    required super.name,
    super.cnpj,
    super.logoUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CompanyResponseModel.fromJson(Map<String, dynamic> json) {
    return CompanyResponseModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      cnpj: json['cnpj'] as String?,
      logoUrl: json['logo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
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

  factory CompanyResponseModel.fromEntity(CompanyEntity entity) {
    return CompanyResponseModel(
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
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
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
