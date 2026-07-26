import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';

class ServiceProviderInvitationEntity extends Equatable {
  const ServiceProviderInvitationEntity({
    required this.id,
    required this.email,
    required this.serviceProviderCompanyId,
    this.inviteToken,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.expiresAt,
  });

  final String id;
  final String email;
  final String serviceProviderCompanyId;
  final String? inviteToken;
  final ServiceProviderInvitationStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [
    id,
    email,
    serviceProviderCompanyId,
    inviteToken,
    status,
    createdAt,
    acceptedAt,
    expiresAt,
  ];

  ServiceProviderInvitationEntity copyWith({
    String? id,
    String? email,
    String? serviceProviderCompanyId,
    String? inviteToken,
    ServiceProviderInvitationStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? expiresAt,
    bool? annulInviteToken,
    bool? annulAcceptedAt,
    bool? annulExpiresAt,
  }) {
    return ServiceProviderInvitationEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      serviceProviderCompanyId:
          serviceProviderCompanyId ?? this.serviceProviderCompanyId,
      inviteToken: annulInviteToken == true
          ? null
          : inviteToken ?? this.inviteToken,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: annulAcceptedAt == true
          ? null
          : acceptedAt ?? this.acceptedAt,
      expiresAt: annulExpiresAt == true ? null : expiresAt ?? this.expiresAt,
    );
  }
}
