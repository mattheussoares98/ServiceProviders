import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit_use_cases.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'assets_state.dart';

@injectable
class AssetsCubit extends BaseCubit<AssetsState> {
  AssetsCubit({required AssetsCubitUseCases useCases})
    : _useCases = useCases,
      super(const AssetsState.initial());

  final AssetsCubitUseCases _useCases;

  Future<void> loadAssets({bool emitLoading = true}) async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.error, assets: []));
      return;
    }
    if (emitLoading) {
    emit(state.copyWith(status: StateStatus.loading));
    }
    final results = await Future.wait([
      _useCases.getAssets(user.companyId),
      _useCases.getLocations(user.companyId),
      _useCases.getAreas(user.companyId),
      _useCases.getCategories(user.companyId),
    ]);

    if (isClosed) return;

    final assetsResult = results[0];
    final locationsResult = results[1];
    final areasResult = results[2];
    final categoriesResult = results[3];

    if (assetsResult is SuccessState<List<AssetEntity>> &&
        locationsResult is SuccessState<List<LocationEntity>> &&
        areasResult is SuccessState<List<AreaEntity>> &&
        categoriesResult is SuccessState<List<CategoryEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          assets: assetsResult.data ?? [],
          locations: locationsResult.data ?? [],
          areas: areasResult.data ?? [],
          categories: categoriesResult.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final errorMessage = assetsResult is FailureState
          ? assetsResult.message
          : locationsResult is FailureState
          ? locationsResult.message
          : areasResult is FailureState
          ? areasResult.message
          : categoriesResult is FailureState
          ? categoriesResult.message
          : '';
      emit(
        state.copyWith(status: StateStatus.error, errorMessage: errorMessage),
      );
    }
  }

  Future<void> createAsset(AssetEntity asset) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.createAsset(asset);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      await loadAssets();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(result);
    }
  }

  Future<void> updateAsset(AssetEntity asset) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.updateAsset(asset);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      await loadAssets();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(result);
    }
  }

  Future<void> deleteAsset(String id) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.deleteAsset(id);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      await loadAssets();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(result);
    }
  }
}
