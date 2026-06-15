import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/data/handlers/supabase_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/data/models/requests/area_request_model.dart';
import 'package:clean_architecture/features/locations/data/models/requests/location_request_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/area_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/location_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class LocationsRemoteDataSource {
  FutureList<LocationModel> getLocations(String companyId);
  FutureData<LocationModel> createLocation(LocationRequestModel request);
  FutureData<LocationModel> updateLocation(LocationRequestModel request);
  FutureVoid deleteLocation(String id);

  FutureList<AreaModel> getAreas(String companyId);
  FutureData<AreaModel> createArea(AreaRequestModel request);
  FutureData<AreaModel> updateArea(AreaRequestModel request);
  FutureVoid deleteArea(String id);
}

@LazySingleton(as: LocationsRemoteDataSource)
final class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  const LocationsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<LocationModel> getLocations(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'locations',
          filters: [SupabaseFilter.eq('company_id', companyId)],
        );
        return response.map(LocationModel.fromJson).toList();
      });

  @override
  FutureData<LocationModel> createLocation(LocationRequestModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'locations',
          values: request.toJson(),
        );
        return LocationModel.fromJson(response.first);
      });

  @override
  FutureData<LocationModel> updateLocation(LocationRequestModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'locations',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return LocationModel.fromJson(response.first);
      });

  @override
  FutureVoid deleteLocation(String id) => SupabaseHandler.call(() async {
    await _database.delete(
      table: 'locations',
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  FutureList<AreaModel> getAreas(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'areas',
          filters: [SupabaseFilter.eq('company_id', companyId)],
        );
        return response.map(AreaModel.fromJson).toList();
      });

  @override
  FutureData<AreaModel> createArea(AreaRequestModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'areas',
          values: request.toJson(),
        );
        return AreaModel.fromJson(response.first);
      });

  @override
  FutureData<AreaModel> updateArea(AreaRequestModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'areas',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return AreaModel.fromJson(response.first);
      });

  @override
  FutureVoid deleteArea(String id) => SupabaseHandler.call(() async {
    await _database.delete(
      table: 'areas',
      filters: [SupabaseFilter.eq('id', id)],
    );
  });
}
