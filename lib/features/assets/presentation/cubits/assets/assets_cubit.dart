import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

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

    final result = await _useCases.getAssets(user.companyId);
    if (isClosed) return;

    if (result is SuccessState<List<AssetEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          assets: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(status: StateStatus.error, errorMessage: result.message),
      );
    }
  }

  Future<bool> saveAsset({
    required String? id,
    required String companyId,
    required String areaId,
    String? categoryId,
    String? parentAssetId,
    required String name,
    String? code,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? installDate,
    DateTime? warrantyExpiration,
    DateTime? revisionForecast,
    required AssetStatus status,
    required AssetCriticality criticality,
    String? notes,
    DateTime? createdAt,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final isUpdate = id != null;
    final now = DateTime.now();

    final asset = AssetEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      areaId: areaId,
      categoryId: categoryId?.trim().isEmpty == true
          ? null
          : categoryId?.trim(),
      parentAssetId: parentAssetId?.trim().isEmpty == true
          ? null
          : parentAssetId?.trim(),
      name: name.trim(),
      code: code?.trim().isEmpty == true ? null : code?.trim(),
      manufacturer: manufacturer?.trim().isEmpty == true
          ? null
          : manufacturer?.trim(),
      model: model?.trim().isEmpty == true ? null : model?.trim(),
      serialNumber: serialNumber?.trim().isEmpty == true
          ? null
          : serialNumber?.trim(),
      installDate: installDate,
      warrantyExpiration: warrantyExpiration,
      revisionForecast: revisionForecast,
      status: status,
      criticality: criticality,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: createdAt ?? now,
      updatedAt: now,
    );

    final result = isUpdate
        ? await _useCases.updateAsset(asset)
        : await _useCases.createAsset(asset);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadAssets(emitLoading: false);
      return true;
    } else {
      if (isClosed) return false;
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(result);
      return false;
    }
  }

  Future<void> deleteAsset(String id) async {
    emit(
      state.copyWith(
        status: StateStatus.deleting,
        deletingIds: {...state.deletingIds, id},
      ),
    );
    final result = await _useCases.deleteAsset(id);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      await loadAssets(emitLoading: false);
      if (isClosed) return;

      emit(
        state.copyWith(
          status: StateStatus.loaded,
          deletingIds: {...state.deletingIds..remove(id)},
        ),
      );
    } else {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StateStatus.error,
          deletingIds: {...state.deletingIds..remove(id)},
        ),
      );
      showDataStateToast(result);
    }
  }
}
