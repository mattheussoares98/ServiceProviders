import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/requests/area_request_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';
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
  FutureBool createLocation(LocationEntity location) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () =>
            _localDataSource.saveLocation(LocationModel.fromEntity(location)),
        remoteCallback: () async {
          final result = await _remoteDataSource.createLocation(
            LocationModel.fromEntity(location),
          );
          if (result is SuccessState<LocationModel>) {
            await _localDataSource.saveLocation(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool updateLocation(LocationEntity location) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.updateLocation(
            LocationModel.fromEntity(location),
          );
          if (result is SuccessState<LocationModel>) {
            await _localDataSource.saveLocation(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
        localCallback: () =>
            _localDataSource.saveLocation(LocationModel.fromEntity(location)),
      );

  @override
  FutureBool deleteLocation(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteLocation(id);
          if (result is SuccessState<void>) {
            await _localDataSource.deleteLocation(id);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
        localCallback: () => _localDataSource.deleteLocation(id),
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
  FutureBool createArea(AreaEntity area) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.createArea(
            AreaRequestModel.fromEntity(area),
          );
          if (result is SuccessState<AreaModel>) {
            await _localDataSource.saveArea(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
        localCallback: () =>
            _localDataSource.saveArea(AreaModel.fromEntity(area)),
      );

  @override
  FutureBool updateArea(AreaEntity area) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.updateArea(
            AreaRequestModel.fromEntity(area),
          );
          if (result is SuccessState<AreaModel>) {
            await _localDataSource.saveArea(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
        localCallback: () =>
            _localDataSource.saveArea(AreaModel.fromEntity(area)),
      );

  @override
  FutureBool deleteArea(String id) => RepositoryHandler.fetchWithFallback<bool>(
    isInternetConnected: _internet.isConnected,
    remoteCallback: () async {
      final result = await _remoteDataSource.deleteArea(id);
      if (result is SuccessState<void>) {
        await _localDataSource.deleteArea(id);
        return const SuccessState(data: true);
      }
      return FailureState(
        message: result.message,
        error: result.error,
        statusCode: result.statusCode,
        response: result.response,
      );
    },
    localCallback: () => _localDataSource.deleteArea(id),
  );
}
