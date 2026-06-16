import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/create_asset_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/delete_asset_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/get_asset_by_id_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/update_asset_use_case.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/get_categories_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_areas_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_locations_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class AssetsCubitUseCases {
  const AssetsCubitUseCases({
    required this.getSessionUser,
    required this.getAssets,
    required this.getAssetById,
    required this.createAsset,
    required this.updateAsset,
    required this.deleteAsset,
    required this.getLocations,
    required this.getAreas,
    required this.getCategories,
  });

  final GetSessionUserUseCase getSessionUser;
  final GetAssetsUseCase getAssets;
  final GetAssetByIdUseCase getAssetById;
  final CreateAssetUseCase createAsset;
  final UpdateAssetUseCase updateAsset;
  final DeleteAssetUseCase deleteAsset;
  final GetLocationsUseCase getLocations;
  final GetAreasUseCase getAreas;
  final GetCategoriesUseCase getCategories;
}
