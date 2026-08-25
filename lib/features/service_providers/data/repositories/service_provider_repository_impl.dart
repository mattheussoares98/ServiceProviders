import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_local_data_source.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_invitation_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/repositories/service_provider_repository.dart';

@LazySingleton(as: ServiceProviderRepository)
final class ServiceProviderRepositoryImpl implements ServiceProviderRepository {
  const ServiceProviderRepositoryImpl({
    required InternetClient internet,
    required ServiceProviderRemoteDataSource remoteDataSource,
    required ServiceProviderLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final ServiceProviderRemoteDataSource _remoteDataSource;
  final ServiceProviderLocalDataSource _localDataSource;

  @override
  FutureList<ServiceProviderCompanyEntity> getServiceProviderCompanies(
    String companyId,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ServiceProviderCompanyModel,
        ServiceProviderCompanyEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () =>
            _remoteDataSource.getServiceProviderCompanies(companyId),
        localCallback: () =>
            _localDataSource.getServiceProviderCompanies(companyId),
        onRemoteSuccess: _localDataSource.saveServiceProviderCompanies,
      );

  @override
  FutureList<ServiceProviderCompanyEntity> getServiceProviderCompaniesByIds(
    List<String> ids,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ServiceProviderCompanyModel,
        ServiceProviderCompanyEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () =>
            _remoteDataSource.getServiceProviderCompaniesByIds(ids),
        // Online-only: these companies belong to other contracting companies, so
        // they must not be cached into the internal-mode Drift scope (V2 §1.4).
      );

  @override
  FutureData<ServiceProviderCompanyEntity> getServiceProviderCompanyById(
    String id,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMap<
        ServiceProviderCompanyModel,
        ServiceProviderCompanyEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () =>
            _remoteDataSource.getServiceProviderCompanyById(id),
        localCallback: () => _localDataSource.getServiceProviderCompanyById(id),
        onRemoteSuccess: _localDataSource.saveServiceProviderCompany,
      );

  @override
  FutureBool createServiceProviderCompany(
    ServiceProviderCompanyEntity company,
  ) {
    final model = ServiceProviderCompanyModel.fromEntity(company);
    return RepositoryHandler.fetchWithFallback<bool>(
      isInternetConnected: _internet.isConnected,
      localCallback: () => _localDataSource.saveServiceProviderCompany(model),
      remoteCallback: () async {
        final result = await _remoteDataSource.createServiceProviderCompany(
          model,
        );
        if (result is SuccessState<bool> && result.data == true) {
          await _localDataSource.saveServiceProviderCompany(model);
          return const SuccessState(data: true);
        }
        return result;
      },
    );
  }

  @override
  FutureBool updateServiceProviderCompany(
    ServiceProviderCompanyEntity company,
  ) {
    final model = ServiceProviderCompanyModel.fromEntity(company);
    return RepositoryHandler.fetchWithFallback<bool>(
      isInternetConnected: _internet.isConnected,
      localCallback: () => _localDataSource.saveServiceProviderCompany(model),
      remoteCallback: () async {
        final result = await _remoteDataSource.updateServiceProviderCompany(
          model,
        );
        if (result is SuccessState<bool> && result.data == true) {
          await _localDataSource.saveServiceProviderCompany(model);
          return const SuccessState(data: true);
        }
        return result;
      },
    );
  }

  @override
  Stream<RealtimeEvent<ServiceProviderCompanyEntity>>
  watchServiceProviderCompaniesRealtime({String? companyId}) async* {
    await for (final event in _remoteDataSource
        .watchServiceProviderCompaniesRealtime(companyId: companyId)) {
      if (event.entity != null &&
          (event.eventType == RealtimeEventType.insert ||
              event.eventType == RealtimeEventType.update)) {
        await _localDataSource.saveServiceProviderCompany(event.entity!);
      } else if (event.eventType == RealtimeEventType.delete &&
          event.id.isNotEmpty) {
        await _localDataSource.deleteServiceProviderCompany(event.id);
      }

      yield RealtimeEvent<ServiceProviderCompanyEntity>(
        eventType: event.eventType,
        id: event.id,
        companyId: event.companyId,
        entity: event.entity,
      );
    }
  }

  @override
  FutureList<ServiceProviderProfileEntity> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ServiceProviderProfileModel,
        ServiceProviderProfileEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getServiceProviderProfiles(
          serviceProviderCompanyId,
        ),
        localCallback: () => _localDataSource.getServiceProviderProfiles(
          serviceProviderCompanyId,
        ),
        onRemoteSuccess: _localDataSource.saveServiceProviderProfiles,
      );

  @override
  FutureList<ServiceProviderProfileEntity>
  getServiceProviderProfilesByCompanyIds(
    List<String> serviceProviderCompanyIds,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ServiceProviderProfileModel,
        ServiceProviderProfileEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource
            .getServiceProviderProfilesByCompanyIds(serviceProviderCompanyIds),
        // Online-only: these profiles belong to other contracting companies, so
        // they must not be cached into the internal-mode Drift scope (V2 §1.4).
      );

  @override
  FutureList<ServiceProviderProfileEntity> getServiceProviderProfilesByAuthUser(
    String authUserId,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ServiceProviderProfileModel,
        ServiceProviderProfileEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () =>
            _remoteDataSource.getServiceProviderProfilesByAuthUser(authUserId),
      );

  @override
  FutureBool createServiceProviderProfile(
    ServiceProviderProfileEntity profile,
  ) {
    final model = ServiceProviderProfileModel.fromEntity(profile);
    return RepositoryHandler.fetchWithFallback<bool>(
      isInternetConnected: _internet.isConnected,
      localCallback: () => _localDataSource.saveServiceProviderProfile(model),
      remoteCallback: () async {
        final result = await _remoteDataSource.createServiceProviderProfile(
          model,
        );
        if (result is SuccessState<bool> && result.data == true) {
          await _localDataSource.saveServiceProviderProfile(model);
          return const SuccessState(data: true);
        }
        return result;
      },
    );
  }

  @override
  FutureBool updateServiceProviderProfile(
    ServiceProviderProfileEntity profile,
  ) {
    final model = ServiceProviderProfileModel.fromEntity(profile);
    return RepositoryHandler.fetchWithFallback<bool>(
      isInternetConnected: _internet.isConnected,
      localCallback: () => _localDataSource.saveServiceProviderProfile(model),
      remoteCallback: () async {
        final result = await _remoteDataSource.updateServiceProviderProfile(
          model,
        );
        if (result is SuccessState<bool> && result.data == true) {
          await _localDataSource.saveServiceProviderProfile(model);
          return const SuccessState(data: true);
        }
        return result;
      },
    );
  }

  @override
  Stream<RealtimeEvent<ServiceProviderProfileEntity>>
  watchServiceProviderProfilesRealtime({
    String? serviceProviderCompanyId,
  }) async* {
    await for (final event in _remoteDataSource
        .watchServiceProviderProfilesRealtime(
          serviceProviderCompanyId: serviceProviderCompanyId,
        )) {
      if (event.entity != null &&
          (event.eventType == RealtimeEventType.insert ||
              event.eventType == RealtimeEventType.update)) {
        await _localDataSource.saveServiceProviderProfile(event.entity!);
      } else if (event.eventType == RealtimeEventType.delete &&
          event.id.isNotEmpty) {
        await _localDataSource.deleteServiceProviderProfile(event.id);
      }

      yield RealtimeEvent<ServiceProviderProfileEntity>(
        eventType: event.eventType,
        id: event.id,
        companyId: event.companyId,
        entity: event.entity,
      );
    }
  }

  @override
  FutureList<ServiceProviderInvitationEntity> getServiceProviderInvitations(
    String serviceProviderCompanyId,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ServiceProviderInvitationModel,
        ServiceProviderInvitationEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getServiceProviderInvitations(
          serviceProviderCompanyId,
        ),
        localCallback: () => _localDataSource.getServiceProviderInvitations(
          serviceProviderCompanyId,
        ),
        onRemoteSuccess: _localDataSource.saveServiceProviderInvitations,
      );

  @override
  FutureBool sendServiceProviderInvitation({
    required String serviceProviderCompanyId,
    required String email,
  }) => _remoteDataSource.sendServiceProviderInvitation(
    serviceProviderCompanyId: serviceProviderCompanyId,
    email: email,
  );

  @override
  FutureBool acceptServiceProviderInvitation(String email) =>
      _remoteDataSource.acceptServiceProviderInvitation(email);

  @override
  FutureBool deleteServiceProviderInvitation(String invitationId) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () =>
            _localDataSource.deleteServiceProviderInvitation(invitationId),
        remoteCallback: () async {
          final result = await _remoteDataSource
              .deleteServiceProviderInvitation(invitationId);
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.deleteServiceProviderInvitation(
              invitationId,
            );
            return const SuccessState(data: true);
          }
          return result;
        },
      );
}
