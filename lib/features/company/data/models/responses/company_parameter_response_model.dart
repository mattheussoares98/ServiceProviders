import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/domain/entities/company_parameter_entity.dart';

class CompanyParameterResponseModel extends CompanyParameterEntity
    implements DataConvertible<CompanyParameterEntity> {
  const CompanyParameterResponseModel({
    required super.id,
    required super.companyId,
    required super.maxOfflineDurationHours,
    required super.maxOfflinePendingRequests,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CompanyParameterResponseModel.fromJson(MapDynamic json) {
    return CompanyParameterResponseModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      maxOfflineDurationHours: json['max_offline_duration_hours'] as int? ?? 2,
      maxOfflinePendingRequests: json['max_offline_pending_requests'] as int? ?? 10,
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

  factory CompanyParameterResponseModel.fromEntity(CompanyParameterEntity entity) {
    return CompanyParameterResponseModel(
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
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
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
