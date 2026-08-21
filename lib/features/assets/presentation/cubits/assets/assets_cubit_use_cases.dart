import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/create_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/delete_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_asset_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/update_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';

@LazySingleton()
class AssetsCubitUseCases {
  const AssetsCubitUseCases({
    required this.getActiveCompanyId,
    required this.getAssets,
    required this.getAssetsByIds,
    required this.getAssetById,
    required this.createAsset,
    required this.updateAsset,
    required this.deleteAsset,
  });

  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetAssetsUseCase getAssets;
  final GetAssetsByIdsUseCase getAssetsByIds;
  final GetAssetByIdUseCase getAssetById;
  final CreateAssetUseCase createAsset;
  final UpdateAssetUseCase updateAsset;
  final DeleteAssetUseCase deleteAsset;
}
