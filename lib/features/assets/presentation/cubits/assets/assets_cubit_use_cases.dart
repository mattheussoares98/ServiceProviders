import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/create_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/delete_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_asset_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/update_asset_use_case.dart';

@LazySingleton()
class AssetsCubitUseCases {
  const AssetsCubitUseCases({
    required this.getSessionUser,
    required this.getAssets,
    required this.getAssetById,
    required this.createAsset,
    required this.updateAsset,
    required this.deleteAsset,
  });

  final GetSessionUserUseCase getSessionUser;
  final GetAssetsUseCase getAssets;
  final GetAssetByIdUseCase getAssetById;
  final CreateAssetUseCase createAsset;
  final UpdateAssetUseCase updateAsset;
  final DeleteAssetUseCase deleteAsset;
}
