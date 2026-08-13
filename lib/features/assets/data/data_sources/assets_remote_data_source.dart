import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/requests/asset_request_model.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';

abstract interface class AssetsRemoteDataSource {
  FutureList<AssetModel> getAssets(String companyId);
  FutureData<AssetModel> getAssetById(String id);
  FutureData<AssetModel> createAsset(AssetRequestModel request);
  FutureData<AssetModel> updateAsset(AssetRequestModel request);
  FutureVoid deleteAsset(String id);
}

@LazySingleton(as: AssetsRemoteDataSource)
final class AssetsRemoteDataSourceImpl implements AssetsRemoteDataSource {
  const AssetsRemoteDataSourceImpl({required SupabaseDatabaseClient database})
    : _database = database;

  final SupabaseDatabaseClient _database;

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
}
