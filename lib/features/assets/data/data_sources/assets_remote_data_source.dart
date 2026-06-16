import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:clean_architecture/core/constants/api_endpoints.dart';
import 'package:clean_architecture/core/data/handlers/api_handler.dart';
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
  const AssetsRemoteDataSourceImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  final HttpClient _httpClient;

  @override
  FutureList<AssetModel> getAssets(String companyId) => ApiHandler.call(
    () => _httpClient.get(
      ApiEndpoints.assets,
      queryParameters: {'company_id': companyId},
    ),
    fromJson: AssetModel.fromJson,
  );

  @override
  FutureData<AssetModel> getAssetById(String id) => ApiHandler.call(
    () => _httpClient.get(ApiEndpoints.assetById(id)),
    fromJson: AssetModel.fromJson,
  );

  @override
  FutureData<AssetModel> createAsset(AssetRequestModel request) =>
      ApiHandler.call(
        () => _httpClient.post(ApiEndpoints.assets, data: request.toJson()),
        fromJson: AssetModel.fromJson,
      );

  @override
  FutureData<AssetModel> updateAsset(AssetRequestModel request) =>
      ApiHandler.call(
        () => _httpClient.put(
          ApiEndpoints.assetById(request.id),
          data: request.toJson(),
        ),
        fromJson: AssetModel.fromJson,
      );

  @override
  FutureVoid deleteAsset(String id) =>
      ApiHandler.voidCall(() => _httpClient.delete(ApiEndpoints.assetById(id)));
}
