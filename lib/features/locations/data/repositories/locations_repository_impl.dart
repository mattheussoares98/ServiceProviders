import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:clean_architecture/features/locations/data/models/responses/area_response_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/location_response_model.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/domain/repositories/locations_repository.dart';
import 'package:injectable/injectable.dart';

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
      RepositoryHandler.fetchFromLocalAndMapList<LocationModel, LocationEntity>(
        localCallback: () => _localDataSource.getLocations(companyId),
      );

  @override
  FutureBool createLocation(LocationEntity location) =>
      _localDataSource.saveLocation(LocationModel.fromEntity(location));

  @override
  FutureBool updateLocation(LocationEntity location) =>
      _localDataSource.saveLocation(LocationModel.fromEntity(location));

  @override
  FutureBool deleteLocation(String id) => _localDataSource.deleteLocation(id);

  @override
  FutureList<AreaEntity> getAreasByLocation(String locationId) =>
      RepositoryHandler.fetchFromLocalAndMapList<AreaResponseModel, AreaEntity>(
        localCallback: () => _localDataSource.getAreasByLocation(locationId),
      );

  @override
  FutureBool createArea(AreaEntity area) =>
      _localDataSource.saveArea(AreaResponseModel.fromEntity(area));

  @override
  FutureBool updateArea(AreaEntity area) =>
      _localDataSource.saveArea(AreaResponseModel.fromEntity(area));

  @override
  FutureBool deleteArea(String id) => _localDataSource.deleteArea(id);
}
