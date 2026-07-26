import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';

abstract interface class ServiceProviderRepository {
  FutureList<ServiceProviderCompanyEntity> getServiceProviderCompanies(
    String companyId,
  );
  FutureData<ServiceProviderCompanyEntity> getServiceProviderCompanyById(
    String id,
  );
  FutureBool createServiceProviderCompany(
    ServiceProviderCompanyEntity company,
  );
  FutureBool updateServiceProviderCompany(
    ServiceProviderCompanyEntity company,
  );

  FutureList<ServiceProviderProfileEntity> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  );
  FutureList<ServiceProviderProfileEntity> getServiceProviderProfilesByAuthUser(
    String authUserId,
  );
  FutureBool createServiceProviderProfile(
    ServiceProviderProfileEntity profile,
  );
  FutureBool updateServiceProviderProfile(
    ServiceProviderProfileEntity profile,
  );

  FutureList<ServiceProviderInvitationEntity> getServiceProviderInvitations(
    String serviceProviderCompanyId,
  );
}
