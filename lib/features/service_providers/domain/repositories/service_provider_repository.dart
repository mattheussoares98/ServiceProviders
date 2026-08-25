import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
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
  FutureList<ServiceProviderCompanyEntity> getServiceProviderCompaniesByIds(
    List<String> ids,
  );
  FutureBool createServiceProviderCompany(
    ServiceProviderCompanyEntity company,
  );
  FutureBool updateServiceProviderCompany(
    ServiceProviderCompanyEntity company,
  );
  Stream<RealtimeEvent<ServiceProviderCompanyEntity>>
  watchServiceProviderCompaniesRealtime({String? companyId});

  FutureList<ServiceProviderProfileEntity> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  );
  FutureList<ServiceProviderProfileEntity>
  getServiceProviderProfilesByCompanyIds(
    List<String> serviceProviderCompanyIds,
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
  Stream<RealtimeEvent<ServiceProviderProfileEntity>>
  watchServiceProviderProfilesRealtime({String? serviceProviderCompanyId});

  FutureList<ServiceProviderInvitationEntity> getServiceProviderInvitations(
    String serviceProviderCompanyId,
  );
  FutureBool sendServiceProviderInvitation({
    required String serviceProviderCompanyId,
    required String email,
  });
  FutureBool acceptServiceProviderInvitation(String email);
  FutureBool deleteServiceProviderInvitation(String invitationId);
}
