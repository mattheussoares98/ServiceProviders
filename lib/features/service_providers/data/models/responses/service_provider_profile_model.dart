import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';

class ServiceProviderProfileModel extends ServiceProviderProfileEntity
    implements DataConvertible<ServiceProviderProfileEntity> {
  const ServiceProviderProfileModel({
    required super.id,
    super.authUserId,
    required super.serviceProviderCompanyId,
    required super.name,
    required super.email,
    super.phone,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ServiceProviderProfileModel.fromEntity(
    ServiceProviderProfileEntity entity,
  ) => ServiceProviderProfileModel(
    id: entity.id,
    authUserId: entity.authUserId,
    serviceProviderCompanyId: entity.serviceProviderCompanyId,
    name: entity.name,
    email: entity.email,
    phone: entity.phone,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  factory ServiceProviderProfileModel.fromJson(MapDynamic json) =>
      ServiceProviderProfileModel(
        id: json['id'] as String? ?? '',
        authUserId: json['auth_user_id'] as String?,
        serviceProviderCompanyId:
            json['service_provider_company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: (json['created_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
        updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'auth_user_id': authUserId,
    'service_provider_company_id': serviceProviderCompanyId,
    'name': name,
    'email': email,
    'phone': phone,
    'is_active': isActive,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
  };

  @override
  ServiceProviderProfileEntity toEntity() => ServiceProviderProfileEntity(
    id: id,
    authUserId: authUserId,
    serviceProviderCompanyId: serviceProviderCompanyId,
    name: name,
    email: email,
    phone: phone,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
