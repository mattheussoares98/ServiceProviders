import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'assets_state.dart';

@injectable
class AssetsCubit extends BaseCubit<AssetsState> {
  AssetsCubit({required AssetsCubitUseCases useCases})
      : _useCases = useCases,
        super(const AssetsState.initial());

  final AssetsCubitUseCases _useCases;

  Future<void> loadAssets() async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.error, assets: []));
      return;
    }

    emit(state.copyWith(status: StateStatus.loading));

    final result = await _useCases.getAssets(user.companyId);

    if (isClosed) return;

    if (result is SuccessState<List<AssetEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          assets: result.data ?? [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: result.message,
        ),
      );
    }
  }

  Future<void> createAsset(AssetEntity asset) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.createAsset(asset);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      showSuccessToast('Equipamento criado com sucesso'.hardcoded);
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
      showSuccessToast('Equipamento atualizado com sucesso'.hardcoded);
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
      showSuccessToast('Equipamento excluído com sucesso'.hardcoded);
      await loadAssets();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(result);
    }
  }
}