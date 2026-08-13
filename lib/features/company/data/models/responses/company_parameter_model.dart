import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';

class CompanyParameterModel extends CompanyParameterEntity
    implements DataConvertible<CompanyParameterEntity> {
  const CompanyParameterModel({
    required super.id,
    required super.companyId,
    required super.maxOfflineDurationHours,
    required super.maxOfflinePendingRequests,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CompanyParameterModel.fromJson(MapDynamic json) {
    return CompanyParameterModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      maxOfflineDurationHours: json['max_offline_duration_hours'] as int? ?? 2,
      maxOfflinePendingRequests:
          json['max_offline_pending_requests'] as int? ?? 10,
      createdAt: (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
    );
  }

  factory CompanyParameterModel.fromEntity(CompanyParameterEntity entity) {
    return CompanyParameterModel(
      id: entity.id,
      companyId: entity.companyId,
      maxOfflineDurationHours: entity.maxOfflineDurationHours,
      maxOfflinePendingRequests: entity.maxOfflinePendingRequests,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'max_offline_duration_hours': maxOfflineDurationHours,
    'max_offline_pending_requests': maxOfflinePendingRequests,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  CompanyParameterEntity toEntity() {
    return CompanyParameterEntity(
      id: id,
      companyId: companyId,
      maxOfflineDurationHours: maxOfflineDurationHours,
      maxOfflinePendingRequests: maxOfflinePendingRequests,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}
