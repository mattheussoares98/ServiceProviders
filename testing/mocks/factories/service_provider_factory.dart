import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';

import 'factory_helpers.dart';

abstract final class ServiceProviderFactory {
  static ServiceProviderCompanyEntity makeServiceProviderCompanyEntity() {
    return ServiceProviderCompanyEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      document: '12345678000199',
      documentType: DocumentType
          .values[FactoryHelpers.makeInt(DocumentType.values.length)],
      contactEmail: FactoryHelpers.makeEmail(),
      contactPhone: FactoryHelpers.makeInt(99999999, min: 10000000).toString(),
      isActive: true,
      invitationStatus: ServiceProviderInvitationStatus.accepted,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
    );
  }

  static List<ServiceProviderCompanyEntity>
  makeServiceProviderCompanyEntityList() =>
      List.generate(3, (_) => makeServiceProviderCompanyEntity());

  static List<ServiceProviderCompanyEntity>
  makeServiceProviderCompanyEntityList2() {
    return [
      makeServiceProviderCompanyEntity(),
      makeServiceProviderCompanyEntity(),
      makeServiceProviderCompanyEntity(),
    ];
  }

  // Service Provider Profile
  static ServiceProviderProfileEntity makeServiceProviderProfileEntity() {
    return ServiceProviderProfileEntity(
      id: FactoryHelpers.makeId(),
      authUserId: FactoryHelpers.makeId(),
      serviceProviderCompanyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makePersonName(),
      email: FactoryHelpers.makeEmail(),
      phone: FactoryHelpers.makeInt(99999999, min: 10000000).toString(),
      isActive: true,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<ServiceProviderProfileEntity>
  makeServiceProviderProfileEntityList() {
    return [
      makeServiceProviderProfileEntity(),
      makeServiceProviderProfileEntity(),
      makeServiceProviderProfileEntity(),
    ];
  }

  // SLA Policy
  static ServiceProviderInvitationEntity makeServiceProviderInvitationEntity() {
    return ServiceProviderInvitationEntity(
      id: FactoryHelpers.makeId(),
      email: FactoryHelpers.makeEmail(),
      serviceProviderCompanyId: FactoryHelpers.makeId(),
      inviteToken: FactoryHelpers.makeString(32),
      status: ServiceProviderInvitationStatus.pending,
      createdAt: FactoryHelpers.makeDateTime(),
      expiresAt: FactoryHelpers.makeDateTime(),
      acceptedAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<ServiceProviderInvitationEntity>
  makeServiceProviderInvitationEntityList() =>
      List.generate(3, (_) => makeServiceProviderInvitationEntity());

  static List<ServiceProviderInvitationEntity>
  makeServiceProviderInvitationEntityList2() {
    return [
      makeServiceProviderInvitationEntity(),
      makeServiceProviderInvitationEntity(),
      makeServiceProviderInvitationEntity(),
    ];
  }
}
