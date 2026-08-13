import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';

class ServiceProviderInvitationModel extends ServiceProviderInvitationEntity
    implements DataConvertible<ServiceProviderInvitationEntity> {
  const ServiceProviderInvitationModel({
    required super.id,
    required super.email,
    required super.serviceProviderCompanyId,
    super.inviteToken,
    required super.status,
    required super.createdAt,
    super.acceptedAt,
    super.expiresAt,
  });

  factory ServiceProviderInvitationModel.fromEntity(
    ServiceProviderInvitationEntity entity,
  ) => ServiceProviderInvitationModel(
    id: entity.id,
    email: entity.email,
    serviceProviderCompanyId: entity.serviceProviderCompanyId,
    inviteToken: entity.inviteToken,
    status: entity.status,
    createdAt: entity.createdAt,
    acceptedAt: entity.acceptedAt,
    expiresAt: entity.expiresAt,
  );

  factory ServiceProviderInvitationModel.fromJson(MapDynamic json) =>
      ServiceProviderInvitationModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        serviceProviderCompanyId:
            json['service_provider_company_id'] as String? ?? '',
        inviteToken: json['invite_token'] as String?,
        status: ServiceProviderInvitationStatus.fromString(
          json['status'] as String? ?? 'pending',
        ),
        createdAt: (json['created_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
        acceptedAt: (json['accepted_at'] as String?).toUtcDateTime(),
        expiresAt: (json['expires_at'] as String?).toUtcDateTime(),
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'email': email,
    'service_provider_company_id': serviceProviderCompanyId,
    'invite_token': inviteToken,
    'status': status.value,
    'created_at': createdAt.toIsoUtcString(),
    'accepted_at': acceptedAt?.toIsoUtcString(),
    'expires_at': expiresAt?.toIsoUtcString(),
  };

  @override
  ServiceProviderInvitationEntity toEntity() => ServiceProviderInvitationEntity(
    id: id,
    email: email,
    serviceProviderCompanyId: serviceProviderCompanyId,
    inviteToken: inviteToken,
    status: status,
    createdAt: createdAt,
    acceptedAt: acceptedAt,
    expiresAt: expiresAt,
  );
}
