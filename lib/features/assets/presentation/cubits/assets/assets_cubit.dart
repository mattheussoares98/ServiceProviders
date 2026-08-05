import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'assets_state.dart';

@injectable
class AssetsCubit extends BaseCubit<AssetsState> {
  AssetsCubit({required AssetsCubitUseCases useCases})
    : _useCases = useCases,
      super(const AssetsState.initial());

  final AssetsCubitUseCases _useCases;

  Future<void> loadAssets({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.loadingError, assets: []));
      return;
    }

    if (emitLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final result = await _useCases.getAssets(companyId);
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
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: result.message,
        ),
      );
    }
  }

  Future<bool> saveAsset({
    required String? id,
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
    final companyId = _useCases.getActiveCompanyId();

    final asset = AssetEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      areaId: areaId,
      categoryId: categoryId?.trimToNull(),
      parentAssetId: parentAssetId?.trimToNull(),
      name: name.trim(),
      code: code?.trimToNull(),
      manufacturer: manufacturer?.trimToNull(),
      model: model?.trimToNull(),
      serialNumber: serialNumber?.trimToNull(),
      installDate: installDate,
      warrantyExpiration: warrantyExpiration,
      revisionForecast: revisionForecast,
      status: status,
      criticality: criticality,
      notes: notes?.trimToNull(),
      createdAt: createdAt ?? now,
      updatedAt: now,
      deletedAt: null,
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
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(result);
      return false;
    }
  }

  Future<bool> deleteAsset(String id) async {
    emit(state.copyWith(status: StateStatus.deleting));
    final result = await _useCases.deleteAsset(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadAssets(emitLoading: false);
      if (isClosed) return false;

      emit(state.copyWith(status: StateStatus.loaded));
      return true;
    } else {
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(result);
      return false;
    }
  }

  Future<void> navigateToCreateUpdateAsset([AssetEntity? asset]) async {
    await pushRoute(CreateUpdateAssetRoute(asset: asset));
  }
}
