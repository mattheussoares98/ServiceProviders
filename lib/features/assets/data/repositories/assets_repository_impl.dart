import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_local_data_source.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:clean_architecture/features/assets/data/models/requests/asset_request_model.dart';
import 'package:clean_architecture/features/assets/data/models/responses/asset_model.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AssetsRepository)
final class AssetsRepositoryImpl implements AssetsRepository {
  AssetsRepositoryImpl({
    required InternetClient internet,
    required AssetsRemoteDataSource remoteDataSource,
    required AssetsLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final AssetsRemoteDataSource _remoteDataSource;
  final AssetsLocalDataSource _localDataSource;

  @override
  FutureList<AssetEntity> getAssets(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<AssetModel, AssetEntity>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getAssets(companyId),
        localCallback: () => _localDataSource.getAssets(companyId),
        onRemoteSuccess: _localDataSource.saveAssets,
      );

  @override
  FutureData<AssetEntity> getAssetById(String id) =>
      RepositoryHandler.fetchWithFallbackAndMap<AssetModel, AssetEntity>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getAssetById(id),
        localCallback: () => _localDataSource.getAssetById(id),
        onRemoteSuccess: _localDataSource.saveAsset,
      );

  @override
  FutureBool createAsset(AssetEntity asset) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.createAsset(
            AssetRequestModel.fromEntity(asset),
          );
          if (result is SuccessState<AssetModel>) {
            await _localDataSource.saveAsset(result.data!);
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
            _localDataSource.saveAsset(AssetModel.fromEntity(asset)),
      );

  @override
  FutureBool updateAsset(AssetEntity asset) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.updateAsset(
            AssetRequestModel.fromEntity(asset),
          );
          if (result is SuccessState<AssetModel>) {
            await _localDataSource.saveAsset(result.data!);
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
            _localDataSource.saveAsset(AssetModel.fromEntity(asset)),
      );

  @override
  FutureBool deleteAsset(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteAsset(id);
          if (result is SuccessState<void>) {
            await _localDataSource.deleteAsset(id);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
        localCallback: () => _localDataSource.deleteAsset(id),
      );
}
