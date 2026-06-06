import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';

abstract interface class AssetsRepository {
  FutureList<AssetEntity> getAssets(String companyId);
  FutureData<AssetEntity> getAssetById(String id);
  FutureBool createAsset(AssetEntity asset);
  FutureBool updateAsset(AssetEntity asset);
  FutureBool deleteAsset(String id);
}