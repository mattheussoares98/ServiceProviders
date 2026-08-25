import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/requests/asset_request_model.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AssetsRemoteDataSource {
  FutureList<AssetModel> getAssets(String companyId);
  FutureList<AssetModel> getAssetsByIds(List<String> ids);
  FutureData<AssetModel> getAssetById(String id);
  FutureData<AssetModel> createAsset(AssetRequestModel request);
  FutureData<AssetModel> updateAsset(AssetRequestModel request);
  FutureVoid deleteAsset(String id);
  Stream<RealtimeEvent<AssetModel>> watchAssetsRealtime({String? companyId});
}

@LazySingleton(as: AssetsRemoteDataSource)
final class AssetsRemoteDataSourceImpl implements AssetsRemoteDataSource {
  const AssetsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  @override
  FutureList<AssetModel> getAssets(
    String companyId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'assets',
      columns:
          '*, areas!inner(location_id, deleted_at, locations!inner(deleted_at))',
      filters: [
        SupabaseFilter.eq('company_id', companyId),
        SupabaseFilter.isFilter('deleted_at', null),
        SupabaseFilter.isFilter('areas.deleted_at', null),
        SupabaseFilter.isFilter('areas.locations.deleted_at', null),
      ],
    );
    return response.map(AssetModel.fromJson).toList();
  });

  // Provider mode reads lookups by id instead of by company: the rows belong to
  // the contracting company, and RLS narrows them to the ones referenced by the
  // provider's own work orders. The areas!inner join is dropped on purpose —
  // the provider is not granted read access to an asset's area unless one of its
  // work orders points at that area too.
  @override
  FutureList<AssetModel> getAssetsByIds(List<String> ids) =>
      SupabaseHandler.call(() async {
        if (ids.isEmpty) return <AssetModel>[];
        final response = await _database.selectList(
          table: 'assets',
          filters: [
            SupabaseFilter.inList('id', ids),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(AssetModel.fromJson).toList();
      });

  @override
  FutureData<AssetModel> getAssetById(
    String id,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectOne(
      table: 'assets',
      columns:
          '*, areas!inner(location_id, deleted_at, locations!inner(deleted_at))',
      filters: [
        SupabaseFilter.eq('id', id),
        SupabaseFilter.isFilter('deleted_at', null),
        SupabaseFilter.isFilter('areas.deleted_at', null),
        SupabaseFilter.isFilter('areas.locations.deleted_at', null),
      ],
    );
    if (response == null) {
      throw Exception('Equipamento não encontrado'.hardcoded);
    }
    return AssetModel.fromJson(response);
  });

  @override
  FutureData<AssetModel> createAsset(AssetRequestModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'assets',
          values: request.toJson(),
        );
        return AssetModel.fromJson(response.first);
      });

  @override
  FutureData<AssetModel> updateAsset(AssetRequestModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'assets',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return AssetModel.fromJson(response.first);
      });

  @override
  FutureVoid deleteAsset(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'assets',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  Stream<RealtimeEvent<AssetModel>> watchAssetsRealtime({String? companyId}) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(
          table: 'assets',
          filter: filter,
        )
        .map((payload) => RealtimePayloadMapper.map(payload, AssetModel.fromJson));
  }
}
