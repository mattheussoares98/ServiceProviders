import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_remote_data_source.dart';
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

  // TODO: Wire to local/remote data sources with RepositoryHandler
  @override
  FutureList<LocationEntity> getLocations(String companyId) =>
      throw UnimplementedError();

  @override
  FutureBool createLocation(LocationEntity location) =>
      throw UnimplementedError();

  @override
  FutureBool updateLocation(LocationEntity location) =>
      throw UnimplementedError();

  @override
  FutureBool deleteLocation(String id) => throw UnimplementedError();

  @override
  FutureList<AreaEntity> getAreasByLocation(String locationId) =>
      throw UnimplementedError();

  @override
  FutureBool createArea(AreaEntity area) => throw UnimplementedError();

  @override
  FutureBool updateArea(AreaEntity area) => throw UnimplementedError();

  @override
  FutureBool deleteArea(String id) => throw UnimplementedError();
}
