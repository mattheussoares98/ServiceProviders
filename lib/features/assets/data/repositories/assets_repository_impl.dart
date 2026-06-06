import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_local_data_source.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:clean_architecture/features/assets/data/models/responses/asset_response_model.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AssetsRepository)
final class AssetsRepositoryImpl implements AssetsRepository {
  AssetsRepositoryImpl({
    required InternetClient internet,
    required AssetsRemoteDataSource remoteDataSource,
    required AssetsLocalDataSource localDataSource,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final InternetClient _internet;
  final AssetsRemoteDataSource _remoteDataSource;
  final AssetsLocalDataSource _localDataSource;

  @override
  FutureList<AssetEntity> getAssets(String companyId) =>
      RepositoryHandler.fetchFromLocalAndMapList<AssetResponseModel,
          AssetEntity>(
        localCallback: () => _localDataSource.getAssets(companyId),
      );

  @override
  FutureData<AssetEntity> getAssetById(String id) =>
      RepositoryHandler.fetchFromLocalAndMap<AssetResponseModel, AssetEntity>(
        localCallback: () => _localDataSource.getAssetById(id),
      );

  @override
  FutureBool createAsset(AssetEntity asset) =>
      _localDataSource.saveAsset(AssetResponseModel.fromEntity(asset));

  @override
  FutureBool updateAsset(AssetEntity asset) =>
      _localDataSource.saveAsset(AssetResponseModel.fromEntity(asset));

  @override
  FutureBool deleteAsset(String id) => _localDataSource.deleteAsset(id);
}
