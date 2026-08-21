import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';

abstract interface class AssetsRepository {
  FutureList<AssetEntity> getAssets(String companyId);
  FutureList<AssetEntity> getAssetsByIds(List<String> ids);
  FutureData<AssetEntity> getAssetById(String id);
  FutureBool createAsset(AssetEntity asset);
  FutureBool updateAsset(AssetEntity asset);
  FutureBool deleteAsset(String id);
}
