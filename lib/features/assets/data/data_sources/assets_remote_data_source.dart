import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/data/handlers/supabase_handler.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/data/models/requests/asset_request_model.dart';
import 'package:clean_architecture/features/assets/data/models/responses/asset_model.dart';
import 'package:injectable/injectable.dart';

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
  FutureList<AssetModel> getAssets(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'assets',
          filters: [SupabaseFilter.eq('company_id', companyId)],
        );
        return response.map(AssetModel.fromJson).toList();
      });

  @override
  FutureData<AssetModel> getAssetById(String id) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'assets',
          filters: [SupabaseFilter.eq('id', id)],
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
    await _database.delete(
      table: 'assets',
      filters: [SupabaseFilter.eq('id', id)],
    );
  });
}
