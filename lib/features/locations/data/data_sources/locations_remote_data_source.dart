import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/requests/area_request_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class LocationsRemoteDataSource {
  FutureList<LocationModel> getLocations(String companyId);
  FutureList<LocationModel> getLocationsByIds(List<String> ids);
  FutureData<LocationModel> createLocation(LocationModel request);
  FutureData<LocationModel> updateLocation(LocationModel request);
  FutureVoid deleteLocation(String id);
  Stream<RealtimeEvent<LocationModel>> watchLocationsRealtime({String? companyId});

  FutureList<AreaModel> getAreas(String companyId);
  FutureList<AreaModel> getAreasByIds(List<String> ids);
  FutureData<AreaModel> createArea(AreaRequestModel request);
  FutureData<AreaModel> updateArea(AreaRequestModel request);
  FutureVoid deleteArea(String id);
  Stream<RealtimeEvent<AreaModel>> watchAreasRealtime({String? companyId});
}

@LazySingleton(as: LocationsRemoteDataSource)
final class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  const LocationsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  @override
  FutureList<LocationModel> getLocations(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'locations',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(LocationModel.fromJson).toList();
      });

  // Provider mode reads lookups by id instead of by company: the rows belong to
  // the contracting company, and RLS narrows them to the ones referenced by the
  // provider's own work orders.
  @override
  FutureList<LocationModel> getLocationsByIds(List<String> ids) =>
      SupabaseHandler.call(() async {
        if (ids.isEmpty) return <LocationModel>[];
        final response = await _database.selectList(
          table: 'locations',
          filters: [
            SupabaseFilter.inList('id', ids),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(LocationModel.fromJson).toList();
      });

  @override
  FutureData<LocationModel> createLocation(LocationModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'locations',
          values: request.toJson(),
        );
        return LocationModel.fromJson(response.first);
      });

  @override
  FutureData<LocationModel> updateLocation(LocationModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'locations',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return LocationModel.fromJson(response.first);
      });

  @override
  FutureVoid deleteLocation(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'locations',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  FutureList<AreaModel> getAreas(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'areas',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(AreaModel.fromJson).toList();
      });

  @override
  FutureList<AreaModel> getAreasByIds(List<String> ids) =>
      SupabaseHandler.call(() async {
        if (ids.isEmpty) return <AreaModel>[];
        final response = await _database.selectList(
          table: 'areas',
          filters: [
            SupabaseFilter.inList('id', ids),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
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
  FutureVoid deleteArea(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'areas',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  Stream<RealtimeEvent<LocationModel>> watchLocationsRealtime({String? companyId}) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(
          table: 'locations',
          schema: 'public',
          event: PostgresChangeEvent.all,
          filter: filter,
        )
        .map((payload) => RealtimePayloadMapper.map(payload, LocationModel.fromJson));
  }

  @override
  Stream<RealtimeEvent<AreaModel>> watchAreasRealtime({String? companyId}) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(
          table: 'areas',
          schema: 'public',
          event: PostgresChangeEvent.all,
          filter: filter,
        )
        .map((payload) => RealtimePayloadMapper.map(payload, AreaModel.fromJson));
  }
}
