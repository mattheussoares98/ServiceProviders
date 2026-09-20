import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/requests/area_request_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/address_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/address_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/repositories/locations_repository.dart';

@LazySingleton(as: LocationsRepository)
final class LocationsRepositoryImpl implements LocationsRepository {
  LocationsRepositoryImpl({
    required InternetClient internet,
    required LocationsRemoteDataSource remoteDataSource,
    required LocationsLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final LocationsRemoteDataSource _remoteDataSource;
  final LocationsLocalDataSource _localDataSource;

  @override
  FutureList<LocationEntity> getLocations(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        LocationModel,
        LocationEntity
      >(
        localCallback: () => _localDataSource.getLocations(companyId),
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getLocations(companyId),
        onRemoteSuccess: _localDataSource.saveLocations,
      );

  @override
  FutureList<LocationEntity> getLocationsByIds(List<String> ids) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        LocationModel,
        LocationEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getLocationsByIds(ids),
        // Deliberately no localCallback and no onRemoteSuccess: this path exists
        // for provider mode, which is online-only (V2 §1.4). The Drift database
        // is scoped to one contracting company, so caching cross-company rows
        // there would corrupt the internal-mode dataset.
      );

  @override
  FutureList<LocationEntity> getProviderLocations(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        LocationModel,
        LocationEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getLocations(companyId),
        // Deliberately no localCallback and no onRemoteSuccess: the rows belong
        // to a contracting company, and the Drift database is scoped to the
        // user's own. Caching them there would corrupt the internal-mode
        // dataset — the same reason getProviderWorkOrders never caches.
      );

  @override
  FutureBool createLocation(LocationEntity location) =>
      RepositoryHandler.executeMutation<LocationModel>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.createLocation(
          LocationModel.fromEntity(location),
        ),
        onRemoteSuccess: _localDataSource.saveLocation,
      );

  @override
  FutureBool updateLocation(LocationEntity location) =>
      RepositoryHandler.executeMutation<LocationModel>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.updateLocation(
          LocationModel.fromEntity(location),
        ),
        onRemoteSuccess: _localDataSource.saveLocation,
      );

  @override
  FutureBool deleteLocation(String id) =>
      RepositoryHandler.executeMutation<void>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.deleteLocation(id),
        onRemoteSuccess: (_) => _localDataSource.deleteLocation(id),
      );

  @override
  FutureList<AreaEntity> getAreas(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<AreaModel, AreaEntity>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getAreas(companyId),
        localCallback: () => _localDataSource.getAreas(companyId),
        onRemoteSuccess: _localDataSource.saveAreas,
      );

  @override
  FutureList<AreaEntity> getAreasByIds(
    List<String> ids,
  ) => RepositoryHandler.fetchWithFallbackAndMapList<AreaModel, AreaEntity>(
    isInternetConnected: _internet.isConnected,
    remoteCallback: () => _remoteDataSource.getAreasByIds(ids),
    // Deliberately no localCallback and no onRemoteSuccess: this path exists
    // for provider mode, which is online-only (V2 §1.4). The Drift database
    // is scoped to one contracting company, so caching cross-company rows
    // there would corrupt the internal-mode dataset.
  );

  @override
  FutureList<AreaEntity> getProviderAreas(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<AreaModel, AreaEntity>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getAreas(companyId),
        // Deliberately no localCallback and no onRemoteSuccess: the rows belong
        // to a contracting company, and the Drift database is scoped to the
        // user's own. Caching them there would corrupt the internal-mode
        // dataset — the same reason getProviderWorkOrders never caches.
      );

  @override
  FutureBool createArea(AreaEntity area) =>
      RepositoryHandler.executeMutation<AreaModel>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.createArea(
          AreaRequestModel.fromEntity(area),
        ),
        onRemoteSuccess: _localDataSource.saveArea,
      );

  @override
  FutureBool updateArea(AreaEntity area) =>
      RepositoryHandler.executeMutation<AreaModel>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.updateArea(
          AreaRequestModel.fromEntity(area),
        ),
        onRemoteSuccess: _localDataSource.saveArea,
      );

  @override
  FutureBool deleteArea(String id) => RepositoryHandler.executeMutation<void>(
    isInternetConnected: _internet.isConnected,
    remoteCallback: () => _remoteDataSource.deleteArea(id),
    onRemoteSuccess: (_) => _localDataSource.deleteArea(id),
  );


  @override
  Stream<RealtimeEvent<LocationEntity>> watchLocationsRealtime({
    String? companyId,
  }) {
    return RepositoryHandler.syncRealtimeStream(
      stream: _remoteDataSource.watchLocationsRealtime(companyId: companyId),
      saveLocal: _localDataSource.saveLocation,
      deleteLocal: _localDataSource.deleteLocation,
      isDeleted: (model) => model.deletedAt != null,
    );
  }

  @override
  Stream<RealtimeEvent<AreaEntity>> watchAreasRealtime({String? companyId}) {
    return RepositoryHandler.syncRealtimeStream(
      stream: _remoteDataSource.watchAreasRealtime(companyId: companyId),
      saveLocal: _localDataSource.saveArea,
      deleteLocal: _localDataSource.deleteArea,
      isDeleted: (model) => model.deletedAt != null,
    );
  }

  @override
  FutureData<AddressEntity> getAddressByCep(String cep) =>
      RepositoryHandler.fetchWithFallbackAndMap<AddressModel, AddressEntity>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getAddressByCep(cep),
      );
}

