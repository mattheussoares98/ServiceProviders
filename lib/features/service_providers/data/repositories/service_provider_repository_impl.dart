import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_response_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_response_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/repositories/service_provider_repository.dart';

@LazySingleton(as: ServiceProviderRepository)
final class ServiceProviderRepositoryImpl implements ServiceProviderRepository {
  const ServiceProviderRepositoryImpl({
    required ServiceProviderRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ServiceProviderRemoteDataSource _remoteDataSource;

  // Provider mode is online-only in V2 — no local fallback.
  static const bool _online = true;

  @override
  FutureList<ServiceProviderCompanyEntity> getServiceProviderCompanies(
    String companyId,
  ) => RepositoryHandler.fetchWithFallbackAndMapList<
    ServiceProviderCompanyResponseModel,
    ServiceProviderCompanyEntity
  >(
    isInternetConnected: _online,
    remoteCallback: () =>
        _remoteDataSource.getServiceProviderCompanies(companyId),
  );

  @override
  FutureData<ServiceProviderCompanyEntity> getServiceProviderCompanyById(
    String id,
  ) => RepositoryHandler.fetchWithFallbackAndMap<
    ServiceProviderCompanyResponseModel,
    ServiceProviderCompanyEntity
  >(
    isInternetConnected: _online,
    remoteCallback: () =>
        _remoteDataSource.getServiceProviderCompanyById(id),
  );

  @override
  FutureBool createServiceProviderCompany(
    ServiceProviderCompanyEntity company,
  ) => _remoteDataSource.createServiceProviderCompany(
    ServiceProviderCompanyResponseModel.fromEntity(company),
  );

  @override
  FutureBool updateServiceProviderCompany(
    ServiceProviderCompanyEntity company,
  ) => _remoteDataSource.updateServiceProviderCompany(
    ServiceProviderCompanyResponseModel.fromEntity(company),
  );

  @override
  FutureList<ServiceProviderProfileEntity> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  ) => RepositoryHandler.fetchWithFallbackAndMapList<
    ServiceProviderProfileResponseModel,
    ServiceProviderProfileEntity
  >(
    isInternetConnected: _online,
    remoteCallback: () => _remoteDataSource.getServiceProviderProfiles(
      serviceProviderCompanyId,
    ),
  );

  @override
  FutureList<ServiceProviderProfileEntity> getServiceProviderProfilesByAuthUser(
    String authUserId,
  ) => RepositoryHandler.fetchWithFallbackAndMapList<
    ServiceProviderProfileResponseModel,
    ServiceProviderProfileEntity
  >(
    isInternetConnected: _online,
    remoteCallback: () =>
        _remoteDataSource.getServiceProviderProfilesByAuthUser(authUserId),
  );

  @override
  FutureBool createServiceProviderProfile(
    ServiceProviderProfileEntity profile,
  ) => _remoteDataSource.createServiceProviderProfile(
    ServiceProviderProfileResponseModel.fromEntity(profile),
  );

  @override
  FutureBool updateServiceProviderProfile(
    ServiceProviderProfileEntity profile,
  ) => _remoteDataSource.updateServiceProviderProfile(
    ServiceProviderProfileResponseModel.fromEntity(profile),
  );
}
