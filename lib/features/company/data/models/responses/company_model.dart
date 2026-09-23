import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/plan_type.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';

class CompanyModel extends CompanyEntity
    implements DataConvertible<CompanyEntity> {
  const CompanyModel({
    required super.id,
    required super.name,
    super.cnpj,
    super.logoUrl,
    required super.isActive,
    super.planType = PlanType.free,
    super.workType = WorkType.internalOnly,
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
      planType:
          PlanType.fromCode(json['plan_type'] as String?) ?? PlanType.free,
      workType:
          WorkType.fromCode(json['work_type'] as String?) ??
          WorkType.internalOnly,
      createdAt:
          (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      updatedAt:
          (json['updated_at'] as String?).toUtcDateTime() ??
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
      planType: entity.planType,
      workType: entity.workType,
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
    'plan_type': planType.code,
    'work_type': workType.code,
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
      planType: planType,
      workType: workType,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}
